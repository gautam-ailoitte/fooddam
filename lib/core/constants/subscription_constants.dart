// lib/core/constants/subscription_constants.dart
class SubscriptionConstants {
  static const List<int> mealPlans = [10, 15, 18, 21];
  static const List<int> durations = [1, 2, 3, 4]; // weeks
  static const List<String> mealTypes = ['breakfast', 'lunch', 'dinner'];

  static const List<String> dietaryPreferences = [
    'vegetarian',
    'non-vegetarian',
  ];

  // Meal type display names
  static const Map<String, String> mealTypeDisplayNames = {
    'breakfast': 'Breakfast',
    'lunch': 'Lunch',
    'dinner': 'Dinner',
  };

  // Duration display text
  static String getDurationText(int weeks) {
    switch (weeks) {
      case 1:
        return '1 Week';
      case 2:
        return '2 Weeks';
      case 3:
        return '3 Weeks';
      case 4:
        return '4 Weeks';
      default:
        return '$weeks Weeks';
    }
  }

  // Meal plan display text
  static String getMealPlanText(int meals) {
    return '$meals Meals/Week';
  }

  // Dietary preference display text
  static String getDietaryPreferenceText(String preference) {
    switch (preference) {
      case 'vegetarian':
        return 'Vegetarian';
      case 'non-vegetarian':
        return 'Non-Vegetarian';
      default:
        return preference;
    }
  }
}
