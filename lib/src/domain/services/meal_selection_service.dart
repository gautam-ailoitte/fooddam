// lib/src/domain/services/meal_selection_service.dart
import 'package:flutter/foundation.dart';
import 'package:foodam/core/constants/subscription_constants.dart';
import 'package:foodam/src/data/datasource/remote_data_source.dart';
import 'package:foodam/src/domain/entities/meal_plan_item.dart';

import '../../presentation/cubits/subscription/week_selection/week_selection_state.dart';

/// Per-session service for managing meal selections
/// This service is created fresh for each planning session and manages
/// local selection state without triggering cubit rebuilds
class MealSelectionService extends ChangeNotifier {
  // Core planning data
  final DateTime startDate;
  final int durationWeeks;
  final int mealsPerWeek;
  final String dietaryPreference;

  // Local selection state - week -> selections map
  final Map<int, Set<DishSelection>> _weekSelections = {};

  // Week package mapping - week -> packageId
  final Map<int, String> _weekPackages = {};

  MealSelectionService({
    required this.startDate,
    required this.durationWeeks,
    required this.mealsPerWeek,
    required this.dietaryPreference,
  });

  // ==========================================
  // SELECTION MANAGEMENT
  // ==========================================

  /// Toggle dish selection for a specific week
  bool toggleDishSelection({
    required int week,
    required MealPlanItem item,
    required String packageId,
  }) {
    if (!_isValidWeek(week)) return false;

    // Store package ID for this week
    _weekPackages[week] = packageId;

    // Initialize week selections if needed
    _weekSelections[week] ??= <DishSelection>{};

    // Calculate the actual date for this selection
    final selectionDate = item.calculateDate(startDate, week);

    // Create selection object
    final selection = DishSelection.fromMealPlanItem(
      week: week,
      item: item,
      date: selectionDate,
      packageId: packageId,
    );

    final weekSelections = _weekSelections[week]!;

    // Check if already selected
    final existingSelection =
        weekSelections.where((s) => s.key == selection.key).firstOrNull;

    if (existingSelection != null) {
      // Remove selection
      weekSelections.remove(existingSelection);
      notifyListeners();
      return false; // Removed
    } else {
      // Check if can add more
      if (weekSelections.length >= mealsPerWeek) {
        return false; // Cannot add more
      }

      // Add selection
      weekSelections.add(selection);
      notifyListeners();
      return true; // Added
    }
  }

  /// Check if a specific dish is selected
  bool isDishSelected(int week, String dishId, String timing) {
    if (!_weekSelections.containsKey(week)) return false;

    return _weekSelections[week]!.any(
      (selection) =>
          selection.dishId == dishId &&
          selection.timing == timing &&
          selection.week == week,
    );
  }

  /// Get selection count for a specific week
  int getSelectionCount(int week) {
    return _weekSelections[week]?.length ?? 0;
  }

  /// Check if a week is complete (has required number of meals)
  bool isWeekComplete(int week) {
    return getSelectionCount(week) == mealsPerWeek;
  }

  /// Check if can select more meals for a week
  bool canSelectMore(int week) {
    return getSelectionCount(week) < mealsPerWeek;
  }

  /// Get all selections for a specific week
  List<DishSelection> getWeekSelections(int week) {
    return _weekSelections[week]?.toList() ?? [];
  }

  /// Get all selections across all weeks
  List<DishSelection> getAllSelections() {
    final allSelections = <DishSelection>[];
    for (final weekSelections in _weekSelections.values) {
      allSelections.addAll(weekSelections);
    }
    return allSelections;
  }

  /// Get selections grouped by meal type for a specific week
  Map<String, List<DishSelection>> getWeekSelectionsByMealType(int week) {
    final weekSelections = getWeekSelections(week);
    final grouped = <String, List<DishSelection>>{};

    for (final mealType in SubscriptionConstants.mealTypes) {
      grouped[mealType] =
          weekSelections
              .where((s) => s.timing.toLowerCase() == mealType.toLowerCase())
              .toList();
    }

    return grouped;
  }

  // ==========================================
  // VALIDATION & PROGRESS
  // ==========================================

  /// Check if all weeks are complete
  bool get isAllWeeksComplete {
    for (int week = 1; week <= durationWeeks; week++) {
      if (!isWeekComplete(week)) return false;
    }
    return true;
  }

  /// Get completion progress (0.0 to 1.0)
  double get completionProgress {
    final totalRequired = durationWeeks * mealsPerWeek;
    final totalSelected = getAllSelections().length;
    return totalRequired > 0 ? totalSelected / totalRequired : 0.0;
  }

  /// Get week completion status
  Map<int, bool> get weekCompletionStatus {
    final status = <int, bool>{};
    for (int week = 1; week <= durationWeeks; week++) {
      status[week] = isWeekComplete(week);
    }
    return status;
  }

  /// Get meal type distribution across all weeks
  Map<String, int> get mealTypeDistribution {
    final distribution = <String, int>{};

    for (final mealType in SubscriptionConstants.mealTypes) {
      distribution[mealType] = 0;
    }

    for (final selection in getAllSelections()) {
      final mealType = selection.timing.toLowerCase();
      distribution[mealType] = (distribution[mealType] ?? 0) + 1;
    }

    return distribution;
  }

  /// Get incomplete weeks list
  List<int> get incompleteWeeks {
    final incomplete = <int>[];
    for (int week = 1; week <= durationWeeks; week++) {
      if (!isWeekComplete(week)) {
        incomplete.add(week);
      }
    }
    return incomplete;
  }

  // ==========================================
  // API CONVERSION
  // ==========================================

  /// Build subscription request for API
  List<WeekSubscriptionRequest> buildSubscriptionRequest() {
    final weeks = <WeekSubscriptionRequest>[];

    for (int week = 1; week <= durationWeeks; week++) {
      final packageId = _weekPackages[week];
      final selections = getWeekSelections(week);

      if (packageId != null && selections.isNotEmpty) {
        final slots =
            selections
                .map(
                  (selection) => MealSlotRequest(
                    day: selection.day,
                    date: selection.date,
                    timing: selection.timing,
                    dishId: selection.dishId, // Correct field name
                  ),
                )
                .toList();

        weeks.add(WeekSubscriptionRequest(packageId: packageId, slots: slots));
      }
    }

    return weeks;
  }

  /// Validate selections for API submission
  String? validateForSubmission() {
    if (!isAllWeeksComplete) {
      final incomplete = incompleteWeeks;
      if (incomplete.length == 1) {
        return 'Week ${incomplete.first} needs ${mealsPerWeek - getSelectionCount(incomplete.first)} more meals';
      } else {
        return '${incomplete.length} weeks need more meals';
      }
    }

    // Check if all weeks have package IDs
    for (int week = 1; week <= durationWeeks; week++) {
      if (!_weekPackages.containsKey(week)) {
        return 'Week $week is missing package information';
      }
    }

    return null; // Valid
  }

  // ==========================================
  // UTILITY METHODS
  // ==========================================

  /// Clear all selections (start over)
  void reset() {
    _weekSelections.clear();
    _weekPackages.clear();
    notifyListeners();
  }

  /// Remove all selections for a specific week
  void clearWeek(int week) {
    _weekSelections.remove(week);
    _weekPackages.remove(week);
    notifyListeners();
  }

  /// Get summary statistics
  Map<String, dynamic> getSummaryStats() {
    return {
      'totalSelections': getAllSelections().length,
      'totalRequired': durationWeeks * mealsPerWeek,
      'completionProgress': completionProgress,
      'weekCompletionStatus': weekCompletionStatus,
      'mealTypeDistribution': mealTypeDistribution,
      'incompleteWeeks': incompleteWeeks,
      'isReadyForSubmission': isAllWeeksComplete,
    };
  }

  // ==========================================
  // PRIVATE HELPERS
  // ==========================================

  bool _isValidWeek(int week) {
    return week >= 1 && week <= durationWeeks;
  }
}

// Extension for list operations
extension _ListExtensions<T> on Iterable<T> {
  T? get firstOrNull {
    if (isEmpty) return null;
    return first;
  }
}
