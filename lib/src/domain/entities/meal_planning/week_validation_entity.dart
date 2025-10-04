// lib/src/domain/entities/meal_planning/week_validation_entity.dart
import 'package:equatable/equatable.dart';

class WeekValidation extends Equatable {
  final bool isValid;
  final String message;
  final int selectedCount;
  final int targetCount;
  final double progress;

  const WeekValidation({
    required this.isValid,
    required this.message,
    required this.selectedCount,
    required this.targetCount,
    required this.progress,
  });

  // Get missing meals count
  int get missingMeals => targetCount - selectedCount;

  // Get excess meals count
  int get excessMeals =>
      selectedCount > targetCount ? selectedCount - targetCount : 0;

  // Check if week is complete
  bool get isComplete => selectedCount == targetCount;

  // Check if week is over-selected
  bool get isOverSelected => selectedCount > targetCount;

  // Check if week is under-selected
  bool get isUnderSelected => selectedCount < targetCount;

  // Get status for UI styling
  ValidationStatus get status {
    if (isComplete) return ValidationStatus.complete;
    if (isOverSelected) return ValidationStatus.overSelected;
    if (selectedCount > 0) return ValidationStatus.partial;
    return ValidationStatus.empty;
  }

  // Get progress percentage (0-1)
  double get progressPercentage => progress.clamp(0.0, 1.0);

  @override
  List<Object?> get props => [
    isValid,
    message,
    selectedCount,
    targetCount,
    progress,
  ];
}

enum ValidationStatus { empty, partial, complete, overSelected }

// Validation status extensions for UI
extension ValidationStatusExtension on ValidationStatus {
  String get displayText {
    switch (this) {
      case ValidationStatus.empty:
        return 'No meals selected';
      case ValidationStatus.partial:
        return 'In progress';
      case ValidationStatus.complete:
        return 'Complete';
      case ValidationStatus.overSelected:
        return 'Too many meals';
    }
  }

  String get colorName {
    switch (this) {
      case ValidationStatus.empty:
        return 'grey';
      case ValidationStatus.partial:
        return 'warning';
      case ValidationStatus.complete:
        return 'success';
      case ValidationStatus.overSelected:
        return 'error';
    }
  }
}
