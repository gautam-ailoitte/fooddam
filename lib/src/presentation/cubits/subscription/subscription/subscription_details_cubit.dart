// lib/src/presentation/cubits/subscription/subscription/subscription_details_cubit.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/core/service/navigation_service.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';
import 'package:foodam/src/domain/usecase/susbcription_usecase.dart';
import 'package:foodam/src/presentation/cubits/meal/meal_cubit.dart';
import 'package:foodam/src/presentation/cubits/subscription/subscription/subscription_details_state.dart';

/// Consolidated Subscription Cubit
///
/// This class consolidates multiple previously separate cubits:
/// - ActiveSubscriptionCubit
/// - SubscriptionDetailCubit
/// - CreateSubscriptionCubit
class SubscriptionCubit extends Cubit<SubscriptionState> {
  final SubscriptionUseCase _subscriptionUseCase;
  final LoggerService _logger = LoggerService();
  final MealCubit mealCubit;

  SubscriptionCubit({
    required SubscriptionUseCase subscriptionUseCase,
    required this.mealCubit,
  }) : _subscriptionUseCase = subscriptionUseCase,
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
          'Subscriptions loaded: ${subscriptions.length} total, ' +
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
  /// This method first tries to find the subscription in the existing loaded subscriptions
  /// If not found, it uses the provided subscription object directly
  Future<void> loadSubscriptionDetails(
    String subscriptionId, {
    bool forceRefresh = false,
  }) async {
    // Skip if already selected and no refresh requested
    if (!forceRefresh && state is SubscriptionLoaded) {
      final currentState = state as SubscriptionLoaded;

      // If the exact same subscription is already selected, don't reload
      if (currentState.selectedSubscription != null &&
          currentState.selectedSubscription!.id == subscriptionId) {
        _logger.d(
          'Subscription $subscriptionId already selected, skipping reload',
        );
        return;
      }

      // Check if we have this subscription in our current cache
      try {
        final foundSubscription = currentState.subscriptions.firstWhere(
          (sub) => sub.id == subscriptionId,
        );

        // Calculate days remaining
        final daysRemaining = _subscriptionUseCase.calculateRemainingDays(
          foundSubscription,
        );

        // Use cached data by emitting the same state with a different selected subscription
        emit(
          currentState.withSelectedSubscription(
            foundSubscription,
            daysRemaining,
          ),
        );
        _logger.i('Using cached subscription details: ${foundSubscription.id}');
        return;
      } catch (e) {
        // Not found in current state, continue to API fetch
        _logger.d('Subscription not found in cached data, fetching from API');
      }
    }

    // Only show loading state if we don't already have subscription data
    final bool hadPreviousData = state is SubscriptionLoaded;
    if (!hadPreviousData) {
      emit(const SubscriptionLoading());
    }

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

        if (hadPreviousData && state is SubscriptionLoaded) {
          // If we had previous data, show a brief error but keep the UI working
          ScaffoldMessenger.of(_getGlobalContext()).showSnackBar(
            SnackBar(
              content: Text(
                isNetworkError
                    ? 'No internet connection'
                    : 'Failed to load latest subscription details',
              ),
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          // If we didn't have data, show the error state
          emit(
            SubscriptionError(
              message:
                  isNetworkError
                      ? 'No internet connection'
                      : 'Failed to load subscription details',
            ),
          );
        }
      },
      (subscription) {
        final daysRemaining = _subscriptionUseCase.calculateRemainingDays(
          subscription,
        );

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
          SubscriptionActionSuccess(
            action: 'pause',
            message: 'Your subscription has been paused until ',
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
    return _subscriptionUseCase.calculateTotalMeals(subscription);
  }

  // Helper methods

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

  // Helper to get global context for showing snackbars
  BuildContext _getGlobalContext() {
    return NavigationService.navigatorKey.currentContext!;
  }

  String _formatDate(DateTime date) {
    // Simple date formatting - you might want to use a proper date formatter
    return '${date.day}/${date.month}/${date.year}';
  }
}
