// lib/src/domain/entities/meal_planning/week_validation_entity.dart
import 'package:equatable/equatable.dart';

enum ValidationStatus { empty, partial, complete, overSelected }

class WeekValidation extends Equatable {
  final int targetCount;
  final int selectedCount;
  final ValidationStatus status;
  final String message;
  final bool isValid;

  const WeekValidation({
    required this.targetCount,
    required this.selectedCount,
    required this.status,
    required this.message,
    required this.isValid,
  });

  factory WeekValidation.create({
    required int targetCount,
    required int selectedCount,
  }) {
    ValidationStatus status;
    String message;
    bool isValid;

    if (selectedCount == 0) {
      status = ValidationStatus.empty;
      message = 'No meals selected';
      isValid = false;
    } else if (selectedCount < targetCount) {
      status = ValidationStatus.partial;
      message = 'Select ${targetCount - selectedCount} more meals';
      isValid = false;
    } else if (selectedCount == targetCount) {
      status = ValidationStatus.complete;
      message = 'Week complete!';
      isValid = true;
    } else {
      status = ValidationStatus.overSelected;
      message = 'Too many meals selected';
      isValid = false;
    }

    return WeekValidation(
      targetCount: targetCount,
      selectedCount: selectedCount,
      status: status,
      message: message,
      isValid: isValid,
    );
  }

  // Check if more meals can be selected (hard limit enforcement)
  bool get canSelectMore => selectedCount < targetCount;

  // Calculate missing meals
  int get missingMeals => targetCount - selectedCount;

  // Check if week is complete
  bool get isComplete => status == ValidationStatus.complete;

  // Progress percentage (0.0 to 1.0)
  double get progressPercentage =>
      targetCount > 0 ? selectedCount / targetCount : 0.0;

  @override
  List<Object?> get props => [
    targetCount,
    selectedCount,
    status,
    message,
    isValid,
  ];
}
