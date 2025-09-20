// lib/core/constants/subscription_constants.dart
class SubscriptionConstants {
  // Prevent instantiation
  SubscriptionConstants._();

  // Dietary preferences
  static const List<String> dietaryPreferences = [
    'vegetarian',
    'non-vegetarian',
  ];

  // Duration options (in weeks)
  static const List<int> durations = [1, 2, 3, 4];

  // Meal plan options (meals per week)
  static const List<int> mealPlans = [10, 15, 18, 21];

  // Meal types
  static const List<String> mealTypes = ['breakfast', 'lunch', 'dinner'];

  // Display names for meal types
  static const Map<String, String> mealTypeDisplayNames = {
    'breakfast': 'Breakfast',
    'lunch': 'Lunch',
    'dinner': 'Dinner',
  };

  // Display names for dietary preferences
  static const Map<String, String> dietaryPreferenceDisplayNames = {
    'vegetarian': 'Vegetarian',
    'non-vegetarian': 'Non-Vegetarian',
  };

  // Helper methods
  static String getDietaryPreferenceText(String preference) {
    return dietaryPreferenceDisplayNames[preference] ?? preference;
  }

  static String getDurationText(int duration) {
    if (duration == 1) {
      return '1 Week';
    }
    return '$duration Weeks';
  }

  static String getMealPlanText(int mealPlan) {
    return '$mealPlan meals per week';
  }

  static String getMealTypeDisplayName(String mealType) {
    return mealTypeDisplayNames[mealType] ?? mealType;
  }

  // Validation constants
  static const int minMealsPerWeek = 10;
  static const int maxMealsPerWeek = 21;
  static const int minDurationWeeks = 1;
  static const int maxDurationWeeks = 4;

  // Days of week
  static const List<String> daysOfWeek = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];

  static const Map<String, String> dayDisplayNames = {
    'monday': 'Monday',
    'tuesday': 'Tuesday',
    'wednesday': 'Wednesday',
    'thursday': 'Thursday',
    'friday': 'Friday',
    'saturday': 'Saturday',
    'sunday': 'Sunday',
  };

  // Time slots for meals
  static const Map<String, String> mealTimeSlots = {
    'breakfast': '08:00 - 10:00',
    'lunch': '12:00 - 14:00',
    'dinner': '19:00 - 21:00',
  };

  // Subscription status
  static const List<String> subscriptionStatuses = [
    'pending',
    'active',
    'paused',
    'cancelled',
    'expired',
  ];

  // Payment status
  static const List<String> paymentStatuses = [
    'pending',
    'paid',
    'failed',
    'refunded',
  ];

  // Order status
  static const List<String> orderStatuses = [
    'coming',
    'delivered',
    'notChosen',
    'noMeal',
  ];

  // Validation helpers
  static bool isValidDietaryPreference(String preference) {
    return dietaryPreferences.contains(preference.toLowerCase());
  }

  static bool isValidDuration(int duration) {
    return durations.contains(duration);
  }

  static bool isValidMealPlan(int mealPlan) {
    return mealPlans.contains(mealPlan);
  }

  static bool isValidMealType(String mealType) {
    return mealTypes.contains(mealType.toLowerCase());
  }

  static bool isValidDay(String day) {
    return daysOfWeek.contains(day.toLowerCase());
  }

  // Default values
  static const String defaultDietaryPreference = 'vegetarian';
  static const int defaultDuration = 1;
  static const int defaultMealPlan = 7;
  static const int defaultNoOfPersons = 1;

  // Limits
  static const int maxWeeksPerSubscription = 52;
  static const int maxMealsPerDay = 3;
  static const int maxPersonsPerSubscription = 10;
  static const int maxFutureMonths = 3;

  // Cache duration
  static const Duration cacheValidDuration = Duration(minutes: 10);
  static const Duration backgroundRefreshInterval = Duration(minutes: 5);

  // API timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration weekDataLoadTimeout = Duration(seconds: 20);

  // UI constants
  static const double mealCardHeight = 120.0;
  static const double weekIndicatorSize = 24.0;
  static const int maxDescriptionLength = 100;
  static const int maxInstructionsLength = 500;

  // Error messages
  static const String errorGeneric = 'An unexpected error occurred';
  static const String errorNetwork = 'Network connection failed';
  static const String errorTimeout = 'Request timed out';
  static const String errorInvalidSelection = 'Invalid meal selection';
  static const String errorMealLimitReached = 'Meal selection limit reached';
  static const String errorWeekIncomplete = 'Please complete all weeks';
  static const String errorInvalidAddress = 'Please select a valid address';

  // Success messages
  static const String successSubscriptionCreated =
      'Subscription created successfully';
  static const String successSelectionSaved = 'Meal selection saved';
  static const String successWeekCompleted = 'Week completed';

  // Info messages
  static const String infoLoadingWeekData = 'Loading week data...';
  static const String infoNoMealsAvailable = 'No meals available for this week';
  static const String infoSelectMeals = 'Please select your meals';
}

// lib/core/extensions/list_extensions.dart (HELPER)
extension ListExtensions<T> on List<T> {
  T? get firstOrNull {
    if (isEmpty) return null;
    return first;
  }

  T? get lastOrNull {
    if (isEmpty) return null;
    return last;
  }

  T? firstWhereOrNull(bool Function(T) test) {
    try {
      return firstWhere(test);
    } catch (e) {
      return null;
    }
  }
}

// lib/core/utils/date_utils.dart (HELPER)
class AppDateUtils {
  static String formatDate(DateTime date) {
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
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  static String formatDateRange(DateTime start, DateTime end) {
    if (start.year == end.year && start.month == end.month) {
      return '${formatDate(start).split(',')[0]} - ${end.day}, ${end.year}';
    }
    return '${formatDate(start)} - ${formatDate(end)}';
  }

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  static bool isWeekend(DateTime date) {
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }

  static String getDayName(DateTime date) {
    const dayNames = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return dayNames[date.weekday - 1];
  }

  static DateTime getWeekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  static DateTime getWeekEnd(DateTime date) {
    return getWeekStart(date).add(const Duration(days: 6));
  }
}

// lib/core/utils/validation_utils.dart (HELPER)
class ValidationUtils {
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool isValidPhone(String phone) {
    return RegExp(
      r'^\+?[1-9]\d{1,14}$',
    ).hasMatch(phone.replaceAll(RegExp(r'[\s-()]'), ''));
  }

  static bool isValidFutureDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final inputDate = DateTime(date.year, date.month, date.day);
    return inputDate.isAfter(today) || inputDate.isAtSameMomentAs(today);
  }

  static bool isValidDuration(int weeks) {
    return weeks >= SubscriptionConstants.minDurationWeeks &&
        weeks <= SubscriptionConstants.maxDurationWeeks;
  }

  static bool isValidMealPlan(int meals) {
    return meals >= SubscriptionConstants.minMealsPerWeek &&
        meals <= SubscriptionConstants.maxMealsPerWeek;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateStartDate(DateTime? date) {
    if (date == null) return 'Start date is required';
    if (!isValidFutureDate(date)) {
      return 'Start date must be today or in the future';
    }

    final maxFutureDate = DateTime.now().add(
      Duration(days: SubscriptionConstants.maxFutureMonths * 30),
    );
    if (date.isAfter(maxFutureDate)) {
      return 'Start date cannot be more than ${SubscriptionConstants.maxFutureMonths} months in the future';
    }

    return null;
  }
}
