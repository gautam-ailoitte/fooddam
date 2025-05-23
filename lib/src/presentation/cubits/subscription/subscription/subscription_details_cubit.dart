// lib/src/presentation/cubits/subscription/subscription_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';
import 'package:foodam/src/domain/usecase/susbcription_usecase.dart';
import 'package:foodam/src/presentation/cubits/subscription/subscription/subscription_details_state.dart';

class SubscriptionCubit extends Cubit<SubscriptionState> {
  final SubscriptionUseCase _subscriptionUseCase;
  final LoggerService _logger = LoggerService();

  // Cache for subscription list
  List<Subscription>? _cachedSubscriptions;
  DateTime? _lastCacheTime;
  static const Duration _cacheValidDuration = Duration(minutes: 5);

  SubscriptionCubit({required SubscriptionUseCase subscriptionUseCase})
    : _subscriptionUseCase = subscriptionUseCase,
      super(SubscriptionInitial());

  /// Load all subscriptions with caching (for list screen)
  Future<void> loadSubscriptions() async {
    // Check if we have valid cached data
    if (_isCacheValid() && _cachedSubscriptions != null) {
      _logger.d('Using cached subscription data', tag: 'SubscriptionCubit');
      emit(SubscriptionLoaded(subscriptions: _cachedSubscriptions!));
      return;
    }

    // If no valid cache or this is initial load, show loading
    if (state is SubscriptionInitial || _cachedSubscriptions == null) {
      emit(SubscriptionLoading());
    }

    _logger.d('Loading subscriptions from API', tag: 'SubscriptionCubit');

    final result = await _subscriptionUseCase.getActiveSubscriptions();

    result.fold(
      (failure) {
        _logger.e(
          'Failed to load subscriptions: ${failure.message}',
          tag: 'SubscriptionCubit',
        );
        emit(
          SubscriptionError(failure.message ?? 'Failed to load subscriptions'),
        );
      },
      (subscriptions) {
        _logger.i(
          'Loaded ${subscriptions.length} subscriptions',
          tag: 'SubscriptionCubit',
        );

        // Cache the data
        _cachedSubscriptions = subscriptions;
        _lastCacheTime = DateTime.now();

        emit(SubscriptionLoaded(subscriptions: subscriptions));
      },
    );
  }

  /// Force refresh subscriptions from API (for pull-to-refresh)
  Future<void> refreshSubscriptions() async {
    _logger.d('Force refreshing subscriptions', tag: 'SubscriptionCubit');

    // Clear cache to force fresh data
    _clearCache();

    // Load fresh data
    await loadSubscriptions();
  }

  /// Load subscription detail (always fresh from API)
  Future<void> loadSubscriptionDetail(String subscriptionId) async {
    _logger.d(
      'Loading subscription detail: $subscriptionId',
      tag: 'SubscriptionCubit',
    );

    emit(SubscriptionLoading());

    final result = await _subscriptionUseCase.getSubscriptionById(
      subscriptionId,
    );

    result.fold(
      (failure) {
        _logger.e(
          'Failed to load subscription detail: ${failure.message}',
          tag: 'SubscriptionCubit',
        );
        emit(
          SubscriptionError(
            failure.message ?? 'Failed to load subscription details',
          ),
        );
      },
      (subscription) {
        _logger.i(
          'Loaded subscription detail: ${subscription.id}',
          tag: 'SubscriptionCubit',
        );
        emit(SubscriptionDetailLoaded(subscription: subscription));
      },
    );
  }

  /// Return to subscription list (use cached data)
  void returnToSubscriptionList() {
    _logger.d('Returning to subscription list', tag: 'SubscriptionCubit');

    if (_cachedSubscriptions != null) {
      emit(SubscriptionLoaded(subscriptions: _cachedSubscriptions!));
    } else {
      // If no cache, reload
      loadSubscriptions();
    }
  }

  /// Pause a subscription
  Future<void> pauseSubscription(String subscriptionId) async {
    _logger.d(
      'Pausing subscription: $subscriptionId',
      tag: 'SubscriptionCubit',
    );

    emit(SubscriptionLoading());

    final result = await _subscriptionUseCase.manageSubscription(
      subscriptionId,
      SubscriptionAction.pause,
    );

    result.fold(
      (failure) {
        _logger.e(
          'Failed to pause subscription: ${failure.message}',
          tag: 'SubscriptionCubit',
        );
        emit(
          SubscriptionError(failure.message ?? 'Failed to pause subscription'),
        );
      },
      (_) {
        _logger.i('Subscription paused successfully', tag: 'SubscriptionCubit');

        // Clear cache to ensure fresh data on next load
        _clearCache();

        // Reload fresh subscription detail
        loadSubscriptionDetail(subscriptionId);
      },
    );
  }

  /// Resume a subscription
  Future<void> resumeSubscription(String subscriptionId) async {
    _logger.d(
      'Resuming subscription: $subscriptionId',
      tag: 'SubscriptionCubit',
    );

    emit(SubscriptionLoading());

    final result = await _subscriptionUseCase.manageSubscription(
      subscriptionId,
      SubscriptionAction.resume,
    );

    result.fold(
      (failure) {
        _logger.e(
          'Failed to resume subscription: ${failure.message}',
          tag: 'SubscriptionCubit',
        );
        emit(
          SubscriptionError(failure.message ?? 'Failed to resume subscription'),
        );
      },
      (_) {
        _logger.i(
          'Subscription resumed successfully',
          tag: 'SubscriptionCubit',
        );

        // Clear cache to ensure fresh data on next load
        _clearCache();

        // Reload fresh subscription detail
        loadSubscriptionDetail(subscriptionId);
      },
    );
  }

  /// Cancel a subscription
  Future<void> cancelSubscription(String subscriptionId) async {
    _logger.d(
      'Cancelling subscription: $subscriptionId',
      tag: 'SubscriptionCubit',
    );

    emit(SubscriptionLoading());

    final result = await _subscriptionUseCase.manageSubscription(
      subscriptionId,
      SubscriptionAction.cancel,
    );

    result.fold(
      (failure) {
        _logger.e(
          'Failed to cancel subscription: ${failure.message}',
          tag: 'SubscriptionCubit',
        );
        emit(
          SubscriptionError(failure.message ?? 'Failed to cancel subscription'),
        );
      },
      (_) async {
        _logger.i(
          'Subscription cancelled successfully',
          tag: 'SubscriptionCubit',
        );

        // Clear cache to ensure fresh data on next load
        _clearCache();

        // Return to list since cancelled subscription may not be relevant to show detail
        await loadSubscriptions();
      },
    );
  }

  /// Get active subscriptions for home screen (uses cached data if available)
  Future<void> loadActiveSubscriptionsForHome() async {
    _logger.d(
      'Loading active subscriptions for home',
      tag: 'SubscriptionCubit',
    );

    // Try to use cached data first
    if (_isCacheValid() && _cachedSubscriptions != null) {
      emit(SubscriptionLoaded(subscriptions: _cachedSubscriptions!));
      return;
    }

    // If no cache, load fresh data but don't show loading state for home
    final result = await _subscriptionUseCase.getActiveSubscriptions();

    result.fold(
      (failure) {
        _logger.e(
          'Failed to load active subscriptions for home: ${failure.message}',
          tag: 'SubscriptionCubit',
        );
        // For home screen, emit empty state instead of error to avoid disrupting UX
        emit(const SubscriptionLoaded(subscriptions: []));
      },
      (subscriptions) {
        _logger.i(
          'Loaded ${subscriptions.length} active subscriptions for home',
          tag: 'SubscriptionCubit',
        );

        // Cache the data
        _cachedSubscriptions = subscriptions;
        _lastCacheTime = DateTime.now();

        emit(SubscriptionLoaded(subscriptions: subscriptions));
      },
    );
  }

  /// Clear subscription cache (useful for logout, etc.)
  void clearCache() {
    _logger.d('Clearing subscription cache', tag: 'SubscriptionCubit');
    _clearCache();
  }

  /// Get subscription status text using usecase helper
  String getSubscriptionStatusText(Subscription subscription) {
    return _subscriptionUseCase.getSubscriptionStatusText(subscription);
  }

  /// Calculate remaining days using usecase helper
  int calculateRemainingDays(Subscription subscription) {
    return _subscriptionUseCase.calculateRemainingDays(subscription);
  }

  /// Check if subscription needs payment using usecase helper
  bool subscriptionNeedsPayment(Subscription subscription) {
    return _subscriptionUseCase.subscriptionNeedsPayment(subscription);
  }

  // Private helper methods

  bool _isCacheValid() {
    if (_lastCacheTime == null) return false;

    final now = DateTime.now();
    final difference = now.difference(_lastCacheTime!);

    return difference < _cacheValidDuration;
  }

  void _clearCache() {
    _cachedSubscriptions = null;
    _lastCacheTime = null;
  }

  @override
  Future<void> close() {
    _clearCache();
    return super.close();
  }
}
