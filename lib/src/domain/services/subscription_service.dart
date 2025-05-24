// lib/src/domain/services/subscription_service.dart (ENHANCED)
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/data/datasource/remote_data_source.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';
import 'package:foodam/src/domain/services/week_data_service.dart';

/// Enhanced subscription service with comprehensive request building and validation
class SubscriptionService {
  final RemoteDataSource _remoteDataSource;
  final LoggerService _logger = LoggerService();

  SubscriptionService({required RemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  /// Create subscription with comprehensive error handling
  Future<Either<Failure, Subscription>> createSubscription({
    required SubscriptionRequest request,
  }) async {
    try {
      _logger.i('Creating subscription with ${request.weeks.length} weeks');

      // Final validation before API call
      final validation = validateRequest(request);
      if (validation.isLeft()) {
        return validation.fold(
          (error) => Left(ValidationFailure(error)),
          (_) => throw Exception('Unexpected validation result'),
        );
      }

      // Convert to API format
      final apiWeeks =
          request.weeks.map((week) {
            return WeekSubscriptionRequest(
              packageId: week.packageId,
              slots:
                  week.slots.map((slot) {
                    return MealSlotRequest(
                      day: slot.dayName.toLowerCase(),
                      date: slot.date,
                      timing: slot.mealType.toLowerCase(),
                      dishId: slot.dishId,
                    );
                  }).toList(),
            );
          }).toList();

      // Make API call
      final subscriptionModel = await _remoteDataSource.createSubscription(
        startDate: request.startDate,
        endDate: request.endDate,
        durationDays: request.durationDays,
        addressId: request.addressId,
        instructions: request.instructions,
        noOfPersons: request.noOfPersons,
        weeks: apiWeeks,
      );

      _logger.i('Subscription created successfully: ${subscriptionModel.id}');
      return Right(subscriptionModel.toEntity());
    } catch (e) {
      _logger.e('Error creating subscription', error: e);

      if (e.toString().contains('network') ||
          e.toString().contains('connection')) {
        return Left(
          NetworkFailure(
            'Network error occurred. Please check your connection.',
          ),
        );
      } else if (e.toString().contains('unauthorized') ||
          e.toString().contains('401')) {
        return Left(AuthFailure('Authentication failed. Please login again.'));
      } else if (e.toString().contains('validation') ||
          e.toString().contains('400')) {
        return Left(
          ValidationFailure(
            'Invalid subscription data. Please review your selections.',
          ),
        );
      } else {
        return Left(
          ServerFailure('Failed to create subscription. Please try again.'),
        );
      }
    }
  }

  /// Build subscription request from planning data
  static SubscriptionRequest buildRequest({
    required DateTime startDate,
    required int durationDays,
    required String addressId,
    String? instructions,
    required int noOfPersons,
    required List<MealSelection> selections,
    required Map<int, String> weekPackageIds,
  }) {
    final LoggerService logger = LoggerService();

    try {
      logger.i(
        'Building subscription request for ${selections.length} selections',
      );

      // Calculate end date
      final endDate = startDate.add(Duration(days: durationDays - 1));

      // Group selections by week
      final Map<int, List<MealSelection>> weekSelections = {};
      for (final selection in selections) {
        weekSelections.putIfAbsent(selection.week, () => []).add(selection);
      }

      // Build weeks
      final List<WeekSubscriptionData> weeks = [];
      for (final entry in weekSelections.entries) {
        final week = entry.key;
        final weekSelectionsList = entry.value;
        final packageId = weekPackageIds[week];

        if (packageId == null) {
          throw Exception('Package ID not found for week $week');
        }

        // Convert selections to slots
        final slots =
            weekSelectionsList.map((selection) {
              return SubscriptionSlotData(
                dayName: selection.dayName,
                date: selection.date,
                mealType: selection.mealType,
                dishId: selection.dishId,
              );
            }).toList();

        weeks.add(
          WeekSubscriptionData(week: week, packageId: packageId, slots: slots),
        );
      }

      // Sort weeks by week number
      weeks.sort((a, b) => a.week.compareTo(b.week));

      logger.d('Built subscription request with ${weeks.length} weeks');

      return SubscriptionRequest(
        startDate: startDate,
        endDate: endDate,
        durationDays: durationDays,
        addressId: addressId,
        instructions: instructions,
        noOfPersons: noOfPersons,
        weeks: weeks,
      );
    } catch (e) {
      logger.e('Error building subscription request', error: e);
      rethrow;
    }
  }

  /// Comprehensive request validation
  static Either<String, void> validateRequest(SubscriptionRequest request) {
    final LoggerService logger = LoggerService();

    try {
      logger.d('Validating subscription request');

      // Basic validation
      if (request.startDate.isBefore(
        DateTime.now().subtract(const Duration(days: 1)),
      )) {
        return const Left('Start date cannot be in the past');
      }

      if (request.endDate.isBefore(request.startDate)) {
        return const Left('End date must be after start date');
      }

      if (request.durationDays <= 0) {
        return const Left('Duration must be positive');
      }

      if (request.addressId.isEmpty) {
        return const Left('Address is required');
      }

      if (request.noOfPersons <= 0) {
        return const Left('Number of persons must be positive');
      }

      if (request.weeks.isEmpty) {
        return const Left('At least one week must be selected');
      }

      // Week validation
      for (int i = 0; i < request.weeks.length; i++) {
        final week = request.weeks[i];
        final weekNumber = i + 1;

        if (week.packageId.isEmpty) {
          return Left('Package ID is required for week $weekNumber');
        }

        if (week.slots.isEmpty) {
          return Left(
            'At least one meal must be selected for week $weekNumber',
          );
        }

        // Slot validation
        for (int j = 0; j < week.slots.length; j++) {
          final slot = week.slots[j];
          final slotNumber = j + 1;

          if (slot.dayName.isEmpty) {
            return Left(
              'Day name is required for week $weekNumber, slot $slotNumber',
            );
          }

          if (slot.mealType.isEmpty) {
            return Left(
              'Meal type is required for week $weekNumber, slot $slotNumber',
            );
          }

          if (slot.dishId.isEmpty) {
            return Left(
              'Dish ID is required for week $weekNumber, slot $slotNumber',
            );
          }

          // Validate meal type
          final validMealTypes = ['breakfast', 'lunch', 'dinner'];
          if (!validMealTypes.contains(slot.mealType.toLowerCase())) {
            return Left(
              'Invalid meal type "${slot.mealType}" for week $weekNumber, slot $slotNumber',
            );
          }

          // Validate day name
          final validDays = [
            'monday',
            'tuesday',
            'wednesday',
            'thursday',
            'friday',
            'saturday',
            'sunday',
          ];
          if (!validDays.contains(slot.dayName.toLowerCase())) {
            return Left(
              'Invalid day name "${slot.dayName}" for week $weekNumber, slot $slotNumber',
            );
          }

          // Validate date is within subscription period
          if (slot.date.isBefore(request.startDate) ||
              slot.date.isAfter(request.endDate)) {
            return Left(
              'Slot date is outside subscription period for week $weekNumber, slot $slotNumber',
            );
          }
        }

        // Check for duplicate slots (same day + meal type)
        final slotKeys =
            week.slots
                .map((slot) => '${slot.dayName}_${slot.mealType}')
                .toList();
        final uniqueSlotKeys = slotKeys.toSet();
        if (slotKeys.length != uniqueSlotKeys.length) {
          return Left('Duplicate meal slots found in week $weekNumber');
        }
      }

      // Cross-week validation
      final weekNumbers = request.weeks.map((w) => w.week).toList();
      final uniqueWeekNumbers = weekNumbers.toSet();
      if (weekNumbers.length != uniqueWeekNumbers.length) {
        return const Left('Duplicate week numbers found');
      }

      // Check week sequence
      weekNumbers.sort();
      for (int i = 0; i < weekNumbers.length; i++) {
        if (weekNumbers[i] != i + 1) {
          return const Left('Week numbers must be sequential starting from 1');
        }
      }

      logger.d('Subscription request validation passed');
      return const Right(null);
    } catch (e) {
      logger.e('Error during request validation', error: e);
      return Left('Validation error: ${e.toString()}');
    }
  }

  /// Generate request summary for logging/debugging
  static Map<String, dynamic> getRequestSummary(SubscriptionRequest request) {
    return {
      'startDate': request.startDate.toIso8601String(),
      'endDate': request.endDate.toIso8601String(),
      'durationDays': request.durationDays,
      'noOfPersons': request.noOfPersons,
      'totalWeeks': request.weeks.length,
      'totalSlots': request.weeks.fold<int>(
        0,
        (sum, week) => sum + week.slots.length,
      ),
      'hasInstructions': request.instructions?.isNotEmpty ?? false,
      'weekSummary':
          request.weeks
              .map(
                (week) => {
                  'week': week.week,
                  'packageId': week.packageId,
                  'slotCount': week.slots.length,
                  'mealTypes':
                      week.slots.map((slot) => slot.mealType).toSet().toList(),
                },
              )
              .toList(),
    };
  }
}

/// Subscription request data structure
class SubscriptionRequest {
  final DateTime startDate;
  final DateTime endDate;
  final int durationDays;
  final String addressId;
  final String? instructions;
  final int noOfPersons;
  final List<WeekSubscriptionData> weeks;

  const SubscriptionRequest({
    required this.startDate,
    required this.endDate,
    required this.durationDays,
    required this.addressId,
    this.instructions,
    required this.noOfPersons,
    required this.weeks,
  });

  /// Convert to JSON for debugging
  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'durationDays': durationDays,
      'address': addressId,
      'instructions': instructions,
      'noOfPersons': noOfPersons,
      'weeks':
          weeks
              .map(
                (week) => {
                  'package': week.packageId,
                  'slots':
                      week.slots
                          .map(
                            (slot) => {
                              'day': slot.dayName.toLowerCase(),
                              'date': slot.date.toIso8601String(),
                              'timing': slot.mealType.toLowerCase(),
                              'meal': slot.dishId,
                            },
                          )
                          .toList(),
                },
              )
              .toList(),
    };
  }
}

/// Week subscription data
class WeekSubscriptionData {
  final int week;
  final String packageId;
  final List<SubscriptionSlotData> slots;

  const WeekSubscriptionData({
    required this.week,
    required this.packageId,
    required this.slots,
  });
}

/// Subscription slot data
class SubscriptionSlotData {
  final String dayName;
  final DateTime date;
  final String mealType;
  final String dishId;

  const SubscriptionSlotData({
    required this.dayName,
    required this.date,
    required this.mealType,
    required this.dishId,
  });
}
