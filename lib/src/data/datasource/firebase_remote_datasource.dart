// lib/src/data/datasource/firebase_remote_data_source.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:foodam/core/errors/execption.dart';
import 'package:foodam/src/data/datasource/remote_data_source.dart';
import 'package:foodam/src/data/model/address_model.dart';
import 'package:foodam/src/data/model/dish_model.dart';
import 'package:foodam/src/data/model/meal_model.dart';
import 'package:foodam/src/data/model/package_model.dart';
import 'package:foodam/src/data/model/subscription_model.dart';
import 'package:foodam/src/data/model/user_model.dart';

class FirebaseRemoteDataSource implements RemoteDataSource {
  final FirebaseFirestore _firestore;
  final firebase_auth.FirebaseAuth _auth;

  // Collection references for easier access
  late final CollectionReference _usersCollection;
  late final CollectionReference _addressesCollection;
  late final CollectionReference _mealsCollection;
  late final CollectionReference _dishesCollection;
  late final CollectionReference _packagesCollection;
  late final CollectionReference _subscriptionsCollection;

  FirebaseRemoteDataSource({
    required FirebaseFirestore firestore,
    required firebase_auth.FirebaseAuth auth,
  }) : _firestore = firestore,
       _auth = auth {
    // Initialize collection references
    _usersCollection = _firestore.collection('users');
    _addressesCollection = _firestore.collection('addresses');
    _mealsCollection = _firestore.collection('meals');
    _dishesCollection = _firestore.collection('dishes');
    _packagesCollection = _firestore.collection('packages');
    _subscriptionsCollection = _firestore.collection('subscriptions');
  }

  // Helper method to get current user ID
  String _getCurrentUserId() {
    final user = _auth.currentUser;
    if (user == null) {
      throw ServerException();
    }
    return user.uid;
  }

  // Helper method to handle Firestore errors
  Future<T> _handleFirestoreOperation<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<String> login(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final token = await userCredential.user?.getIdToken() ?? '';
      return token;
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<String> register(String email, String password, String phone) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Create user document
      await _usersCollection.doc(userCredential.user!.uid).set({
        'id': userCredential.user!.uid,
        'email': email,
        'phone': phone,
        'role': 'user', // Default role
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      final token = await userCredential.user?.getIdToken() ?? '';
      return token;
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    return _handleFirestoreOperation(() async {
      final userId = _getCurrentUserId();
      final docSnapshot = await _usersCollection.doc(userId).get();
      
      if (!docSnapshot.exists) {
        throw ServerException();
      }
      
      final userData = docSnapshot.data() as Map<String, dynamic>;
      return UserModel.fromJson({
        ...userData,
        'id': docSnapshot.id,
      });
    });
  }

  @override
  Future<List<AddressModel>> getUserAddresses() async {
    return _handleFirestoreOperation(() async {
      final userId = _getCurrentUserId();
      final querySnapshot = await _addressesCollection
          .where('userId', isEqualTo: userId)
          .get();
      
      return querySnapshot.docs
          .map((doc) => AddressModel.fromJson({
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }))
          .toList();
    });
  }

  @override
  Future<AddressModel> addAddress(AddressModel address) async {
    return _handleFirestoreOperation(() async {
      final userId = _getCurrentUserId();
      
      // Create a map from the address model but without the ID
      final addressData = address.toJson();
      addressData.remove('id'); // Remove the ID as Firestore will generate one
      addressData['userId'] = userId; // Add user ID reference
      
      // Add the address document
      final docRef = await _addressesCollection.add(addressData);
      
      // Fetch the created document to return
      final docSnapshot = await docRef.get();
      return AddressModel.fromJson({
        ...docSnapshot.data() as Map<String, dynamic>,
        'id': docSnapshot.id,
      });
    });
  }

  @override
  Future<void> updateAddress(AddressModel address) async {
    return _handleFirestoreOperation(() async {
      final userId = _getCurrentUserId();
      
      // Verify the address belongs to the user
      final docSnapshot = await _addressesCollection.doc(address.id).get();
      if (!docSnapshot.exists || (docSnapshot.data() as Map<String, dynamic>)['userId'] != userId) {
        throw ServerException();
      }
      
      // Update the address
      final addressData = address.toJson();
      addressData.remove('id'); // Remove ID from the data to update
      
      await _addressesCollection.doc(address.id).update(addressData);
    });
  }

  @override
  Future<void> deleteAddress(String addressId) async {
    return _handleFirestoreOperation(() async {
      final userId = _getCurrentUserId();
      
      // Verify the address belongs to the user
      final docSnapshot = await _addressesCollection.doc(addressId).get();
      if (!docSnapshot.exists || (docSnapshot.data() as Map<String, dynamic>)['userId'] != userId) {
        throw ServerException();
      }
      
      await _addressesCollection.doc(addressId).delete();
    });
  }

  @override
  Future<MealModel> getMealById(String mealId) async {
    return _handleFirestoreOperation(() async {
      final docSnapshot = await _mealsCollection.doc(mealId).get();
      
      if (!docSnapshot.exists) {
        throw ServerException();
      }
      
      // Get all dishes for this meal
      final mealData = docSnapshot.data() as Map<String, dynamic>;
      final dishIds = List<String>.from(mealData['dishIds'] ?? []);
      
      // Fetch all dishes in parallel
      final dishes = await Future.wait(
        dishIds.map((dishId) => getDishById(dishId)),
      );
      
      // Create a meal with dishes
      return MealModel.fromJson({
        ...mealData,
        'id': docSnapshot.id,
        'dishes': dishes.map((dish) => dish.toJson()).toList(),
      });
    });
  }

  @override
  Future<DishModel> getDishById(String dishId) async {
    return _handleFirestoreOperation(() async {
      final docSnapshot = await _dishesCollection.doc(dishId).get();
      
      if (!docSnapshot.exists) {
        throw ServerException();
      }
      
      return DishModel.fromJson({
        ...docSnapshot.data() as Map<String, dynamic>,
        'id': docSnapshot.id,
      });
    });
  }

  @override
  Future<List<PackageModel>> getAllPackages() async {
    return _handleFirestoreOperation(() async {
      final querySnapshot = await _packagesCollection.get();
      
      List<PackageModel> packages = [];
      for (var doc in querySnapshot.docs) {
        final packageData = doc.data() as Map<String, dynamic>;
        
        // Fetch all slots with their meals
        final List<Map<String, dynamic>> slots = List<Map<String, dynamic>>.from(packageData['slots'] ?? []);
        
        // For each slot that has a mealId, fetch the meal details
        for (int i = 0; i < slots.length; i++) {
          if (slots[i].containsKey('meal') && slots[i]['meal'] is String) {
            try {
              final mealId = slots[i]['meal'];
              final meal = await getMealById(mealId);
              slots[i]['meal'] = meal.toJson();
            } catch (e) {
              // If meal fetch fails, keep the mealId
            }
          }
        }
        
        packages.add(PackageModel.fromJson({
          ...packageData,
          'id': doc.id,
          'slots': slots,
        }));
      }
      
      return packages;
    });
  }

  @override
  Future<PackageModel> getPackageById(String packageId) async {
    return _handleFirestoreOperation(() async {
      final docSnapshot = await _packagesCollection.doc(packageId).get();
      
      if (!docSnapshot.exists) {
        throw ServerException();
      }
      
      final packageData = docSnapshot.data() as Map<String, dynamic>;
      
      // Fetch all slots with their meals
      final List<Map<String, dynamic>> slots = List<Map<String, dynamic>>.from(packageData['slots'] ?? []);
      
      // For each slot that has a mealId, fetch the meal details
      for (int i = 0; i < slots.length; i++) {
        if (slots[i].containsKey('meal') && slots[i]['meal'] is String) {
          try {
            final mealId = slots[i]['meal'];
            final meal = await getMealById(mealId);
            slots[i]['meal'] = meal.toJson();
          } catch (e) {
            // If meal fetch fails, keep the mealId
          }
        }
      }
      
      return PackageModel.fromJson({
        ...packageData,
        'id': docSnapshot.id,
        'slots': slots,
      });
    });
  }

  @override
 Future<List<SubscriptionModel>> getActiveSubscriptions() async {
  return _handleFirestoreOperation(() async {
    final userId = _getCurrentUserId();
    
    final querySnapshot = await _subscriptionsCollection
        .where('userId', isEqualTo: userId)
        .where('subscriptionStatus', whereIn: ['active', 'pending', 'paused'])
        .get();
    
    List<SubscriptionModel> subscriptions = [];
    for (var doc in querySnapshot.docs) {
      final subscriptionData = doc.data() as Map<String, dynamic>;
      
      // Fetch the address for this subscription
      final addressId = subscriptionData['address'];
      final addressDoc = await _addressesCollection.doc(addressId).get();
      
      if (!addressDoc.exists) {
        continue; // Skip this subscription if address not found
      }
      
      // Fetch all slots with their meals
      final List<Map<String, dynamic>> slots = 
          List<Map<String, dynamic>>.from(subscriptionData['slots'] ?? []);
      
      // Optional: Fetch meal details for each slot if needed
      for (int i = 0; i < slots.length; i++) {
        if (slots[i].containsKey('meal') && slots[i]['meal'] is String) {
          try {
            final mealId = slots[i]['meal'];
            final meal = await getMealById(mealId);
            slots[i]['meal'] = meal.toJson();
          } catch (e) {
            // If meal fetch fails, keep the mealId
          }
        }
      }
      
      // Now use the processed slots
      subscriptions.add(SubscriptionModel.fromJson({
        ...subscriptionData,
        'id': doc.id,
        'address': {
          ...addressDoc.data() as Map<String, dynamic>,
          'id': addressDoc.id,
        },
        'slots': slots, // Use the processed slots
      }));
    }
    
    return subscriptions;
  });
}
  @override
  Future<SubscriptionModel> getSubscriptionById(String subscriptionId) async {
    return _handleFirestoreOperation(() async {
      final userId = _getCurrentUserId();
      
      final docSnapshot = await _subscriptionsCollection.doc(subscriptionId).get();
      
      if (!docSnapshot.exists) {
        throw ServerException();
      }
      
      final subscriptionData = docSnapshot.data() as Map<String, dynamic>;
      
      // Verify the subscription belongs to the user
      if (subscriptionData['userId'] != userId) {
        throw ServerException();
      }
      
      // Fetch the address for this subscription
      final addressId = subscriptionData['address'];
      final addressDoc = await _addressesCollection.doc(addressId).get();
      
      if (!addressDoc.exists) {
        throw ServerException();
      }
      
      return SubscriptionModel.fromJson({
        ...subscriptionData,
        'id': docSnapshot.id,
        'address': {
          ...addressDoc.data() as Map<String, dynamic>,
          'id': addressDoc.id,
        },
      });
    });
  }

  @override
  Future<SubscriptionModel> createSubscription({
    required String packageId,
    required DateTime startDate,
    required int durationDays,
    required String addressId,
    String? instructions,
    required List<Map<String, String>> slots,
  }) async {
    return _handleFirestoreOperation(() async {
      final userId = _getCurrentUserId();
      
      // Verify the package exists
      final packageDoc = await _packagesCollection.doc(packageId).get();
      if (!packageDoc.exists) {
        throw ServerException();
      }
      
      // Verify the address exists and belongs to the user
      final addressDoc = await _addressesCollection.doc(addressId).get();
      if (!addressDoc.exists || (addressDoc.data() as Map<String, dynamic>)['userId'] != userId) {
        throw ServerException();
      }
      
      // Assign meals to slots from the package
      final packageData = packageDoc.data() as Map<String, dynamic>;
      final packageSlots = List<Map<String, dynamic>>.from(packageData['slots'] ?? []);
      
      final List<Map<String, dynamic>> subscriptionSlots = [];
      
      // Match requested slots with package slots to assign meals
      for (var requestedSlot in slots) {
        final day = requestedSlot['day'];
        final timing = requestedSlot['timing'];
        
        // Find matching slot in package
        final matchingSlot = packageSlots.firstWhere(
          (packageSlot) => 
            packageSlot['day'] == day && 
            packageSlot['timing'] == timing,
          orElse: () => {},
        );
        
        if (matchingSlot.isNotEmpty && matchingSlot.containsKey('meal')) {
          final mealId = matchingSlot['meal'] is Map 
              ? matchingSlot['meal']['id'] 
              : matchingSlot['meal'];
          
          subscriptionSlots.add({
            'day': day,
            'timing': timing,
            'meal': mealId,
          });
        }
      }
      
      // Create the subscription
      final subscriptionData = {
        'userId': userId,
        'package': packageId,
        'startDate': startDate.toIso8601String(),
        'durationDays': durationDays,
        'address': addressId,
        'instructions': instructions ?? '',
        'slots': subscriptionSlots,
        'paymentDetails': {
          'paymentStatus': 'pending',
        },
        'pauseDetails': {
          'isPaused': false,
        },
        'subscriptionStatus': 'pending',
        'cloudKitchen': '',
        'createdAt': FieldValue.serverTimestamp(),
      };
      
      final docRef = await _subscriptionsCollection.add(subscriptionData);
      
      // Fetch the created subscription with the address
      final addressData = addressDoc.data() as Map<String, dynamic>;
      
      return SubscriptionModel.fromJson({
        ...subscriptionData,
        'id': docRef.id,
        'address': {
          ...addressData,
          'id': addressDoc.id,
        },
      });
    });
  }

  @override
  Future<void> updateSubscription(String subscriptionId, List<Map<String, String>> slots) async {
    return _handleFirestoreOperation(() async {
      final userId = _getCurrentUserId();
      
      // Verify the subscription exists and belongs to the user
      final docSnapshot = await _subscriptionsCollection.doc(subscriptionId).get();
      
      if (!docSnapshot.exists || (docSnapshot.data() as Map<String, dynamic>)['userId'] != userId) {
        throw ServerException();
      }
      
      // Get the package ID from the subscription
      final subscriptionData = docSnapshot.data() as Map<String, dynamic>;
      final packageId = subscriptionData['package'];
      
      // Fetch the package to get available meals
      final packageDoc = await _packagesCollection.doc(packageId).get();
      if (!packageDoc.exists) {
        throw ServerException();
      }
      
      final packageData = packageDoc.data() as Map<String, dynamic>;
      final packageSlots = List<Map<String, dynamic>>.from(packageData['slots'] ?? []);
      
      final List<Map<String, dynamic>> updatedSlots = [];
      
      // Match requested slots with package slots to assign meals
      for (var requestedSlot in slots) {
        final day = requestedSlot['day'];
        final timing = requestedSlot['timing'];
        
        // Find matching slot in package
        final matchingSlot = packageSlots.firstWhere(
          (packageSlot) => 
            packageSlot['day'] == day && 
            packageSlot['timing'] == timing,
          orElse: () => {},
        );
        
        if (matchingSlot.isNotEmpty && matchingSlot.containsKey('meal')) {
          final mealId = matchingSlot['meal'] is Map 
              ? matchingSlot['meal']['id'] 
              : matchingSlot['meal'];
          
          updatedSlots.add({
            'day': day,
            'timing': timing,
            'meal': mealId,
          });
        }
      }
      
      // Update the subscription
      await _subscriptionsCollection.doc(subscriptionId).update({
        'slots': updatedSlots,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Future<void> cancelSubscription(String subscriptionId) async {
    return _handleFirestoreOperation(() async {
      final userId = _getCurrentUserId();
      
      // Verify the subscription exists and belongs to the user
      final docSnapshot = await _subscriptionsCollection.doc(subscriptionId).get();
      
      if (!docSnapshot.exists || (docSnapshot.data() as Map<String, dynamic>)['userId'] != userId) {
        throw ServerException();
      }
      
      // Update the subscription status
      await _subscriptionsCollection.doc(subscriptionId).update({
        'subscriptionStatus': 'cancelled',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Future<void> pauseSubscription(String subscriptionId, DateTime untilDate) async {
    return _handleFirestoreOperation(() async {
      final userId = _getCurrentUserId();
      
      // Verify the subscription exists and belongs to the user
      final docSnapshot = await _subscriptionsCollection.doc(subscriptionId).get();
      
      if (!docSnapshot.exists || (docSnapshot.data() as Map<String, dynamic>)['userId'] != userId) {
        throw ServerException();
      }
      
      // Update the subscription
      await _subscriptionsCollection.doc(subscriptionId).update({
        'pauseDetails': {
          'isPaused': true,
          'untilDate': untilDate.toIso8601String(),
        },
        'subscriptionStatus': 'paused',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Future<void> resumeSubscription(String subscriptionId) async {
    return _handleFirestoreOperation(() async {
      final userId = _getCurrentUserId();
      
      // Verify the subscription exists and belongs to the user
      final docSnapshot = await _subscriptionsCollection.doc(subscriptionId).get();
      
      if (!docSnapshot.exists || (docSnapshot.data() as Map<String, dynamic>)['userId'] != userId) {
        throw ServerException();
      }
      
      // Update the subscription
      await _subscriptionsCollection.doc(subscriptionId).update({
        'pauseDetails': {
          'isPaused': false,
        },
        'subscriptionStatus': 'active',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }
}