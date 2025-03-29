// lib/core/constants/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Primary and accent colors
  static const Color primary = Color(0xFFFF6A3D); // Vibrant Orange
  static const Color primaryLight = Color(0xFFFF8F6C); // Light Orange
  static const Color primaryLighter = Color(0xFFFFE2D9); // Very Light Orange
  static const Color primaryDark = Color(0xFFE64D20); // Dark Orange
  static const Color accent = Color(0xFF2FA84F); // Green
  static const Color accentLight = Color(0xFF6BCA84); // Light Green
  static const Color accentLighter = Color(0xFFE0F5E6); // Very Light Green
  static const Color accentDark = Color(0xFF1E7A34); // Dark Green

  // Secondary colors
  static const Color secondary = Color(0xFFFF6B6B); // Red
  static const Color secondaryLight = Color(0xFFFFB0B0); // Light Red
  static const Color secondaryDark = Color(0xFFC03A3A); // Dark Red

  // Neutral colors
  static const Color neutral900 = Color(0xFF1C1C27); // Very Dark (almost black)
  static const Color neutral800 = Color(0xFF2E2E3A); // Dark Grey
  static const Color neutral700 = Color(0xFF4A4A5A); // Medium Dark Grey
  static const Color neutral600 = Color(0xFF686878); // Medium Grey
  static const Color neutral500 = Color(0xFF8E8E9C); // Grey
  static const Color neutral400 = Color(0xFFB0B0BC); // Light Grey
  static const Color neutral300 = Color(0xFFD2D2DC); // Lighter Grey
  static const Color neutral200 = Color(0xFFE6E6ED); // Very Light Grey
  static const Color neutral100 = Color(0xFFF5F5FA); // Almost White

  // Text colors
  static const Color textPrimary = neutral900;
  static const Color textSecondary = neutral700;
  static const Color textTertiary = neutral500;
  static const Color textLight = Colors.white;
  static const Color textOnPrimary = Colors.white;
  static const Color textOnSecondary = Colors.white;

  // Background colors
  static const Color background = Colors.white;
  static const Color backgroundLight = neutral100;
  static const Color backgroundDark = neutral200;
  static const Color surface = Colors.white;
  static const Color surfaceLight = neutral100;

  // Status colors
  static const Color success = Color(0xFF2CA74E); // Green
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color error = Color(0xFFEC4E4E); // Red
  static const Color warning = Color(0xFFFFB020); // Amber
  static const Color info = Color(0xFF2196F3); // Blue

  // Food-specific colors
  static const Color vegetarian = Color(0xFF2CA74E); // Green
  static const Color nonVegetarian = Color(0xFFEC4E4E); // Red
  static const Color vegan = Color(0xFF00AF91); // Teal Green
  static const Color spicy = Color(0xFFFF5722); // Deep Orange

  // Food preference colors
  static const Color glutenFree = Color(0xFFAB47BC); // Purple
  static const Color dairyFree = Color(0xFF42A5F5); // Blue
  static const Color nutFree = Color(0xFF795548); // Brown
  static const Color lowCalorie = Color(0xFF26A69A); // Teal

  // Order status colors
  static const Color pending = Color(0xFFFFB020); // Amber
  static const Color preparing = Color(0xFF2196F3); // Blue
  static const Color readyForPickup = Color(0xFF9C27B0); // Purple
  static const Color onTheWay = Color(0xFF3F51B5); // Indigo
  static const Color delivered = Color(0xFF2CA74E); // Green
  static const Color cancelled = Color(0xFFEC4E4E); // Red

  // Subscription status colors
  static const Color active = Color(0xFF2CA74E); // Green
  static const Color paused = Color(0xFFFFB020); // Amber
  static const Color expired = neutral600; // Medium Grey
  // static const Color cancelled = neutral500; // Grey

  // Misc colors
  static const Color divider = neutral200;
  static const Color shadow = Color(0x1A000000); // Black with 10% opacity
  static const Color overlay = Color(0x80000000); // Black with 50% opacity
  static const Color cardStroke = neutral200;
  static const Color badge = primary;

  // Dark theme specific colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF2C2C2C);
  static const Color darkDivider = Color(0xFF323232);
  static const Color darkBorder = Color(0xFF3E3E3E);
  static const Color darkTextPrimary = Color(0xFFEEEEEE);
  static const Color darkTextSecondary = Color(0xFFB3B3B3);
  static const Color darkTextTertiary = Color(0xFF8A8A8A);

  // Theme-specific color schemes
  static ColorScheme get lightColorScheme => ColorScheme(
    primary: primary,
    primaryContainer: primaryLight,
    secondary: accent,
    secondaryContainer: accentLight,
    surface: surface,
    background: background,
    error: error,
    onPrimary: textOnPrimary,
    onSecondary: textOnSecondary,
    onSurface: textPrimary,
    onBackground: textPrimary,
    onError: textLight,
    brightness: Brightness.light,
  );
  
  // Dark color scheme
  static ColorScheme get darkColorScheme => ColorScheme(
    primary: primaryLight,  // Lighter primary for better visibility in dark mode
    primaryContainer: primaryDark,
    secondary: accentLight, // Lighter accent for better visibility in dark mode
    secondaryContainer: accentDark,
    surface: darkSurface,
    background: darkBackground,
    error: Color(0xFFFF5252), // Brighter red for dark theme
    onPrimary: textLight,
    onSecondary: textLight,
    onSurface: darkTextPrimary,
    onBackground: darkTextPrimary,
    onError: textLight,
    brightness: Brightness.dark,
  );

  // Helper to create a MaterialColor from a Color for primary swatch
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
  
  // Primary swatch for the app
  static MaterialColor primarySwatch = createMaterialColor(primary);
}