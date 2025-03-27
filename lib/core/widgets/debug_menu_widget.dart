// lib/core/widgets/debug_menu_widget.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_constants.dart';
import 'package:foodam/core/widgets/log_control_widget.dart';

/// A debug menu widget for development purposes
/// 
/// This widget provides a floating action button that opens a debug menu
/// with various development tools and settings.
class DebugMenuWidget extends StatelessWidget {
  final Widget child;
  
  const DebugMenuWidget({required this.child, super.key});
  
  @override
  Widget build(BuildContext context) {
    // Only show in debug mode
    if (!kDebugMode) {
      return child;
    }
    
    // Return the child directly wrapped with the Material-based fab
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          child,
          SafeArea(
            child: Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 16, bottom: 80),
                child: FloatingActionButton(
                  heroTag: 'debugMenuFab',
                  onPressed: () {
                    // Show a simpler bottom sheet for debug menu
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => const SafeArea(
                        child: LogControlWidget(showAsDialog: true),
                      ),
                    );
                  },
                  backgroundColor: Colors.red.withOpacity(0.8),
                  mini: true,
                  child: const Icon(Icons.bug_report),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}