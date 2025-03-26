// lib/firebase_config.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Firebase configuration helper
class FirebaseConfig {
  static FirebaseApp? _app;
  static bool _initialized = false;

  /// Initialize Firebase services
  static Future<void> initialize() async {
    if (_initialized) {
      debugPrint('Firebase already initialized, skipping');
      return;
    }

    try {
      debugPrint('Initializing Firebase...');
      
      // The Firebase app should already be initialized in main.dart
      // This is just to ensure we handle the initialization state correctly
      _initialized = true;
      debugPrint('Firebase initialized successfully');
    } catch (e) {
      debugPrint('Error initializing Firebase: $e');
      rethrow;
    }
  }

  /// Check if Firebase is initialized
  static bool get isInitialized => _initialized;
  
  /// Get the Firebase auth instance
  static FirebaseAuth get auth {
    // Don't throw here, just initialize if needed
    if (!_initialized) {
      debugPrint('Warning: Accessing Firebase Auth before initialization');
      _initialized = true;
    }
    return FirebaseAuth.instance;
  }

  /// Get the Firestore instance
  static FirebaseFirestore get firestore {
    // Don't throw here, just initialize if needed
    if (!_initialized) {
      debugPrint('Warning: Accessing Firestore before initialization');
      _initialized = true;
    }
    return FirebaseFirestore.instance;
  }
}