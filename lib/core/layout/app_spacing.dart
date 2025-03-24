// lib/core/ui/layout/app_spacing.dart
import 'package:flutter/material.dart';

/// Standardized spacing system for consistent layouts
class AppSpacing {
  /// Micro spacing - 2.0
  static const double micro = 2.0;

  /// Extra small spacing - 4.0
  static const double xs = 4.0;

  /// Small spacing - 8.0
  static const double sm = 8.0;

  /// Medium spacing - 16.0
  static const double md = 16.0;

  /// Large spacing - 24.0
  static const double lg = 24.0;

  /// Extra large spacing - 32.0
  static const double xl = 32.0;

  /// Double extra large spacing - 48.0
  static const double xxl = 48.0;

  /// Triple extra large spacing - 64.0
  static const double xxxl = 64.0;

  /// Standard page padding
  static const EdgeInsets pagePadding = EdgeInsets.all(md);

  /// Padding for cards
  static const EdgeInsets cardPadding = EdgeInsets.all(md);

  /// Padding for form fields
  static const EdgeInsets formFieldPadding = EdgeInsets.symmetric(vertical: sm);

  // Default screen padding
  static EdgeInsets screenPadding({
    required double screenHorizontal,
    required double screenVertical,
  }) => EdgeInsets.symmetric(
    horizontal: screenHorizontal,
    vertical: screenVertical,
  );

  // List item padding
  static EdgeInsets listPadding({
    required double listItemPadding,
    required double screenHorizontal,
  }) => EdgeInsets.symmetric(
    vertical: listItemPadding,
    horizontal: screenHorizontal,
  );

  /// Spacing between form fields
  static const double formFieldSpacing = md;

  /// Spacing between grouped items
  static const double groupedItemSpacing = sm;

  /// Spacing between sections
  static const double sectionSpacing = xl;

  /// Helper method to create a SizedBox with height
  static SizedBox vSpace(double height) => SizedBox(height: height);

  /// Helper method to create a SizedBox with width
  static SizedBox hSpace(double width) => SizedBox(width: width);

  /// Helper method for micro vertical spacing
  static SizedBox get vMicro => vSpace(micro);

  /// Helper method for extra small vertical spacing
  static SizedBox get vXs => vSpace(xs);

  /// Helper method for small vertical spacing
  static SizedBox get vSm => vSpace(sm);

  /// Helper method for medium vertical spacing
  static SizedBox get vMd => vSpace(md);

  /// Helper method for large vertical spacing
  static SizedBox get vLg => vSpace(lg);

  /// Helper method for extra large vertical spacing
  static SizedBox get vXl => vSpace(xl);

  /// Helper method for double extra large vertical spacing
  static SizedBox get vXxl => vSpace(xxl);

  /// Helper method for triple extra large vertical spacing
  static SizedBox get vXxxl => vSpace(xxxl);

  /// Helper method for micro horizontal spacing
  static SizedBox get hMicro => hSpace(micro);

  /// Helper method for extra small horizontal spacing
  static SizedBox get hXs => hSpace(xs);

  /// Helper method for small horizontal spacing
  static SizedBox get hSm => hSpace(sm);

  /// Helper method for medium horizontal spacing
  static SizedBox get hMd => hSpace(md);

  /// Helper method for large horizontal spacing
  static SizedBox get hLg => hSpace(lg);

  /// Helper method for extra large horizontal spacing
  static SizedBox get hXl => hSpace(xl);

  /// Helper method for double extra large horizontal spacing
  static SizedBox get hXxl => hSpace(xxl);

  /// Helper method for triple extra large horizontal spacing
  static SizedBox get hXxxl => hSpace(xxxl);
}


// lib/core/constants/dimensions.dart
class AppDimensions {
  // Margins & Padding
  static const double marginSmall = 8.0;
  static const double marginMedium = 16.0;
  static const double marginLarge = 24.0;
  static const double marginExtraLarge = 32.0;
  
  // Border Radius
  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusMedium = 8.0;
  static const double borderRadiusLarge = 12.0;
  static const double borderRadiusExtraLarge = 24.0;
  
  // Icon Sizes
  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  
  // Button Height
  static const double buttonSmallHeight = 32.0;
  static const double buttonHeight = 48.0;
  static const double buttonLargeHeight = 56.0;
  
  // Card Sizes
  static const double cardElevation = 2.0;
  static const double cardBorderRadius = 12.0;
  
  // Input Field
  static const double inputHeight = 48.0;
  
  // Bottom Navigation
  static const double bottomNavHeight = 60.0;
  
  // App Bar
  static const double appBarHeight = 56.0;
}