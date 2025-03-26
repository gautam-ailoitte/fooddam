// lib/src/presentation/cubits/subscription/subscription_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/domain/entities/meal_slot_entity.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';
import 'package:foodam/src/domain/usecase/susbcription_usecase.dart';
import 'package:foodam/src/presentation/cubits/meal/meal_cubit.dart';
import 'package:foodam/src/presentation/cubits/meal/meal_state.dart';
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

  // For subscription creation flow
  int _currentStage = 0;
  String? _packageId;
  List<MealSlot>? _mealSlots;
  String? _addressId;
  int _personCount = 1;
  String? _instructions;

  SubscriptionCubit({
    required SubscriptionUseCase subscriptionUseCase,
    required this.mealCubit,
  }) : _subscriptionUseCase = subscriptionUseCase,
       super(const SubscriptionInitial());

  // Active Subscriptions Methods

  /// Load all active subscriptions for the current user
  Future<void> loadActiveSubscriptions() async {
    emit(const SubscriptionLoading());

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
        emit(
          SubscriptionLoaded(
            subscriptions: subscriptions,
            activeSubscriptions: active,
            pausedSubscriptions: paused,
          ),
        );
      },
    );
  }

  // Subscription Detail Methods

  /// Load details for a specific subscription
  Future<void> loadSubscriptionDetails(String subscriptionId) async {
    emit(const SubscriptionLoading());

    final result = await _subscriptionUseCase.getSubscriptionById(
      subscriptionId,
    );

    result.fold(
      (failure) {
        _logger.e('Failed to get subscription details', error: failure);
        emit(SubscriptionError(message: 'Failed to load subscription details'));
      },
      (subscription) {
        _logger.i('Subscription details loaded: ${subscription.id}');

        // Calculate days remaining (would need to implement this logic)
        final daysRemaining = _calculateDaysRemaining(subscription);

        subscription.slots.map((slot) {
          // get meal by id using meal cubit
          mealCubit.getMealById(slot.mealId!);
          final state = mealCubit.state as MealLoaded;
          return MealSlot(
            day: slot.day,
            timing: slot.timing,
            mealId: slot.mealId,
            meal: state.meal,
          );
        }).toList();

        emit(
          SubscriptionDetailLoaded(
            subscription: subscription,
            daysRemaining: daysRemaining,
          ),
        );
      },
    );
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
        emit(
          SubscriptionActionSuccess(
            action: 'pause',
            message:
                'Your subscription has been paused until ${_formatDate(untilDate)}',
          ),
        );

        // Refresh subscription details
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
        emit(
          const SubscriptionActionSuccess(
            action: 'resume',
            message: 'Your subscription has been resumed successfully',
          ),
        );

        // Refresh subscription details
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
        emit(
          const SubscriptionActionSuccess(
            action: 'cancel',
            message: 'Your subscription has been cancelled',
          ),
        );

        // Refresh the active subscriptions list
        loadActiveSubscriptions();
      },
    );
  }

  // Subscription Creation Methods

  /// Start the subscription creation flow
  void startSubscriptionCreation() {
    _resetCreationFlow();
    _moveToStage(0);
  }

  /// Move to the next stage in subscription creation
  void nextStage() {
    _moveToStage(_currentStage + 1);
  }

  /// Move to the previous stage in subscription creation
  void previousStage() {
    if (_currentStage > 0) {
      _moveToStage(_currentStage - 1);
    }
  }

  /// Move to a specific stage in the creation flow
  void _moveToStage(int stage) {
    _currentStage = stage;
    switch (_currentStage) {
      case 0: // Package selection
        emit(
          SubscriptionCreationStage(stage: 0, selectedPackageId: _packageId),
        );
        break;
      case 1: // Meal distribution
        if (_packageId == null) {
          emit(SubscriptionError(message: 'Please select a package first'));
          _moveToStage(0);
        } else {
          emit(
            SubscriptionCreationStage(
              stage: 1,
              selectedPackageId: _packageId,
              mealSlots: _mealSlots,
              personCount: _personCount,
            ),
          );
        }
        break;
      case 2: // Address selection
        if (_mealSlots == null || _mealSlots!.isEmpty) {
          emit(SubscriptionError(message: 'Please select at least one meal'));
          _moveToStage(1);
        } else {
          emit(
            SubscriptionCreationStage(
              stage: 2,
              selectedPackageId: _packageId,
              mealSlots: _mealSlots,
              selectedAddressId: _addressId,
              personCount: _personCount,
            ),
          );
        }
        break;
      case 3: // Subscription summary
        if (_addressId == null) {
          emit(SubscriptionError(message: 'Please select a delivery address'));
          _moveToStage(2);
        } else {
          emit(
            SubscriptionCreationStage(
              stage: 3,
              selectedPackageId: _packageId!,
              mealSlots: _mealSlots!,
              selectedAddressId: _addressId!,
              personCount: _personCount,
              instructions: _instructions,
            ),
          );
        }
        break;
    }
  }

  /// Select a package for the subscription
  void selectPackage(String packageId) {
    _packageId = packageId;

    if (_currentStage == 0) {
      emit(SubscriptionCreationStage(stage: 0, selectedPackageId: packageId));
    }
  }

  /// Set meal slots for the subscription
  void setMealSlots(List<MealSlot> slots, int personCount) {
    _mealSlots = slots;
    _personCount = personCount;

    if (_currentStage == 1) {
      emit(
        SubscriptionCreationStage(
          stage: 1,
          selectedPackageId: _packageId,
          mealSlots: slots,
          personCount: personCount,
        ),
      );
    }
  }

  /// Select a delivery address for the subscription
  void selectAddress(String addressId) {
    _addressId = addressId;

    if (_currentStage == 2) {
      emit(
        SubscriptionCreationStage(
          stage: 2,
          selectedPackageId: _packageId,
          mealSlots: _mealSlots,
          selectedAddressId: addressId,
          personCount: _personCount,
        ),
      );
    }
  }

  /// Set delivery instructions for the subscription
  void setInstructions(String? instructions) {
    _instructions = instructions;

    if (_currentStage == 3) {
      emit(
        SubscriptionCreationStage(
          stage: 3,
          selectedPackageId: _packageId!,
          mealSlots: _mealSlots!,
          selectedAddressId: _addressId!,
          personCount: _personCount,
          instructions: instructions,
        ),
      );
    }
  }

  /// Create the subscription with the collected data
  Future<void> createSubscription() async {
    if (_packageId == null ||
        _mealSlots == null ||
        _mealSlots!.isEmpty ||
        _addressId == null) {
      emit(
        SubscriptionError(
          message: 'Missing required information for subscription',
        ),
      );
      return;
    }

    emit(const SubscriptionCreationLoading());

    final params = SubscriptionParams(
      packageId: _packageId!,
      startDate: DateTime.now(),
      durationDays: 7, // Weekly subscription
      addressId: _addressId!,
      instructions: _instructions,
      slots: _mealSlots!,
      personCount: _personCount,
    );

    final result = await _subscriptionUseCase.createSubscription(params);

    result.fold(
      (failure) {
        _logger.e('Failed to create subscription', error: failure);
        emit(
          SubscriptionError(
            message: 'Failed to create subscription. Please try again.',
          ),
        );
      },
      (subscription) {
        _logger.i('Subscription created successfully: ${subscription.id}');
        emit(SubscriptionCreationSuccess(subscription: subscription));

        // Reset creation flow
        _resetCreationFlow();
      },
    );
  }

  /// Reset the subscription creation flow
  void _resetCreationFlow() {
    _currentStage = 0;
    _packageId = null;
    _mealSlots = null;
    _addressId = null;
    _personCount = 1;
    _instructions = null;
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
