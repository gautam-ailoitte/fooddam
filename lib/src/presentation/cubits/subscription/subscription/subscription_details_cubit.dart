// lib/src/presentation/cubits/subscription/subscription/subscription_details_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/domain/entities/meal_slot_entity.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';
import 'package:foodam/src/domain/usecase/susbcription_usecase.dart';
import 'package:foodam/src/presentation/cubits/subscription/subscription/subscription_details_state.dart';

/// Consolidated Subscription Cubit
///
/// This class manages the viewing and manipulation of subscriptions
/// including loading active subscriptions, viewing details, and managing
/// subscription status (pause, resume, cancel)
class SubscriptionCubit extends Cubit<SubscriptionState> {
  final SubscriptionUseCase _subscriptionUseCase;
  final LoggerService _logger = LoggerService();

  SubscriptionCubit({required SubscriptionUseCase subscriptionUseCase})
    : _subscriptionUseCase = subscriptionUseCase,
      super(const SubscriptionInitial());

  /// Load all active subscriptions for the current user
  Future<void> loadActiveSubscriptions() async {
    // If we're not already in a loading state, show loading
    if (state is! SubscriptionLoading) {
      emit(const SubscriptionLoading());
    }

    final result = await _subscriptionUseCase.getActiveSubscriptions();

    result.fold(
      (failure) {
        _logger.e('Failed to get active subscriptions', error: failure);
        emit(SubscriptionError(message: 'Failed to load your subscriptions'));
      },
      (subscriptions) {
        // Separate subscriptions by status
        final active =
            subscriptions
                .where(
                  (sub) =>
                      sub.status == SubscriptionStatus.active && !sub.isPaused,
                )
                .toList();

        final paused =
            subscriptions
                .where(
                  (sub) =>
                      sub.status == SubscriptionStatus.paused || sub.isPaused,
                )
                .toList();

        final pending =
            subscriptions
                .where((sub) => sub.status == SubscriptionStatus.pending)
                .toList();

        _logger.i(
          'Subscriptions loaded: ${subscriptions.length} total, '
          '${active.length} active, ${paused.length} paused, ${pending.length} pending',
        );

        // If we already have a SubscriptionLoaded state with a selected subscription,
        // preserve that selection but with updated lists
        if (state is SubscriptionLoaded &&
            (state as SubscriptionLoaded).hasSelectedSubscription) {
          final currentState = state as SubscriptionLoaded;
          final selectedSubId = currentState.selectedSubscription!.id;

          // Find the updated version of the selected subscription
          Subscription? updatedSelectedSub;
          try {
            updatedSelectedSub = subscriptions.firstWhere(
              (sub) => sub.id == selectedSubId,
            );

            // Calculate days remaining
            final daysRemaining = _subscriptionUseCase.calculateRemainingDays(
              updatedSelectedSub,
            );

            emit(
              SubscriptionLoaded(
                subscriptions: subscriptions,
                activeSubscriptions: active,
                pausedSubscriptions: paused,
                pendingSubscriptions: pending,
                selectedSubscription: updatedSelectedSub,
                daysRemaining: daysRemaining,
                weeklyMeals: currentState.weeklyMeals,
                upcomingMeals: currentState.upcomingMeals,
              ),
            );
          } catch (e) {
            // The subscription may have been deleted, so emit without a selected subscription
            emit(
              SubscriptionLoaded(
                subscriptions: subscriptions,
                activeSubscriptions: active,
                pausedSubscriptions: paused,
                pendingSubscriptions: pending,
              ),
            );
          }
        } else {
          // Otherwise just emit the new lists without a selected subscription
          emit(
            SubscriptionLoaded(
              subscriptions: subscriptions,
              activeSubscriptions: active,
              pausedSubscriptions: paused,
              pendingSubscriptions: pending,
            ),
          );
        }
      },
    );
  }

  /// Load details for a specific subscription (for detail screen)
  Future<void> loadSubscriptionDetails(
    String subscriptionId, {
    bool forceRefresh = false,
  }) async {
    emit(const SubscriptionLoading());

    // Fetch from API
    final result = await _subscriptionUseCase.getSubscriptionById(
      subscriptionId,
    );

    result.fold(
      (failure) {
        _logger.e('Failed to get subscription details', error: failure);

        // NetworkFailure or other error types will be returned by the repository
        final bool isNetworkError =
            failure.message?.toLowerCase().contains('network') ?? false;

        emit(
          SubscriptionError(
            message:
                isNetworkError
                    ? 'No internet connection'
                    : 'Failed to load subscription details',
          ),
        );
      },
      (subscription) {
        final daysRemaining = _calculateRemainingDays(subscription);

        // Process subscription weeks and meals
        final weeklyMeals = _processSubscriptionWeeks(subscription);
        final upcomingMeals = _extractUpcomingMeals(subscription);

        if (state is SubscriptionLoaded) {
          final currentState = state as SubscriptionLoaded;

          // Update the subscription in our lists
          final List<Subscription> updatedList = _updateSubscriptionInList(
            currentState.subscriptions,
            subscription,
          );

          // Recategorize all subscriptions
          final active =
              updatedList
                  .where(
                    (sub) =>
                        sub.status == SubscriptionStatus.active &&
                        !sub.isPaused,
                  )
                  .toList();

          final paused =
              updatedList
                  .where(
                    (sub) =>
                        sub.status == SubscriptionStatus.paused || sub.isPaused,
                  )
                  .toList();

          final pending =
              updatedList
                  .where((sub) => sub.status == SubscriptionStatus.pending)
                  .toList();

          emit(
            SubscriptionLoaded(
              subscriptions: updatedList,
              activeSubscriptions: active,
              pausedSubscriptions: paused,
              pendingSubscriptions: pending,
              filteredSubscriptions: currentState.filteredSubscriptions,
              filterType: currentState.filterType,
              filterValue: currentState.filterValue,
              selectedSubscription: subscription,
              daysRemaining: daysRemaining,
              weeklyMeals: weeklyMeals,
              upcomingMeals: upcomingMeals,
            ),
          );
        } else {
          // Create initial state with just this subscription
          emit(
            SubscriptionLoaded(
              subscriptions: [subscription],
              activeSubscriptions:
                  subscription.status == SubscriptionStatus.active &&
                          !subscription.isPaused
                      ? [subscription]
                      : [],
              pausedSubscriptions:
                  (subscription.status == SubscriptionStatus.paused ||
                          subscription.isPaused)
                      ? [subscription]
                      : [],
              pendingSubscriptions:
                  subscription.status == SubscriptionStatus.pending
                      ? [subscription]
                      : [],
              selectedSubscription: subscription,
              daysRemaining: daysRemaining,
              weeklyMeals: weeklyMeals,
              upcomingMeals: upcomingMeals,
            ),
          );
        }

        _logger.i('Loaded subscription details: ${subscription.id}');
      },
    );
  }

  /// Pause a subscription until a specific date
  Future<void> pauseSubscription(String subscriptionId) async {
    emit(const SubscriptionActionInProgress(action: 'pause'));

    final result = await _subscriptionUseCase.manageSubscription(
      subscriptionId,
      SubscriptionAction.pause,
    );

    result.fold(
      (failure) {
        _logger.e('Failed to pause subscription', error: failure);
        emit(SubscriptionError(message: 'Failed to pause subscription'));
      },
      (_) {
        _logger.i('Subscription paused successfully: $subscriptionId');

        // First emit success
        emit(
          const SubscriptionActionSuccess(
            action: 'pause',
            message: 'Your subscription has been paused',
          ),
        );

        // Then reload all data to reflect changes
        loadSubscriptionDetails(subscriptionId);
      },
    );
  }

  /// Resume a paused subscription
  Future<void> resumeSubscription(String subscriptionId) async {
    emit(const SubscriptionActionInProgress(action: 'resume'));

    final result = await _subscriptionUseCase.manageSubscription(
      subscriptionId,
      SubscriptionAction.resume,
    );

    result.fold(
      (failure) {
        _logger.e('Failed to resume subscription', error: failure);
        emit(SubscriptionError(message: 'Failed to resume subscription'));
      },
      (_) {
        _logger.i('Subscription resumed successfully: $subscriptionId');

        // First emit success
        emit(
          const SubscriptionActionSuccess(
            action: 'resume',
            message: 'Your subscription has been resumed successfully',
          ),
        );

        // Then reload all data to reflect changes
        loadSubscriptionDetails(subscriptionId);
      },
    );
  }

  /// Cancel a subscription
  Future<void> cancelSubscription(String subscriptionId) async {
    emit(const SubscriptionActionInProgress(action: 'cancel'));

    final result = await _subscriptionUseCase.manageSubscription(
      subscriptionId,
      SubscriptionAction.cancel,
    );

    result.fold(
      (failure) {
        _logger.e('Failed to cancel subscription', error: failure);
        emit(SubscriptionError(message: 'Failed to cancel subscription'));
      },
      (_) {
        _logger.i('Subscription cancelled successfully: $subscriptionId');

        // First emit success
        emit(
          const SubscriptionActionSuccess(
            action: 'cancel',
            message: 'Your subscription has been cancelled',
          ),
        );

        // Then reload all subscriptions to reflect changes
        loadActiveSubscriptions();
      },
    );
  }

  /// Get total meals count for a subscription
  int getTotalMealCount(Subscription subscription) {
    // First check if totalSlots is available in the subscription
    if (subscription.totalSlots > 0) {
      return subscription.totalSlots;
    }
    // Fall back to calculation
    return _calculateTotalMeals(subscription);
  }

  /// Get meals for a specific meal time (breakfast, lunch, dinner)
  List<MealSlot> getMealsForTime(Subscription subscription, String mealTime) {
    final mealSlots = <MealSlot>[];

    // Check if weeks is available in the subscription
    if (subscription.weeks == null || subscription.weeks!.isEmpty) {
      return mealSlots;
    }

    // Iterate through all weeks and slots
    for (final week in subscription.weeks!) {
      for (final slot in week.slots) {
        if (slot.timing.toLowerCase() == mealTime.toLowerCase() &&
            slot.meal != null) {
          mealSlots.add(slot);
        }
      }
    }

    return mealSlots;
  }

  /// Get today's meals from the subscription
  List<MealSlot> getTodayMeals(Subscription subscription) {
    final today = DateTime.now();
    final todayMeals = <MealSlot>[];

    // Check if weeks is available
    if (subscription.weeks == null || subscription.weeks!.isEmpty) {
      return todayMeals;
    }

    // Find today's meals
    for (final weekPlan in subscription.weeks!) {
      for (final slot in weekPlan.slots) {
        if (slot.date != null &&
            slot.date!.year == today.year &&
            slot.date!.month == today.month &&
            slot.date!.day == today.day &&
            slot.meal != null) {
          todayMeals.add(slot);
        }
      }
    }

    // Sort by meal time
    todayMeals.sort((a, b) {
      final aOrder = _getMealTimeOrder(a.timing);
      final bOrder = _getMealTimeOrder(b.timing);
      return aOrder.compareTo(bOrder);
    });

    return todayMeals;
  }

  // Helper methods

  /// Process subscription weeks to get structured weekly meal data
  List<SubscriptionWeek> _processSubscriptionWeeks(Subscription subscription) {
    final result = <SubscriptionWeek>[];

    // Check if weeks is available
    if (subscription.weeks == null || subscription.weeks!.isEmpty) {
      return result;
    }

    // Process each week
    for (final weekPlan in subscription.weeks!) {
      final weekNumber = weekPlan.week;
      final packageId = weekPlan.package?.id ?? '';
      final packageName = weekPlan.package?.name ?? 'Unknown Package';

      // Group slots by day
      final slotsByDay = <String, List<MealSlot>>{};

      for (final slot in weekPlan.slots) {
        final day = slot.day.toLowerCase();
        slotsByDay.putIfAbsent(day, () => []);
        slotsByDay[day]!.add(slot);
      }

      // Create daily meals
      final dailyMeals = <SubscriptionDayMeal>[];

      for (final day in slotsByDay.keys) {
        final slots = slotsByDay[day]!;

        // Group slots by timing
        final mealsByType = <String, MealSlot?>{
          'breakfast': null,
          'lunch': null,
          'dinner': null,
        };

        // Use the first slot's date
        DateTime? date;
        if (slots.isNotEmpty && slots.first.date != null) {
          date = slots.first.date;
        }

        // Assign meals by type
        for (final slot in slots) {
          final timing = slot.timing.toLowerCase();
          if (mealsByType.containsKey(timing)) {
            mealsByType[timing] = slot;
          }
        }

        // Only add if we have a date
        if (date != null) {
          dailyMeals.add(
            SubscriptionDayMeal(date: date, day: day, mealsByType: mealsByType),
          );
        }
      }

      // Sort daily meals by date
      dailyMeals.sort((a, b) => a.date.compareTo(b.date));

      // Add the week
      result.add(
        SubscriptionWeek(
          weekNumber: weekNumber,
          packageId: packageId,
          packageName: packageName,
          dailyMeals: dailyMeals,
        ),
      );
    }

    return result;
  }

  /// Extract upcoming meals from a subscription
  List<MealSlot> _extractUpcomingMeals(Subscription subscription) {
    final now = DateTime.now();
    final upcomingMeals = <MealSlot>[];

    // Check if weeks is available
    if (subscription.weeks == null || subscription.weeks!.isEmpty) {
      return upcomingMeals;
    }

    // Find upcoming meals
    for (final weekPlan in subscription.weeks!) {
      for (final slot in weekPlan.slots) {
        if (slot.date != null && slot.date!.isAfter(now) && slot.meal != null) {
          upcomingMeals.add(slot);
        }
      }
    }

    // Sort by date
    upcomingMeals.sort((a, b) {
      final dateComparison = a.date!.compareTo(b.date!);
      if (dateComparison != 0) {
        return dateComparison;
      }

      // If same date, sort by meal time
      return _getMealTimeOrder(a.timing).compareTo(_getMealTimeOrder(b.timing));
    });

    return upcomingMeals;
  }

  /// Get numerical order for meal times
  int _getMealTimeOrder(String mealTime) {
    switch (mealTime.toLowerCase()) {
      case 'breakfast':
        return 0;
      case 'lunch':
        return 1;
      case 'dinner':
        return 2;
      default:
        return 3;
    }
  }

  /// Helper method to calculate remaining days
  int _calculateRemainingDays(Subscription subscription) {
    final now = DateTime.now();

    // Try to get endDate directly if available
    if (subscription.endDate != null) {
      if (now.isAfter(subscription.endDate!)) {
        return 0;
      }
      return subscription.endDate!.difference(now).inDays;
    }

    // Calculate based on startDate and durationDays
    final endDate = subscription.startDate.add(
      Duration(days: subscription.durationDays),
    );

    if (now.isAfter(endDate)) {
      return 0;
    }

    return endDate.difference(now).inDays;
  }

  /// Helper method to calculate total meals
  int _calculateTotalMeals(Subscription subscription) {
    // If totalSlots is provided, use it
    if (subscription.totalSlots > 0) {
      return subscription.totalSlots;
    }

    // If weeks is available, count slots
    if (subscription.weeks != null && subscription.weeks!.isNotEmpty) {
      int totalSlots = 0;
      for (final weekPlan in subscription.weeks!) {
        totalSlots += weekPlan.slots.length;
      }
      return totalSlots;
    }

    // Default case - calculate based on duration (3 meals per day)
    return subscription.durationDays * 3;
  }

  /// Update a subscription in the list
  List<Subscription> _updateSubscriptionInList(
    List<Subscription> subscriptions,
    Subscription updatedSubscription,
  ) {
    final index = subscriptions.indexWhere(
      (sub) => sub.id == updatedSubscription.id,
    );
    final newList = List<Subscription>.from(subscriptions);

    if (index >= 0) {
      newList[index] = updatedSubscription;
    } else {
      newList.add(updatedSubscription);
    }

    return newList;
  }

  /// Format date to string
  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
