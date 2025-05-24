// lib/src/domain/service/subscription_service.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/data/datasource/remote_data_source.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';
import 'package:foodam/src/domain/services/week_data_service.dart';

class SubscriptionService {
  final RemoteDataSource _remoteDataSource;
  final LoggerService _logger = LoggerService();

  SubscriptionService({required RemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  /// Create subscription with meal selections
  Future<Either<Failure, Subscription>> createSubscription({
    required SubscriptionRequest request,
  }) async {
    try {
      _logger.i('Creating subscription with ${request.weeks.length} weeks');

      final subscriptionModel = await _remoteDataSource.createSubscription(
        startDate: request.startDate,
        endDate: request.endDate,
        durationDays: request.durationDays,
        addressId: request.addressId,
        instructions: request.instructions,
        noOfPersons: request.noOfPersons,
        weeks: request.weeks,
      );

      _logger.i('Subscription created successfully: ${subscriptionModel.id}');
      return Right(subscriptionModel.toEntity());
    } catch (e) {
      _logger.e('Failed to create subscription', error: e);
      if (e is Failure) {
        return Left(e);
      }
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  /// Build subscription request from meal selections
  static SubscriptionRequest buildRequest({
    required DateTime startDate,
    required int durationDays,
    required String addressId,
    String? instructions,
    required int noOfPersons,
    required List<MealSelection> selections,
    required Map<int, String> weekPackageIds,
  }) {
    // Group selections by week
    final Map<int, List<MealSelection>> selectionsByWeek = {};
    for (final selection in selections) {
      selectionsByWeek.putIfAbsent(selection.week, () => []).add(selection);
    }

    // Build week subscription requests
    final List<WeekSubscriptionRequest> weeks = [];
    for (final entry in selectionsByWeek.entries) {
      final week = entry.key;
      final weekSelections = entry.value;
      final packageId = weekPackageIds[week];

      if (packageId == null) {
        throw Exception('Missing package ID for week $week');
      }

      final slots =
          weekSelections.map((selection) {
            return MealSlotRequest(
              day: selection.dayName,
              date: selection.date,
              timing: selection.mealType,
              mealId:
                  selection.dishId, // This is the dish ID from calculated plan
            );
          }).toList();

      weeks.add(WeekSubscriptionRequest(packageId: packageId, slots: slots));
    }

    return SubscriptionRequest(
      startDate: startDate,
      endDate: startDate.add(Duration(days: durationDays)),
      durationDays: durationDays,
      addressId: addressId,
      instructions: instructions,
      noOfPersons: noOfPersons,
      weeks: weeks,
    );
  }

  /// Validate subscription request before submission
  static Either<String, void> validateRequest(SubscriptionRequest request) {
    // Check required fields
    if (request.addressId.isEmpty) {
      return const Left('Address is required');
    }

    if (request.noOfPersons <= 0) {
      return const Left('Number of persons must be greater than 0');
    }

    if (request.weeks.isEmpty) {
      return const Left('At least one week must be selected');
    }

    // Validate each week
    for (int i = 0; i < request.weeks.length; i++) {
      final week = request.weeks[i];

      if (week.packageId.isEmpty) {
        return Left('Week ${i + 1} is missing package ID');
      }

      if (week.slots.isEmpty) {
        return Left('Week ${i + 1} has no meal selections');
      }

      // Validate each slot
      for (final slot in week.slots) {
        if (slot.mealId.isEmpty) {
          return Left('Invalid meal selection in week ${i + 1}');
        }

        if (![
          'breakfast',
          'lunch',
          'dinner',
        ].contains(slot.timing.toLowerCase())) {
          return Left('Invalid meal timing "${slot.timing}" in week ${i + 1}');
        }

        if (![
          'monday',
          'tuesday',
          'wednesday',
          'thursday',
          'friday',
          'saturday',
          'sunday',
        ].contains(slot.day.toLowerCase())) {
          return Left('Invalid day "${slot.day}" in week ${i + 1}');
        }
      }
    }

    return const Right(null);
  }
}

/// Request model for subscription creation
class SubscriptionRequest {
  final DateTime startDate;
  final DateTime endDate;
  final int durationDays;
  final String addressId;
  final String? instructions;
  final int noOfPersons;
  final List<WeekSubscriptionRequest> weeks;

  const SubscriptionRequest({
    required this.startDate,
    required this.endDate,
    required this.durationDays,
    required this.addressId,
    this.instructions,
    required this.noOfPersons,
    required this.weeks,
  });

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'durationDays': durationDays,
      'address': addressId,
      'instructions': instructions,
      'noOfPersons': noOfPersons,
      'weeks': weeks.map((week) => week.toJson()).toList(),
    };
  }
}

/// Simple meal selection model (flat structure)
class MealSelection {
  final String id;
  final int week;
  final DateTime date;
  final String dayName;
  final String mealType;
  final String dishId;
  final String dishName;
  final String dishDescription;
  final String parentMealId;

  const MealSelection({
    required this.id,
    required this.week,
    required this.date,
    required this.dayName,
    required this.mealType,
    required this.dishId,
    required this.dishName,
    required this.dishDescription,
    required this.parentMealId,
  });

  /// Create from meal option when user selects it
  factory MealSelection.fromMealOption({
    required int week,
    required MealOption mealOption,
  }) {
    return MealSelection(
      id: '${week}_${mealOption.id}',
      week: week,
      date: mealOption.date,
      dayName: mealOption.dayName,
      mealType: mealOption.mealType,
      dishId: mealOption.dish.id,
      dishName: mealOption.dish.name,
      dishDescription: mealOption.dish.description,
      parentMealId: mealOption.parentMealId,
    );
  }

  /// Check if this is today's meal
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Get meal type display name
  String get mealTypeDisplay {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return 'Breakfast';
      case 'lunch':
        return 'Lunch';
      case 'dinner':
        return 'Dinner';
      default:
        return mealType;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MealSelection &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'MealSelection(week: $week, day: $dayName, type: $mealType, dish: $dishName)';
}

// Forward declaration of MealOption (will be imported from week_data_service.dart)
// class MealOption {
//   final String id;
//   final DateTime date;
//   final String dayName;
//   final String mealType;
//   final Dish dish;
//   final String parentMealId;
//
//   const MealOption({
//     required this.id,
//     required this.date,
//     required this.dayName,
//     required this.mealType,
//     required this.dish,
//     required this.parentMealId,
//   });
// }

// Forward declaration (will be imported)
class Dish {
  final String id;
  final String name;
  final String description;
  final List<String> dietaryPreferences;
  final bool isAvailable;
  final String? imageUrl;

  const Dish({
    required this.id,
    required this.name,
    required this.description,
    this.dietaryPreferences = const [],
    this.isAvailable = true,
    this.imageUrl,
  });
}
