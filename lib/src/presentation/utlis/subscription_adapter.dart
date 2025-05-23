// lib/src/presentation/utils/subscription_adapter.dart
import 'package:foodam/src/domain/entities/dish_entity.dart';
import 'package:foodam/src/domain/entities/meal_slot_entity.dart';
import 'package:foodam/src/domain/entities/pacakge_entity.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';

/// Utility class for adapting subscription entities to UI-friendly formats
class SubscriptionAdapter {
  /// Get all meal slots from a subscription (flattened from all weeks)
  static List<MealSlot> getAllSlots(Subscription subscription) {
    if (subscription.weeks == null || subscription.weeks!.isEmpty) {
      return [];
    }

    // Flatten all slots from all weeks
    return subscription.weeks!.expand((week) => week.slots).toList();
  }

  /// Count meals by type (breakfast, lunch, dinner)
  static Map<String, int> countMealsByType(Subscription subscription) {
    final Map<String, int> counts = {'breakfast': 0, 'lunch': 0, 'dinner': 0};

    final slots = getAllSlots(subscription);

    for (final slot in slots) {
      final timing = slot.timing.toLowerCase();
      if (counts.containsKey(timing)) {
        counts[timing] = (counts[timing] ?? 0) + 1;
      }
    }

    return counts;
  }

  /// Get total meal count in a subscription
  static int getTotalMealCount(Subscription subscription) {
    // If totalSlots is already available, use it
    if (subscription.totalSlots > 0) {
      return subscription.totalSlots;
    }

    // Otherwise count all slots
    return getAllSlots(subscription).length;
  }

  /// Get price for a package based on meal count option
  static double? getPackagePrice(Package package, int? mealCount) {
    if (package.priceOptions == null || package.priceOptions!.isEmpty) {
      return null;
    }

    // If no meal count specified, return the first price
    if (mealCount == null) {
      return package.priceOptions!.first.price;
    }

    // Find exact match
    final exactMatch =
        package.priceOptions!
            .where((option) => option.numberOfMeals == mealCount)
            .toList();

    if (exactMatch.isNotEmpty) {
      return exactMatch.first.price;
    }

    // Find closest match
    package.priceOptions!.sort(
      (a, b) => (a.numberOfMeals - mealCount).abs().compareTo(
        (b.numberOfMeals - mealCount).abs(),
      ),
    );

    return package.priceOptions!.first.price;
  }

  /// Format meal timing to user-friendly format
  static String formatTiming(String timing) {
    if (timing.isEmpty) return '';
    return timing.substring(0, 1).toUpperCase() +
        timing.substring(1).toLowerCase();
  }

  /// Format day to user-friendly format
  static String formatDay(String day) {
    if (day.isEmpty) return '';
    return day.substring(0, 1).toUpperCase() + day.substring(1).toLowerCase();
  }

  /// Get next delivery date based on subscription
  static DateTime? getNextDeliveryDate(Subscription subscription) {
    if (subscription.isPaused) return null;

    final now = DateTime.now();
    final dayOfWeek = now.weekday;

    // Get all slots
    final slots = getAllSlots(subscription);

    // Find next upcoming slot
    for (int i = 0; i < 7; i++) {
      final targetDay = (dayOfWeek + i) % 7;
      final dayName = _getWeekdayName(targetDay);

      // Find a slot for this day
      final matchingSlots =
          slots
              .where((slot) => slot.day.toLowerCase() == dayName.toLowerCase())
              .toList();

      if (matchingSlots.isNotEmpty) {
        return now.add(Duration(days: i));
      }
    }

    return null;
  }

  /// Internal helper to get day name from weekday number
  static String _getWeekdayName(int weekday) {
    final days = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];
    return days[(weekday - 1) % 7];
  }

  /// Calculate days remaining in subscription
  static int calculateDaysRemaining(Subscription subscription) {
    final now = DateTime.now();
    final endDate =
        subscription.endDate ??
        subscription.startDate.add(Duration(days: subscription.durationDays));

    if (now.isAfter(endDate)) {
      return 0;
    }

    return endDate.difference(now).inDays;
  }

  /// Get dish for specified meal type from a slot
  static Dish? getDishForMealType(MealSlot slot, String mealType) {
    if (slot.meal == null) return null;

    final dishes = slot.meal?.dishes;
    if (dishes == null || dishes.isEmpty) return null;

    // Look for dish with matching type
    // for (final entry in dishes.entries) {
    //   if (entry.key.toLowerCase() == mealType.toLowerCase()) {
    //     return entry.value;
    //   }
    // }  //todo:

    return null;
  }

  /// Convert SubscriptionStatus to user-friendly string
  static String getStatusText(SubscriptionStatus status, bool isPaused) {
    if (isPaused) return 'Paused';

    switch (status) {
      case SubscriptionStatus.pending:
        return 'Pending';
      case SubscriptionStatus.active:
        return 'Active';
      case SubscriptionStatus.paused:
        return 'Paused';
      case SubscriptionStatus.cancelled:
        return 'Cancelled';
      case SubscriptionStatus.expired:
        return 'Expired';
    }
  }
}
