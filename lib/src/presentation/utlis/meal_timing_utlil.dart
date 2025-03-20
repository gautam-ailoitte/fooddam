// lib/src/presentation/utils/meal_timing_util.dart
import 'package:intl/intl.dart';

class MealTimingUtil {
  // Standard meal time ranges
  final Map<String, Map<String, DateTime>> _standardMealTimes = {
    'Breakfast': {
      'start': DateTime(0, 0, 0, 7, 0), // 7:00 AM
      'end': DateTime(0, 0, 0, 9, 0),   // 9:00 AM
    },
    'Lunch': {
      'start': DateTime(0, 0, 0, 12, 0), // 12:00 PM
      'end': DateTime(0, 0, 0, 14, 0),   // 2:00 PM
    },
    'Dinner': {
      'start': DateTime(0, 0, 0, 19, 0), // 7:00 PM
      'end': DateTime(0, 0, 0, 21, 0),   // 9:00 PM
    },
  };
  
  String getMealTimeRange(String mealType) {
    if (_standardMealTimes.containsKey(mealType)) {
      final start = _formatTime(_standardMealTimes[mealType]!['start']!);
      final end = _formatTime(_standardMealTimes[mealType]!['end']!);
      return '$start - $end';
    }
    return 'Time not specified';
  }
  
  DateTime getExpectedDeliveryTime(String mealType, DateTime date) {
    if (_standardMealTimes.containsKey(mealType)) {
      final mealTime = _standardMealTimes[mealType]!['start']!;
      return DateTime(
        date.year,
        date.month,
        date.day,
        mealTime.hour,
        mealTime.minute,
      );
    }
    return date;
  }
  
  bool isCurrentMealTime(String mealType) {
    if (!_standardMealTimes.containsKey(mealType)) {
      return false;
    }
    
    final now = DateTime.now();
    final start = _standardMealTimes[mealType]!['start']!;
    final end = _standardMealTimes[mealType]!['end']!;
    
    final currentTime = DateTime(0, 0, 0, now.hour, now.minute);
    return currentTime.isAfter(start) && currentTime.isBefore(end);
  }
  
  String getCurrentMealPeriod() {
    final now = DateTime.now();
    final currentTime = DateTime(0, 0, 0, now.hour, now.minute);
    
    for (var entry in _standardMealTimes.entries) {
      final start = entry.value['start']!;
      final end = entry.value['end']!;
      
      if (currentTime.isAfter(start) && currentTime.isBefore(end)) {
        return entry.key;
      }
    }
    
    // Determine the upcoming meal period
    if (currentTime.isBefore(_standardMealTimes['Breakfast']!['start']!)) {
      return 'Before Breakfast';
    } else if (currentTime.isBefore(_standardMealTimes['Lunch']!['start']!)) {
      return 'Before Lunch';
    } else if (currentTime.isBefore(_standardMealTimes['Dinner']!['start']!)) {
      return 'Before Dinner';
    } else {
      return 'After Dinner';
    }
  }
  
  String formatTime(DateTime time) {
    return DateFormat('h:mm a').format(time);
  }
  
  String _formatTime(DateTime time) {
    return DateFormat('h:mm a').format(time);
  }
  
  bool isMealDeliveryPending(String mealType, DateTime date) {
    if (!_standardMealTimes.containsKey(mealType)) {
      return false;
    }
    
    final now = DateTime.now();
    final mealEndTime = DateTime(
      date.year,
      date.month,
      date.day,
      _standardMealTimes[mealType]!['end']!.hour,
      _standardMealTimes[mealType]!['end']!.minute,
    );
    
    return now.isBefore(mealEndTime);
  }
}