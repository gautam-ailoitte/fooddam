import 'dart:convert';

import 'package:foodam/core/constants/app_constants.dart';
import 'package:foodam/core/errors/execption.dart';
import 'package:foodam/core/service/storage_service.dart';
import 'package:foodam/mock_data.dart';
import 'package:foodam/src/data/model/address_model.dart';
import 'package:foodam/src/data/model/package_model.dart';
import 'package:foodam/src/data/model/subscription_model.dart';
import 'package:foodam/src/data/model/user_model.dart';
abstract class LocalDataSource {
  // Auth
  Future<void> cacheToken(String token);
  Future<String?> getToken();
  Future<void> clearToken();
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getUser();

  // Addresses
  Future<void> cacheAddresses(List<AddressModel> addresses);
  Future<List<AddressModel>?> getAddresses();

  // Packages
  Future<void> cachePackages(List<PackageModel> packages);
  Future<List<PackageModel>?> getPackages();
  Future<void> cachePackage(PackageModel package);
  Future<PackageModel?> getPackage(String packageId);

  // Subscriptions
  Future<void> cacheActiveSubscriptions(List<SubscriptionModel> subscriptions);
  Future<List<SubscriptionModel>?> getActiveSubscriptions();
  Future<void> cacheSubscription(SubscriptionModel subscription);
  Future<SubscriptionModel?> getSubscription(String subscriptionId);

  // Draft selections
  Future<void> cacheDraftSubscription(Map<String, dynamic> subscription);
  Future<Map<String, dynamic>?> getDraftSubscription();
  Future<void> clearDraftSubscription();
}

class LocalDataSourceImpl implements LocalDataSource {
  final StorageService storageService;
  
  // Keys
  static const String _tokenKey = AppConstants.tokenKey;
  static const String _userKey = AppConstants.userKey;
  static const String _addressesKey = 'CACHED_ADDRESSES';
  static const String _packagesKey = 'CACHED_PACKAGES';
  static const String _packagePrefix = 'CACHED_PACKAGE_';
  static const String _activeSubscriptionsKey = 'CACHED_ACTIVE_SUBSCRIPTIONS';
  static const String _subscriptionPrefix = 'CACHED_SUBSCRIPTION_';
  static const String _draftSubscriptionKey = 'CACHED_DRAFT_SUBSCRIPTION';
  
  // Flag to initialize with mock data - helpful for development
  final bool initWithMockData;

  LocalDataSourceImpl({
    required this.storageService,
    this.initWithMockData = true,
  }) {
    if (initWithMockData) {
      _initializeMockData();
    }
  }
  
  // Initialize storage with mock data for faster development
  Future<void> _initializeMockData() async {
    // Only init if data doesn't exist yet
    if (!(await _hasInitializedMockData())) {
      try {
        // Cache token
        await storageService.setString(_tokenKey, MockData.mockToken);
        
        // Cache user
        await storageService.setString(_userKey, json.encode(MockData.currentUser));
        
        // Cache addresses
        final addressesJson = json.encode(MockData.addresses);
        await storageService.setString(_addressesKey, addressesJson);
        
        // Cache packages
        final packagesJson = json.encode(MockData.packages);
        await storageService.setString(_packagesKey, packagesJson);
        
        // Cache active subscriptions
        final subscriptionsJson = json.encode(MockData.activeSubscriptions);
        await storageService.setString(_activeSubscriptionsKey, subscriptionsJson);
        
        // Cache individual packages
        for (var package in MockData.packages) {
          await storageService.setString(_packagePrefix + package['id'], json.encode(package));
        }
        
        // Cache individual subscriptions
        for (var subscription in MockData.activeSubscriptions) {
          await storageService.setString(_subscriptionPrefix + subscription['id'], json.encode(subscription));
        }
        
        // Set flag to indicate mock data was initialized
        await storageService.setBool('MOCK_DATA_INITIALIZED', true);
      } catch (e) {
        // Handle error initializing mock data
      }
    }
  }
  
  Future<bool> _hasInitializedMockData() async {
    return storageService.getBool('MOCK_DATA_INITIALIZED') ?? false;
  }

  @override
  Future<void> cacheToken(String token) async {
    try {
      await storageService.setString(_tokenKey, token);
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      return storageService.getString(_tokenKey);
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> clearToken() async {
    try {
      await storageService.remove(_tokenKey);
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      await storageService.setString(_userKey, json.encode(user.toJson()));
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<UserModel?> getUser() async {
    try {
      final userString = storageService.getString(_userKey);
      if (userString == null) {
        return null;
      }
      final userJson = json.decode(userString);
      return UserModel.fromJson(userJson);
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> cacheAddresses(List<AddressModel> addresses) async {
    try {
      final jsonList = addresses.map((address) => address.toJson()).toList();
      await storageService.setString(_addressesKey, json.encode(jsonList));
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<List<AddressModel>?> getAddresses() async {
    try {
      final addressesString = storageService.getString(_addressesKey);
      if (addressesString == null) {
        return null;
      }
      final jsonList = json.decode(addressesString) as List<dynamic>;
      return jsonList.map((json) => AddressModel.fromJson(json)).toList();
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> cachePackages(List<PackageModel> packages) async {
    try {
      final jsonList = packages.map((package) => package.toJson()).toList();
      await storageService.setString(_packagesKey, json.encode(jsonList));
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<List<PackageModel>?> getPackages() async {
    try {
      final packagesString = storageService.getString(_packagesKey);
      if (packagesString == null) {
        return null;
      }
      final jsonList = json.decode(packagesString) as List<dynamic>;
      return jsonList.map((json) => PackageModel.fromJson(json)).toList();
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> cachePackage(PackageModel package) async {
    try {
      await storageService.setString(
        _packagePrefix + package.id,
        json.encode(package.toJson()),
      );
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<PackageModel?> getPackage(String packageId) async {
    try {
      final packageString = storageService.getString(_packagePrefix + packageId);
      if (packageString == null) {
        return null;
      }
      final packageJson = json.decode(packageString);
      return PackageModel.fromJson(packageJson);
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> cacheActiveSubscriptions(List<SubscriptionModel> subscriptions) async {
    try {
      final jsonList = subscriptions.map((subscription) => subscription.toJson()).toList();
      await storageService.setString(_activeSubscriptionsKey, json.encode(jsonList));
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<List<SubscriptionModel>?> getActiveSubscriptions() async {
    try {
      final subsString = storageService.getString(_activeSubscriptionsKey);
      if (subsString == null) {
        return null;
      }
      final jsonList = json.decode(subsString) as List<dynamic>;
      return jsonList.map((json) => SubscriptionModel.fromJson(json)).toList();
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> cacheSubscription(SubscriptionModel subscription) async {
    try {
      await storageService.setString(
        _subscriptionPrefix + subscription.id,
        json.encode(subscription.toJson()),
      );
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<SubscriptionModel?> getSubscription(String subscriptionId) async {
    try {
      final subString = storageService.getString(_subscriptionPrefix + subscriptionId);
      if (subString == null) {
        return null;
      }
      final subJson = json.decode(subString);
      return SubscriptionModel.fromJson(subJson);
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> cacheDraftSubscription(Map<String, dynamic> subscription) async {
    try {
      await storageService.setString(
        _draftSubscriptionKey, 
        json.encode(subscription),
      );
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<Map<String, dynamic>?> getDraftSubscription() async {
    try {
      final subscriptionString = storageService.getString(_draftSubscriptionKey);
      if (subscriptionString == null) {
        return null;
      }
      return json.decode(subscriptionString) as Map<String, dynamic>;
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> clearDraftSubscription() async {
    try {
      await storageService.remove(_draftSubscriptionKey);
    } catch (e) {
      throw CacheException();
    }
  }
}