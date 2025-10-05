// lib/src/presentation/cubits/checkout/checkout_state.dart

part of 'checkout_cubit.dart';

abstract class CheckoutState extends Equatable {
  const CheckoutState();

  @override
  List<Object?> get props => [];
}

class CheckoutInitial extends CheckoutState {
  const CheckoutInitial();
}

class CheckoutLoading extends CheckoutState {
  final String? message;

  const CheckoutLoading({this.message});

  @override
  List<Object?> get props => [message];
}

class CheckoutActive extends CheckoutState {
  // Planning data (copied once from MealPlanningCubit)
  final DateTime startDate;
  final Map<int, WeekCheckoutData> weeks;
  final double basePrice;

  // Checkout form data
  final List<Address>? addresses;
  final String? selectedAddressId;
  final String instructions;
  final int noOfPersons;

  // UI state
  final bool isLoadingAddresses;
  final bool isSubmitting;

  const CheckoutActive({
    required this.startDate,
    required this.weeks,
    required this.basePrice,
    this.addresses,
    this.selectedAddressId,
    this.instructions = '',
    this.noOfPersons = 1,
    this.isLoadingAddresses = false,
    this.isSubmitting = false,
  });

  // Validation
  bool get canSubmit =>
      selectedAddressId != null &&
      selectedAddressId!.isNotEmpty &&
      noOfPersons > 0 &&
      !isSubmitting;

  List<String> get missingFields {
    final missing = <String>[];
    if (selectedAddressId == null || selectedAddressId!.isEmpty) {
      missing.add('delivery address');
    }
    if (noOfPersons <= 0) missing.add('number of persons');
    return missing;
  }

  // Total amount calculation
  double get totalAmount => basePrice * noOfPersons;

  CheckoutActive copyWith({
    DateTime? startDate,
    Map<int, WeekCheckoutData>? weeks,
    double? basePrice,
    List<Address>? addresses,
    String? selectedAddressId,
    String? instructions,
    int? noOfPersons,
    bool? isLoadingAddresses,
    bool? isSubmitting,
  }) {
    return CheckoutActive(
      startDate: startDate ?? this.startDate,
      weeks: weeks ?? this.weeks,
      basePrice: basePrice ?? this.basePrice,
      addresses: addresses ?? this.addresses,
      selectedAddressId: selectedAddressId ?? this.selectedAddressId,
      instructions: instructions ?? this.instructions,
      noOfPersons: noOfPersons ?? this.noOfPersons,
      isLoadingAddresses: isLoadingAddresses ?? this.isLoadingAddresses,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [
    startDate,
    weeks,
    basePrice,
    addresses,
    selectedAddressId,
    instructions,
    noOfPersons,
    isLoadingAddresses,
    isSubmitting,
  ];
}

class CheckoutSubscriptionCreated extends CheckoutState {
  final String subscriptionId;
  final double totalAmount;

  const CheckoutSubscriptionCreated({
    required this.subscriptionId,
    required this.totalAmount,
  });

  @override
  List<Object?> get props => [subscriptionId, totalAmount];
}

class CheckoutError extends CheckoutState {
  final String message;
  final bool canRetry;

  const CheckoutError({required this.message, this.canRetry = true});

  @override
  List<Object?> get props => [message, canRetry];
}

// Data class to hold week information
class WeekCheckoutData extends Equatable {
  final String dietaryPreference;
  final List<String> slots;

  const WeekCheckoutData({
    required this.dietaryPreference,
    required this.slots,
  });

  @override
  List<Object?> get props => [dietaryPreference, slots];
}
