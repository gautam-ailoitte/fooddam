// lib/src/presentation/cubits/subscription_creation/subscription_creation_state.dart
import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';

abstract class SubscriptionCreationState extends Equatable {
  const SubscriptionCreationState();

  @override
  List<Object?> get props => [];
}

class SubscriptionCreationInitial extends SubscriptionCreationState {}

class SubscriptionCreationLoading extends SubscriptionCreationState {}

class SubscriptionCreationError extends SubscriptionCreationState {
  final String message;

  const SubscriptionCreationError(this.message);

  @override
  List<Object?> get props => [message];
}

class MealSelectionActive extends SubscriptionCreationState {
  final DateTime startDate;
  final DateTime endDate;
  final int durationDays;
  final int personCount;
  final String? addressId;
  final String? instructions;

  final List<WeekSelection> weekSelections;

  final int totalSelectedMeals;
  final int requiredMealCount;
  final double totalPrice;

  const MealSelectionActive({
    required this.startDate,
    required this.endDate,
    required this.durationDays,
    this.personCount = 1,
    this.addressId,
    this.instructions,
    required this.weekSelections,
    required this.totalSelectedMeals,
    required this.requiredMealCount,
    required this.totalPrice,
  });

  @override
  List<Object?> get props => [
    startDate,
    endDate,
    durationDays,
    personCount,
    addressId,
    instructions,
    weekSelections,
    totalSelectedMeals,
    requiredMealCount,
    totalPrice,
  ];

  bool get isValid => totalSelectedMeals == requiredMealCount;

  MealSelectionActive copyWith({
    DateTime? startDate,
    DateTime? endDate,
    int? durationDays,
    int? personCount,
    String? addressId,
    String? instructions,
    List<WeekSelection>? weekSelections,
    int? totalSelectedMeals,
    int? requiredMealCount,
    double? totalPrice,
  }) {
    return MealSelectionActive(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      durationDays: durationDays ?? this.durationDays,
      personCount: personCount ?? this.personCount,
      addressId: addressId ?? this.addressId,
      instructions: instructions ?? this.instructions,
      weekSelections: weekSelections ?? this.weekSelections,
      totalSelectedMeals: totalSelectedMeals ?? this.totalSelectedMeals,
      requiredMealCount: requiredMealCount ?? this.requiredMealCount,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }
}

class SubscriptionCreationSuccess extends SubscriptionCreationState {
  final Subscription subscription;

  const SubscriptionCreationSuccess({required this.subscription});

  @override
  List<Object?> get props => [subscription];
}

// Helper classes for managing selections
class WeekSelection {
  final int weekNumber;
  final String packageId;
  final List<DaySelection> daySelections;

  WeekSelection({
    required this.weekNumber,
    required this.packageId,
    required this.daySelections,
  });

  int get selectedMealCount {
    return daySelections.fold(0, (sum, day) => sum + day.selectedMealCount);
  }

  List<Map<String, dynamic>> toSlotList() {
    final slots = <Map<String, dynamic>>[];

    for (final day in daySelections) {
      slots.addAll(day.toSlotList());
    }

    return slots;
  }
}

class DaySelection {
  final DateTime date;
  final String day;
  final Map<String, MealSelection> mealSelections;

  DaySelection({
    required this.date,
    required this.day,
    required this.mealSelections,
  });

  int get selectedMealCount {
    return mealSelections.values
        .where((selection) => selection.isSelected)
        .length;
  }

  List<Map<String, dynamic>> toSlotList() {
    final slots = <Map<String, dynamic>>[];

    mealSelections.forEach((timing, selection) {
      if (selection.isSelected) {
        slots.add({
          'day': day,
          'date': date.toIso8601String(),
          'timing': timing,
          'meal': selection.mealId,
        });
      }
    });

    return slots;
  }
}

class MealSelection {
  final String mealId;
  final bool isSelected;

  MealSelection({required this.mealId, this.isSelected = false});
}
