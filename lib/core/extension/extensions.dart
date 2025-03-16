// lib/core/extensions/context_extensions.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/layout/responsive_layout.dart';

extension ContextExtensions on BuildContext {
  // Theme shortcuts
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;
  
  // MediaQuery shortcuts
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => mediaQuery.size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
  EdgeInsets get viewPadding => mediaQuery.viewPadding;
  EdgeInsets get viewInsets => mediaQuery.viewInsets;
  EdgeInsets get padding => mediaQuery.padding;
  
  // SafeArea
  EdgeInsets get safeAreaPadding => padding;
  double get safeAreaTop => padding.top;
  double get safeAreaBottom => padding.bottom;
  double get safeAreaLeft => padding.left;
  double get safeAreaRight => padding.right;
  double get safeAreaHorizontal => safeAreaLeft + safeAreaRight;
  double get safeAreaVertical => safeAreaTop + safeAreaBottom;
  
  // Device type
  bool get isMobile => screenWidth < ResponsiveBuilder.mobileMaxWidth;
  bool get isTablet => screenWidth >= ResponsiveBuilder.mobileMaxWidth && screenWidth < ResponsiveBuilder.tabletMaxWidth;
  bool get isDesktop => screenWidth >= ResponsiveBuilder.tabletMaxWidth;
  
  // Orientation
  bool get isPortrait => mediaQuery.orientation == Orientation.portrait;
  bool get isLandscape => mediaQuery.orientation == Orientation.landscape;
  
  // Responsive size helpers
  double get blockSizeHorizontal => screenWidth / 100;
  double get blockSizeVertical => screenHeight / 100;
  
  // // Navigation helpers
  // Future<T?> push<T>(Widget page) {
  //   return Navigator.of(this).push<T>(
  //     MaterialPageRoute(builder: (_) => page),
  //   );
  // }
  
  // Future<T?> pushNamed<T>(String routeName, {Object? arguments}) {
  //   return Navigator.of(this).pushNamed<T>(routeName, arguments: arguments);
  // }
  
  // Future<T?> pushReplacement<T, TO>(Widget page) {
  //   return Navigator.of(this).pushReplacement<T, TO>(
  //     MaterialPageRoute(builder: (_) => page),
  //   );
  // }
  
  // Future<T?> pushReplacementNamed<T, TO>(String routeName, {Object? arguments}) {
  //   return Navigator.of(this).pushReplacementNamed<T, TO>(routeName, arguments: arguments);
  // }
  
  // Future<T?> pushAndRemoveUntil<T>(Widget page, RoutePredicate predicate) {
  //   return Navigator.of(this).pushAndRemoveUntil<T>(
  //     MaterialPageRoute(builder: (_) => page),
  //     predicate,
  //   );
  // }
  
  // Future<T?> pushNamedAndRemoveUntil<T>(String routeName, RoutePredicate predicate, {Object? arguments}) {
  //   return Navigator.of(this).pushNamedAndRemoveUntil<T>(routeName, predicate, arguments: arguments);
  // }
  
  // void pop<T>([T? result]) {
  //   return Navigator.of(this).pop<T>(result);
  // }
  
  // void popUntil(RoutePredicate predicate) {
  //   return Navigator.of(this).popUntil(predicate);
  // }
  
  // Snackbar helpers
  void showSnackBar(String message, {Duration duration = const Duration(seconds: 2)}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
      ),
    );
  }
  
  void showErrorSnackBar(String message, {Duration duration = const Duration(seconds: 3)}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        backgroundColor: Colors.red,
      ),
    );
  }
  
  void showSuccessSnackBar(String message, {Duration duration = const Duration(seconds: 2)}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        backgroundColor: Colors.green,
      ),
    );
  }
  
  // Hide current snackbar
  void hideSnackBar() {
    ScaffoldMessenger.of(this).hideCurrentSnackBar();
  }
  
  // Remove current snackbar
  void removeSnackBar() {
    ScaffoldMessenger.of(this).removeCurrentSnackBar();
  }
  
  // Clear all snackbars
  void clearSnackBars() {
    ScaffoldMessenger.of(this).clearSnackBars();
  }
}

// lib/core/extensions/string_extensions.dart
extension StringExtensions on String {
  // Capitalize first letter of a string
  String get capitalize => isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
  
  // Capitalize first letter of each word
  String get capitalizeWords => isEmpty 
    ? this 
    : split(' ').map((word) => word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}').join(' ');
  
  // Check if string is a valid email
  bool get isEmail => RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  
  // Check if string is a valid URL
  bool get isUrl => RegExp(r'^(http|https)://[a-zA-Z0-9]+([\-\.]{1}[a-zA-Z0-9]+)*\.[a-zA-Z]{2,5}(:[0-9]{1,5})?(\/.*)?$').hasMatch(this);
  
  // Check if string is a valid phone number
  bool get isPhoneNumber => RegExp(r'^\+?[0-9]{10,14}$').hasMatch(this);
  
  // Check if string contains only digits
  bool get isNumeric => RegExp(r'^[0-9]+$').hasMatch(this);
  
  // Check if string contains only letters
  bool get isAlpha => RegExp(r'^[a-zA-Z]+$').hasMatch(this);
  
  // Check if string contains only letters and numbers
  bool get isAlphanumeric => RegExp(r'^[a-zA-Z0-9]+$').hasMatch(this);
  
  // Check if string is empty or only contains whitespace
  bool get isEmptyOrWhitespace => trim().isEmpty;
  
  // Return the first n characters
  String first(int n) => length < n ? this : substring(0, n);
  
  // Return the last n characters
  String last(int n) => length < n ? this : substring(length - n);
  
  // Truncate string to n characters and add ellipsis if truncated
  String truncate(int n, {String ellipsis = '...'}) {
    if (length <= n) return this;
    return '${substring(0, n)}$ellipsis';
  }
  
  // Remove all whitespace
  String get removeWhitespace => replaceAll(RegExp(r'\s+'), '');
  
  // Convert to camelCase
  String get toCamelCase {
    if (isEmpty) return this;
    
    final words = trim().split(RegExp(r'[\s_-]+'));
    final firstWord = words.first.toLowerCase();
    final capitalized = words.skip(1).map((word) {
      return word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
    }).join('');
    
    return firstWord + capitalized;
  }
  
  // Convert to snake_case
  String get toSnakeCase {
    if (isEmpty) return this;
    
    final result = StringBuffer();
    for (var i = 0; i < length; i++) {
      final char = this[i];
      if (char.toUpperCase() == char && char != ' ' && i != 0) {
        result.write('_');
      }
      result.write(char.toLowerCase());
    }
    
    return result.toString().replaceAll(' ', '_').replaceAll(RegExp(r'_+'), '_');
  }
}

// lib/core/extensions/num_extensions.dart
// import 'package:flutter/material.dart';

extension NumExtensions on num {
  // Duration shortcuts
  Duration get milliseconds => Duration(milliseconds: toInt());
  Duration get seconds => Duration(seconds: toInt());
  Duration get minutes => Duration(minutes: toInt());
  Duration get hours => Duration(hours: toInt());
  Duration get days => Duration(days: toInt());
  
  // Spacing widgets
  Widget get hSpace => SizedBox(width: toDouble());
  Widget get vSpace => SizedBox(height: toDouble());
  
  // Currency formatting
  String toCurrency({String symbol = '₹', int decimalPlaces = 2}) {
    return '$symbol${toStringAsFixed(decimalPlaces)}';
  }
  
  // Percentage formatting
  String toPercentage({int decimalPlaces = 1}) {
    return '${toStringAsFixed(decimalPlaces)}%';
  }
  
  // Clamp value between min and max
  num clamp(num min, num max) => this < min ? min : (this > max ? max : this);
  
  // Map a value from one range to another
  double mapRange(num inMin, num inMax, num outMin, num outMax) {
    return ((this - inMin) * (outMax - outMin) / (inMax - inMin)) + outMin;
  }
  
  // Check if number is between two values (inclusive)
  bool isBetween(num min, num max) => this >= min && this <= max;
}

// lib/core/extensions/datetime_extensions.dart
extension DateTimeExtensions on DateTime {
  // Format to ISO date string (YYYY-MM-DD)
  String get toIsoDateString => '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
  
  // Format to local date string (DD/MM/YYYY)
  String get toLocalDateString => '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year';
  
  // Format to short date (DD MMM YYYY)
  String get toShortDateString {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${day.toString().padLeft(2, '0')} ${months[month - 1]} $year';
  }
  
  // Format to time string (HH:MM)
  String get toTimeString => '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  
  // Format to 12-hour time string (hh:mm AM/PM)
  String get to12HourTimeString {
    final h = hour % 12 == 0 ? 12 : hour % 12;
    final amPm = hour < 12 ? 'AM' : 'PM';
    return '${h.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $amPm';
  }
  
  // Format to date time string (DD/MM/YYYY HH:MM)
  String get toDateTimeString => '$toLocalDateString $toTimeString';
  
  // Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
  
  // Check if date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }
  
  // Check if date is tomorrow
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year && month == tomorrow.month && day == tomorrow.day;
  }
  
  // Check if date is in the same week
  bool get isThisWeek {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    return isAfter(weekStart.subtract(const Duration(days: 1))) && 
           isBefore(weekEnd.add(const Duration(days: 1)));
  }
  
  // Check if date is in the past
  bool get isPast => isBefore(DateTime.now());
  
  // Check if date is in the future
  bool get isFuture => isAfter(DateTime.now());
  
  // Get start of day (00:00:00)
  DateTime get startOfDay => DateTime(year, month, day);
  
  // Get end of day (23:59:59)
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);
  
  // Get start of week (Monday)
  DateTime get startOfWeek {
    final daysToSubtract = weekday - 1;
    return subtract(Duration(days: daysToSubtract)).startOfDay;
  }
  
  // Get end of week (Sunday)
  DateTime get endOfWeek {
    final daysToAdd = 7 - weekday;
    return add(Duration(days: daysToAdd)).endOfDay;
  }
  
  // Get start of month
  DateTime get startOfMonth => DateTime(year, month, 1);
  
  // Get end of month
  DateTime get endOfMonth {
    final nextMonth = month < 12 ? DateTime(year, month + 1, 1) : DateTime(year + 1, 1, 1);
    return nextMonth.subtract(const Duration(days: 1)).endOfDay;
  }
  
  // Get age in years
  int get age {
    final now = DateTime.now();
    int years = now.year - year;
    if (now.month < month || (now.month == month && now.day < day)) {
      years--;
    }
    return years;
  }
  
  // Format as relative time (just now, 5 minutes ago, yesterday, etc.)
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(this);
    
    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months == 1 ? '' : 's'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years year${years == 1 ? '' : 's'} ago';
    }
  }
}

// lib/core/extensions/widget_extensions.dart


extension WidgetExtensions on Widget {
  // Add padding around widget
  Widget padding({
    double all = 0.0,
    double horizontal = 0.0,
    double vertical = 0.0,
    double left = 0.0,
    double top = 0.0,
    double right = 0.0,
    double bottom = 0.0,
  }) {
    EdgeInsets padding;
    
    if (all > 0) {
      padding = EdgeInsets.all(all);
    } else if (horizontal > 0 || vertical > 0) {
      padding = EdgeInsets.symmetric(
        horizontal: horizontal,
        vertical: vertical,
      );
    } else {
      padding = EdgeInsets.only(
        left: left,
        top: top,
        right: right,
        bottom: bottom,
      );
    }
    
    return Padding(padding: padding, child: this);
  }
  
  // Add margin around widget
  Widget margin({
    double all = 0.0,
    double horizontal = 0.0,
    double vertical = 0.0,
    double left = 0.0,
    double top = 0.0,
    double right = 0.0,
    double bottom = 0.0,
  }) {
    return Container(
      margin: all > 0 
          ? EdgeInsets.all(all)
          : EdgeInsets.only(
              left: horizontal > 0 ? horizontal : left,
              top: vertical > 0 ? vertical : top,
              right: horizontal > 0 ? horizontal : right,
              bottom: vertical > 0 ? vertical : bottom,
            ),
      child: this,
    );
  }
  
  // Center widget
  Widget get center => Center(child: this);
  
  // Align widget
  Widget align(Alignment alignment) => Align(alignment: alignment, child: this);
  
  // Make widget expandable
  Widget get expanded => Expanded(child: this);
  
  // Make widget flexible
  Widget flexible({int flex = 1}) => Flexible(flex: flex, child: this);
  
  // Set widget size
  Widget size({double? width, double? height}) {
    return SizedBox(width: width, height: height, child: this);
  }
  
  // Make widget scrollable
  Widget scrollable({
    ScrollPhysics? physics,
    bool? primary,
    ScrollController? controller,
    Axis scrollDirection = Axis.vertical,
    bool reverse = false,
    EdgeInsetsGeometry? padding,
  }) {
    return SingleChildScrollView(
      physics: physics,
      primary: primary,
      controller: controller,
      scrollDirection: scrollDirection,
      reverse: reverse,
      padding: padding,
      child: this,
    );
  }
  
  // Add card styling
  Widget card({
    double elevation = 1.0,
    Color? color,
    Color? shadowColor,
    ShapeBorder? shape,
    EdgeInsetsGeometry? margin,
    Clip clipBehavior = Clip.none,
    bool borderOnForeground = true,
  }) {
    return Card(
      elevation: elevation,
      color: color,
      shadowColor: shadowColor,
      shape: shape,
      margin: margin,
      clipBehavior: clipBehavior,
      borderOnForeground: borderOnForeground,
      child: this,
    );
  }
  
  // Make widget tappable
  Widget onTap(VoidCallback onTap, {bool inkWell = true}) {
    return inkWell
        ? InkWell(onTap: onTap, child: this)
        : GestureDetector(onTap: onTap, child: this);
  }
  
  // Add border to widget
  Widget border({
    Color color = Colors.grey,
    double width = 1.0,
    BorderRadius? borderRadius,
    List<BoxShadow>? boxShadow,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: color, width: width),
        borderRadius: borderRadius,
        boxShadow: boxShadow,
      ),
      child: this,
    );
  }
  
  // Add circle shape to widget
  Widget circle({
    double? radius,
    Color? backgroundColor,
    BoxBorder? border,
    List<BoxShadow>? boxShadow,
  }) {
    return Container(
      width: radius != null ? radius * 2 : null,
      height: radius != null ? radius * 2 : null,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
        border: border,
        boxShadow: boxShadow,
      ),
      child: this,
    );
  }
  
  // Clip to rounded rectangle
  Widget roundedCorners({
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(8)),
    CustomClipper<RRect>? clipper,
    Clip clipBehavior = Clip.antiAlias,
  }) {
    return ClipRRect(
      borderRadius: borderRadius,
      clipper: clipper,
      clipBehavior: clipBehavior,
      child: this,
    );
  }
  
  // Set background color
  Widget backgroundColor(Color color) {
    return Container(
      color: color,
      child: this,
    );
  }
  
  // Add visibility condition
  Widget visible(bool visible) {
    return visible ? this : const SizedBox.shrink();
  }
  
  // Add opacity
  Widget opacity(double opacity) {
    return Opacity(
      opacity: opacity,
      child: this,
    );
  }
}