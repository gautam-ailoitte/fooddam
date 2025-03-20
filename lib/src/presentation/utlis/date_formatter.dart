// lib/src/presentation/utils/date_formatter.dart
import 'package:intl/intl.dart';

class DateFormatter {
  String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }
  
  String formatShortDate(DateTime date) {
    return DateFormat('MM/dd/yyyy').format(date);
  }
  
  String formatTime(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }
  
  String formatDateTime(DateTime date) {
    return DateFormat('MMM dd, yyyy h:mm a').format(date);
  }
  
  String formatDateRange(DateTime start, DateTime end) {
    return '${formatDate(start)} - ${formatDate(end)}';
  }
  
  String getWeekday(DateTime date) {
    return DateFormat('EEEE').format(date);
  }
  
  String getShortWeekday(DateTime date) {
    return DateFormat('E').format(date);
  }
  
  String getMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }
  
  String getRelativeTimeFromNow(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);
    
    if (difference.inDays.abs() > 365) {
      final years = (difference.inDays.abs() / 365).floor();
      return difference.isNegative 
          ? '$years ${years == 1 ? 'year' : 'years'} ago'
          : 'in $years ${years == 1 ? 'year' : 'years'}';
    } else if (difference.inDays.abs() > 30) {
      final months = (difference.inDays.abs() / 30).floor();
      return difference.isNegative 
          ? '$months ${months == 1 ? 'month' : 'months'} ago'
          : 'in $months ${months == 1 ? 'month' : 'months'}';
    } else if (difference.inDays.abs() > 0) {
      return difference.isNegative 
          ? '${difference.inDays.abs()} ${difference.inDays.abs() == 1 ? 'day' : 'days'} ago'
          : 'in ${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'}';
    } else if (difference.inHours.abs() > 0) {
      return difference.isNegative 
          ? '${difference.inHours.abs()} ${difference.inHours.abs() == 1 ? 'hour' : 'hours'} ago'
          : 'in ${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'}';
    } else if (difference.inMinutes.abs() > 0) {
      return difference.isNegative 
          ? '${difference.inMinutes.abs()} ${difference.inMinutes.abs() == 1 ? 'minute' : 'minutes'} ago'
          : 'in ${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'}';
    } else {
      return difference.isNegative ? 'just now' : 'just now';
    }
  }
}