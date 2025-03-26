// lib/firebase_config.dart - ensure this is updated like this

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
      
      // Initialize the Firebase app
      _app = await Firebase.initializeApp();
      
      // Verify Firebase Auth and Firestore are accessible
      final auth = FirebaseAuth.instance;
      final firestore = FirebaseFirestore.instance;
      
      // Enable Firestore offline persistence
      await firestore.enablePersistence();
      
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
    if (!_initialized) {
      throw Exception('Firebase not initialized. Call initialize() first.');
    }
    return FirebaseAuth.instance;
  }

  /// Get the Firestore instance
  static FirebaseFirestore get firestore {
    if (!_initialized) {
      throw Exception('Firebase not initialized. Call initialize() first.');
    }
    return FirebaseFirestore.instance;
  }
}