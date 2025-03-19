// lib/src/presentation/cubits/subscription/subscription_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/src/domain/entities/address_entity.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart' as domain;
import 'package:foodam/src/domain/usecase/subscription/cancel_subscription_usecase.dart';
import 'package:foodam/src/domain/usecase/subscription/clear_draft_subscription_usecase.dart';
import 'package:foodam/src/domain/usecase/subscription/create_subscription_usecase.dart';
import 'package:foodam/src/domain/usecase/subscription/get_active_subscription_usecase.dart';
import 'package:foodam/src/domain/usecase/subscription/get_available_subscriptions_usecase.dart';
import 'package:foodam/src/domain/usecase/subscription/get_draft_subscription_usecase.dart';
import 'package:foodam/src/domain/usecase/subscription/get_subscription_history_usecase.dart';
import 'package:foodam/src/domain/usecase/subscription/pause_subscription_usecase.dart';
import 'package:foodam/src/domain/usecase/subscription/resume_subscription_usecase.dart';
import 'package:foodam/src/domain/usecase/subscription/save_draft_subscription_usecase.dart';
import 'package:foodam/src/presentation/cubits/subscription/subscription_state.dart';

class SubscriptionCubit extends Cubit<SubscriptionState> {
  final GetActiveSubscriptionUseCase _getActiveSubscriptionUseCase;
  final GetAvailableSubscriptionsUseCase _getAvailableSubscriptionsUseCase;
  final GetDraftSubscriptionUseCase _getDraftSubscriptionUseCase;
  final SaveDraftSubscriptionUseCase _saveDraftSubscriptionUseCase;
  final ClearDraftSubscriptionUseCase _clearDraftSubscriptionUseCase;
  final CreateSubscriptionUseCase _createSubscriptionUseCase;
  final PauseSubscriptionUseCase _pauseSubscriptionUseCase;
  final ResumeSubscriptionUseCase _resumeSubscriptionUseCase;
  final CancelSubscriptionUseCase _cancelSubscriptionUseCase;
  final GetSubscriptionHistoryUseCase _getSubscriptionHistoryUseCase;

  SubscriptionCubit({
    required GetActiveSubscriptionUseCase getActiveSubscriptionUseCase,
    required GetAvailableSubscriptionsUseCase getAvailableSubscriptionsUseCase,
    required GetDraftSubscriptionUseCase getDraftSubscriptionUseCase,
    required SaveDraftSubscriptionUseCase saveDraftSubscriptionUseCase,
    required ClearDraftSubscriptionUseCase clearDraftSubscriptionUseCase,
    required CreateSubscriptionUseCase createSubscriptionUseCase,
    required PauseSubscriptionUseCase pauseSubscriptionUseCase,
    required ResumeSubscriptionUseCase resumeSubscriptionUseCase,
    required CancelSubscriptionUseCase cancelSubscriptionUseCase,
    required GetSubscriptionHistoryUseCase getSubscriptionHistoryUseCase,
  })  : _getActiveSubscriptionUseCase = getActiveSubscriptionUseCase,
        _getAvailableSubscriptionsUseCase = getAvailableSubscriptionsUseCase,
        _getDraftSubscriptionUseCase = getDraftSubscriptionUseCase,
        _saveDraftSubscriptionUseCase = saveDraftSubscriptionUseCase,
        _clearDraftSubscriptionUseCase = clearDraftSubscriptionUseCase,
        _createSubscriptionUseCase = createSubscriptionUseCase,
        _pauseSubscriptionUseCase = pauseSubscriptionUseCase,
        _resumeSubscriptionUseCase = resumeSubscriptionUseCase,
        _cancelSubscriptionUseCase = cancelSubscriptionUseCase,
        _getSubscriptionHistoryUseCase = getSubscriptionHistoryUseCase,
        super(const SubscriptionState());

  // Load active subscription (if any)
  Future<void> loadActiveSubscription() async {
    emit(state.copyWith(isLoading: true));

    final result = await _getActiveSubscriptionUseCase();

    result.fold(
      (failure) => emit(state.copyWith(
        status: SubscriptionStatus.error,
        isLoading: false,
        errorMessage: _mapFailureToMessage(failure),
      )),
      (subscription) => emit(state.copyWith(
        status: subscription != null ? SubscriptionStatus.active : SubscriptionStatus.inactive,
        activeSubscription: subscription,
        isLoading: false,
      )),
    );
  }

  // Load available subscription templates
  Future<void> loadAvailableSubscriptions() async {
    emit(state.copyWith(isLoading: true));

    final result = await _getAvailableSubscriptionsUseCase();

    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        errorMessage: _mapFailureToMessage(failure),
      )),
      (subscriptions) => emit(state.copyWith(
        availableSubscriptions: subscriptions,
        isLoading: false,
      )),
    );
  }

  // Load draft subscription (if any)
  Future<void> loadDraftSubscription() async {
    emit(state.copyWith(isLoading: true));

    final result = await _getDraftSubscriptionUseCase();

    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        errorMessage: _mapFailureToMessage(failure),
      )),
      (draftSubscription) => emit(state.copyWith(
        status: draftSubscription != null ? SubscriptionStatus.draft : state.status,
        draftSubscription: draftSubscription,
        isLoading: false,
      )),
    );
  }

  // Save a draft subscription
  Future<void> saveDraftSubscription(domain.Subscription subscription) async {
    emit(state.copyWith(isLoading: true));

    final result = await _saveDraftSubscriptionUseCase(subscription);

    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        errorMessage: _mapFailureToMessage(failure),
      )),
      (savedSubscription) => emit(state.copyWith(
        status: SubscriptionStatus.draft,
        draftSubscription: savedSubscription,
        isLoading: false,
      )),
    );
  }

  // Clear draft subscription
  Future<void> clearDraftSubscription() async {
    emit(state.copyWith(isLoading: true));

    final result = await _clearDraftSubscriptionUseCase();

    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        errorMessage: _mapFailureToMessage(failure),
      )),
      (_) => emit(state.copyWith(
        draftSubscription: null,
        isLoading: false,
      )),
    );
  }

  // Create a new subscription
  Future<void> createSubscription({
    required domain.SubscriptionDuration duration,
    required DateTime startDate,
    required List<domain.MealPreference> mealPreferences,
    required domain.DeliverySchedule deliverySchedule,
    required Address deliveryAddress,
    String? paymentMethodId,
  }) async {
    emit(state.copyWith(
      status: SubscriptionStatus.creating,
      isLoading: true,
    ));

    final params = CreateSubscriptionParams(
      duration: duration,
      startDate: startDate,
      mealPreferences: mealPreferences,
      deliverySchedule: deliverySchedule,
      deliveryAddress: deliveryAddress,
      paymentMethodId: paymentMethodId,
    );

    final result = await _createSubscriptionUseCase(params);

    result.fold(
      (failure) => emit(state.copyWith(
        status: SubscriptionStatus.error,
        isLoading: false,
        errorMessage: _mapFailureToMessage(failure),
      )),
      (subscription) => emit(state.copyWith(
        status: SubscriptionStatus.active,
        activeSubscription: subscription,
        isLoading: false,
      )),
    );
  }

  // Pause an active subscription
  Future<void> pauseSubscription(String subscriptionId, DateTime resumeDate) async {
    emit(state.copyWith(isLoading: true));

    final params = PauseSubscriptionParams(
      subscriptionId: subscriptionId,
      resumeDate: resumeDate,
    );

    final result = await _pauseSubscriptionUseCase(params);

    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        errorMessage: _mapFailureToMessage(failure),
      )),
      (pausedSubscription) => emit(state.copyWith(
        activeSubscription: pausedSubscription,
        isLoading: false,
      )),
    );
  }

  // Resume a paused subscription
  Future<void> resumeSubscription(String subscriptionId) async {
    emit(state.copyWith(isLoading: true));

    final result = await _resumeSubscriptionUseCase(subscriptionId);

    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        errorMessage: _mapFailureToMessage(failure),
      )),
      (resumedSubscription) => emit(state.copyWith(
        activeSubscription: resumedSubscription,
        isLoading: false,
      )),
    );
  }

  // Cancel a subscription
  Future<void> cancelSubscription(String subscriptionId, String reason) async {
    emit(state.copyWith(isLoading: true));

    final params = CancelSubscriptionParams(
      subscriptionId: subscriptionId,
      reason: reason,
    );

    final result = await _cancelSubscriptionUseCase(params);

    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        errorMessage: _mapFailureToMessage(failure),
      )),
      (cancelledSubscription) {
        // If cancelled, set status to inactive and add to history
        final updatedHistory = List<domain.Subscription>.from(state.subscriptionHistory)
          ..add(cancelledSubscription);
        
        emit(state.copyWith(
          status: SubscriptionStatus.inactive,
          activeSubscription: null,
          subscriptionHistory: updatedHistory,
          isLoading: false,
        ));
      },
    );
  }

  // Load subscription history
  Future<void> loadSubscriptionHistory() async {
    emit(state.copyWith(isLoading: true));

    final result = await _getSubscriptionHistoryUseCase();

    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        errorMessage: _mapFailureToMessage(failure),
      )),
      (history) => emit(state.copyWith(
        subscriptionHistory: history,
        isLoading: false,
      )),
    );
  }

  // Helper method to map failures to user-friendly messages
  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Server error. Please try again later.';
      case NetworkFailure:
        return 'Network error. Please check your connection.';
      case CacheFailure:
        return 'Cache error. Please restart the app.';
      default:
        return 'An unexpected error occurred.';
    }
  }
}