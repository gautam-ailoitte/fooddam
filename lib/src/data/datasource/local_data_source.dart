// lib/src/data/datasource/local_data_source.dart
import 'dart:convert';
import 'package:foodam/core/errors/execption.dart';
import 'package:foodam/src/domain/entities/address_entity.dart';
import 'package:foodam/src/domain/entities/dish_entity.dart';
import 'package:foodam/src/domain/entities/user_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class LocalDataSource {
  // User related
  Future<void> cacheUser(User user);
  Future<User> getLastLoggedInUser();
  Future<bool> isUserLoggedIn();
  Future<void> clearUserCache();
  
  // Address related
  Future<void> cacheAddresses(List<Address> addresses);
  Future<List<Address>> getCachedAddresses();
  
  // Subscription draft
  Future<void> cacheDraftSubscription(Map<String, dynamic> subscription);
  Future<Map<String, dynamic>?> getDraftSubscription();
  Future<void> clearDraftSubscription();
}

class LocalDataSourceImpl implements LocalDataSource {
  final SharedPreferences sharedPreferences;

  LocalDataSourceImpl({required this.sharedPreferences});

  // Keys for SharedPreferences
  static const String cachedUserKey = 'CACHED_USER';
  static const String tokenKey = 'CACHED_TOKEN';
  static const String cachedAddressesKey = 'CACHED_ADDRESSES';
  static const String draftSubscriptionKey = 'DRAFT_SUBSCRIPTION';

  @override
  Future<void> cacheUser(User user) async {
    final userJson = {
      'id': user.id,
      'firstName': user.firstName,
      'lastName': user.lastName,
      'email': user.email,
      'phone': user.phone,
      'address': {
        'street': user.address.street,
        'city': user.address.city,
        'state': user.address.state,
        'zipCode': user.address.zipCode,
        'country': user.address.country,
        'coordinates': user.address.coordinates != null
            ? {
                'latitude': user.address.coordinates!.latitude,
                'longitude': user.address.coordinates!.longitude,
              }
            : null,
      },
      'dietaryPreferences': user.dietaryPreferences?.map((pref) => pref.toString().split('.').last).toList(),
      'allergies': user.allergies,
      'role': user.role.toString().split('.').last,
      'createdAt': user.createdAt.toIso8601String(),
      'updatedAt': user.updatedAt?.toIso8601String(),
    };
    
    await sharedPreferences.setString(cachedUserKey, json.encode(userJson));
    
    // Also set a token to indicate user is logged in
    await sharedPreferences.setString(tokenKey, 'mock_token_${user.id}');
  }

  @override
  Future<User> getLastLoggedInUser() async {
    final jsonString = sharedPreferences.getString(cachedUserKey);
    if (jsonString == null) {
      throw CacheException();
    }
    
    final userMap = json.decode(jsonString);
    
    final addressMap = userMap['address'];
    final address = Address(
      street: addressMap['street'],
      city: addressMap['city'],
      state: addressMap['state'],
      zipCode: addressMap['zipCode'],
      country: addressMap['country'],
      coordinates: addressMap['coordinates'] != null
          ? Coordinates(
              latitude: addressMap['coordinates']['latitude'],
              longitude: addressMap['coordinates']['longitude'],
            )
          : null,
    );
    
    final dietaryPreferencesStrings = userMap['dietaryPreferences'] != null 
        ? List<String>.from(userMap['dietaryPreferences'])
        : null;
    
    final dietaryPreferences = dietaryPreferencesStrings?.map((prefString) {
      return DietaryPreference.values.firstWhere(
        (pref) => pref.toString().split('.').last == prefString,
      );
    }).toList();
    
    final roleString = userMap['role'];
    final role = UserRole.values.firstWhere(
      (r) => r.toString().split('.').last == roleString,
    );
    
    return User(
      id: userMap['id'],
      firstName: userMap['firstName'],
      lastName: userMap['lastName'],
      email: userMap['email'],
      phone: userMap['phone'],
      address: address,
      dietaryPreferences: dietaryPreferences,
      allergies: userMap['allergies'] != null 
          ? List<String>.from(userMap['allergies'])
          : null,
      role: role,
      createdAt: DateTime.parse(userMap['createdAt']),
      updatedAt: userMap['updatedAt'] != null 
          ? DateTime.parse(userMap['updatedAt'])
          : null,
    );
  }

  @override
  Future<bool> isUserLoggedIn() async {
    return sharedPreferences.containsKey(tokenKey);
  }

  @override
  Future<void> clearUserCache() async {
    await sharedPreferences.remove(cachedUserKey);
    await sharedPreferences.remove(tokenKey);
  }

  @override
  Future<void> cacheAddresses(List<Address> addresses) async {
    final addressesJson = addresses.map((address) => {
      'street': address.street,
      'city': address.city,
      'state': address.state,
      'zipCode': address.zipCode,
      'country': address.country,
      'coordinates': address.coordinates != null
          ? {
              'latitude': address.coordinates!.latitude,
              'longitude': address.coordinates!.longitude,
            }
          : null,
    }).toList();
    
    await sharedPreferences.setString(cachedAddressesKey, json.encode(addressesJson));
  }

  @override
  Future<List<Address>> getCachedAddresses() async {
    final jsonString = sharedPreferences.getString(cachedAddressesKey);
    if (jsonString == null) {
      return [];
    }
    
    final List<dynamic> addressesList = json.decode(jsonString);
    
    return addressesList.map((addressMap) {
      return Address(
        street: addressMap['street'],
        city: addressMap['city'],
        state: addressMap['state'],
        zipCode: addressMap['zipCode'],
        country: addressMap['country'],
        coordinates: addressMap['coordinates'] != null
            ? Coordinates(
                latitude: addressMap['coordinates']['latitude'],
                longitude: addressMap['coordinates']['longitude'],
              )
            : null,
      );
    }).toList();
  }

  @override
  Future<void> cacheDraftSubscription(Map<String, dynamic> subscription) async {
    await sharedPreferences.setString(draftSubscriptionKey, json.encode(subscription));
  }

  @override
  Future<Map<String, dynamic>?> getDraftSubscription() async {
    final jsonString = sharedPreferences.getString(draftSubscriptionKey);
    if (jsonString == null) {
      return null;
    }
    
    return json.decode(jsonString);
  }

  @override
  Future<void> clearDraftSubscription() async {
    await sharedPreferences.remove(draftSubscriptionKey);
  }
}