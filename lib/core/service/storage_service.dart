// lib/core/services/storage_service.dart
import 'dart:convert';
import 'package:foodam/core/service/logger_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Generic, type-safe storage service for handling local data caching
class StorageService {
  final SharedPreferences _prefs;
  final LoggerService _logger = LoggerService();

  StorageService(this._prefs);

  /// Save a string value
  Future<bool> setString(String key, String value) async {
    try {
      return await _prefs.setString(key, value);
    } catch (e) {
      _logger.e('Error saving string for key: $key', error: e);
      return false;
    }
  }

  /// Get a string value
  String? getString(String key) {
    try {
      return _prefs.getString(key);
    } catch (e) {
      _logger.e('Error getting string for key: $key', error: e);
      return null;
    }
  }

  /// Save an integer value
  Future<bool> setInt(String key, int value) async {
    try {
      return await _prefs.setInt(key, value);
    } catch (e) {
      _logger.e('Error saving int for key: $key', error: e);
      return false;
    }
  }

  /// Get an integer value
  int? getInt(String key) {
    try {
      return _prefs.getInt(key);
    } catch (e) {
      _logger.e('Error getting int for key: $key', error: e);
      return null;
    }
  }

  /// Save a boolean value
  Future<bool> setBool(String key, bool value) async {
    try {
      return await _prefs.setBool(key, value);
    } catch (e) {
      _logger.e('Error saving bool for key: $key', error: e);
      return false;
    }
  }

  /// Get a boolean value
  bool? getBool(String key) {
    try {
      return _prefs.getBool(key);
    } catch (e) {
      _logger.e('Error getting bool for key: $key', error: e);
      return null;
    }
  }

  /// Save a double value
  Future<bool> setDouble(String key, double value) async {
    try {
      return await _prefs.setDouble(key, value);
    } catch (e) {
      _logger.e('Error saving double for key: $key', error: e);
      return false;
    }
  }

  /// Get a double value
  double? getDouble(String key) {
    try {
      return _prefs.getDouble(key);
    } catch (e) {
      _logger.e('Error getting double for key: $key', error: e);
      return null;
    }
  }

  /// Save a list of strings
  Future<bool> setStringList(String key, List<String> value) async {
    try {
      return await _prefs.setStringList(key, value);
    } catch (e) {
      _logger.e('Error saving string list for key: $key', error: e);
      return false;
    }
  }

  /// Get a list of strings
  List<String>? getStringList(String key) {
    try {
      return _prefs.getStringList(key);
    } catch (e) {
      _logger.e('Error getting string list for key: $key', error: e);
      return null;
    }
  }

  /// Save an object value (serialized to JSON)
  Future<bool> setObject<T>(String key, T value) async {
    try {
      // Convert object to JSON string
      if (value is Map || value is List) {
        final jsonString = json.encode(value);
        return await _prefs.setString(key, jsonString);
      } else {
        _logger.e('Error: Cannot serialize object of type ${value.runtimeType}', tag: 'STORAGE');
        return false;
      }
    } catch (e) {
      _logger.e('Error saving object for key: $key', error: e);
      return false;
    }
  }

  /// Get an object value (deserialized from JSON)
  T? getObject<T>(String key, T Function(Map<String, dynamic>) fromJson) {
    try {
      final jsonString = _prefs.getString(key);
      if (jsonString == null) {
        return null;
      }

      final decoded = json.decode(jsonString);
      if (decoded is Map<String, dynamic>) {
        return fromJson(decoded);
      } else {
        _logger.e('Error: Decoded object is not a Map<String, dynamic>', tag: 'STORAGE');
        return null;
      }
    } catch (e) {
      _logger.e('Error getting object for key: $key', error: e);
      return null;
    }
  }

  /// Save a list of objects (serialized to JSON)
  Future<bool> setObjectList<T>(String key, List<T> value, dynamic Function(T) toJson) async {
    try {
      // Convert each object to JSON
      final jsonList = value.map((item) => toJson(item)).toList();
      final jsonString = json.encode(jsonList);
      return await _prefs.setString(key, jsonString);
    } catch (e) {
      _logger.e('Error saving object list for key: $key', error: e);
      return false;
    }
  }

  /// Get a list of objects (deserialized from JSON)
  List<T>? getObjectList<T>(String key, T Function(Map<String, dynamic>) fromJson) {
    try {
      final jsonString = _prefs.getString(key);
      if (jsonString == null) {
        return null;
      }

      final decoded = json.decode(jsonString);
      if (decoded is List) {
        // Convert each map in the list to an object
        return decoded
            .map((item) => fromJson(item as Map<String, dynamic>))
            .toList()
            .cast<T>();
      } else {
        _logger.e('Error: Decoded object is not a List', tag: 'STORAGE');
        return null;
      }
    } catch (e) {
      _logger.e('Error getting object list for key: $key', error: e);
      return null;
    }
  }

  /// Check if a key exists
  bool containsKey(String key) {
    try {
      return _prefs.containsKey(key);
    } catch (e) {
      _logger.e('Error checking key: $key', error: e);
      return false;
    }
  }

  /// Remove a value
  Future<bool> remove(String key) async {
    try {
      return await _prefs.remove(key);
    } catch (e) {
      _logger.e('Error removing key: $key', error: e);
      return false;
    }
  }

  /// Clear all values
  Future<bool> clear() async {
    try {
      return await _prefs.clear();
    } catch (e) {
      _logger.e('Error clearing storage', error: e);
      return false;
    }
  }

  /// Get all keys
  Set<String> getKeys() {
    try {
      return _prefs.getKeys();
    } catch (e) {
      _logger.e('Error getting keys', error: e);
      return {};
    }
  }
}