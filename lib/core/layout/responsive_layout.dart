// lib/core/layout/responsive_layout.dart
import 'package:flutter/material.dart';

/// Device screen types
enum DeviceScreenType {
  mobile,
  tablet,
  desktop,
}

/// Device orientation types
enum DeviceOrientation {
  portrait,
  landscape,
}

/// Screen information including size, device type, and orientation
class ScreenInfo {
  final Size size;
  final DeviceScreenType deviceType;
  final DeviceOrientation orientation;
  final double widthPx;
  final double heightPx;
  final double blockSizeHorizontal;
  final double blockSizeVertical;
  final double safeBlockHorizontal;
  final double safeBlockVertical;
  final double safeAreaHorizontal;
  final double safeAreaVertical;
  final double safeAreaWidthPx;
  final double safeAreaHeightPx;

  ScreenInfo({
    required this.size,
    required this.deviceType,
    required this.orientation,
    required this.widthPx,
    required this.heightPx,
    required this.blockSizeHorizontal,
    required this.blockSizeVertical,
    required this.safeBlockHorizontal,
    required this.safeBlockVertical,
    required this.safeAreaHorizontal,
    required this.safeAreaVertical,
    required this.safeAreaWidthPx,
    required this.safeAreaHeightPx,
  });

  bool get isMobile => deviceType == DeviceScreenType.mobile;
  bool get isTablet => deviceType == DeviceScreenType.tablet;
  bool get isDesktop => deviceType == DeviceScreenType.desktop;
  bool get isPortrait => orientation == DeviceOrientation.portrait;
  bool get isLandscape => orientation == DeviceOrientation.landscape;
}

/// Responsive builder widget that provides screen information and device-specific builders
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ScreenInfo screenInfo) builder;

  // Device breakpoints
  static const double mobileMaxWidth = 600;
  static const double tabletMaxWidth = 900;

  const ResponsiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final mediaQuery = MediaQuery.of(context);
      final size = mediaQuery.size;
      final width = size.width;
      final height = size.height;
      final safeAreaHorizontal = mediaQuery.padding.left + mediaQuery.padding.right;
      final safeAreaVertical = mediaQuery.padding.top + mediaQuery.padding.bottom;
      final safeAreaWidth = width - safeAreaHorizontal;
      final safeAreaHeight = height - safeAreaVertical;

      // Determine device type
      DeviceScreenType deviceType;
      if (width < mobileMaxWidth) {
        deviceType = DeviceScreenType.mobile;
      } else if (width < tabletMaxWidth) {
        deviceType = DeviceScreenType.tablet;
      } else {
        deviceType = DeviceScreenType.desktop;
      }

      // Determine orientation
      final orientation = height > width 
          ? DeviceOrientation.portrait 
          : DeviceOrientation.landscape;

      // Calculate block sizes (1% of screen)
      final blockSizeHorizontal = width / 100;
      final blockSizeVertical = height / 100;
      final safeBlockHorizontal = safeAreaWidth / 100;
      final safeBlockVertical = safeAreaHeight / 100;

      final screenInfo = ScreenInfo(
        size: size,
        deviceType: deviceType,
        orientation: orientation,
        widthPx: width,
        heightPx: height,
        blockSizeHorizontal: blockSizeHorizontal,
        blockSizeVertical: blockSizeVertical,
        safeBlockHorizontal: safeBlockHorizontal,
        safeBlockVertical: safeBlockVertical,
        safeAreaHorizontal: safeAreaHorizontal,
        safeAreaVertical: safeAreaVertical,
        safeAreaWidthPx: safeAreaWidth,
        safeAreaHeightPx: safeAreaHeight,
      );

      return builder(context, screenInfo);
    });
  }
}

/// A widget that returns different widgets based on screen size
class ScreenTypeLayout extends StatelessWidget {
  final Widget? mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ScreenTypeLayout({
    super.key,
    this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screenInfo) {
        // If we're on mobile and we have a mobile layout then return that
        if (screenInfo.deviceType == DeviceScreenType.mobile) {
          return mobile ?? _defaultWidget();
        }

        // If we're on tablet and we have a tablet layout then return that
        if (screenInfo.deviceType == DeviceScreenType.tablet) {
          return tablet ?? mobile ?? _defaultWidget();
        }

        // If we're on desktop and we have a desktop layout then return that
        return desktop ?? tablet ?? mobile ?? _defaultWidget();
      },
    );
  }

  Widget _defaultWidget() {
    return const Center(
      child: Text('No layout specified for this device'),
    );
  }
}

/// A widget that returns different widgets based on orientation
class OrientationLayout extends StatelessWidget {
  final Widget? portrait;
  final Widget? landscape;

  const OrientationLayout({
    super.key,
    this.portrait,
    this.landscape,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screenInfo) {
        // If we're in portrait mode and have a portrait layout, return that
        if (screenInfo.orientation == DeviceOrientation.portrait) {
          return portrait ?? _defaultWidget();
        }

        // If we're in landscape mode and have a landscape layout, return that
        return landscape ?? portrait ?? _defaultWidget();
      },
    );
  }

  Widget _defaultWidget() {
    return const Center(
      child: Text('No layout specified for this orientation'),
    );
  }
}

/// Extension methods on numbers for responsive sizing
extension ResponsiveSizeExt on num {
  // Get a percentage of the screen width
  double widthPercent(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return (this / 100) * screenWidth;
  }

  // Get a percentage of the screen height
  double heightPercent(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return (this / 100) * screenHeight;
  }

  // Get a scaled value based on screen size (useful for text and spacing)
  double scaledSp(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = screenWidth / 375; // 375 is the design width for iPhone X
    return this * scale;
  }
}