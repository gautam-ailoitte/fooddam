// lib/src/presentation/utils/plan_duration_calculator.dart
class PlanDurationCalculator {
  // Map of duration descriptions to their corresponding days
  final Map<String, int> _durationMap = {
    '7 days': 7,
    '14 days': 14,
    '28 days': 28,
    'Weekly': 7,
    'Bi-weekly': 14,
    'Monthly': 30,
  };
  
  int getDurationDays(String durationDescription) {
    return _durationMap[durationDescription] ?? 0;
  }
  
  String getDurationDescription(int days) {
    switch (days) {
      case 7:
        return '7 days (1 week)';
      case 14:
        return '14 days (2 weeks)';
      case 28:
        return '28 days (4 weeks)';
      case 30:
        return '30 days (1 month)';
      default:
        return '$days days';
    }
  }
  
  DateTime calculateEndDate(DateTime startDate, String durationDescription) {
    int days = getDurationDays(durationDescription);
    if (days == 0) {
      // Try to parse the duration string for a number
      final RegExp daysRegex = RegExp(r'(\d+)');
      final match = daysRegex.firstMatch(durationDescription);
      if (match != null) {
        days = int.tryParse(match.group(1) ?? '0') ?? 0;
      }
    }
    
    return startDate.add(Duration(days: days));
  }
  
  DateTime calculateEndDate2(DateTime startDate, int days) {
    return startDate.add(Duration(days: days - 1)); // Subtract 1 to include start date
  }
  
  int calculateRemainingDays(DateTime endDate) {
    final now = DateTime.now();
    final difference = endDate.difference(now).inDays;
    return difference > 0 ? difference : 0;
  }
  
  double calculateCompletionPercentage(DateTime startDate, DateTime endDate) {
    final now = DateTime.now();
    final totalDays = endDate.difference(startDate).inDays;
    final elapsedDays = now.difference(startDate).inDays;
    
    if (elapsedDays <= 0) return 0.0;
    if (elapsedDays >= totalDays) return 100.0;
    
    return (elapsedDays / totalDays) * 100;
  }
  
  List<DateTime> generateDatesBetween(DateTime startDate, DateTime endDate) {
    List<DateTime> dates = [];
    DateTime currentDate = startDate;
    
    while (!currentDate.isAfter(endDate)) {
      dates.add(currentDate);
      currentDate = currentDate.add(Duration(days: 1));
    }
    
    return dates;
  }
  
  Map<String, int> defaultMealDistribution(int totalMeals) {
    // Default distribution as per app requirements
    switch (totalMeals) {
      case 7:
        return {'Breakfast': 0, 'Lunch': 3, 'Dinner': 4};
      case 14:
        return {'Breakfast': 4, 'Lunch': 4, 'Dinner': 6};
      case 21:
        return {'Breakfast': 7, 'Lunch': 7, 'Dinner': 7};
      case 28:
        return {'Breakfast': 7, 'Lunch': 9, 'Dinner': 12};
      default:
        // Create a balanced distribution
        final int perMeal = totalMeals ~/ 3;
        final int remainder = totalMeals % 3;
        
        return {
          'Breakfast': perMeal,
          'Lunch': perMeal,
          'Dinner': perMeal + remainder, // Add remainder to dinner
        };
    }
  }
}