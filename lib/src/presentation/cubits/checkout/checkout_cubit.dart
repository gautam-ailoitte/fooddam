
// lib/src/presentation/cubits/checkout/checkout_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/src/domain/entities/address_entity.dart';
import 'package:foodam/src/domain/entities/payment_entity.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';
import 'package:foodam/src/domain/usecase/payment/process_payment_usecase.dart';
import 'package:foodam/src/domain/usecase/payment/verify_coupon_usecase.dart';
import 'package:foodam/src/domain/usecase/subscription/save_subscription_and_get_payment_url_usecase.dart';
import 'package:foodam/src/domain/usecase/user/get_user_addresses_usecase.dart';
import 'package:foodam/src/presentation/cubits/checkout/checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  final GetUserAddressesUseCase _getUserAddressesUseCase;
  final VerifyCouponUseCase _verifyCouponUseCase;
  final ProcessPaymentUseCase _processPaymentUseCase;
  final SaveSubscriptionAndGetPaymentUrlUseCase _saveSubscriptionAndGetPaymentUrlUseCase;

  CheckoutCubit({
    required GetUserAddressesUseCase getUserAddressesUseCase,
    required VerifyCouponUseCase verifyCouponUseCase,
    required ProcessPaymentUseCase processPaymentUseCase,
    required SaveSubscriptionAndGetPaymentUrlUseCase saveSubscriptionAndGetPaymentUrlUseCase,
  })  : _getUserAddressesUseCase = getUserAddressesUseCase,
        _verifyCouponUseCase = verifyCouponUseCase,
        _processPaymentUseCase = processPaymentUseCase,
        _saveSubscriptionAndGetPaymentUrlUseCase = saveSubscriptionAndGetPaymentUrlUseCase,
        super(const CheckoutState());

  // Initialize checkout with subscription details
  void initializeCheckout(double basePrice, double additionalCost) {
    final subtotal = basePrice + additionalCost;
    
    emit(state.copyWith(
      status: CheckoutStatus.initial,
      subtotal: subtotal,
      totalAmount: subtotal,
    ));
    
    // Load user addresses
    loadUserAddresses();
  }

  // Load user addresses
  Future<void> loadUserAddresses() async {
    emit(state.copyWith(isLoading: true));

    final result = await _getUserAddressesUseCase();

    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        errorMessage: _mapFailureToMessage(failure),
      )),
      (addresses) => emit(state.copyWith(
        addresses: addresses,
        isLoading: false,
      )),
    );
  }

  // Select delivery address
  void selectAddress(Address address) {
    emit(state.copyWith(
      status: CheckoutStatus.addressSelected,
      selectedAddress: address,
    ));
  }

  // Select payment method
  void selectPaymentMethod(PaymentMethod method, String? paymentMethodId) {
    emit(state.copyWith(
      status: CheckoutStatus.paymentMethodSelected,
      selectedPaymentMethod: method,
      selectedPaymentMethodId: paymentMethodId,
    ));
  }

  // Apply coupon code
  Future<void> applyCoupon(String code) async {
    emit(state.copyWith(
      isLoading: true,
      couponCode: code,
    ));

    final params = VerifyCouponParams(
      couponCode: code,
      orderAmount: state.subtotal,
    );

    final result = await _verifyCouponUseCase(params);

    result.fold(
      (failure) => emit(state.copyWith(
        status: CheckoutStatus.couponInvalid,
        isLoading: false,
        errorMessage: 'Invalid coupon: ${_mapFailureToMessage(failure)}',
      )),
      (coupon) {
        // Calculate discount based on coupon type
        double discount = 0.0;
        if (coupon.discountType == 'percentage') {
          discount = (coupon.discountValue / 100) * state.subtotal;
          
          // Apply max discount if specified
          if (coupon.maxDiscountAmount != null && discount > coupon.maxDiscountAmount!) {
            discount = coupon.maxDiscountAmount!;
          }
        } else {
          // Fixed amount discount
          discount = coupon.discountValue;
        }
        
        // Calculate total amount after discount
        final totalAmount = state.subtotal - discount;
        
        emit(state.copyWith(
          status: CheckoutStatus.couponApplied,
          appliedCoupon: coupon,
          discount: discount,
          totalAmount: totalAmount,
          isLoading: false,
          successMessage: 'Coupon applied successfully!',
        ));
      },
    );
  }

  // Remove applied coupon
  void removeCoupon() {
    emit(state.copyWith(
      couponCode: null,
      appliedCoupon: null,
      discount: 0.0,
      totalAmount: state.subtotal,
    ));
  }

  // Process payment and complete checkout
  Future<void> processPayment(Subscription subscription, String orderId) async {
    if (!state.canProceed) {
      emit(state.copyWith(
        errorMessage: 'Please select a delivery address and payment method.',
      ));
      return;
    }

    emit(state.copyWith(
      status: CheckoutStatus.processing,
      isLoading: true,
    ));

    // First, save the subscription
    final subscriptionResult = await _saveSubscriptionAndGetPaymentUrlUseCase(subscription);
    
     subscriptionResult.fold(
      (failure) => emit(state.copyWith(
        status: CheckoutStatus.error,
        isLoading: false,
        errorMessage: 'Failed to save subscription: ${_mapFailureToMessage(failure)}',
      )),
      (paymentUrl) async {
        // Now process the payment
        final paymentParams = ProcessPaymentParams(
          orderId: orderId,
          paymentMethod: state.selectedPaymentMethod!,
          couponCode: state.appliedCoupon?.code,
          paymentDetails: {
            'paymentMethodId': state.selectedPaymentMethodId,
            'amount': state.totalAmount,
          },
        );

        final paymentResult = await _processPaymentUseCase(paymentParams);

        paymentResult.fold(
          (failure) => emit(state.copyWith(
            status: CheckoutStatus.error,
            isLoading: false,
            errorMessage: 'Payment failed: ${_mapFailureToMessage(failure)}',
          )),
          (payment) => emit(state.copyWith(
            status: CheckoutStatus.success,
            isLoading: false,
            successMessage: 'Payment successful! Your subscription is now active.',
          )),
        );
      },
    );
  }

  // Helper method to map failures to user-friendly messages
  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Server error. Please try again later.';
      case NetworkFailure:
        return 'Network error. Please check your connection.';
      default:
        return 'An unexpected error occurred.';
    }
  }
}