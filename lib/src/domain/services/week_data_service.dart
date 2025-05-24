// lib/src/domain/service/week_data_service.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/domain/entities/calculated_plan.dart';
import 'package:foodam/src/domain/entities/dish_entity.dart';
import 'package:foodam/src/domain/usecase/calendar_usecase.dart';

class WeekDataService {
  final CalendarUseCase _calendarUseCase;
  final LoggerService _logger = LoggerService();

  // Cache for week data
  final Map<String, WeekCache> _cache = {};

  WeekDataService({required CalendarUseCase calendarUseCase})
    : _calendarUseCase = calendarUseCase;

  /// Get week data with caching
  Future<Either<Failure, WeekCache>> getWeekData({
    required int week,
    required DateTime startDate,
    required String dietaryPreference,
  }) async {
    final cacheKey = _buildCacheKey(week, startDate, dietaryPreference);

    // Return cached data if available and not loading
    if (_cache.containsKey(cacheKey)) {
      final cached = _cache[cacheKey]!;
      if (cached.isLoaded || cached.hasError) {
        _logger.d('Returning cached data for week $week');
        return Right(cached);
      }
      if (cached.isLoading) {
        _logger.d('Week $week is already loading');
        return Right(cached);
      }
    }

    // Set loading state
    _cache[cacheKey] = WeekCache.loading(week: week);
    _logger.i('Loading week $week data from API');

    try {
      // Calculate start date for this specific week
      final weekStartDate = startDate.add(Duration(days: (week - 1) * 7));

      final result = await _calendarUseCase.getCalculatedPlan(
        dietaryPreference: dietaryPreference,
        week: week,
        startDate: weekStartDate,
      );

      return result.fold(
        (failure) {
          _logger.e('Failed to load week $week: ${failure.message}');
          final errorCache = WeekCache.error(
            week: week,
            errorMessage: failure.message ?? 'Failed to load week data',
          );
          _cache[cacheKey] = errorCache;
          return Right(errorCache);
        },
        (calculatedPlan) {
          _logger.i('Successfully loaded week $week data');
          final successCache = WeekCache.success(
            week: week,
            calculatedPlan: calculatedPlan,
          );
          _cache[cacheKey] = successCache;
          return Right(successCache);
        },
      );
    } catch (e) {
      _logger.e('Unexpected error loading week $week', error: e);
      final errorCache = WeekCache.error(
        week: week,
        errorMessage: 'An unexpected error occurred',
      );
      _cache[cacheKey] = errorCache;
      return Right(errorCache);
    }
  }

  /// Extract meal options from calculated plan for UI
  List<MealOption> extractMealOptions(CalculatedPlan calculatedPlan) {
    final List<MealOption> options = [];

    for (final dailyMeal in calculatedPlan.dailyMeals) {
      final dayMeal = dailyMeal.slot.meal;
      if (dayMeal == null) continue;

      final date = DateTime(
        dailyMeal.date.year,
        dailyMeal.date.month,
        dailyMeal.date.day,
      );

      // Extract breakfast option
      final breakfastDish = dayMeal.dishes['breakfast'];
      if (breakfastDish != null) {
        options.add(
          MealOption(
            id:
                '${dailyMeal.date.millisecondsSinceEpoch}_breakfast_${breakfastDish.id}',
            date: date,
            dayName: _getDayName(date.weekday),
            mealType: 'breakfast',
            dish: breakfastDish,
            parentMealId: dayMeal.id,
          ),
        );
      }

      // Extract lunch option
      final lunchDish = dayMeal.dishes['lunch'];
      if (lunchDish != null) {
        options.add(
          MealOption(
            id: '${dailyMeal.date.millisecondsSinceEpoch}_lunch_${lunchDish.id}',
            date: date,
            dayName: _getDayName(date.weekday),
            mealType: 'lunch',
            dish: lunchDish,
            parentMealId: dayMeal.id,
          ),
        );
      }

      // Extract dinner option
      final dinnerDish = dayMeal.dishes['dinner'];
      if (dinnerDish != null) {
        options.add(
          MealOption(
            id:
                '${dailyMeal.date.millisecondsSinceEpoch}_dinner_${dinnerDish.id}',
            date: date,
            dayName: _getDayName(date.weekday),
            mealType: 'dinner',
            dish: dinnerDish,
            parentMealId: dayMeal.id,
          ),
        );
      }
    }

    return options;
  }

  /// Clear all cached data
  void clearCache() {
    _logger.i('Clearing week data cache');
    _cache.clear();
  }

  /// Clear cache for specific parameters (when form data changes)
  void clearCacheForParams({
    required DateTime startDate,
    required String dietaryPreference,
  }) {
    final keysToRemove =
        _cache.keys
            .where(
              (key) => key.contains(
                '_${startDate.millisecondsSinceEpoch}_$dietaryPreference',
              ),
            )
            .toList();

    for (final key in keysToRemove) {
      _cache.remove(key);
    }

    _logger.i('Cleared cache for ${keysToRemove.length} weeks');
  }

  /// Check if week is cached and loaded
  bool isWeekCached({
    required int week,
    required DateTime startDate,
    required String dietaryPreference,
  }) {
    final cacheKey = _buildCacheKey(week, startDate, dietaryPreference);
    return _cache.containsKey(cacheKey) && _cache[cacheKey]!.isLoaded;
  }

  /// Get package ID for a specific week
  String? getPackageIdForWeek({
    required int week,
    required DateTime startDate,
    required String dietaryPreference,
  }) {
    final cacheKey = _buildCacheKey(week, startDate, dietaryPreference);
    final cache = _cache[cacheKey];
    return cache?.calculatedPlan?.package?.id;
  }

  String _buildCacheKey(
    int week,
    DateTime startDate,
    String dietaryPreference,
  ) {
    return 'week_${week}_${startDate.millisecondsSinceEpoch}_$dietaryPreference';
  }

  String _getDayName(int weekday) {
    const days = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];
    return days[weekday - 1];
  }
}

/// Cache container for week data
class WeekCache {
  final int week;
  final CalculatedPlan? calculatedPlan;
  final bool isLoading;
  final bool isLoaded;
  final bool hasError;
  final String? errorMessage;
  final DateTime loadedAt;

  const WeekCache({
    required this.week,
    this.calculatedPlan,
    this.isLoading = false,
    this.isLoaded = false,
    this.hasError = false,
    this.errorMessage,
    required this.loadedAt,
  });

  factory WeekCache.loading({required int week}) {
    return WeekCache(week: week, isLoading: true, loadedAt: DateTime.now());
  }

  factory WeekCache.success({
    required int week,
    required CalculatedPlan calculatedPlan,
  }) {
    return WeekCache(
      week: week,
      calculatedPlan: calculatedPlan,
      isLoaded: true,
      loadedAt: DateTime.now(),
    );
  }

  factory WeekCache.error({required int week, required String errorMessage}) {
    return WeekCache(
      week: week,
      hasError: true,
      errorMessage: errorMessage,
      loadedAt: DateTime.now(),
    );
  }

  /// Get package ID from calculated plan
  String? get packageId => calculatedPlan?.package?.id;

  /// Check if cache is stale (older than 10 minutes)
  bool get isStale {
    final now = DateTime.now();
    return now.difference(loadedAt).inMinutes > 10;
  }
}

/// Meal option extracted from calculated plan for UI
class MealOption {
  final String id;
  final DateTime date;
  final String dayName;
  final String mealType;
  final Dish dish;
  final String parentMealId;

  const MealOption({
    required this.id,
    required this.date,
    required this.dayName,
    required this.mealType,
    required this.dish,
    required this.parentMealId,
  });

  /// Get display name for meal type
  String get mealTypeDisplay {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return 'Breakfast';
      case 'lunch':
        return 'Lunch';
      case 'dinner':
        return 'Dinner';
      default:
        return mealType;
    }
  }

  /// Check if this is today's meal
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
