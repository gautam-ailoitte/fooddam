// lib/core/constants/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Primary and accent colors
  static const Color primary = Colors.orange;
  static const Color primaryLight = Color(0xFFFFB74D);
  static const Color primaryDark = Color(0xFFE65100);
  static const Color accent = Colors.green;
  static const Color accentLight = Color(0xFF81C784);
  static const Color accentDark = Color(0xFF388E3C);
  
  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textTertiary = Color(0xFFBDBDBD);
  static const Color textLight = Colors.white;
  
  // Background colors
  static const Color background = Colors.white;
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFFE0E0E0);
  
  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFA000);
  static const Color info = Color(0xFF2196F3);
  
  // Misc colors
  static const Color divider = Color(0xFFEEEEEE);
  static const Color shadow = Color(0x1A000000);
  static const Color overlay = Color(0x80000000);
  
  // Food-specific colors
  static const Color vegetarian = Color(0xFF4CAF50);  // Green for vegetarian
  static const Color nonVegetarian = Color(0xFFE53935);  // Red for non-vegetarian
  
  // Semantic status colors
  static const Color activeStatus = Color(0xFF4CAF50);
  static const Color inactiveStatus = Color(0xFF9E9E9E);
  static const Color pendingStatus = Color(0xFFFFA000);
  
  // Theme-specific
  static ColorScheme get lightColorScheme => ColorScheme(
    primary: primary,
    secondary: accent,
    surface: background,
    background: backgroundLight,
    error: error,
    onPrimary: textLight,
    onSecondary: textLight,
    onSurface: textPrimary,
    onBackground: textPrimary,
    onError: textLight,
    brightness: Brightness.light,
  );
  
  // Helper to create a MaterialColor from a Color
  static MaterialColor createMaterialColor(Color color) {
    List<double> strengths = <double>[.05, .1, .2, .3, .4, .5, .6, .7, .8, .9];
    final int r = color.red, g = color.green, b = color.blue;
    Map<int, Color> swatch = {};
    
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    
    return MaterialColor(color.value, swatch);
  }
  
  // Primary swatch
  static MaterialColor primarySwatch = createMaterialColor(primary);


  // Primary color and its shades
  // Secondary color and its shades
  static const Color secondary = Color(0xFFFF6B6B);
  static const Color secondaryLight = Color(0xFFFFB0B0);
  static const Color secondaryDark = Color(0xFFC03A3A);


  // Utility colors

  // Divider, border, and card colors

  // Status colors for order tracking
  static const Color pending = Color(0xFFFF9F43);
  static const Color confirmed = Color(0xFF4889FD);
  static const Color preparing = Color(0xFF9C27B0);
  static const Color ready = Color(0xFF009688);
  static const Color outForDelivery = Color(0xFF3F51B5);
  static const Color delivered = Color(0xFF28C76F);
  static const Color cancelled = Color(0xFFEA5455);

  // Dietary preference colors
  static const Color vegan = Color(0xFF009688);
  static const Color glutenFree = Color(0xFFFF9800);
  static const Color dairyFree = Color(0xFF2196F3);
  static const Color nutFree = Color(0xFF795548);
  static const Color pescatarian = Color(0xFF03A9F4);
  static const Color keto = Color(0xFF9C27B0);
  static const Color paleo = Color(0xFFFF5722);
}
