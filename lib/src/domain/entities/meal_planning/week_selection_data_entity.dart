// lib/src/domain/entities/meal_planning/week_selection_data_entity.dart
import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/meal_planning/calculated_plan_entity.dart';
import 'package:foodam/src/domain/entities/meal_planning/week_validation_entity.dart';

class WeekSelectionData extends Equatable {
  final int targetMealCount;
  final Map<String, bool> selectedSlots;
  final String dietaryPreference;
  final CalculatedPlan? weekData;

  const WeekSelectionData({
    required this.targetMealCount,
    required this.selectedSlots,
    required this.dietaryPreference,
    this.weekData,
  });

  // Get validation for this specific week
  WeekValidation get validation {
    int selectedCount = selectedSlots.values.where((s) => s).length;

    return WeekValidation(
      selectedCount: selectedCount,
      targetCount: targetMealCount,
      isValid: selectedCount == targetMealCount,
      message: _getValidationMessage(selectedCount, targetMealCount),
      progress: targetMealCount > 0 ? selectedCount / targetMealCount : 0.0,
    );
  }

  // Calculate price for this week only
  double get weekPrice {
    int selectedCount = selectedSlots.values.where((s) => s).length;
    return selectedCount * _getPricePerMeal(targetMealCount);
  }

  // Get selected slot keys as list
  List<String> get selectedSlotKeys {
    return selectedSlots.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
  }

  // Check if specific slot is selected
  bool isSlotSelected(String slotKey) {
    return selectedSlots[slotKey] ?? false;
  }

  // Copy with updated selections
  WeekSelectionData copyWith({
    int? targetMealCount,
    Map<String, bool>? selectedSlots,
    String? dietaryPreference,
    CalculatedPlan? weekData,
  }) {
    return WeekSelectionData(
      targetMealCount: targetMealCount ?? this.targetMealCount,
      selectedSlots: selectedSlots ?? this.selectedSlots,
      dietaryPreference: dietaryPreference ?? this.dietaryPreference,
      weekData: weekData ?? this.weekData,
    );
  }

  // Update slot selection
  WeekSelectionData toggleSlot(String slotKey) {
    final updatedSlots = Map<String, bool>.from(selectedSlots);
    updatedSlots[slotKey] = !(updatedSlots[slotKey] ?? false);

    return copyWith(selectedSlots: updatedSlots);
  }

  @override
  List<Object?> get props => [
    targetMealCount,
    selectedSlots,
    dietaryPreference,
    weekData,
  ];

  // Private helper methods
  String _getValidationMessage(int selected, int target) {
    if (selected == target) return "Week complete!";
    if (selected < target) return "Select ${target - selected} more meals";
    return "Remove ${selected - target} meals";
  }

  double _getPricePerMeal(int targetCount) {
    // Price per meal based on target meal count
    switch (targetCount) {
      case 10:
        return 45.0;
      case 15:
        return 42.0;
      case 21:
        return 38.0;
      default:
        return 40.0;
    }
  }
}

// Factory for creating initialized week selection data
class WeekSelectionDataFactory {
  static WeekSelectionData create({
    required int targetMealCount,
    required String dietaryPreference,
    CalculatedPlan? weekData,
  }) {
    // Initialize all 21 slots (7 days x 3 meals) as unselected
    const days = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];
    const meals = ['breakfast', 'lunch', 'dinner'];

    final Map<String, bool> initialSlots = {};
    for (final day in days) {
      for (final meal in meals) {
        initialSlots['$day::$meal'] = false;
      }
    }

    return WeekSelectionData(
      targetMealCount: targetMealCount,
      selectedSlots: initialSlots,
      dietaryPreference: dietaryPreference,
      weekData: weekData,
    );
  }
}
