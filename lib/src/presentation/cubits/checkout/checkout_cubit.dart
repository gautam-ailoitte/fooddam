// lib/src/presentation/cubits/checkout/checkout_cubit.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';
import 'package:foodam/src/domain/usecase/susbcription_usecase.dart';
import 'package:foodam/src/domain/usecase/user_usecase.dart';
import 'package:foodam/src/presentation/cubits/checkout/checkout_state.dart';
import 'package:foodam/src/presentation/cubits/subscription/week_selection/week_selection_state.dart'
    as WeekSelection;

import '../../../../core/errors/failure.dart';
import '../../../data/datasource/remote_data_source.dart';
import 'week_selection_data_extractor.dart';

/// Cubit to handle checkout flow after week selection
class CheckoutCubit extends Cubit<CheckoutState> {
  final UserUseCase _userUseCase;
  final SubscriptionUseCase _subscriptionUseCase;
  final LoggerService _logger = LoggerService();

  CheckoutCubit({
    required UserUseCase userUseCase,
    required SubscriptionUseCase subscriptionUseCase,
  }) : _userUseCase = userUseCase,
       _subscriptionUseCase = subscriptionUseCase,
       super(const CheckoutInitial());

  // ============================================================================
  // INITIALIZATION
  // ============================================================================

  /// Initialize checkout from WeekSelectionCubit data
  Future<void> initializeFromWeekSelection(
    WeekSelection.WeekSelectionActive weekSelectionState,
  ) async {
    try {
      _logger.i('🔄 Initializing checkout from week selection');
      emit(const CheckoutLoading('Setting up checkout...'));

      // Extract and transform data
      final weekData = WeekSelectionDataExtractor.extract(weekSelectionState);
      final pricing = SubscriptionPricingCalculator.calculate(
        weekData,
        weekSelectionState,
      );

      _logger.d(
        '📊 Extracted data: ${weekData.totalDuration} weeks, ${weekData.totalMeals} meals',
      );
      _logger.d('💰 Total pricing: ₹${pricing.totalPrice}');

      // Load user addresses
      await _loadUserAddresses(weekData, pricing);
    } catch (e) {
      _logger.e('❌ Error initializing checkout', error: e);
      emit(
        CheckoutError(
          message: 'Failed to initialize checkout: ${e.toString()}',
        ),
      );
    }
  }

  /// Load user addresses and initialize active state
  Future<void> _loadUserAddresses(
    WeekSelectionData weekData,
    SubscriptionPricing pricing,
  ) async {
    try {
      _logger.d('📍 Loading user addresses');

      // FIXED: Changed getUserProfile() to getUserDetails()
      final result = await _userUseCase.getUserDetails();

      result.fold(
        (failure) {
          _logger.e('❌ Failed to load user details: ${failure.message}');

          // Initialize without addresses - user can add them
          emit(
            CheckoutActive(weekData: weekData, pricing: pricing, addresses: []),
          );
        },
        (user) {
          _logger.i(
            '✅ Loaded user with ${user.addresses?.length ?? 0} addresses',
          );

          final addresses = user.addresses ?? [];
          String? selectedAddressId;

          // Auto-select first address if available
          if (addresses.isNotEmpty) {
            selectedAddressId = addresses.first.id;
            _logger.d('🎯 Auto-selected first address: $selectedAddressId');
          }

          emit(
            CheckoutActive(
              weekData: weekData,
              pricing: pricing,
              addresses: addresses,
              selectedAddressId: selectedAddressId,
            ),
          );
        },
      );
    } catch (e) {
      _logger.e('❌ Unexpected error loading user details', error: e);

      // Initialize without addresses as fallback
      emit(CheckoutActive(weekData: weekData, pricing: pricing, addresses: []));
    }
  }

  // ============================================================================
  // ADDRESS MANAGEMENT
  // ============================================================================

  /// Refresh addresses from server
  Future<void> refreshAddresses() async {
    final currentState = state;
    if (currentState is! CheckoutActive) return;

    try {
      _logger.d('🔄 Refreshing addresses');

      // FIXED: Changed getUserProfile() to getUserDetails()
      final result = await _userUseCase.getUserDetails();

      result.fold(
        (failure) {
          _logger.e('❌ Failed to refresh user details: ${failure.message}');
          // Keep current state, don't show error for refresh
        },
        (user) {
          final addresses = user.addresses ?? [];
          _logger.i('✅ Refreshed addresses: ${addresses.length} found');

          // Preserve selected address if it still exists
          String? selectedAddressId = currentState.selectedAddressId;
          if (selectedAddressId != null) {
            final stillExists = addresses.any(
              (addr) => addr.id == selectedAddressId,
            );
            if (!stillExists) {
              selectedAddressId =
                  addresses.isNotEmpty ? addresses.first.id : null;
              _logger.d(
                '🔄 Previous address not found, selected new: $selectedAddressId',
              );
            }
          } else if (addresses.isNotEmpty) {
            selectedAddressId = addresses.first.id;
            _logger.d('🎯 Auto-selected first address: $selectedAddressId');
          }

          emit(
            currentState.copyWith(
              addresses: addresses,
              selectedAddressId: selectedAddressId,
            ),
          );
        },
      );
    } catch (e) {
      _logger.e('❌ Unexpected error refreshing addresses', error: e);
      // Keep current state, don't show error for refresh
    }
  }

  /// Select specific address
  void selectAddress(String addressId) {
    final currentState = state;
    if (currentState is! CheckoutActive) return;

    _logger.d('🎯 Selecting address: $addressId');

    emit(currentState.copyWith(selectedAddressId: addressId));
  }

  // ============================================================================
  // FORM DATA MANAGEMENT
  // ============================================================================

  /// Update delivery instructions
  void updateInstructions(String? instructions) {
    final currentState = state;
    if (currentState is! CheckoutActive) return;

    emit(currentState.copyWith(instructions: instructions));
  }

  /// Update number of persons
  void updateNoOfPersons(int noOfPersons) {
    final currentState = state;
    if (currentState is! CheckoutActive) return;

    if (noOfPersons < 1 || noOfPersons > 10) {
      _logger.w('⚠️ Invalid person count: $noOfPersons');
      return;
    }

    _logger.d('👥 Updated person count: $noOfPersons');
    emit(currentState.copyWith(noOfPersons: noOfPersons));
  }

  // ============================================================================
  // SUBSCRIPTION CREATION
  // ============================================================================

  /// Create subscription and prepare for payment
  Future<void> createSubscription() async {
    final currentState = state;
    if (currentState is! CheckoutActive) return;

    if (!currentState.canSubmit) {
      final missing = currentState.missingFields;
      emit(
        CheckoutError(
          message: 'Please complete required fields: ${missing.join(', ')}',
          weekData: currentState.weekData,
          pricing: currentState.pricing,
          selectedAddressId: currentState.selectedAddressId,
          instructions: currentState.instructions,
          noOfPersons: currentState.noOfPersons,
        ),
      );
      return;
    }

    try {
      _logger.i('🔨 Creating subscription');

      // Set submitting state
      emit(currentState.copyWith(isSubmitting: true));

      // Build subscription request
      final requestData = CheckoutSubscriptionRequestBuilder.buildRequest(
        weekData: currentState.weekData,
        addressId: currentState.selectedAddressId!,
        noOfPersons: currentState.noOfPersons,
        instructions: currentState.instructions,
      );

      _logger.d(
        '📤 Subscription request built with ${requestData['weeks']?.length ?? 0} weeks',
      );

      // Create subscription via use case
      final result = await _subscriptionUseCase.createSubscriptionFromRequest(
        requestData,
      );

      result.fold(
        (failure) {
          _logger.e('❌ Subscription creation failed: ${failure.message}');

          emit(
            CheckoutError(
              message: failure.message ?? 'Failed to create subscription',
              weekData: currentState.weekData,
              pricing: currentState.pricing,
              selectedAddressId: currentState.selectedAddressId,
              instructions: currentState.instructions,
              noOfPersons: currentState.noOfPersons,
            ),
          );
        },
        (subscription) {
          _logger.i('✅ Subscription created successfully: ${subscription.id}');

          emit(
            CheckoutSubscriptionCreated(
              subscription: subscription,
              weekData: currentState.weekData,
              pricing: currentState.pricing,
              selectedAddressId: currentState.selectedAddressId!,
              instructions: currentState.instructions,
              noOfPersons: currentState.noOfPersons,
            ),
          );
        },
      );
    } catch (e) {
      _logger.e('❌ Unexpected error creating subscription', error: e);

      emit(
        CheckoutError(
          message: 'An unexpected error occurred while creating subscription',
          weekData: currentState.weekData,
          pricing: currentState.pricing,
          selectedAddressId: currentState.selectedAddressId,
          instructions: currentState.instructions,
          noOfPersons: currentState.noOfPersons,
        ),
      );
    }
  }

  /// Retry subscription creation from error state
  Future<void> retryCreateSubscription() async {
    final currentState = state;
    if (currentState is! CheckoutError || !currentState.canRetry) return;

    _logger.i('🔄 Retrying subscription creation');

    // Go back to active state and retry
    emit(
      CheckoutActive(
        weekData: currentState.weekData!,
        pricing: currentState.pricing!,
        selectedAddressId: currentState.selectedAddressId,
        instructions: currentState.instructions,
        noOfPersons: currentState.noOfPersons ?? 1,
      ),
    );

    // Load addresses again and then retry creation
    await refreshAddresses();
    await createSubscription();
  }

  // ============================================================================
  // VALIDATION & HELPERS
  // ============================================================================

  /// Validate current checkout state
  bool validateCheckout() {
    final currentState = state;
    if (currentState is! CheckoutActive) return false;

    return currentState.canSubmit;
  }

  /// Get validation errors
  List<String> getValidationErrors() {
    final currentState = state;
    if (currentState is! CheckoutActive) return ['Invalid checkout state'];

    return currentState.missingFields;
  }

  /// Get current total amount
  double? getCurrentTotal() {
    final currentState = state;
    if (currentState is CheckoutActive) {
      return currentState.totalAmount;
    } else if (currentState is CheckoutSubscriptionCreated) {
      return currentState.totalAmount;
    }
    return null;
  }

  /// Check if checkout is ready for payment
  bool get isReadyForPayment => state is CheckoutSubscriptionCreated;

  /// Get subscription for payment (only available after successful creation)
  Subscription? get subscriptionForPayment {
    final currentState = state;
    if (currentState is CheckoutSubscriptionCreated) {
      return currentState.subscription;
    }
    return null;
  }

  // ============================================================================
  // NAVIGATION HELPERS
  // ============================================================================

  /// Reset to initial state
  void reset() {
    _logger.i('🔄 Resetting checkout');
    emit(const CheckoutInitial());
  }

  /// Go back to week selection (if user wants to edit)
  void returnToWeekSelection() {
    _logger.i('🔙 Returning to week selection');
    reset();
  }

  @override
  Future<void> close() {
    _logger.d('🔒 Closing CheckoutCubit');
    return super.close();
  }
}

// ============================================================================
// EXTENSION FOR SUBSCRIPTION USE CASE
// ============================================================================

/// Extension to add direct subscription creation method to SubscriptionUseCase
extension SubscriptionUseCaseCheckoutExtension on SubscriptionUseCase {
  /// Create subscription from request data (for checkout flow)
  Future<Either<Failure, Subscription>> createSubscriptionFromRequest(
    Map<String, dynamic> requestData,
  ) async {
    // This would be implemented in the actual SubscriptionUseCase
    // For now, using the existing createSubscription method pattern

    try {
      final params = SubscriptionParams(
        startDate: DateTime.parse(requestData['startDate']),
        durationDays: requestData['durationDays'],
        addressId: requestData['address'],
        instructions: requestData['instructions'],
        noOfPersons: requestData['noOfPersons'],
        weeks:
            (requestData['weeks'] as List).map((weekData) {
              return WeekSubscriptionRequest(
                packageId: weekData['package'],
                slots:
                    (weekData['slots'] as List).map((slotData) {
                      return MealSlotRequest(
                        day: slotData['day'],
                        date: DateTime.parse(slotData['date']),
                        timing: slotData['timing'],
                        dishId: slotData['meal'],
                      );
                    }).toList(),
              );
            }).toList(),
      );

      return await createSubscription(params);
    } catch (e) {
      return Left(ServerFailure('Failed to process subscription request: $e'));
    }
  }
}
