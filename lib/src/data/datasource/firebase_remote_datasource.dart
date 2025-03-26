import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
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
      debugPrint('Firestore operation error: $e');
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
      debugPrint('Login error: $e');
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
      debugPrint('Register error: $e');
      throw ServerException();
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('Logout error: $e');
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
      try {
        final userId = _getCurrentUserId();
        debugPrint('Getting addresses for user $userId');
        
        // Query addresses where userId field equals current user's ID
        final querySnapshot = await _addressesCollection
            .where('userId', isEqualTo: userId)
            .get();
        
        debugPrint('Found ${querySnapshot.docs.length} addresses for user');
        
        return querySnapshot.docs
            .map((doc) => AddressModel.fromJson({
                  ...doc.data() as Map<String, dynamic>,
                  'id': doc.id,
                }))
            .toList();
      } catch (e) {
        debugPrint('Error getting user addresses: $e');
        throw ServerException();
      }
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
      try {
        final docSnapshot = await _mealsCollection.doc(mealId).get();
        
        if (!docSnapshot.exists) {
          throw ServerException();
        }
        
        // Get all dishes for this meal
        final mealData = docSnapshot.data() as Map<String, dynamic>;
        final dishIds = List<String>.from(mealData['dishIds'] ?? []);
        
        List<DishModel> dishes = [];
        
        // Fetch each dish individually to handle potential missing dishes
        for (final dishId in dishIds) {
          try {
            final dish = await getDishById(dishId);
            dishes.add(dish);
          } catch (e) {
            // Skip dishes that fail to load
            debugPrint('Failed to load dish $dishId: $e');
          }
        }
        
        // Create a meal with available dishes
        return MealModel.fromJson({
          ...mealData,
          'id': docSnapshot.id,
          'dishes': dishes.map((dish) => dish.toJson()).toList(),
        });
      } catch (e) {
        debugPrint('Error getting meal $mealId: $e');
        throw ServerException();
      }
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
      try {
        final querySnapshot = await _packagesCollection.get();
        
        List<PackageModel> packages = [];
        for (var doc in querySnapshot.docs) {
          try {
            final packageData = doc.data() as Map<String, dynamic>;
            
            // Process slots to ensure they have the right format
            List<Map<String, dynamic>>? slots = [];
            if (packageData.containsKey('slots') && packageData['slots'] is List) {
              final rawSlots = packageData['slots'] as List;
              slots = rawSlots
                  .map((slot) => slot is Map ? Map<String, dynamic>.from(slot) : {}).cast<Map<String, dynamic>>()
                  .toList();
            }
            
            packages.add(PackageModel.fromJson({
              ...packageData,
              'id': doc.id,
              'slots': slots,
            }));
          } catch (e) {
            // Skip packages that fail to load
            debugPrint('Failed to load package ${doc.id}: $e');
          }
        }
        
        return packages;
      } catch (e) {
        debugPrint('Error getting all packages: $e');
        throw ServerException();
      }
    });
  }

  @override
  Future<PackageModel> getPackageById(String packageId) async {
    return _handleFirestoreOperation(() async {
      try {
        final docSnapshot = await _packagesCollection.doc(packageId).get();
        
        if (!docSnapshot.exists) {
          throw ServerException();
        }
        
        final packageData = docSnapshot.data() as Map<String, dynamic>;
        
        // Process slots to ensure they have the right format
        List<Map<String, dynamic>>? slots = [];
        if (packageData.containsKey('slots') && packageData['slots'] is List) {
          final rawSlots = packageData['slots'] as List;
          slots = rawSlots
              .map((slot) => slot is Map ? Map<String, dynamic>.from(slot) : {}).cast<Map<String, dynamic>>()
              .toList();
        }
        
        return PackageModel.fromJson({
          ...packageData,
          'id': docSnapshot.id,
          'slots': slots,
        });
      } catch (e) {
        debugPrint('Error getting package $packageId: $e');
        throw ServerException();
      }
    });
  }

  @override
  Future<List<SubscriptionModel>> getActiveSubscriptions() async {
    return _handleFirestoreOperation(() async {
      try {
        final userId = _getCurrentUserId();
        
        debugPrint('Getting subscriptions for user $userId');
        
        // Query all subscriptions first
        final querySnapshot = await _subscriptionsCollection.get();
        
        // Filter for the current user's subscriptions in-memory
        final userSubscriptions = querySnapshot.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['userId'] == userId;
        }).toList();
        
        debugPrint('Found ${userSubscriptions.length} subscriptions for user');
        
        // If no subscriptions, return empty list
        if (userSubscriptions.isEmpty) {
          return [];
        }
        
        List<SubscriptionModel> subscriptions = [];
        for (var doc in userSubscriptions) {
          try {
            final subscriptionData = doc.data() as Map<String, dynamic>;
            
            // Process address
            Map<String, dynamic> addressData;
            String addressId = subscriptionData['address'] as String? ?? '';
            
            try {
              DocumentSnapshot addressDoc = await _addressesCollection.doc(addressId).get();
              if (addressDoc.exists) {
                addressData = {
                  ...addressDoc.data() as Map<String, dynamic>,
                  'id': addressDoc.id,
                };
              } else {
                // Use placeholder if address not found
                addressData = {
                  'id': 'placeholder',
                  'street': 'Address not found',
                  'city': 'Unknown',
                  'state': 'Unknown',
                  'zipCode': '000000',
                  'coordinates': {
                    'latitude': 0,
                    'longitude': 0
                  }
                };
              }
            } catch (e) {
              // Fallback for address error
              addressData = {
                'id': 'placeholder',
                'street': 'Address not found',
                'city': 'Unknown',
                'state': 'Unknown',
                'zipCode': '000000',
                'coordinates': {
                  'latitude': 0,
                  'longitude': 0
                }
              };
              debugPrint('Error loading address: $e');
            }
            
            // Process slots
            List<Map<String, dynamic>>? slots = [];
            if (subscriptionData.containsKey('slots') && subscriptionData['slots'] is List) {
              final rawSlots = subscriptionData['slots'] as List;
              slots = rawSlots
                  .map((slot) => slot is Map ? Map<String, dynamic>.from(slot) : {}).cast<Map<String, dynamic>>()
                  .toList();
            }
            
            // Ensure pauseDetails is properly structured
            Map<String, dynamic> pauseDetails = {
              'isPaused': false,
            };
            if (subscriptionData.containsKey('pauseDetails') && subscriptionData['pauseDetails'] is Map) {
              pauseDetails = Map<String, dynamic>.from(subscriptionData['pauseDetails'] as Map);
            }
            
            // Ensure paymentDetails is properly structured
            Map<String, dynamic> paymentDetails = {
              'paymentStatus': 'pending',
            };
            if (subscriptionData.containsKey('paymentDetails') && subscriptionData['paymentDetails'] is Map) {
              paymentDetails = Map<String, dynamic>.from(subscriptionData['paymentDetails'] as Map);
            }
            
            // Create the subscription model with all data
            final subscription = SubscriptionModel.fromJson({
              ...subscriptionData,
              'id': doc.id,
              'address': addressData,
              'slots': slots,
              'pauseDetails': pauseDetails,
              'paymentDetails': paymentDetails,
            });
            
            subscriptions.add(subscription);
          } catch (e) {
            // Skip subscriptions that fail to load
            debugPrint('Failed to load subscription ${doc.id}: $e');
          }
        }
        
        return subscriptions;
      } catch (e) {
        debugPrint('Error getting active subscriptions: $e');
        throw ServerException();
      }
    });
  }

  @override
  Future<SubscriptionModel> getSubscriptionById(String subscriptionId) async {
    return _handleFirestoreOperation(() async {
      try {
        final userId = _getCurrentUserId();
        
        final docSnapshot = await _subscriptionsCollection.doc(subscriptionId).get();
        
        if (!docSnapshot.exists) {
          throw ServerException();
        }
        
        final subscriptionData = docSnapshot.data() as Map<String, dynamic>;
        
        // Confirm subscription belongs to the user or skip this check in development
        if (subscriptionData.containsKey('userId') && subscriptionData['userId'] != userId) {
          throw ServerException();
        }
        
        // Get address for this subscription
        String addressId = subscriptionData['address'] as String? ?? '';
        Map<String, dynamic> addressData;
        
        try {
          final addressDoc = await _addressesCollection.doc(addressId).get();
          
          if (addressDoc.exists) {
            addressData = {
              ...addressDoc.data() as Map<String, dynamic>,
              'id': addressDoc.id,
            };
          } else {
            // Use a placeholder if address not found
            addressData = {
              'id': 'placeholder',
              'street': 'Address not found',
              'city': 'Unknown',
              'state': 'Unknown',
              'zipCode': '000000',
              'coordinates': {
                'latitude': 0,
                'longitude': 0
              }
            };
          }
        } catch (e) {
          // Fallback for address error
          addressData = {
            'id': 'placeholder',
            'street': 'Address not found',
            'city': 'Unknown',
            'state': 'Unknown',
            'zipCode': '000000',
            'coordinates': {
              'latitude': 0,
              'longitude': 0
            }
          };
          debugPrint('Error loading address: $e');
        }
        
        // Process slots
        List<Map<String, dynamic>>? slots = [];
        if (subscriptionData.containsKey('slots') && subscriptionData['slots'] is List) {
          final rawSlots = subscriptionData['slots'] as List;
          slots = rawSlots
              .map((slot) => slot is Map ? Map<String, dynamic>.from(slot) : {}).cast<Map<String, dynamic>>()
              .toList();
        }
        
        // Ensure pauseDetails is properly structured
        Map<String, dynamic> pauseDetails = {
          'isPaused': false,
        };
        if (subscriptionData.containsKey('pauseDetails') && subscriptionData['pauseDetails'] is Map) {
          pauseDetails = Map<String, dynamic>.from(subscriptionData['pauseDetails'] as Map);
        }
        
        // Ensure paymentDetails is properly structured
        Map<String, dynamic> paymentDetails = {
          'paymentStatus': 'pending',
        };
        if (subscriptionData.containsKey('paymentDetails') && subscriptionData['paymentDetails'] is Map) {
          paymentDetails = Map<String, dynamic>.from(subscriptionData['paymentDetails'] as Map);
        }
        
        return SubscriptionModel.fromJson({
          ...subscriptionData,
          'id': docSnapshot.id,
          'address': addressData,
          'slots': slots,
          'pauseDetails': pauseDetails,
          'paymentDetails': paymentDetails,
        });
      } catch (e) {
        debugPrint('Error getting subscription $subscriptionId: $e');
        throw ServerException();
      }
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
      try {
        final userId = _getCurrentUserId();
        
        // Verify the package exists
        final packageDoc = await _packagesCollection.doc(packageId).get();
        if (!packageDoc.exists) {
          debugPrint('Package $packageId not found');
          throw ServerException();
        }
        
        // Verify the address exists
        final addressDoc = await _addressesCollection.doc(addressId).get();
        if (!addressDoc.exists) {
          debugPrint('Address $addressId not found');
          throw ServerException();
        }
        
        // Convert slots to expected format
        final List<Map<String, dynamic>> subscriptionSlots = slots.map((slot) => {
          'day': slot['day'],
          'timing': slot['timing'],
          'meal': slot['meal'],
        }).toList();
        
        // Calculate end date
        final endDate = startDate.add(Duration(days: durationDays));
        
        // Create the subscription document
        final subscriptionData = {
          'userId': userId,
          'package': packageId,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
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
          'createdAt': FieldValue.serverTimestamp(),
        };
        
        final docRef = await _subscriptionsCollection.add(subscriptionData);
        
        // Fetch the created subscription with all details
        final addressData = addressDoc.data() as Map<String, dynamic>;
        
        return SubscriptionModel.fromJson({
          ...subscriptionData,
          'id': docRef.id,
          'address': {
            ...addressData,
            'id': addressDoc.id,
          },
        });
      } catch (e) {
        debugPrint('Error creating subscription: $e');
        throw ServerException();
      }
    });
  }

  @override
  Future<void> updateSubscription(String subscriptionId, List<Map<String, String>> slots) async {
    return _handleFirestoreOperation(() async {
      try {
        final userId = _getCurrentUserId();
        
        // Verify the subscription exists and belongs to the user
        final docSnapshot = await _subscriptionsCollection.doc(subscriptionId).get();
        
        if (!docSnapshot.exists) {
          throw ServerException();
        }
        
        final subscriptionData = docSnapshot.data() as Map<String, dynamic>;
        
        // Skip ownership verification in development or verify it
        if (subscriptionData.containsKey('userId') && subscriptionData['userId'] != userId) {
          throw ServerException();
        }
        
        // Convert slots to expected format
        final updatedSlots = slots.map((slot) => {
          'day': slot['day'],
          'timing': slot['timing'],
          'meal': slot['meal'],
        }).toList();
        
        // Update the subscription
        await _subscriptionsCollection.doc(subscriptionId).update({
          'slots': updatedSlots,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        debugPrint('Error updating subscription $subscriptionId: $e');
        throw ServerException();
      }
    });
  }

  @override
  Future<void> cancelSubscription(String subscriptionId) async {
    return _handleFirestoreOperation(() async {
      try {
        final userId = _getCurrentUserId();
        
        // Verify the subscription exists
        final docSnapshot = await _subscriptionsCollection.doc(subscriptionId).get();
        
        if (!docSnapshot.exists) {
          throw ServerException();
        }
        
        final subscriptionData = docSnapshot.data() as Map<String, dynamic>;
        
        // Skip ownership verification in development or verify it
        if (subscriptionData.containsKey('userId') && subscriptionData['userId'] != userId) {
          throw ServerException();
        }
        
        // Update the subscription status
        await _subscriptionsCollection.doc(subscriptionId).update({
          'subscriptionStatus': 'cancelled',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        debugPrint('Error canceling subscription $subscriptionId: $e');
        throw ServerException();
      }
    });
  }

  @override
  Future<void> pauseSubscription(String subscriptionId, DateTime untilDate) async {
    return _handleFirestoreOperation(() async {
      try {
        final userId = _getCurrentUserId();
        
        // Verify the subscription exists
        final docSnapshot = await _subscriptionsCollection.doc(subscriptionId).get();
        
        if (!docSnapshot.exists) {
          throw ServerException();
        }
        
        final subscriptionData = docSnapshot.data() as Map<String, dynamic>;
        
        // Skip ownership verification in development or verify it
        if (subscriptionData.containsKey('userId') && subscriptionData['userId'] != userId) {
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
      } catch (e) {
        debugPrint('Error pausing subscription $subscriptionId: $e');
        throw ServerException();
      }
    });
  }

  @override
  Future<void> resumeSubscription(String subscriptionId) async {
    return _handleFirestoreOperation(() async {
      try {
        final userId = _getCurrentUserId();
        
        // Verify the subscription exists
        final docSnapshot = await _subscriptionsCollection.doc(subscriptionId).get();
        
        if (!docSnapshot.exists) {
          throw ServerException();
        }
        
        final subscriptionData = docSnapshot.data() as Map<String, dynamic>;
        
        // Skip ownership verification in development or verify it
        if (subscriptionData.containsKey('userId') && subscriptionData['userId'] != userId) {
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
      } catch (e) {
        debugPrint('Error resuming subscription $subscriptionId: $e');
        throw ServerException();
      }
    });
  }
}