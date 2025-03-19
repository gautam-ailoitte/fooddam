// lib/src/presentation/cubits/checkout/checkout_state.dart
import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/address_entity.dart';
import 'package:foodam/src/domain/entities/payment_entity.dart';

enum CheckoutStatus {
  initial,
  loading,
  addressSelected,
  paymentMethodSelected,
  couponApplied,
  couponInvalid,
  processing,
  success,
  error
}

class CheckoutState extends Equatable {
  final CheckoutStatus status;
  final List<Address> addresses;
  final Address? selectedAddress;
  final String? selectedPaymentMethodId;
  final PaymentMethod? selectedPaymentMethod;
  final String? couponCode;
  final Coupon? appliedCoupon;
  final double subtotal;
  final double discount;
  final double totalAmount;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const CheckoutState({
    this.status = CheckoutStatus.initial,
    this.addresses = const [],
    this.selectedAddress,
    this.selectedPaymentMethodId,
    this.selectedPaymentMethod,
    this.couponCode,
    this.appliedCoupon,
    this.subtotal = 0.0,
    this.discount = 0.0,
    this.totalAmount = 0.0,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  CheckoutState copyWith({
    CheckoutStatus? status,
    List<Address>? addresses,
    Address? selectedAddress,
    String? selectedPaymentMethodId,
    PaymentMethod? selectedPaymentMethod,
    String? couponCode,
    Coupon? appliedCoupon,
    double? subtotal,
    double? discount,
    double? totalAmount,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return CheckoutState(
      status: status ?? this.status,
      addresses: addresses ?? this.addresses,
      selectedAddress: selectedAddress ?? this.selectedAddress,
      selectedPaymentMethodId: selectedPaymentMethodId ?? this.selectedPaymentMethodId,
      selectedPaymentMethod: selectedPaymentMethod ?? this.selectedPaymentMethod,
      couponCode: couponCode ?? this.couponCode,
      appliedCoupon: appliedCoupon ?? this.appliedCoupon,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      totalAmount: totalAmount ?? this.totalAmount,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
    );
  }

  bool get isAddressSelected => selectedAddress != null;
  bool get isPaymentMethodSelected => selectedPaymentMethod != null;
  bool get canProceed => isAddressSelected && isPaymentMethodSelected;

  @override
  List<Object?> get props => [
    status,
    addresses,
    selectedAddress,
    selectedPaymentMethodId,
    selectedPaymentMethod,
    couponCode,
    appliedCoupon,
    subtotal,
    discount,
    totalAmount,
    isLoading,
    errorMessage,
    successMessage,
  ];
}