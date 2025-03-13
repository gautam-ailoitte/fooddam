// ThaliCustomizationManager
import 'package:foodam/src/domain/entities/user_entity.dart';

/// A singleton manager to track customization state across different days and meal types
class ThaliCustomizationManager {
  // Singleton instance
  static final ThaliCustomizationManager _instance = ThaliCustomizationManager._internal();
  
  factory ThaliCustomizationManager() {
    return _instance;
  }
  
  ThaliCustomizationManager._internal();
  
  // Maps to track customization state
  // Key format: 'day_mealType_thaliId'
  final Map<String, bool> _customizationInProgress = {};
  final Map<String, Thali> _customizedThalis = {};
  
  // Getters for customization state
  bool isCustomizing(DayOfWeek day, MealType mealType, String thaliId) {
    final key = _getKey(day, mealType, thaliId);
    return _customizationInProgress[key] ?? false;
  }
  
  Thali? getCustomizedThali(DayOfWeek day, MealType mealType, String thaliId) {
    final key = _getKey(day, mealType, thaliId);
    return _customizedThalis[key];
  }
  
  // Methods to manage customization state
  void startCustomization(DayOfWeek day, MealType mealType, String thaliId) {
    final key = _getKey(day, mealType, thaliId);
    _customizationInProgress[key] = true;
  }
  
  void completeCustomization(DayOfWeek day, MealType mealType, String thaliId, Thali customizedThali) {
    final key = _getKey(day, mealType, thaliId);
    _customizationInProgress[key] = false;
    _customizedThalis[key] = customizedThali;
  }
  
  void cancelCustomization(DayOfWeek day, MealType mealType, String thaliId) {
    final key = _getKey(day, mealType, thaliId);
    _customizationInProgress[key] = false;
  }
  
  // Clear all customizations for a plan
  void clearAllCustomizations() {
    _customizationInProgress.clear();
    _customizedThalis.clear();
  }
  
  // Helper to generate keys
  String _getKey(DayOfWeek day, MealType mealType, String thaliId) {
    return '${day.toString()}_${mealType.toString()}_$thaliId';
  }
  
  // Get all customized thalis
  Map<String, Thali> getAllCustomizedThalis() {
    return Map.from(_customizedThalis);
  }
  
  // Utility method to decode key into components
  static Map<String, dynamic> decodeKey(String key) {
    final parts = key.split('_');
    if (parts.length < 3) return {};
    
    // Parse day
    final dayString = parts[0];
    final day = DayOfWeek.values.firstWhere(
      (d) => d.toString() == dayString,
      orElse: () => DayOfWeek.monday,
    );
    
    // Parse meal type
    final mealTypeString = parts[1];
    final mealType = MealType.values.firstWhere(
      (m) => m.toString() == mealTypeString,
      orElse: () => MealType.breakfast,
    );
    
    // Get thali ID
    final thaliId = parts.sublist(2).join('_'); // In case thaliId contains underscores
    
    return {
      'day': day,
      'mealType': mealType,
      'thaliId': thaliId,
    };
  }
}