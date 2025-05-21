import 'dart:convert';

import 'package:foodam/core/constants/app_constants.dart';
import 'package:foodam/core/errors/execption.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/core/service/storage_service.dart';
import 'package:foodam/src/data/model/address_model.dart';
import 'package:foodam/src/data/model/package_model.dart';
import 'package:foodam/src/data/model/subscription_model.dart';
import 'package:foodam/src/data/model/user_model.dart';

abstract class LocalDataSource {
  // Auth
  Future<void> cacheToken(String token);
  Future<String?> getToken();
  Future<void> clearToken();
  Future<void> cacheRefreshToken(String refreshToken);
  Future<String?> getRefreshToken();
  Future<void> clearRefreshToken();
  Future<void> clearAuthData(); // Clears all auth-related data
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getUser();

  // Addresses
  Future<void> cacheAddresses(List<AddressModel> addresses);
  Future<List<AddressModel>?> getAddresses();

  // Subscriptions

  // Draft selections
  Future<void> cacheDraftSubscription(Map<String, dynamic> subscription);
  Future<Map<String, dynamic>?> getDraftSubscription();
  Future<void> clearDraftSubscription();

  // Session management
  Future<DateTime?> getLastLoginTime();
  Future<void> setLastLoginTime(DateTime time);
  Future<bool> isLoggedIn();
}

class LocalDataSourceImpl implements LocalDataSource {
  final StorageService storageService;
  final LoggerService _logger = LoggerService();

  // Keys
  static const String _tokenKey = AppConstants.tokenKey;
  static const String _refreshTokenKey = AppConstants.refreshTokenKey;
  static const String _userKey = AppConstants.userKey;
  static const String _addressesKey = 'CACHED_ADDRESSES';
  static const String _packagesKey = 'CACHED_PACKAGES';
  static const String _packagePrefix = 'CACHED_PACKAGE_';
  static const String _activeSubscriptionsKey = 'CACHED_ACTIVE_SUBSCRIPTIONS';
  static const String _subscriptionPrefix = 'CACHED_SUBSCRIPTION_';
  static const String _draftSubscriptionKey = 'CACHED_DRAFT_SUBSCRIPTION';
  static const String _lastLoginTimeKey = 'LAST_LOGIN_TIME';

  LocalDataSourceImpl({required this.storageService});

  @override
  Future<void> cacheToken(String token) async {
    try {
      await storageService.setString(_tokenKey, token);
      _logger.d('Cached auth token', tag: 'LocalDataSource');
    } catch (e) {
      _logger.e('Failed to cache token', error: e, tag: 'LocalDataSource');
      throw CacheException('Failed to cache auth token');
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      return storageService.getString(_tokenKey);
    } catch (e) {
      _logger.e('Failed to get token', error: e, tag: 'LocalDataSource');
      throw CacheException('Failed to retrieve auth token');
    }
  }

  @override
  Future<void> clearToken() async {
    try {
      await storageService.remove(_tokenKey);
      _logger.d('Cleared auth token', tag: 'LocalDataSource');
    } catch (e) {
      _logger.e('Failed to clear token', error: e, tag: 'LocalDataSource');
      throw CacheException('Failed to clear auth token');
    }
  }

  @override
  Future<void> cacheRefreshToken(String refreshToken) async {
    try {
      await storageService.setString(_refreshTokenKey, refreshToken);
      _logger.d('Cached refresh token', tag: 'LocalDataSource');
    } catch (e) {
      _logger.e(
        'Failed to cache refresh token',
        error: e,
        tag: 'LocalDataSource',
      );
      throw CacheException('Failed to cache refresh token');
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      return storageService.getString(_refreshTokenKey);
    } catch (e) {
      _logger.e(
        'Failed to get refresh token',
        error: e,
        tag: 'LocalDataSource',
      );
      throw CacheException('Failed to retrieve refresh token');
    }
  }

  @override
  Future<void> clearRefreshToken() async {
    try {
      await storageService.remove(_refreshTokenKey);
      _logger.d('Cleared refresh token', tag: 'LocalDataSource');
    } catch (e) {
      _logger.e(
        'Failed to clear refresh token',
        error: e,
        tag: 'LocalDataSource',
      );
      throw CacheException('Failed to clear refresh token');
    }
  }

  @override
  Future<void> clearAuthData() async {
    try {
      await clearToken();
      await clearRefreshToken();
      await storageService.remove(_userKey);
      _logger.d('Cleared all auth data', tag: 'LocalDataSource');
    } catch (e) {
      _logger.e('Failed to clear auth data', error: e, tag: 'LocalDataSource');
      throw CacheException('Failed to clear authentication data');
    }
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      await storageService.setString(_userKey, json.encode(user.toJson()));
      _logger.d('Cached user data', tag: 'LocalDataSource');
    } catch (e) {
      _logger.e('Failed to cache user', error: e, tag: 'LocalDataSource');
      throw CacheException('Failed to cache user data');
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
      _logger.e('Failed to get user', error: e, tag: 'LocalDataSource');
      throw CacheException('Failed to retrieve user data');
    }
  }

  @override
  Future<void> cacheAddresses(List<AddressModel> addresses) async {
    try {
      final jsonList = addresses.map((address) => address.toJson()).toList();
      await storageService.setString(_addressesKey, json.encode(jsonList));
      _logger.d('Cached ${addresses.length} addresses', tag: 'LocalDataSource');
    } catch (e) {
      _logger.e('Failed to cache addresses', error: e, tag: 'LocalDataSource');
      throw CacheException('Failed to cache addresses');
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
      _logger.e('Failed to get addresses', error: e, tag: 'LocalDataSource');
      throw CacheException('Failed to retrieve addresses');
    }
  }

  @override
  Future<void> cachePackages(List<PackageModel> packages) async {
    try {
      final jsonList = packages.map((package) => package.toJson()).toList();
      await storageService.setString(_packagesKey, json.encode(jsonList));
      _logger.d('Cached ${packages.length} packages', tag: 'LocalDataSource');
    } catch (e) {
      _logger.e('Failed to cache packages', error: e, tag: 'LocalDataSource');
      throw CacheException('Failed to cache packages');
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
      _logger.e('Failed to get packages', error: e, tag: 'LocalDataSource');
      throw CacheException('Failed to retrieve packages');
    }
  }

  @override
  Future<PackageModel?> getPackage(String packageId) async {
    try {
      final packageString = storageService.getString(
        _packagePrefix + packageId,
      );
      if (packageString == null) {
        return null;
      }
      final packageJson = json.decode(packageString);
      return PackageModel.fromJson(packageJson);
    } catch (e) {
      _logger.e(
        'Failed to get package $packageId',
        error: e,
        tag: 'LocalDataSource',
      );
      throw CacheException('Failed to retrieve package');
    }
  }

  @override
  Future<void> cacheActiveSubscriptions(
    List<SubscriptionModel> subscriptions,
  ) async {
    try {
      final jsonList =
          subscriptions.map((subscription) => subscription.toJson()).toList();
      await storageService.setString(
        _activeSubscriptionsKey,
        json.encode(jsonList),
      );
      _logger.d(
        'Cached ${subscriptions.length} active subscriptions',
        tag: 'LocalDataSource',
      );
    } catch (e) {
      _logger.e(
        'Failed to cache active subscriptions',
        error: e,
        tag: 'LocalDataSource',
      );
      throw CacheException('Failed to cache active subscriptions');
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
      _logger.e(
        'Failed to get active subscriptions',
        error: e,
        tag: 'LocalDataSource',
      );
      throw CacheException('Failed to retrieve active subscriptions');
    }
  }

  @override
  Future<SubscriptionModel?> getSubscription(String subscriptionId) async {
    try {
      final subString = storageService.getString(
        _subscriptionPrefix + subscriptionId,
      );
      if (subString == null) {
        return null;
      }
      final subJson = json.decode(subString);
      return SubscriptionModel.fromJson(subJson);
    } catch (e) {
      _logger.e(
        'Failed to get subscription $subscriptionId',
        error: e,
        tag: 'LocalDataSource',
      );
      throw CacheException('Failed to retrieve subscription');
    }
  }

  @override
  Future<void> cacheDraftSubscription(Map<String, dynamic> subscription) async {
    try {
      await storageService.setString(
        _draftSubscriptionKey,
        json.encode(subscription),
      );
      _logger.d('Cached draft subscription', tag: 'LocalDataSource');
    } catch (e) {
      _logger.e(
        'Failed to cache draft subscription',
        error: e,
        tag: 'LocalDataSource',
      );
      throw CacheException('Failed to cache draft subscription');
    }
  }

  @override
  Future<Map<String, dynamic>?> getDraftSubscription() async {
    try {
      final subscriptionString = storageService.getString(
        _draftSubscriptionKey,
      );
      if (subscriptionString == null) {
        return null;
      }
      return json.decode(subscriptionString) as Map<String, dynamic>;
    } catch (e) {
      _logger.e(
        'Failed to get draft subscription',
        error: e,
        tag: 'LocalDataSource',
      );
      throw CacheException('Failed to retrieve draft subscription');
    }
  }

  @override
  Future<void> clearDraftSubscription() async {
    try {
      await storageService.remove(_draftSubscriptionKey);
      _logger.d('Cleared draft subscription', tag: 'LocalDataSource');
    } catch (e) {
      _logger.e(
        'Failed to clear draft subscription',
        error: e,
        tag: 'LocalDataSource',
      );
      throw CacheException('Failed to clear draft subscription');
    }
  }

  @override
  Future<DateTime?> getLastLoginTime() async {
    try {
      final timestamp = storageService.getString(_lastLoginTimeKey);
      if (timestamp == null) {
        return null;
      }
      return DateTime.parse(timestamp);
    } catch (e) {
      _logger.e(
        'Failed to get last login time',
        error: e,
        tag: 'LocalDataSource',
      );
      throw CacheException('Failed to retrieve last login time');
    }
  }

  @override
  Future<void> setLastLoginTime(DateTime time) async {
    try {
      await storageService.setString(_lastLoginTimeKey, time.toIso8601String());
      _logger.d(
        'Set last login time to ${time.toIso8601String()}',
        tag: 'LocalDataSource',
      );
    } catch (e) {
      _logger.e(
        'Failed to set last login time',
        error: e,
        tag: 'LocalDataSource',
      );
      throw CacheException('Failed to set last login time');
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      final token = await getToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      _logger.e(
        'Failed to check if logged in',
        error: e,
        tag: 'LocalDataSource',
      );
      return false;
    }
  }
}
