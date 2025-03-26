// lib/core/firebase/seed_manager.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:foodam/firebase_seed.dart';
import 'package:foodam/core/service/logger_service.dart';

/// Simple manual seed manager - only seeds when user presses the button
class SeedManager {
  static final LoggerService _logger = LoggerService();
  
  /// Show a developer menu button in debug builds
  static Widget buildDebugButton(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();
    
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 16.0, bottom: 96.0),
        child: FloatingActionButton(
          heroTag: 'seedingFab',
          onPressed: () => showSeedingDialog(context),
          backgroundColor: Colors.amber,
          child: const Icon(Icons.data_array),
        ),
      ),
    );
  }
  
  /// Display a seed data confirmation dialog
  static Future<void> showSeedingDialog(BuildContext context) async {
    if (!kDebugMode) return;
    
    // Make sure context is valid
    if (!context.mounted) return;
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seed Firebase Database'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This will populate the Firebase database with test data.'),
            SizedBox(height: 10),
            Text(
              'Test login credentials after seeding will be:\n'
              'Email: johndoe@example.com\n'
              'Password: password'
            ),
            SizedBox(height: 10),
            Text('Would you like to proceed with seeding?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _performSeeding(context);
            },
            child: const Text('Seed Database'),
          ),
        ],
      ),
    );
  }
  
  /// Perform the actual seeding process
  static Future<void> _performSeeding(BuildContext context) async {
    if (!kDebugMode) return;
    
    // Verify context is still valid
    if (!context.mounted) return;
    
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    // Show loading indicator
    scaffoldMessenger.showSnackBar(
      const SnackBar(
        content: Text('Seeding Firebase database... This may take a moment.'),
        duration: Duration(seconds: 2),
      ),
    );
    
    try {
      _logger.i('Starting database seeding', tag: 'FIREBASE_SEED');
      
      // Perform seeding
      await FirebaseSeed.seedDatabase();
      
      _logger.i('Database seeding completed successfully', tag: 'FIREBASE_SEED');
      
      // Show success message if context is still valid
      if (context.mounted) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Firebase database successfully seeded with test data. You can use the test login credentials shown in the dialog.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      _logger.e('Error seeding database', error: e, tag: 'FIREBASE_SEED');
      
      // Show error message if context is still valid
      if (context.mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Error seeding Firebase database: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}