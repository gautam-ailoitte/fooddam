// lib/src/presentation/cubits/subscription/subscription_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/src/domain/entities/address_entity.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';
import 'package:foodam/src/domain/usecase/subscription/get_active_subscription_usecase.dart';
import 'package:foodam/src/domain/usecase/subscription/get_available_subscriptions_usecase.dart';
import 'package:foodam/src/domain/usecase/subscription/create_subscription_usecase.dart';
import 'package:foodam/src/domain/usecase/subscription/customize_subscription_usecase.dart';
import 'package:foodam/src/domain/usecase/subscription/pause_subscription_usecase.dart';
import 'package:foodam/src/domain/usecase/subscription/resume_subscription_usecase.dart';
import 'package:foodam/src/domain/usecase/subscription/cancel_subscription_usecase.dart';
import 'package:foodam/src/domain/usecase/subscription/get_subscription_history_usecase.dart';
import 'package:foodam/src/domain/usecase/subscription/save_draft_subscription_usecase.dart';
import 'package:foodam/src/domain/usecase/subscription/get_draft_subscription_usecase.dart';
import 'package:foodam/src/domain/usecase/subscription/clear_draft_subscription_usecase.dart';
import 'package:foodam/src/presentation/cubits/susbcription/susbcription_state.dart';

class SubscriptionCubit extends Cubit<SubscriptionState> {
  final GetActiveSubscriptionUseCase _getActiveSubscriptionUseCase;
  final GetAvailableSubscriptionsUseCase _getAvailableSubscriptionsUseCase;
  final CreateSubscriptionUseCase _createSubscriptionUseCase;
  final CustomizeSubscriptionUseCase _customizeSubscriptionUseCase;
  final PauseSubscriptionUseCase _pauseSubscriptionUseCase;
  final ResumeSubscriptionUseCase _resumeSubscriptionUseCase;
  final CancelSubscriptionUseCase _cancelSubscriptionUseCase;
  final GetSubscriptionHistoryUseCase _getSubscriptionHistoryUseCase;
  final SaveDraftSubscriptionUseCase _saveDraftSubscriptionUseCase;
  final GetDraftSubscriptionUseCase _getDraftSubscriptionUseCase;
  final ClearDraftSubscriptionUseCase _clearDraftSubscriptionUseCase;

  SubscriptionCubit({
    required GetActiveSubscriptionUseCase getActiveSubscriptionUseCase,
    required GetAvailableSubscriptionsUseCase getAvailableSubscriptionsUseCase,
    required CreateSubscriptionUseCase createSubscriptionUseCase,
    required CustomizeSubscriptionUseCase customizeSubscriptionUseCase,
    required PauseSubscriptionUseCase pauseSubscriptionUseCase,
    required ResumeSubscriptionUseCase resumeSubscriptionUseCase,
    required CancelSubscriptionUseCase cancelSubscriptionUseCase,
    required GetSubscriptionHistoryUseCase getSubscriptionHistoryUseCase,
    required SaveDraftSubscriptionUseCase saveDraftSubscriptionUseCase,
    required GetDraftSubscriptionUseCase getDraftSubscriptionUseCase,
    required ClearDraftSubscriptionUseCase clearDraftSubscriptionUseCase,
  })  : _getActiveSubscriptionUseCase = getActiveSubscriptionUseCase,
        _getAvailableSubscriptionsUseCase = getAvailableSubscriptionsUseCase,
        _createSubscriptionUseCase = createSubscriptionUseCase,
        _customizeSubscriptionUseCase = customizeSubscriptionUseCase,
        _pauseSubscriptionUseCase = pauseSubscriptionUseCase,
        _resumeSubscriptionUseCase = resumeSubscriptionUseCase,
        _cancelSubscriptionUseCase = cancelSubscriptionUseCase,
        _getSubscriptionHistoryUseCase = getSubscriptionHistoryUseCase,
        _saveDraftSubscriptionUseCase = saveDraftSubscriptionUseCase,
        _getDraftSubscriptionUseCase = getDraftSubscriptionUseCase,
        _clearDraftSubscriptionUseCase = clearDraftSubscriptionUseCase,
        super(SubscriptionInitial());

  Future<void> getActiveSubscription() async {
    emit(SubscriptionLoading());
    
    final result = await _getActiveSubscriptionUseCase();
    
    result.fold(
      (failure) => emit(SubscriptionError(message: _mapFailureToMessage(failure))),
      (subscription) {
        if (subscription != null) {
          emit(NoActiveSubscription());
        } else {
          emit(NoActiveSubscription());
        }
      },
    );
  }

  Future<void> getAvailableSubscriptions() async {
    emit(SubscriptionLoading());
    
    final result = await _getAvailableSubscriptionsUseCase();
    
    result.fold(
      (failure) => emit(SubscriptionError(message: _mapFailureToMessage(failure))),
      (subscriptions) => emit(AvailableSubscriptionsLoaded(subscriptions: subscriptions)),
    );
  }

  Future<void> createSubscription({
    required SubscriptionDuration duration,
    required DateTime startDate,
    required List<MealPreference> mealPreferences,
    required DeliverySchedule deliverySchedule,
    required Address deliveryAddress,
    String? paymentMethodId,
  }) async {
    emit(SubscriptionLoading());
    
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
      (failure) => emit(SubscriptionError(message: _mapFailureToMessage(failure))),
      (subscription) => emit(SubscriptionCreated(subscription: subscription)),
    );
  }

  Future<void> customizeSubscription({
    required String subscriptionId,
    List<MealPreference>? mealPreferences,
    DeliverySchedule? deliverySchedule,
    Address? deliveryAddress,
  }) async {
    emit(SubscriptionLoading());
    
    final params = CustomizeSubscriptionParams(
      subscriptionId: subscriptionId,
      mealPreferences: mealPreferences,
      deliverySchedule: deliverySchedule,
      deliveryAddress: deliveryAddress,
    );
    
    final result = await _customizeSubscriptionUseCase(params);
    
    result.fold(
      (failure) => emit(SubscriptionError(message: _mapFailureToMessage(failure))),
      (subscription) => emit(SubscriptionCustomized(subscription: subscription)),
    );
  }

  Future<void> pauseSubscription(String subscriptionId, DateTime resumeDate) async {
    emit(SubscriptionLoading());
    
    final params = PauseSubscriptionParams(
      subscriptionId: subscriptionId,
      resumeDate: resumeDate,
    );
    
    final result = await _pauseSubscriptionUseCase(params);
    
    result.fold(
      (failure) => emit(SubscriptionError(message: _mapFailureToMessage(failure))),
      (subscription) => emit(SubscriptionPaused(subscription: subscription)),
    );
  }

  Future<void> resumeSubscription(String subscriptionId) async {
    emit(SubscriptionLoading());
    
    final result = await _resumeSubscriptionUseCase(subscriptionId);
    
    result.fold(
      (failure) => emit(SubscriptionError(message: _mapFailureToMessage(failure))),
      (subscription) => emit(SubscriptionResumed(subscription: subscription)),
    );
  }

  Future<void> cancelSubscription(String subscriptionId, String reason) async {
    emit(SubscriptionLoading());
    
    final params = CancelSubscriptionParams(
      subscriptionId: subscriptionId,
      reason: reason,
    );
    
    final result = await _cancelSubscriptionUseCase(params);
    
    result.fold(
      (failure) => emit(SubscriptionError(message: _mapFailureToMessage(failure))),
      (subscription) => emit(SubscriptionCancelled(subscription: subscription)),
    );
  }

  Future<void> getSubscriptionHistory() async {
    emit(SubscriptionLoading());
    
    final result = await _getSubscriptionHistoryUseCase();
    
    result.fold(
      (failure) => emit(SubscriptionError(message: _mapFailureToMessage(failure))),
      (subscriptions) => emit(SubscriptionHistoryLoaded(subscriptions: subscriptions)),
    );
  }

  Future<void> saveDraftSubscription(Subscription subscription) async {
    emit(SubscriptionLoading());
    
    final result = await _saveDraftSubscriptionUseCase(subscription);
    
    result.fold(
      (failure) => emit(SubscriptionError(message: _mapFailureToMessage(failure))),
      (savedSubscription) => emit(DraftSubscriptionSaved(subscription: savedSubscription)),
    );
  }

  Future<void> getDraftSubscription() async {
    emit(SubscriptionLoading());
    
    final result = await _getDraftSubscriptionUseCase();
    
    result.fold(
      (failure) => emit(SubscriptionError(message: _mapFailureToMessage(failure))),
      (subscription) {
        if (subscription != null) {
          emit(DraftSubscriptionLoaded(subscription: subscription));
        } else {
          emit(NoDraftSubscription());
        }
      },
    );
  }

  Future<void> clearDraftSubscription() async {
    emit(SubscriptionLoading());
    
    final result = await _clearDraftSubscriptionUseCase();
    
    result.fold(
      (failure) => emit(SubscriptionError(message: _mapFailureToMessage(failure))),
      (_) => emit(DraftSubscriptionCleared()),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Server error occurred. Please try again.';
      case NetworkFailure:
        return 'Network error occurred. Please check your connection.';
      case CacheFailure:
        return 'Cache error occurred. Please restart the app.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}