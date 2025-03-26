// lib/firebase_seed.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:foodam/mock_data.dart';

/// Utility class to seed Firebase with initial data for development/testing
class FirebaseSeed {
  /// Seed Firebase with mock data
  static Future<void> seedDatabase() async {
    try {
      // Only seed data in debug mode
      if (!kDebugMode) {
        debugPrint('Seeding is only available in debug mode');
        return;
      }

      debugPrint('Starting Firebase data seeding...');
      
      // Ensure Firebase is initialized by checking instance availability
      final FirebaseFirestore firestore;
      final FirebaseAuth auth;
      
      try {
        firestore = FirebaseFirestore.instance;
        auth = FirebaseAuth.instance;
      } catch (e) {
        debugPrint('Firebase not properly initialized: $e');
        throw Exception('Firebase not properly initialized. Make sure FirebaseCore.initialize() is called first.');
      }
      
      // Create test user if it doesn't exist
      User? testUser;
      try {
        final userCredential = await auth.createUserWithEmailAndPassword(
          email: 'johndoe@example.com',
          password: 'password',
        );
        testUser = userCredential.user;
        debugPrint('Created test user: ${testUser?.uid}');
      } catch (e) {
        // User might already exist, try to sign in
        try {
          final userCredential = await auth.signInWithEmailAndPassword(
            email: 'johndoe@example.com',
            password: 'password',
          );
          testUser = userCredential.user;
          debugPrint('Signed in as test user: ${testUser?.uid}');
        } catch (e) {
          debugPrint('Error creating/signing in test user: $e');
          return;
        }
      }

      if (testUser == null) {
        debugPrint('Failed to get a valid test user');
        return;
      }

      // Define collection references
      final usersRef = firestore.collection('users');
      final dishesRef = firestore.collection('dishes');
      final mealsRef = firestore.collection('meals');
      final packagesRef = firestore.collection('packages');
      final addressesRef = firestore.collection('addresses');
      final subscriptionsRef = firestore.collection('subscriptions');
      
      // Start a batch operation for better performance
      final batch = firestore.batch();

      // Seed users collection
      batch.set(
        usersRef.doc(testUser.uid),
        {
          ...MockData.currentUser,
          'id': testUser.uid,
          'email': 'johndoe@example.com',
        },
        SetOptions(merge: true),
      );
      debugPrint('Added user data');
      
      // Seed dishes - use the existing dishes from MockData
      for (final dish in MockData.dishes) {
        final dishId = dish['id'];
        final dishData = Map<String, dynamic>.from(dish);
        dishData.remove('id'); // Firestore will use the ID in the document reference
        
        batch.set(dishesRef.doc(dishId), dishData);
      }
      debugPrint('Added dishes data');
      
      // Seed meals
      for (final meal in MockData.meals) {
        final mealId = meal['id'];
        final mealData = Map<String, dynamic>.from(meal);
        
        // Extract dish IDs
        final dishes = mealData['dishes'] as List;
        final dishIds = dishes.map((dish) => dish['id']).toList();
        
        // Store dish IDs instead of full dish objects
        mealData.remove('dishes');
        mealData['dishIds'] = dishIds;
        mealData.remove('id'); // Firestore will use the ID in the document reference
        
        batch.set(mealsRef.doc(mealId), mealData);
      }
      debugPrint('Added meals data');
      
      // Seed packages
      for (final package in MockData.packages) {
        final packageId = package['id'];
        final packageData = Map<String, dynamic>.from(package);
        
        // Simplify slots to store only meal IDs
        if (packageData.containsKey('slots') && packageData['slots'] is List) {
          final slots = packageData['slots'] as List;
          for (int i = 0; i < slots.length; i++) {
            final slot = slots[i] as Map<String, dynamic>;
            if (slot.containsKey('meal') && slot['meal'] is Map) {
              slots[i]['meal'] = slot['meal']['id'];
            }
          }
        }
        
        packageData.remove('id'); // Firestore will use the ID in the document reference
        
        batch.set(packagesRef.doc(packageId), packageData);
      }
      debugPrint('Added packages data');
      
      // Seed addresses for the test user
      for (final address in MockData.addresses) {
        final addressId = address['id'];
        final addressData = Map<String, dynamic>.from(address);
        addressData.remove('id'); // Firestore will use the ID in the document reference
        addressData['userId'] = testUser.uid; // Add user reference
        
        batch.set(addressesRef.doc(addressId), addressData);
      }
      debugPrint('Added addresses data');
      
      // Seed subscriptions for the test user
      for (final subscription in MockData.activeSubscriptions) {
        final subscriptionId = subscription['id'];
        final subscriptionData = Map<String, dynamic>.from(subscription);
        
        // Simplify slots to store only meal IDs
        if (subscriptionData.containsKey('slots') && subscriptionData['slots'] is List) {
          final slots = subscriptionData['slots'] as List;
          for (int i = 0; i < slots.length; i++) {
            final slot = slots[i] as Map<String, dynamic>;
            if (slot.containsKey('meal') && slot['meal'] is Map) {
              slots[i]['meal'] = slot['meal']['id'];
            }
          }
        }
        
        subscriptionData.remove('id'); // Firestore will use the ID in the document reference
        subscriptionData['userId'] = testUser.uid; // Add user reference
        
        batch.set(subscriptionsRef.doc(subscriptionId), subscriptionData);
      }
      debugPrint('Added subscriptions data');

      // Commit the batch
      await batch.commit();
      debugPrint('Firebase data seeding completed successfully');
    } catch (e) {
      debugPrint('Error seeding Firebase data: $e');
      rethrow; // Re-throw to allow the UI to handle the error
    }
  }
}