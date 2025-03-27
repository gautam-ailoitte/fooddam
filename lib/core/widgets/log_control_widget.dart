// lib/core/widgets/log_control_widget.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:foodam/core/service/loggin_manager.dart';

/// A widget to control logging levels in debug mode
/// 
/// This widget can be placed in a debug menu or overlaid on the app
/// to allow dynamic control of logging levels during development.
class LogControlWidget extends StatefulWidget {
  final bool showAsDialog;

  const LogControlWidget({this.showAsDialog = false, super.key});

  /// Show the log control as a dialog
  static Future<void> showDialog(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (context) => const LogControlWidget(showAsDialog: true),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  @override
  State<LogControlWidget> createState() => _LogControlWidgetState();
}

class _LogControlWidgetState extends State<LogControlWidget> {
  final LoggingManager _loggingManager = LoggingManager();
  late AppLogLevel _currentLevel;
  
  @override
  void initState() {
    super.initState();
    _currentLevel = _loggingManager.currentLogLevel;
  }
  
  void _setLogLevel(AppLogLevel level) {
    setState(() {
      _currentLevel = level;
      _loggingManager.setLogLevel(level);
    });
    
    if (widget.showAsDialog) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Log level set to: ${level.name}'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // Only show in debug mode
    if (!kDebugMode && !widget.showAsDialog) {
      return const SizedBox.shrink();
    }
    
    final theme = Theme.of(context);
    
    return widget.showAsDialog
        ? _buildFullControl(theme)
        : _buildCompactControl(theme);
  }
  
  Widget _buildFullControl(ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Logging Controls',
            style: theme.textTheme.titleLarge,
          ),
        ),
        const Divider(),
        _buildLogLevelOption(theme, AppLogLevel.none, 'None - No logging'),
        _buildLogLevelOption(theme, AppLogLevel.critical, 'Critical - Only fatal errors'),
        _buildLogLevelOption(theme, AppLogLevel.error, 'Error - Errors and warnings'),
        _buildLogLevelOption(theme, AppLogLevel.info, 'Info - General app flow'),
        _buildLogLevelOption(theme, AppLogLevel.debug, 'Debug - API requests, state changes'),
        _buildLogLevelOption(theme, AppLogLevel.verbose, 'Verbose - All possible details'),
        const SizedBox(height: 20),
      ],
    );
  }
  
  Widget _buildCompactControl(ThemeData theme) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Log Level', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            DropdownButton<AppLogLevel>(
              value: _currentLevel,
              onChanged: (level) {
                if (level != null) _setLogLevel(level);
              },
              items: AppLogLevel.values.map((level) {
                return DropdownMenuItem<AppLogLevel>(
                  value: level,
                  child: Text(level.name),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLogLevelOption(ThemeData theme, AppLogLevel level, String description) {
    final isSelected = _currentLevel == level;
    
    return ListTile(
      title: Text(
        level.name.toUpperCase(),
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(description),
      leading: Radio<AppLogLevel>(
        value: level,
        groupValue: _currentLevel,
        onChanged: (value) {
          if (value != null) _setLogLevel(value);
        },
      ),
      tileColor: isSelected ? theme.colorScheme.primaryContainer.withOpacity(0.3) : null,
      onTap: () => _setLogLevel(level),
    );
  }
}