// lib/src/domain/services/week_selection_data_extractor.dart
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/presentation/cubits/checkout/checkout_state.dart'
    as Checkout;
// Use import aliases to handle conflicts cleanly
import 'package:foodam/src/presentation/cubits/subscription/week_selection/week_selection_state.dart'
    as WeekSelection;

class WeekSelectionDataExtractor {
  static final LoggerService _logger = LoggerService();

  /// Extract complete data from WeekSelectionActive state
  static Checkout.WeekSelectionData extract(
    WeekSelection.WeekSelectionActive state,
  ) {
    _logger.i('🔄 Extracting week selection data for checkout');

    try {
      // Group selections by week
      final groupedSelections = _groupSelectionsByWeek(state.selections);

      // Extract week package IDs
      final weekPackageIds = _extractWeekPackageIds(state, groupedSelections);

      // Convert week configs to checkout format
      final checkoutWeekConfigs = _convertWeekConfigs(state.weekConfigs);

      final extractedData = Checkout.WeekSelectionData(
        startDate: state.planningData.startDate,
        defaultDietaryPreference: state.planningData.dietaryPreference,
        weekConfigs: checkoutWeekConfigs,
        groupedSelections: groupedSelections,
        weekPackageIds: weekPackageIds,
        totalDuration: state.weekConfigs.keys.length,
        totalMeals: state.selections.length,
      );

      _logger.i(
        '✅ Successfully extracted data for ${extractedData.totalDuration} weeks, ${extractedData.totalMeals} meals',
      );
      return extractedData;
    } catch (e) {
      _logger.e('❌ Error extracting week selection data', error: e);
      rethrow;
    }
  }

  /// Group flat selections map by week
  static Map<int, List<WeekSelection.DishSelection>> _groupSelectionsByWeek(
    Map<String, WeekSelection.DishSelection> flatSelections,
  ) {
    final grouped = <int, List<WeekSelection.DishSelection>>{};

    for (final selection in flatSelections.values) {
      grouped.putIfAbsent(selection.week, () => []).add(selection);
    }

    // Sort selections within each week by day and timing
    for (final weekSelections in grouped.values) {
      weekSelections.sort((a, b) {
        // Sort by day first, then by timing
        final dayComparison = _getDayOrder(
          a.day,
        ).compareTo(_getDayOrder(b.day));
        if (dayComparison != 0) return dayComparison;

        return _getMealTimingOrder(
          a.timing,
        ).compareTo(_getMealTimingOrder(b.timing));
      });
    }

    _logger.d(
      '📊 Grouped selections: ${grouped.map((k, v) => MapEntry(k, v.length))}',
    );
    return grouped;
  }

  /// Extract package IDs for each week from selections
  static Map<int, String> _extractWeekPackageIds(
    WeekSelection.WeekSelectionActive state,
    Map<int, List<WeekSelection.DishSelection>> groupedSelections,
  ) {
    final weekPackageIds = <int, String>{};

    for (final entry in groupedSelections.entries) {
      final week = entry.key;
      final selections = entry.value;

      if (selections.isNotEmpty) {
        // Use package ID from first selection
        weekPackageIds[week] = selections.first.packageId;
      } else {
        // Fallback: try to get from week data cache
        final weekData = state.weekDataCache[week];
        if (weekData?.packageId != null) {
          weekPackageIds[week] = weekData!.packageId!;
        } else {
          _logger.w('⚠️ No package ID found for week $week');
        }
      }
    }

    _logger.d('📦 Week package IDs: $weekPackageIds');
    return weekPackageIds;
  }

  /// Convert WeekSelectionCubit week configs to checkout format
  static Map<int, Checkout.CheckoutWeekConfig> _convertWeekConfigs(
    Map<int, WeekSelection.WeekConfig> originalConfigs,
  ) {
    final converted = <int, Checkout.CheckoutWeekConfig>{};

    for (final entry in originalConfigs.entries) {
      final week = entry.key;
      final original = entry.value;

      converted[week] = Checkout.CheckoutWeekConfig(
        week: original.week,
        dietaryPreference: original.dietaryPreference,
        mealPlan: original.mealPlan,
        isComplete: original.isComplete,
      );
    }

    return converted;
  }

  /// Get day order for sorting (Monday = 0, Sunday = 6)
  static int _getDayOrder(String day) {
    const dayOrder = {
      'monday': 0,
      'tuesday': 1,
      'wednesday': 2,
      'thursday': 3,
      'friday': 4,
      'saturday': 5,
      'sunday': 6,
    };
    return dayOrder[day.toLowerCase()] ?? 7;
  }

  /// Get meal timing order for sorting (breakfast = 0, lunch = 1, dinner = 2)
  static int _getMealTimingOrder(String timing) {
    const timingOrder = {'breakfast': 0, 'lunch': 1, 'dinner': 2};
    return timingOrder[timing.toLowerCase()] ?? 3;
  }
}

/// Service to calculate pricing from week selection data
class SubscriptionPricingCalculator {
  static final LoggerService _logger = LoggerService();

  /// Calculate complete pricing for checkout
  static Checkout.SubscriptionPricing calculate(
    Checkout.WeekSelectionData weekData,
    WeekSelection.WeekSelectionActive weekSelectionState,
  ) {
    _logger.i('💰 Calculating subscription pricing');

    try {
      final weekPricing = <int, double>{};
      final weekDetails = <int, Checkout.WeekPricingDetails>{};
      double totalPrice = 0.0;

      for (final entry in weekData.weekConfigs.entries) {
        final week = entry.key;
        final config = entry.value;

        // Get week data from original state
        final weekSelectionData = weekSelectionState.weekDataCache[week];
        if (weekSelectionData?.priceOptions != null) {
          final selections = weekData.groupedSelections[week] ?? [];
          final actualMealCount = selections.length;

          // Calculate price based on actual meal count
          final weekPrice = _calculateWeekPrice(
            weekSelectionData!.priceOptions!,
            actualMealCount,
          );

          weekPricing[week] = weekPrice;
          totalPrice += weekPrice;

          // Create detailed pricing info
          weekDetails[week] = Checkout.WeekPricingDetails(
            week: week,
            mealCount: actualMealCount,
            pricePerMeal:
                actualMealCount > 0 ? weekPrice / actualMealCount : 0.0,
            weekTotal: weekPrice,
            packageId: weekData.weekPackageIds[week] ?? '',
            dietaryPreference: config.dietaryPreference,
          );

          _logger.d('💰 Week $week: $actualMealCount meals = ₹$weekPrice');
        } else {
          _logger.w('⚠️ No price options available for week $week');
        }
      }

      final pricing = Checkout.SubscriptionPricing(
        weekPricing: weekPricing,
        totalPrice: totalPrice,
        weekDetails: weekDetails,
      );

      _logger.i(
        '✅ Total pricing calculated: ₹$totalPrice for ${weekData.totalMeals} meals',
      );
      return pricing;
    } catch (e) {
      _logger.e('❌ Error calculating pricing', error: e);
      rethrow;
    }
  }

  /// Calculate price for specific week based on meal count
  static double _calculateWeekPrice(
    List<PriceOption> priceOptions,
    int actualMealCount,
  ) {
    if (priceOptions.isEmpty || actualMealCount == 0) return 0.0;

    // Try exact match first
    for (final option in priceOptions) {
      if (option.numberOfMeals == actualMealCount) {
        return option.price;
      }
    }

    // Fallback to closest match
    final sortedOptions = List<PriceOption>.from(priceOptions);
    sortedOptions.sort(
      (a, b) => (a.numberOfMeals - actualMealCount).abs().compareTo(
        (b.numberOfMeals - actualMealCount).abs(),
      ),
    );

    final closestOption = sortedOptions.first;
    _logger.d(
      '📍 Using closest price match: ${closestOption.numberOfMeals} meals = ₹${closestOption.price} for $actualMealCount actual meals',
    );

    return closestOption.price;
  }
}

/// Helper to build subscription request for API
class CheckoutSubscriptionRequestBuilder {
  static final LoggerService _logger = LoggerService();

  /// Build complete subscription request
  static Map<String, dynamic> buildRequest({
    required Checkout.WeekSelectionData weekData,
    required String addressId,
    required int noOfPersons,
    String? instructions,
  }) {
    _logger.i('🔨 Building subscription request');

    try {
      final weeks = <Map<String, dynamic>>[];

      // Build weeks array
      for (final entry in weekData.groupedSelections.entries) {
        final week = entry.key;
        final selections = entry.value;

        if (selections.isNotEmpty) {
          final packageId = weekData.weekPackageIds[week];
          if (packageId != null) {
            // Build slots array for this week
            final slots =
                selections
                    .map(
                      (selection) => {
                        'day': selection.day.toLowerCase(),
                        'date': selection.date.toUtc().toIso8601String(),
                        'timing': selection.timing.toLowerCase(),
                        'meal':
                            selection
                                .dishId, // API expects dishId in 'meal' field
                      },
                    )
                    .toList();

            weeks.add({'package': packageId, 'slots': slots});

            _logger.d(
              '📦 Week $week: ${slots.length} slots with package $packageId',
            );
          }
        }
      }

      final request = {
        'startDate': weekData.startDate.toUtc().toIso8601String(),
        'endDate': weekData.endDate.toUtc().toIso8601String(),
        'durationDays': weekData.totalDuration * 7,
        'address': addressId,
        'instructions': instructions ?? '',
        'noOfPersons': noOfPersons,
        'weeks': weeks,
      };

      _logger.i(
        '✅ Built subscription request: ${weeks.length} weeks, ${weekData.totalMeals} total meals',
      );
      return request;
    } catch (e) {
      _logger.e('❌ Error building subscription request', error: e);
      rethrow;
    }
  }
}
