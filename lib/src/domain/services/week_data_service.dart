// lib/src/domain/services/week_data_service.dart (ENHANCED)
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/domain/entities/calculated_plan.dart';
import 'package:foodam/src/domain/entities/dish_entity.dart';
import 'package:foodam/src/domain/usecase/calendar_usecase.dart';

class WeekDataService {
  final CalendarUseCase _calendarUseCase;
  final LoggerService _logger = LoggerService();

  // Cache with metadata for better management
  final Map<String, _CachedWeekData> _cache = {};

  WeekDataService({required CalendarUseCase calendarUseCase})
    : _calendarUseCase = calendarUseCase;

  /// Get week data with intelligent caching
  Future<Either<Failure, WeekCache>> getWeekData({
    required int week,
    required DateTime startDate,
    required String dietaryPreference,
  }) async {
    final cacheKey = _generateCacheKey(week, startDate, dietaryPreference);

    // Check cache first
    if (_cache.containsKey(cacheKey)) {
      final cachedData = _cache[cacheKey]!;

      // Check if cache is still valid (1 hour expiry)
      if (DateTime.now().difference(cachedData.timestamp).inHours < 1) {
        _logger.d('Returning cached week data for week $week');
        return Right(cachedData.weekCache);
      } else {
        _logger.d('Cache expired for week $week, removing');
        _cache.remove(cacheKey);
      }
    }

    try {
      _logger.i('Fetching week $week data from API');

      // Calculate actual start date for this week
      final weekStartDate = startDate.add(Duration(days: (week - 1) * 7));

      final result = await _calendarUseCase.getCalculatedPlan(
        dietaryPreference: dietaryPreference,
        week: week,
        startDate: weekStartDate,
      );

      return result.fold(
        (failure) {
          _logger.e('Failed to fetch week $week data: ${failure.message}');
          return Left(failure);
        },
        (calculatedPlan) {
          _logger.d('Successfully fetched week $week data');

          // Create week cache
          final weekCache = WeekCache.loaded(
            week: week,
            calculatedPlan: calculatedPlan,
            packageId: calculatedPlan.package?.id,
            timestamp: DateTime.now(),
          );

          // Cache the result
          _cache[cacheKey] = _CachedWeekData(
            weekCache: weekCache,
            timestamp: DateTime.now(),
          );

          return Right(weekCache);
        },
      );
    } catch (e) {
      _logger.e('Unexpected error fetching week $week data', error: e);
      return Left(UnexpectedFailure('Failed to load week data: $e'));
    }
  }

  /// Extract meal options from calculated plan
  List<MealOption> extractMealOptions(CalculatedPlan calculatedPlan) {
    final List<MealOption> mealOptions = [];

    try {
      for (final dailyMeal in calculatedPlan.dailyMeals) {
        final dayName = _getDayName(dailyMeal.date);
        final isToday = _isToday(dailyMeal.date);

        // Extract meals from the day meal
        if (dailyMeal.slot.meal != null) {
          final dayMealData = dailyMeal.slot.meal!;

          // Process each dish type (breakfast, lunch, dinner)
          for (final entry in dayMealData.dishes.entries) {
            final mealType = entry.key; // breakfast, lunch, dinner
            final dish = entry.value;

            if (dish.isAvailable) {
              final mealOption = MealOption(
                id: '${dayMealData.id}_${mealType}_${dish.id}',
                dayName: dayName,
                mealType: mealType,
                dish: dish,
                date: dailyMeal.date,
                isToday: isToday,
                mealTypeDisplay: _formatMealType(mealType),
              );

              mealOptions.add(mealOption);
            }
          }
        }
      }

      _logger.d('Extracted ${mealOptions.length} meal options');
      return mealOptions;
    } catch (e) {
      _logger.e('Error extracting meal options', error: e);
      return [];
    }
  }

  /// Clear all cached data
  void clearCache() {
    _cache.clear();
    _logger.i('Cleared week data cache');
  }

  /// Clear expired cache entries
  void cleanupExpiredCache() {
    final now = DateTime.now();
    final expiredKeys =
        _cache.entries
            .where((entry) => now.difference(entry.value.timestamp).inHours > 1)
            .map((entry) => entry.key)
            .toList();

    for (final key in expiredKeys) {
      _cache.remove(key);
    }

    if (expiredKeys.isNotEmpty) {
      _logger.d('Cleaned up ${expiredKeys.length} expired cache entries');
    }
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    final now = DateTime.now();
    final validEntries =
        _cache.values
            .where((data) => now.difference(data.timestamp).inHours < 1)
            .length;

    return {
      'totalEntries': _cache.length,
      'validEntries': validEntries,
      'expiredEntries': _cache.length - validEntries,
    };
  }

  // Private helper methods
  String _generateCacheKey(
    int week,
    DateTime startDate,
    String dietaryPreference,
  ) {
    return '${week}_${startDate.toIso8601String().split('T')[0]}_$dietaryPreference';
  }

  String _getDayName(DateTime date) {
    const dayNames = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];
    return dayNames[date.weekday - 1];
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String _formatMealType(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return 'Breakfast';
      case 'lunch':
        return 'Lunch';
      case 'dinner':
        return 'Dinner';
      default:
        return mealType.substring(0, 1).toUpperCase() +
            mealType.substring(1).toLowerCase();
    }
  }
}

/// Cached week data with metadata
class _CachedWeekData {
  final WeekCache weekCache;
  final DateTime timestamp;

  _CachedWeekData({required this.weekCache, required this.timestamp});
}

/// Enhanced WeekCache class
class WeekCache extends Equatable {
  final int week;
  final CalculatedPlan? calculatedPlan;
  final String? packageId;
  final DateTime timestamp;
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;

  const WeekCache._({
    required this.week,
    this.calculatedPlan,
    this.packageId,
    required this.timestamp,
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage,
  });

  /// Create loading state
  factory WeekCache.loading({required int week}) {
    return WeekCache._(week: week, timestamp: DateTime.now(), isLoading: true);
  }

  /// Create loaded state
  factory WeekCache.loaded({
    required int week,
    required CalculatedPlan calculatedPlan,
    String? packageId,
    DateTime? timestamp,
  }) {
    return WeekCache._(
      week: week,
      calculatedPlan: calculatedPlan,
      packageId: packageId,
      timestamp: timestamp ?? DateTime.now(),
    );
  }

  /// Create error state
  factory WeekCache.error({required int week, required String errorMessage}) {
    return WeekCache._(
      week: week,
      timestamp: DateTime.now(),
      hasError: true,
      errorMessage: errorMessage,
    );
  }

  bool get isLoaded => calculatedPlan != null && !isLoading && !hasError;

  @override
  List<Object?> get props => [
    week,
    calculatedPlan,
    packageId,
    timestamp,
    isLoading,
    hasError,
    errorMessage,
  ];
}

/// Enhanced MealOption class
class MealOption extends Equatable {
  final String id;
  final String dayName;
  final String mealType;
  final Dish dish;
  final DateTime date;
  final bool isToday;
  final String mealTypeDisplay;

  const MealOption({
    required this.id,
    required this.dayName,
    required this.mealType,
    required this.dish,
    required this.date,
    required this.isToday,
    required this.mealTypeDisplay,
  });

  @override
  List<Object?> get props => [
    id,
    dayName,
    mealType,
    dish,
    date,
    isToday,
    mealTypeDisplay,
  ];

  /// Get formatted date string
  String get formattedDate {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  /// Check if this meal option is for the weekend
  bool get isWeekend {
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }

  /// Get display text for day and meal type
  String get displayText => '$dayName $mealTypeDisplay';
}

/// Enhanced MealSelection class
class MealSelection extends Equatable {
  final String id;
  final int week;
  final String dayName;
  final String mealType;
  final String dishId;
  final String dishName;
  final DateTime date;
  final bool isToday;
  final String mealTypeDisplay;

  const MealSelection({
    required this.id,
    required this.week,
    required this.dayName,
    required this.mealType,
    required this.dishId,
    required this.dishName,
    required this.date,
    required this.isToday,
    required this.mealTypeDisplay,
  });

  /// Create from MealOption
  factory MealSelection.fromMealOption({
    required int week,
    required MealOption mealOption,
  }) {
    return MealSelection(
      id: '${week}_${mealOption.id}',
      week: week,
      dayName: mealOption.dayName,
      mealType: mealOption.mealType,
      dishId: mealOption.dish.id,
      dishName: mealOption.dish.name,
      date: mealOption.date,
      isToday: mealOption.isToday,
      mealTypeDisplay: mealOption.mealTypeDisplay,
    );
  }

  @override
  List<Object?> get props => [
    id,
    week,
    dayName,
    mealType,
    dishId,
    dishName,
    date,
    isToday,
    mealTypeDisplay,
  ];

  /// Get formatted date string
  String get formattedDate {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  /// Convert to API request format
  Map<String, dynamic> toApiRequest() {
    return {
      'day': dayName.toLowerCase(),
      'date': date.toIso8601String(),
      'timing': mealType.toLowerCase(),
      'meal': dishId,
    };
  }

  /// Get display text
  String get displayText => '$dayName $mealTypeDisplay: $dishName';

  /// Check if this selection is for the weekend
  bool get isWeekend {
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }
}
