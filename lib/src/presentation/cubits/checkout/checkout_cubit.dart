// lib/src/presentation/cubits/checkout/checkout_cubit.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/service/loggin_manager.dart';
import 'package:foodam/src/domain/entities/address_entity.dart';
import 'package:foodam/src/domain/entities/meal_planning/subscription_request_entity.dart';
import 'package:foodam/src/domain/usecase/user_usecase.dart';
import 'package:intl/intl.dart';

import '../../../domain/usecase/meal_planning/create_subscription_use_case.dart';

part 'checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  final UserUseCase userUseCase;
  final CreateSubscriptionUseCase createSubscriptionUseCase;
  final LoggingManager _logger = LoggingManager();

  CheckoutCubit({
    required this.userUseCase,
    required this.createSubscriptionUseCase,
  }) : super(const CheckoutInitial()) {
    _logger.logger.i('CheckoutCubit initialized', tag: 'Checkout');
  }

  // Initialize checkout with planning data
  Future<void> initializeCheckout({
    required DateTime startDate,
    required Map<int, WeekCheckoutData> weeks,
    required double basePrice,
  }) async {
    _logger.logger.i(
      '========== CHECKOUT INITIALIZATION ==========',
      tag: 'Checkout',
    );
    _logger.logger.i(
      'Start Date: ${DateFormat('yyyy-MM-dd').format(startDate)}',
      tag: 'Checkout',
    );
    _logger.logger.i('Weeks Count: ${weeks.length}', tag: 'Checkout');
    _logger.logger.i('Base Price: ₹$basePrice', tag: 'Checkout');

    emit(
      CheckoutActive(startDate: startDate, weeks: weeks, basePrice: basePrice),
    );

    _logger.logger.i('CheckoutActive state emitted', tag: 'Checkout');

    // Automatically fetch addresses
    await fetchAddresses();
  }

  // Fetch addresses from user repository
  Future<void> fetchAddresses() async {
    final currentState = state;
    if (currentState is! CheckoutActive) {
      _logger.logger.w(
        'Cannot fetch addresses - state is not CheckoutActive',
        tag: 'Checkout',
      );
      return;
    }

    _logger.logger.i('Fetching user addresses...', tag: 'Checkout');
    emit(currentState.copyWith(isLoadingAddresses: true));

    final result = await userUseCase.getUserAddresses();

    result.fold(
      (failure) {
        _logger.logger.e(
          'Failed to fetch addresses: ${failure.message}',
          tag: 'Checkout',
        );
        emit(currentState.copyWith(isLoadingAddresses: false, addresses: []));
        _logger.logger.w(
          'Emitted empty address list due to error',
          tag: 'Checkout',
        );
      },
      (addresses) {
        _logger.logger.i(
          'Addresses fetched successfully: ${addresses.length} addresses',
          tag: 'Checkout',
        );

        // Log each address for debugging
        for (var i = 0; i < addresses.length; i++) {
          _logger.logger.d(
            'Address $i: ID=${addresses[i].id}, ${addresses[i].street}, ${addresses[i].city}',
            tag: 'Checkout',
          );
        }

        emit(
          currentState.copyWith(
            isLoadingAddresses: false,
            addresses: addresses,
          ),
        );
        _logger.logger.i(
          'CheckoutActive updated with addresses',
          tag: 'Checkout',
        );
      },
    );
  }

  // Refresh addresses
  Future<void> refreshAddresses() async {
    _logger.logger.i('Refreshing addresses...', tag: 'Checkout');
    await fetchAddresses();
  }

  // Select an address
  void selectAddress(String addressId) {
    final currentState = state;
    if (currentState is! CheckoutActive) {
      _logger.logger.w(
        'Cannot select address - state is not CheckoutActive',
        tag: 'Checkout',
      );
      return;
    }

    _logger.logger.i('Address selected: $addressId', tag: 'Checkout');

    // Find and log the selected address details
    final selectedAddr = currentState.addresses?.firstWhere(
      (addr) => addr.id == addressId,
      orElse:
          () => const Address(
            id: '',
            street: '',
            city: '',
            state: '',
            zipCode: '',
          ),
    );

    if (selectedAddr != null && selectedAddr.id.isNotEmpty) {
      _logger.logger.d(
        'Selected address details: ${selectedAddr.street}, ${selectedAddr.city}, ${selectedAddr.state}',
        tag: 'Checkout',
      );
    }

    emit(currentState.copyWith(selectedAddressId: addressId));
    _logger.logger.i(
      'Validation status - Can submit: ${(state as CheckoutActive).canSubmit}',
      tag: 'Checkout',
    );
  }

  // Update number of persons
  void updateNoOfPersons(int count) {
    final currentState = state;
    if (currentState is! CheckoutActive) {
      _logger.logger.w(
        'Cannot update person count - state is not CheckoutActive',
        tag: 'Checkout',
      );
      return;
    }

    if (count < 1 || count > 10) {
      _logger.logger.w(
        'Invalid person count: $count (must be 1-10)',
        tag: 'Checkout',
      );
      return;
    }

    _logger.logger.i('Person count updated: $count', tag: 'Checkout');
    _logger.logger.d(
      'New total amount: ₹${currentState.basePrice * count}',
      tag: 'Checkout',
    );

    emit(currentState.copyWith(noOfPersons: count));
  }

  // Update instructions
  void updateInstructions(String instructions) {
    final currentState = state;
    if (currentState is! CheckoutActive) {
      _logger.logger.w(
        'Cannot update instructions - state is not CheckoutActive',
        tag: 'Checkout',
      );
      return;
    }

    _logger.logger.d(
      'Instructions updated: ${instructions.isEmpty ? "(empty)" : instructions}',
      tag: 'Checkout',
    );
    emit(currentState.copyWith(instructions: instructions));
  }

  // Create subscription
  Future<void> createSubscription() async {
    final currentState = state;
    if (currentState is! CheckoutActive) {
      _logger.logger.e(
        'Cannot create subscription - state is not CheckoutActive',
        tag: 'Checkout',
      );
      return;
    }

    if (!currentState.canSubmit) {
      final missing = currentState.missingFields;
      _logger.logger.w(
        'Cannot submit - missing fields: ${missing.join(", ")}',
        tag: 'Checkout',
      );
      emit(
        CheckoutError(
          message: 'Please provide: ${missing.join(", ")}',
          canRetry: true,
        ),
      );
      return;
    }

    _logger.logger.i(
      '========== CREATING SUBSCRIPTION ==========',
      tag: 'Checkout',
    );
    _logger.logger.i(
      'Start Date: ${DateFormat('yyyy-MM-dd').format(currentState.startDate)}',
      tag: 'Checkout',
    );
    _logger.logger.i(
      'Address ID: ${currentState.selectedAddressId}',
      tag: 'Checkout',
    );
    _logger.logger.i(
      'Instructions: ${currentState.instructions.isEmpty ? "(none)" : currentState.instructions}',
      tag: 'Checkout',
    );
    _logger.logger.i(
      'Number of Persons: ${currentState.noOfPersons}',
      tag: 'Checkout',
    );
    _logger.logger.i('Base Price: ₹${currentState.basePrice}', tag: 'Checkout');
    _logger.logger.i(
      'Total Amount: ₹${currentState.totalAmount}',
      tag: 'Checkout',
    );

    emit(currentState.copyWith(isSubmitting: true));
    _logger.logger.d('Submitting flag set to true', tag: 'Checkout');

    // Build week requests
    final weekRequests =
        currentState.weeks.entries.map((entry) {
          _logger.logger.d(
            'Week ${entry.key}: ${entry.value.slots.length} slots, ${entry.value.dietaryPreference}',
            tag: 'Checkout',
          );
          return WeekRequestData(
            dietaryPreference: entry.value.dietaryPreference,
            slots: entry.value.slots,
          );
        }).toList();

    _logger.logger.d(
      'Total weeks in request: ${weekRequests.length}',
      tag: 'Checkout',
    );

    final request = SubscriptionRequest(
      startDate: currentState.startDate,
      address: currentState.selectedAddressId!,
      instructions: currentState.instructions,
      noOfPersons: currentState.noOfPersons,
      weeks: weekRequests,
    );

    _logger.logger.i(
      'Subscription request built - calling use case...',
      tag: 'Checkout',
    );

    final result = await createSubscriptionUseCase.call(
      CreateSubscriptionParams(request: request),
    );

    result.fold(
      (failure) {
        _logger.logger.e(
          '========== SUBSCRIPTION FAILED ==========',
          tag: 'Checkout',
        );
        _logger.logger.e('Error: ${failure.message}', tag: 'Checkout');
        _logger.logger.e('Error type: ${failure.runtimeType}', tag: 'Checkout');

        emit(CheckoutError(message: failure.message ?? "", canRetry: true));

        _logger.logger.i('CheckoutError state emitted', tag: 'Checkout');
      },
      (response) {
        _logger.logger.i(
          '========== SUBSCRIPTION CREATED ==========',
          tag: 'Checkout',
        );
        _logger.logger.i('Subscription ID: ${response.id}', tag: 'Checkout');
        _logger.logger.i('Status: ${response.status}', tag: 'Checkout');
        _logger.logger.i(
          'Total Amount: ₹${response.totalAmount}',
          tag: 'Checkout',
        );
        _logger.logger.i('Created At: ${response.createdAt}', tag: 'Checkout');

        if (response.message != null) {
          _logger.logger.d('API Message: ${response.message}', tag: 'Checkout');
        }

        emit(
          CheckoutSubscriptionCreated(
            subscriptionId: response.id ?? '',
            totalAmount: response.totalAmount ?? currentState.totalAmount,
          ),
        );

        _logger.logger.i(
          'CheckoutSubscriptionCreated state emitted',
          tag: 'Checkout',
        );
        _logger.logger.i('Ready for payment processing', tag: 'Checkout');
      },
    );
  }

  // Retry after error
  Future<void> retryCreateSubscription() async {
    _logger.logger.i('Retrying subscription creation...', tag: 'Checkout');

    final currentState = state;
    if (currentState is CheckoutError) {
      _logger.logger.w(
        'Cannot retry from error state - checkout data lost',
        tag: 'Checkout',
      );
      _logger.logger.w(
        'User needs to go back and start checkout again',
        tag: 'Checkout',
      );
      return;
    }

    await createSubscription();
  }

  // Return to week selection
  void returnToWeekSelection() {
    _logger.logger.i(
      'Returning to week selection - resetting checkout',
      tag: 'Checkout',
    );
    emit(const CheckoutInitial());
  }

  @override
  Future<void> close() {
    _logger.logger.i('CheckoutCubit closing', tag: 'Checkout');
    return super.close();
  }
}
