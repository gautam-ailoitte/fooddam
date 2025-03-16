import 'package:flutter/material.dart';

/// Standard scaffold variants
enum ScaffoldType {
  /// Basic scaffold with only body
  basic,
  
  /// Scaffold with app bar
  withAppBar,
  
  /// Scaffold with bottom navigation
  withBottomNav,
  
  /// Scaffold with app bar and bottom navigation
  withAppBarAndBottomNav
}

/// Standard app scaffold with consistent styling
class AppScaffold extends StatelessWidget {
  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final ScaffoldType type;
  final bool safeAreaTop;
  final bool safeAreaBottom;
  final bool resizeToAvoidBottomInset;
  final bool centerTitle;
  final bool hasBackButton;
  final Color? backgroundColor;
  final PreferredSizeWidget? customAppBar;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onBackPressed;

  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.type = ScaffoldType.withAppBar,
    this.safeAreaTop = true,
    this.safeAreaBottom = true,
    this.resizeToAvoidBottomInset = true,
    this.centerTitle = true,
    this.hasBackButton = true,
    this.backgroundColor,
    this.customAppBar,
    this.padding,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Determine if app bar should be shown
    final showAppBar = type == ScaffoldType.withAppBar || 
                        type == ScaffoldType.withAppBarAndBottomNav;
    
    // Determine if bottom nav should be shown
    final showBottomNav = type == ScaffoldType.withBottomNav || 
                          type == ScaffoldType.withAppBarAndBottomNav;
    
    // Build the actual scaffold
    return Scaffold(
      appBar: showAppBar 
          ? customAppBar ?? _buildAppBar(context) 
          : null,
      body: SafeArea(
        top: safeAreaTop,
        bottom: safeAreaBottom,
        child: padding != null 
            ? Padding(
                padding: padding!,
                child: body,
              )
            : body,
      ),
      bottomNavigationBar: showBottomNav ? bottomNavigationBar : null,
      floatingActionButton: floatingActionButton,
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    );
  }
  
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: title != null ? Text(title!) : null,
      centerTitle: centerTitle,
      actions: actions,
      automaticallyImplyLeading: hasBackButton,
      leading: hasBackButton && Navigator.canPop(context) 
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
            ) 
          : null,
    );
  }
}