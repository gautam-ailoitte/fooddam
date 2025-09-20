// lib/src/data/datasource/local_data_source.dart
import 'package:foodam/core/constants/app_constants.dart';
import 'package:foodam/core/errors/execption.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/core/service/storage_service.dart';
import 'package:foodam/src/data/model/address_model.dart';
import 'package:foodam/src/data/model/subscription_model.dart';
import 'package:foodam/src/data/model/user_model.dart';

import '../model/package/package_model.dart';

abstract class LocalDataSource {
  // Auth methods
  Future<void> cacheToken(String token);
  Future<String?> getToken();
  Future<void> clearToken();
  Future<void> cacheRefreshToken(String refreshToken);
  Future<String?> getRefreshToken();
  Future<void> clearRefreshToken();
  Future<void> clearAuthData(); // Clears auth-related data only
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getUser();
  Future<void> clearUser();

  // Address methods
  Future<void> cacheAddresses(List<AddressModel> addresses);
  Future<List<AddressModel>?> getAddresses();
  Future<void> clearAddresses();

  // Package methods
  Future<void> cachePackages(List<PackageModel> packages);
  Future<List<PackageModel>?> getPackages();
  Future<PackageModel?> getPackage(String packageId);
  Future<void> cachePackage(String packageId, PackageModel package);
  Future<void> clearPackages();

  // Subscription methods
  Future<void> cacheActiveSubscriptions(List<SubscriptionModel> subscriptions);
  Future<List<SubscriptionModel>?> getActiveSubscriptions();
  Future<SubscriptionModel?> getSubscription(String subscriptionId);
  Future<void> cacheSubscription(
    String subscriptionId,
    SubscriptionModel subscription,
  );
  Future<void> clearSubscriptions();

  // Draft subscription methods
  Future<void> cacheDraftSubscription(Map<String, dynamic> subscription);
  Future<Map<String, dynamic>?> getDraftSubscription();
  Future<void> clearDraftSubscription();

  // Session management
  Future<DateTime?> getLastLoginTime();
  Future<void> setLastLoginTime(DateTime time);
  Future<bool> isLoggedIn();

  // App settings
  Future<void> cacheAppSettings(Map<String, dynamic> settings);
  Future<Map<String, dynamic>?> getAppSettings();
  Future<void> clearAppSettings();

  // ✅ NEW: Complete data clearing methods
  Future<void> clearAllData(); // Nuclear option - clears EVERYTHING
  Future<void>
  clearUserSpecificData(); // Clears user data but keeps app settings
  Future<Set<String>> getAllStoredKeys(); // For debugging
  Future<Map<String, String>> getStorageDebugInfo(); // For debugging
}

class LocalDataSourceImpl implements LocalDataSource {
  final StorageService _storageService;
  final LoggerService _logger = LoggerService();

  LocalDataSourceImpl({required StorageService storageService})
    : _storageService = storageService;

  // Storage Keys Constants
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
  static const String _appSettingsKey = 'APP_SETTINGS';

  // App-level settings keys (things that might persist across logins)
  static const String _onboardingCompletedKey = 'ONBOARDING_COMPLETED';
  static const String _selectedLanguageKey = 'SELECTED_LANGUAGE';
  static const String _themePreferenceKey = 'THEME_PREFERENCE';
  static const String _notificationSettingsKey = 'NOTIFICATION_SETTINGS';
  static const String _appVersionKey = 'APP_VERSION';
  static const String _firstLaunchKey = 'FIRST_LAUNCH_DATE';

  // =================================================================
  // AUTH METHODS
  // =================================================================

  @override
  Future<void> cacheToken(String token) async {
    try {
      final success = await _storageService.setString(_tokenKey, token);
      if (success) {
        _logger.d('Cached auth token', tag: 'LocalDataSource');
      } else {
        throw CacheException('Failed to save auth token');
      }
    } catch (e) {
      _logger.e('Failed to cache token', error: e, tag: 'LocalDataSource');
      throw CacheException('Failed to cache auth token');
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      return _storageService.getString(_tokenKey);
    } catch (e) {
      _logger.e('Failed to get token', error: e, tag: 'LocalDataSource');
      return null;
    }
  }

  @override
  Future<void> clearToken() async {
    try {
      await _storageService.remove(_tokenKey);
      _logger.d('Cleared auth token', tag: 'LocalDataSource');
    } catch (e) {
      _logger.e('Failed to clear token', error: e, tag: 'LocalDataSource');
      throw CacheException('Failed to clear auth token');
    }
  }

  @override
  Future<void> cacheRefreshToken(String refreshToken) async {
    try {
      final success = await _storageService.setString(
        _refreshTokenKey,
        refreshToken,
      );
      if (success) {
        _logger.d('Cached refresh token', tag: 'LocalDataSource');
      } else {
        throw CacheException('Failed to save refresh token');
      }
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
      return _storageService.getString(_refreshTokenKey);
    } catch (e) {
      _logger.e(
        'Failed to get refresh token',
        error: e,
        tag: 'LocalDataSource',
      );
      return null;
    }
  }

  @override
  Future<void> clearRefreshToken() async {
    try {
      await _storageService.remove(_refreshTokenKey);
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
  Future<void> cacheUser(UserModel user) async {
    try {
      final success = await _storageService.setObject(_userKey, user.toJson());
      if (success) {
        _logger.d(
          'Cached user data for ID: ${user.id}',
          tag: 'LocalDataSource',
        );
      } else {
        throw CacheException('Failed to save user data');
      }
    } catch (e) {
      _logger.e('Failed to cache user', error: e, tag: 'LocalDataSource');
      throw CacheException('Failed to cache user data');
    }
  }

  @override
  Future<UserModel?> getUser() async {
    try {
      return _storageService.getObject(
        _userKey,
        (json) => UserModel.fromJson(json),
      );
    } catch (e) {
      _logger.e('Failed to get user', error: e, tag: 'LocalDataSource');
      return null;
    }
  }

  @override
  Future<void> clearUser() async {
    try {
      await _storageService.remove(_userKey);
      _logger.d('Cleared user data', tag: 'LocalDataSource');
    } catch (e) {
      _logger.e('Failed to clear user data', error: e, tag: 'LocalDataSource');
      throw CacheException('Failed to clear user data');
    }
  }

  @override
  Future<void> clearAuthData() async {
    try {
      await Future.wait([
        clearToken(),
        clearRefreshToken(),
        clearUser(),
        _storageService.remove(_lastLoginTimeKey),
        clearDraftSubscription(), // Clear any pending subscription data
      ]);
      _logger.i('Cleared all auth-specific data', tag: 'LocalDataSource');
    } catch (e) {
      _logger.e('Failed to clear auth data', error: e, tag: 'LocalDataSource');
      throw CacheException('Failed to clear authentication data');
    }
  }

  // =================================================================
  // ADDRESS METHODS
  // =================================================================

  @override
  Future<void> cacheAddresses(List<AddressModel> addresses) async {
    try {
      final success = await _storageService.setObjectList(
        _addressesKey,
        addresses,
        (address) => address.toJson(),
      );
      if (success) {
        _logger.d(
          'Cached ${addresses.length} addresses',
          tag: 'LocalDataSource',
        );
      } else {
        throw CacheException('Failed to save addresses');
      }
    } catch (e) {
      _logger.e('Failed to cache addresses', error: e, tag: 'LocalDataSource');
      throw CacheException('Failed to cache addresses');
    }
  }

  @override
  Future<List<AddressModel>?> getAddresses() async {
    try {
      return _storageService.getObjectList(
        _addressesKey,
        (json) => AddressModel.fromJson(json),
      );
    } catch (e) {
      _logger.e('Failed to get addresses', error: e, tag: 'LocalDataSource');
      return null;
    }
  }

  @override
  Future<void> clearAddresses() async {
    try {
      await _storageService.remove(_addressesKey);
      _logger.d('Cleared addresses cache', tag: 'LocalDataSource');
    } catch (e) {
      _logger.e('Failed to clear addresses', error: e, tag: 'LocalDataSource');
      throw CacheException('Failed to clear addresses');
    }
  }

  // =================================================================
  // PACKAGE METHODS
  // =================================================================

  @override
  Future<void> cachePackages(List<PackageModel> packages) async {
    try {
      final success = await _storageService.setObjectList(
        _packagesKey,
        packages,
        (package) => package.toJson(),
      );
      if (success) {
        _logger.d('Cached ${packages.length} packages', tag: 'LocalDataSource');
      } else {
        throw CacheException('Failed to save packages');
      }
    } catch (e) {
      _logger.e('Failed to cache packages', error: e, tag: 'LocalDataSource');
      throw CacheException('Failed to cache packages');
    }
  }

  @override
  Future<List<PackageModel>?> getPackages() async {
    try {
      return _storageService.getObjectList(
        _packagesKey,
        (json) => PackageModel.fromJson(json),
      );
    } catch (e) {
      _logger.e('Failed to get packages', error: e, tag: 'LocalDataSource');
      return null;
    }
  }

  @override
  Future<PackageModel?> getPackage(String packageId) async {
    try {
      final key = _packagePrefix + packageId;
      return _storageService.getObject(
        key,
        (json) => PackageModel.fromJson(json),
      );
    } catch (e) {
      _logger.e(
        'Failed to get package $packageId',
        error: e,
        tag: 'LocalDataSource',
      );
      return null;
    }
  }

  @override
  Future<void> cachePackage(String packageId, PackageModel package) async {
    try {
      final key = _packagePrefix + packageId;
      final success = await _storageService.setObject(key, package.toJson());
      if (success) {
        _logger.d('Cached package: $packageId', tag: 'LocalDataSource');
      } else {
        throw CacheException('Failed to save package');
      }
    } catch (e) {
      _logger.e(
        'Failed to cache package $packageId',
        error: e,
        tag: 'LocalDataSource',
      );
      throw CacheException('Failed to cache package');
    }
  }

  @override
  Future<void> clearPackages() async {
    try {
      // Clear main packages list
      await _storageService.remove(_packagesKey);

      // Clear individual package caches
      final allKeys = _storageService.getKeys();
      final packageKeys = allKeys.where(
        (key) => key.startsWith(_packagePrefix),
      );

      await Future.wait(packageKeys.map((key) => _storageService.remove(key)));

      _logger.d(
        'Cleared ${packageKeys.length + 1} package caches',
        tag: 'LocalDataSource',
      );
    } catch (e) {
      _logger.e('Failed to clear packages', error: e, tag: 'LocalDataSource');
      throw CacheException('Failed to clear packages');
    }
  }

  // =================================================================
  // SUBSCRIPTION METHODS
  // =================================================================

  @override
  Future<void> cacheActiveSubscriptions(
    List<SubscriptionModel> subscriptions,
  ) async {
    try {
      final success = await _storageService.setObjectList(
        _activeSubscriptionsKey,
        subscriptions,
        (subscription) => subscription.toJson(),
      );
      if (success) {
        _logger.d(
          'Cached ${subscriptions.length} active subscriptions',
          tag: 'LocalDataSource',
        );
      } else {
        throw CacheException('Failed to save subscriptions');
      }
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
      return _storageService.getObjectList(
        _activeSubscriptionsKey,
        (json) => SubscriptionModel.fromJson(json),
      );
    } catch (e) {
      _logger.e(
        'Failed to get active subscriptions',
        error: e,
        tag: 'LocalDataSource',
      );
      return null;
    }
  }

  @override
  Future<SubscriptionModel?> getSubscription(String subscriptionId) async {
    try {
      final key = _subscriptionPrefix + subscriptionId;
      return _storageService.getObject(
        key,
        (json) => SubscriptionModel.fromJson(json),
      );
    } catch (e) {
      _logger.e(
        'Failed to get subscription $subscriptionId',
        error: e,
        tag: 'LocalDataSource',
      );
      return null;
    }
  }

  @override
  Future<void> cacheSubscription(
    String subscriptionId,
    SubscriptionModel subscription,
  ) async {
    try {
      final key = _subscriptionPrefix + subscriptionId;
      final success = await _storageService.setObject(
        key,
        subscription.toJson(),
      );
      if (success) {
        _logger.d(
          'Cached subscription: $subscriptionId',
          tag: 'LocalDataSource',
        );
      } else {
        throw CacheException('Failed to save subscription');
      }
    } catch (e) {
      _logger.e(
        'Failed to cache subscription $subscriptionId',
        error: e,
        tag: 'LocalDataSource',
      );
      throw CacheException('Failed to cache subscription');
    }
  }

  @override
  Future<void> clearSubscriptions() async {
    try {
      // Clear main subscriptions list
      await _storageService.remove(_activeSubscriptionsKey);

      // Clear individual subscription caches
      final allKeys = _storageService.getKeys();
      final subscriptionKeys = allKeys.where(
        (key) => key.startsWith(_subscriptionPrefix),
      );

      await Future.wait(
        subscriptionKeys.map((key) => _storageService.remove(key)),
      );

      _logger.d(
        'Cleared ${subscriptionKeys.length + 1} subscription caches',
        tag: 'LocalDataSource',
      );
    } catch (e) {
      _logger.e(
        'Failed to clear subscriptions',
        error: e,
        tag: 'LocalDataSource',
      );
      throw CacheException('Failed to clear subscriptions');
    }
  }

  // =================================================================
  // DRAFT SUBSCRIPTION METHODS
  // =================================================================

  @override
  Future<void> cacheDraftSubscription(Map<String, dynamic> subscription) async {
    try {
      final success = await _storageService.setObject(
        _draftSubscriptionKey,
        subscription,
      );
      if (success) {
        _logger.d('Cached draft subscription', tag: 'LocalDataSource');
      } else {
        throw CacheException('Failed to save draft subscription');
      }
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
      return _storageService.getObject(_draftSubscriptionKey, (json) => json);
    } catch (e) {
      _logger.e(
        'Failed to get draft subscription',
        error: e,
        tag: 'LocalDataSource',
      );
      return null;
    }
  }

  @override
  Future<void> clearDraftSubscription() async {
    try {
      await _storageService.remove(_draftSubscriptionKey);
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

  // =================================================================
  // SESSION MANAGEMENT
  // =================================================================

  @override
  Future<DateTime?> getLastLoginTime() async {
    try {
      final timestamp = _storageService.getString(_lastLoginTimeKey);
      return timestamp != null ? DateTime.parse(timestamp) : null;
    } catch (e) {
      _logger.e(
        'Failed to get last login time',
        error: e,
        tag: 'LocalDataSource',
      );
      return null;
    }
  }

  @override
  Future<void> setLastLoginTime(DateTime time) async {
    try {
      final success = await _storageService.setString(
        _lastLoginTimeKey,
        time.toIso8601String(),
      );
      if (success) {
        _logger.d(
          'Set last login time to ${time.toIso8601String()}',
          tag: 'LocalDataSource',
        );
      } else {
        throw CacheException('Failed to save last login time');
      }
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

  // =================================================================
  // APP SETTINGS METHODS
  // =================================================================

  @override
  Future<void> cacheAppSettings(Map<String, dynamic> settings) async {
    try {
      final success = await _storageService.setObject(
        _appSettingsKey,
        settings,
      );
      if (success) {
        _logger.d('Cached app settings', tag: 'LocalDataSource');
      } else {
        throw CacheException('Failed to save app settings');
      }
    } catch (e) {
      _logger.e(
        'Failed to cache app settings',
        error: e,
        tag: 'LocalDataSource',
      );
      throw CacheException('Failed to cache app settings');
    }
  }

  @override
  Future<Map<String, dynamic>?> getAppSettings() async {
    try {
      return _storageService.getObject(_appSettingsKey, (json) => json);
    } catch (e) {
      _logger.e('Failed to get app settings', error: e, tag: 'LocalDataSource');
      return null;
    }
  }

  @override
  Future<void> clearAppSettings() async {
    try {
      await _storageService.remove(_appSettingsKey);
      _logger.d('Cleared app settings', tag: 'LocalDataSource');
    } catch (e) {
      _logger.e(
        'Failed to clear app settings',
        error: e,
        tag: 'LocalDataSource',
      );
      throw CacheException('Failed to clear app settings');
    }
  }

  // =================================================================
  // ✅ COMPLETE DATA CLEARING METHODS
  // =================================================================

  @override
  Future<void> clearAllData() async {
    try {
      _logger.i(
        '🔥 NUCLEAR OPTION: Starting complete app data clear...',
        tag: 'LocalDataSource',
      );

      // Use your existing StorageService clear method - it's perfect!
      final success = await _storageService.clear();

      if (success) {
        _logger.i(
          '✅ Successfully cleared ALL shared preferences data',
          tag: 'LocalDataSource',
        );
        _logger.i(
          '📱 App is now in fresh install state',
          tag: 'LocalDataSource',
        );
      } else {
        throw CacheException('StorageService.clear() returned false');
      }
    } catch (e) {
      _logger.e(
        '❌ Failed to clear all app data',
        error: e,
        tag: 'LocalDataSource',
      );
      throw CacheException(
        'Failed to clear all application data: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> clearUserSpecificData() async {
    try {
      _logger.i(
        '🧹 Clearing user-specific data (keeping app settings)...',
        tag: 'LocalDataSource',
      );

      // Keep these app-level settings
      final settingsToKeep = <String, dynamic>{};

      // Preserve app settings
      if (_storageService.containsKey(_onboardingCompletedKey)) {
        settingsToKeep[_onboardingCompletedKey] = _storageService.getBool(
          _onboardingCompletedKey,
        );
      }
      if (_storageService.containsKey(_selectedLanguageKey)) {
        settingsToKeep[_selectedLanguageKey] = _storageService.getString(
          _selectedLanguageKey,
        );
      }
      if (_storageService.containsKey(_themePreferenceKey)) {
        settingsToKeep[_themePreferenceKey] = _storageService.getString(
          _themePreferenceKey,
        );
      }
      if (_storageService.containsKey(_appVersionKey)) {
        settingsToKeep[_appVersionKey] = _storageService.getString(
          _appVersionKey,
        );
      }
      if (_storageService.containsKey(_firstLaunchKey)) {
        settingsToKeep[_firstLaunchKey] = _storageService.getString(
          _firstLaunchKey,
        );
      }

      // Clear everything
      await _storageService.clear();

      // Restore app settings
      for (final entry in settingsToKeep.entries) {
        if (entry.value is bool) {
          await _storageService.setBool(entry.key, entry.value as bool);
        } else if (entry.value is String) {
          await _storageService.setString(entry.key, entry.value as String);
        } else if (entry.value is int) {
          await _storageService.setInt(entry.key, entry.value as int);
        } else if (entry.value is double) {
          await _storageService.setDouble(entry.key, entry.value as double);
        }
      }

      _logger.i(
        '✅ Cleared user data, preserved ${settingsToKeep.length} app settings',
        tag: 'LocalDataSource',
      );
    } catch (e) {
      _logger.e(
        '❌ Failed to clear user-specific data',
        error: e,
        tag: 'LocalDataSource',
      );
      throw CacheException(
        'Failed to clear user-specific data: ${e.toString()}',
      );
    }
  }

  // =================================================================
  // 🛠️ DEBUGGING METHODS
  // =================================================================

  @override
  Future<Set<String>> getAllStoredKeys() async {
    try {
      return _storageService.getKeys();
    } catch (e) {
      _logger.e(
        'Failed to get all stored keys',
        error: e,
        tag: 'LocalDataSource',
      );
      return <String>{};
    }
  }

  @override
  Future<Map<String, String>> getStorageDebugInfo() async {
    try {
      final keys = _storageService.getKeys();
      final debugInfo = <String, String>{};

      for (final key in keys) {
        try {
          final value = _storageService.getString(key);
          if (value != null) {
            // Truncate long values for debugging
            final truncatedValue =
                value.length > 100 ? '${value.substring(0, 100)}...' : value;
            debugInfo[key] = truncatedValue;
          } else {
            debugInfo[key] = '<null>';
          }
        } catch (e) {
          debugInfo[key] = '<error: ${e.toString()}>';
        }
      }

      _logger.d(
        'Generated debug info for ${keys.length} keys',
        tag: 'LocalDataSource',
      );
      return debugInfo;
    } catch (e) {
      _logger.e(
        'Failed to generate storage debug info',
        error: e,
        tag: 'LocalDataSource',
      );
      return <String, String>{'error': e.toString()};
    }
  }
}
