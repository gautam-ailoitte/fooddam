

import 'package:foodam/src/domain/entities/daily_meals_entity.dart';
import 'package:intl/intl.dart';

class DateUtil {
  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }
  
  static String formatDay(DateTime date) {
    return DateFormat('EEEE').format(date);
  }
  
  static DayOfWeek toDayOfWeek(DateTime date) {
    final weekday = date.weekday;
    switch (weekday) {
      case 1:
        return DayOfWeek.monday;
      case 2:
        return DayOfWeek.tuesday;
      case 3:
        return DayOfWeek.wednesday;
      case 4:
        return DayOfWeek.thursday;
      case 5:
        return DayOfWeek.friday;
      case 6:
        return DayOfWeek.saturday;
      case 7:
        return DayOfWeek.sunday;
      default:
        return DayOfWeek.monday;
    }
  }
  
  static int getPlanDurationDays(PlanDuration duration) {
    switch (duration) {
      case PlanDuration.sevenDays:
        return 7;
      case PlanDuration.fourteenDays:
        return 14;
      case PlanDuration.twentyEightDays:
        return 28;
      }
  }
  
  static DateTime calculateEndDate(DateTime startDate, PlanDuration duration) {
    final days = getPlanDurationDays(duration);
    return startDate.add(Duration(days: days - 1));
  }
}