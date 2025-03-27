// lib/src/presentation/cubits/subscription/subscription/subscription_details_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/service/logger_service.dart';
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
    // Future.delayed(const Duration(milliseconds: 300));
    final result = await _subscriptionUseCase.getActiveSubscriptions();

    result.fold(
      (failure) {
        _logger.e('Failed to get active subscriptions', error: failure);
        emit(SubscriptionError(message: 'Failed to load your subscriptions'));
      },
      (subscriptions) {
        // Separate active and paused subscriptions
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

        _logger.i(
          'Active subscriptions loaded: ${subscriptions.length} subscriptions',
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
            final daysRemaining = _calculateDaysRemaining(updatedSelectedSub);

            emit(
              SubscriptionLoaded(
                subscriptions: subscriptions,
                activeSubscriptions: active,
                pausedSubscriptions: paused,
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
            ),
          );
        }
      },
    );
  }

  /// Load details for a specific subscription (for detail screen)
  /// This method first tries to find the subscription in the existing loaded subscriptions
  /// If not found, it uses the provided subscription object directly
  Future<void> loadSubscriptionDetails(String subscriptionId) async {
    // First check if we already have a loaded state with subscriptions
    if (state is SubscriptionLoaded) {
      final currentState = state as SubscriptionLoaded;

      // Try to find the subscription in our existing data
      try {
        final foundSubscription = currentState.subscriptions.firstWhere(
          (sub) => sub.id == subscriptionId,
        );

        // Calculate days remaining
        final daysRemaining = _calculateDaysRemaining(foundSubscription);

        // Emit the same state but with selected subscription
        emit(
          currentState.withSelectedSubscription(
            foundSubscription,
            daysRemaining,
          ),
        );

        _logger.i('Using cached subscription details: ${foundSubscription.id}');
        return;
      } catch (e) {
        _logger.d(
          'Subscription not found in current state, will load active subscriptions',
        );
        // Continue to load all subscriptions to refresh our data
      }
    }

    // Load all subscriptions to populate our state
    await loadActiveSubscriptions();
    // emit(const SubscriptionLoading());
    // Future.delayed(const Duration(milliseconds: 300));

    // Now check again after reloading
    if (state is SubscriptionLoaded) {
      final currentState = state as SubscriptionLoaded;

      try {
        final foundSubscription = currentState.subscriptions.firstWhere(
          (sub) => sub.id == subscriptionId,
        );

        // Calculate days remaining
        final daysRemaining = _calculateDaysRemaining(foundSubscription);

        // Emit with the selected subscription
        emit(
          currentState.withSelectedSubscription(
            foundSubscription,
            daysRemaining,
          ),
        );

        _logger.i('Found subscription after reload: ${foundSubscription.id}');
      } catch (e) {
        _logger.w('Subscription not found even after reload: $subscriptionId');
        // Keep the current state if subscription not found
      }
    }
  }

  /// Pause a subscription until a specific date
  Future<void> pauseSubscription(
    String subscriptionId,
    DateTime untilDate,
  ) async {
    emit(const SubscriptionActionInProgress(action: 'pause'));

    final result = await _subscriptionUseCase.manageSubscription(
      subscriptionId,
      SubscriptionAction.pause,
      untilDate: untilDate,
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
            message:
                'Your subscription has been paused until ${_formatDate(untilDate)}',
          ),
        );

        // Then reload all data to reflect changes
        // loadActiveSubscriptions();
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
        // loadActiveSubscriptions();
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

  // Helper methods

  int _calculateDaysRemaining(Subscription subscription) {
    // Calculate days remaining in subscription - this is a simplified implementation
    final startDate = subscription.startDate;
    final endDate = startDate.add(Duration(days: subscription.durationDays));
    final now = DateTime.now();

    if (now.isAfter(endDate)) return 0;

    return endDate.difference(now).inDays;
  }

  String _formatDate(DateTime date) {
    // Simple date formatting - you might want to use a proper date formatter
    return '${date.day}/${date.month}/${date.year}';
  }
}
