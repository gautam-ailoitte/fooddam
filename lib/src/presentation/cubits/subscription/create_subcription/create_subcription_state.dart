// lib/src/presentation/cubits/subscription/create_subcription/create_subcription_state.dart
import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/calculated_plan.dart';
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

// State for package and meal count selection
class PackageSelectionActive extends SubscriptionCreationState {
  final String packageId;
  final int selectedMealCount; // 10, 15, 18, or 21
  final double pricePerWeek;
  final DateTime? startDate;
  final int? durationDays;

  const PackageSelectionActive({
    required this.packageId,
    required this.selectedMealCount,
    required this.pricePerWeek,
    this.startDate,
    this.durationDays,
  });

  @override
  List<Object?> get props => [
    packageId,
    selectedMealCount,
    pricePerWeek,
    startDate,
    durationDays,
  ];
}

// State for calculated plan loading
class CalculatedPlanLoading extends SubscriptionCreationState {}

// State for meal selection across multiple weeks
class MealSelectionActive extends SubscriptionCreationState {
  final DateTime startDate;
  final DateTime endDate;
  final int durationDays;
  final int personCount;
  final String? addressId;
  final String? instructions;
  final String packageId;
  final int mealCountPerWeek; // 10, 15, 18, or 21
  final double pricePerWeek;
  final CalculatedPlan? calculatedPlan;
  final List<WeekSelection> weekSelections;
  final double totalPrice;

  const MealSelectionActive({
    required this.startDate,
    required this.endDate,
    required this.durationDays,
    this.personCount = 1,
    this.addressId,
    this.instructions,
    required this.packageId,
    required this.mealCountPerWeek,
    required this.pricePerWeek,
    this.calculatedPlan,
    required this.weekSelections,
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
    packageId,
    mealCountPerWeek,
    pricePerWeek,
    calculatedPlan,
    weekSelections,
    totalPrice,
  ];

  // Check if all weeks have valid meal selections
  bool get isValid {
    return weekSelections.every((week) => week.isValid);
  }

  // Get total selected meals across all weeks
  int get totalSelectedMeals {
    return weekSelections.fold(0, (sum, week) => sum + week.selectedMealCount);
  }

  // Get required total meals
  int get requiredTotalMeals {
    return weekSelections.length * mealCountPerWeek;
  }

  MealSelectionActive copyWith({
    DateTime? startDate,
    DateTime? endDate,
    int? durationDays,
    int? personCount,
    String? addressId,
    String? instructions,
    String? packageId,
    int? mealCountPerWeek,
    double? pricePerWeek,
    CalculatedPlan? calculatedPlan,
    List<WeekSelection>? weekSelections,
    double? totalPrice,
  }) {
    return MealSelectionActive(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      durationDays: durationDays ?? this.durationDays,
      personCount: personCount ?? this.personCount,
      addressId: addressId ?? this.addressId,
      instructions: instructions ?? this.instructions,
      packageId: packageId ?? this.packageId,
      mealCountPerWeek: mealCountPerWeek ?? this.mealCountPerWeek,
      pricePerWeek: pricePerWeek ?? this.pricePerWeek,
      calculatedPlan: calculatedPlan ?? this.calculatedPlan,
      weekSelections: weekSelections ?? this.weekSelections,
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
  final DateTime weekStartDate;
  final DateTime weekEndDate;
  final List<DaySelection> daySelections;
  final int requiredMealCount; // Target meal count for this week

  WeekSelection({
    required this.weekNumber,
    required this.packageId,
    required this.weekStartDate,
    required this.weekEndDate,
    required this.daySelections,
    required this.requiredMealCount,
  });

  int get selectedMealCount {
    return daySelections.fold(0, (sum, day) => sum + day.selectedMealCount);
  }

  bool get isValid => selectedMealCount == requiredMealCount;

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
  final Map<String, MealSelection> mealSelections; // breakfast, lunch, dinner

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
      if (selection.isSelected && selection.mealId.isNotEmpty) {
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
  final String? mealName;
  final bool isSelected;
  final bool isAvailable;

  MealSelection({
    required this.mealId,
    this.mealName,
    this.isSelected = false,
    this.isAvailable = true,
  });
}
