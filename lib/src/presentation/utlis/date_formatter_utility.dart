// lib/src/presentation/presentation_helpers/core/date_formatter.dart
import 'package:foodam/src/domain/entities/daily_meals_entity.dart';
import 'package:intl/intl.dart';
import 'package:foodam/core/constants/string_constants.dart';

/// Date formatting utilities for the presentation layer
class DateFormatter {
  static const String DEFAULT_DATE_FORMAT = 'dd MMM yyyy';
  static const String SIMPLE_DATE_FORMAT = 'dd/MM/yyyy';
  
  /// Format date to standard format
  static String formatDate(DateTime? date, {String format = DEFAULT_DATE_FORMAT}) {
    if (date == null) return 'Not set';
    return DateFormat(format).format(date);
  }
  
  /// Get current day of week
  static DayOfWeek getCurrentDayOfWeek() {
    final weekday = DateTime.now().weekday;
    switch (weekday) {
      case 1: return DayOfWeek.monday;
      case 2: return DayOfWeek.tuesday;
      case 3: return DayOfWeek.wednesday;
      case 4: return DayOfWeek.thursday;
      case 5: return DayOfWeek.friday;
      case 6: return DayOfWeek.saturday;
      case 7: return DayOfWeek.sunday;
      default: return DayOfWeek.monday;
    }
  }
  
  /// Get day name from DayOfWeek
  static String getDayName(DayOfWeek day) {
    switch (day) {
      case DayOfWeek.monday: return StringConstants.monday;
      case DayOfWeek.tuesday: return StringConstants.tuesday;
      case DayOfWeek.wednesday: return StringConstants.wednesday;
      case DayOfWeek.thursday: return StringConstants.thursday;
      case DayOfWeek.friday: return StringConstants.friday;
      case DayOfWeek.saturday: return StringConstants.saturday;
      case DayOfWeek.sunday: return StringConstants.sunday;
    }
  }
  
  /// Get short day name
  static String getDayAbbreviation(DayOfWeek day) {
    switch (day) {
      case DayOfWeek.monday: return 'Mon';
      case DayOfWeek.tuesday: return 'Tue';
      case DayOfWeek.wednesday: return 'Wed';
      case DayOfWeek.thursday: return 'Thu';
      case DayOfWeek.friday: return 'Fri';
      case DayOfWeek.saturday: return 'Sat';
      case DayOfWeek.sunday: return 'Sun';
    }
  }
  
  /// Calculate end date based on start date and duration
  static DateTime calculateEndDate(DateTime startDate, PlanDuration duration) {
    int days;
    switch (duration) {
      case PlanDuration.sevenDays: days = 7; break;
      case PlanDuration.fourteenDays: days = 14; break;
      case PlanDuration.twentyEightDays: days = 28; break;
    }
    
    return startDate.add(Duration(days: days - 1));
  }
}