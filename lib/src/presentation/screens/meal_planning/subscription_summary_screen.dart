// lib/src/presentation/screens/meal_planning/subscription_summary_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/route/app_router.dart';
import 'package:foodam/core/service/loggin_manager.dart';
import 'package:foodam/core/widgets/primary_button.dart';
import 'package:foodam/src/domain/entities/address_entity.dart';
import 'package:foodam/src/domain/entities/payment_entity.dart';
import 'package:foodam/src/presentation/cubits/checkout/checkout_cubit.dart';
import 'package:foodam/src/presentation/cubits/meal_planning/meal_planning_cubit.dart';
import 'package:foodam/src/presentation/cubits/payment/razor_pay_cubit/razor_pay_cubit/razor_pay_cubit_cubit.dart';
import 'package:foodam/src/presentation/cubits/payment/razor_pay_cubit/razor_pay_cubit/razor_pay_cubit_state.dart';

class SubscriptionSummaryScreen extends StatefulWidget {
  const SubscriptionSummaryScreen({super.key});

  @override
  State<SubscriptionSummaryScreen> createState() =>
      _SubscriptionSummaryScreenState();
}

class _SubscriptionSummaryScreenState extends State<SubscriptionSummaryScreen> {
  final LoggingManager _logger = LoggingManager();

  PaymentMethod _selectedPaymentMethod = PaymentMethod.upi;
  bool _isProcessingPayment = false;

  @override
  void initState() {
    super.initState();
    _logger.logger.i(
      '========== SUMMARY SCREEN INIT ==========',
      tag: 'Checkout',
    );
    _initializeCheckout();
  }

  void _initializeCheckout() {
    _logger.logger.i(
      'Initializing checkout from planning data...',
      tag: 'Checkout',
    );

    final planningState = context.read<MealPlanningCubit>().state;
    _logger.logger.d(
      'Planning state type: ${planningState.runtimeType}',
      tag: 'Checkout',
    );

    if (planningState is! WeekGridLoaded) {
      _logger.logger.e(
        'Invalid planning state - cannot initialize checkout',
        tag: 'Checkout',
      );
      _showErrorAndGoBack('Invalid planning data');
      return;
    }

    _logger.logger.i('Planning data validated successfully', tag: 'Checkout');

    // Access via getters
    final startDate = planningState.startDate; // Uses getter
    final dietaryPreference =
        planningState.defaultDietaryPreference; // Uses getter

    _logger.logger.d('Start Date: $startDate', tag: 'Checkout');
    _logger.logger.d('Dietary Preference: $dietaryPreference', tag: 'Checkout');

    // Convert planning data to checkout format
    final checkoutWeeks = <int, WeekCheckoutData>{};
    planningState.weekSelections.forEach((weekNum, weekData) {
      checkoutWeeks[weekNum] = WeekCheckoutData(
        dietaryPreference: weekData.dietaryPreference,
        slots: weekData.selectedSlotKeys, // Use the existing method
      );
    });

    context.read<CheckoutCubit>().initializeCheckout(
      startDate: startDate,
      weeks: checkoutWeeks,
      basePrice: planningState.totalPrice,
    );
  }

  @override
  void dispose() {
    _logger.logger.i('Summary screen disposing', tag: 'Checkout');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Your Plan'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: BlocConsumer<CheckoutCubit, CheckoutState>(
        listener: _handleCheckoutState,
        builder: (context, state) {
          _logger.logger.d(
            'Building UI for state: ${state.runtimeType}',
            tag: 'Checkout',
          );

          if (state is CheckoutLoading) {
            return _buildLoadingState(state.message);
          } else if (state is CheckoutActive) {
            return _buildCheckoutContent(state);
          } else if (state is CheckoutSubscriptionCreated) {
            return _buildPaymentProcessing(state);
          } else if (state is CheckoutError) {
            return _buildErrorState(state);
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  void _handleCheckoutState(BuildContext context, CheckoutState state) {
    _logger.logger.i(
      'Checkout state changed: ${state.runtimeType}',
      tag: 'Checkout',
    );

    if (state is CheckoutSubscriptionCreated) {
      _logger.logger.i(
        'Subscription created - triggering payment',
        tag: 'Checkout',
      );
      _triggerPayment(state.subscriptionId);
    }
  }

  void _triggerPayment(String subscriptionId) {
    _logger.logger.i('========== PAYMENT TRIGGER ==========', tag: 'Payment');
    _logger.logger.i('Subscription ID: $subscriptionId', tag: 'Payment');
    _logger.logger.i('Payment Method: $_selectedPaymentMethod', tag: 'Payment');

    setState(() => _isProcessingPayment = true);

    context.read<RazorpayPaymentCubit>().processPaymentForSubscription(
      subscriptionId,
      _selectedPaymentMethod,
    );
  }

  Widget _buildLoadingState(String? message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          SizedBox(height: AppSpacing.md),
          Text(message ?? 'Loading...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(CheckoutError state) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            SizedBox(height: AppSpacing.md),
            Text(
              'Error',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(state.message, textAlign: TextAlign.center),
            SizedBox(height: AppSpacing.lg),
            if (state.canRetry)
              PrimaryButton(
                text: 'Retry',
                onPressed: () {
                  _logger.logger.i('Retry button pressed', tag: 'Checkout');
                  context.read<CheckoutCubit>().retryCreateSubscription();
                },
              ),
            SizedBox(height: AppSpacing.sm),
            OutlinedButton(
              onPressed: () {
                _logger.logger.i(
                  'Back button pressed from error',
                  tag: 'Checkout',
                );
                Navigator.pop(context);
              },
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentProcessing(CheckoutSubscriptionCreated state) {
    return BlocListener<RazorpayPaymentCubit, RazorpayPaymentState>(
      listener: _handlePaymentState,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: AppSpacing.md),
            Text(
              'Processing Payment...',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppSpacing.sm),
            Text('Total: ₹${state.totalAmount.toInt()}'),
          ],
        ),
      ),
    );
  }

  void _handlePaymentState(BuildContext context, RazorpayPaymentState state) {
    _logger.logger.i('Payment state: ${state.runtimeType}', tag: 'Payment');

    if (state is RazorpayPaymentSuccessWithId) {
      _logger.logger.i('========== PAYMENT SUCCESS ==========', tag: 'Payment');
      setState(() => _isProcessingPayment = false);
      _showPaymentSuccessDialog();
    } else if (state is RazorpayPaymentError) {
      _logger.logger.e('========== PAYMENT FAILED ==========', tag: 'Payment');
      _logger.logger.e('Error: ${state.message}', tag: 'Payment');

      setState(() => _isProcessingPayment = false);
      _showErrorSnackBar('Payment failed: ${state.message}');

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(AppRouter.mainRoute, (route) => false);
        }
      });
    }
  }

  Widget _buildCheckoutContent(CheckoutActive state) {
    _logger.logger.d('Building checkout content', tag: 'Checkout');
    _logger.logger.d('Can submit: ${state.canSubmit}', tag: 'Checkout');

    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPersonCountSection(state),
                    SizedBox(height: AppSpacing.lg),
                    _buildAddressSection(state),
                    SizedBox(height: AppSpacing.lg),
                    _buildInstructionsSection(state),
                    SizedBox(height: AppSpacing.lg),
                    _buildPaymentMethodSection(),
                    SizedBox(height: AppSpacing.lg),
                    _buildPricingSummary(state),
                    SizedBox(height: AppSpacing.lg * 2),
                  ],
                ),
              ),
            ),
          ],
        ),

        if (_isProcessingPayment) _buildPaymentOverlay(),

        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _buildBottomActions(state),
        ),
      ],
    );
  }

  Widget _buildPersonCountSection(CheckoutActive state) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Number of Persons',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppSpacing.md),
            Row(
              children: [
                IconButton(
                  onPressed:
                      state.noOfPersons > 1
                          ? () {
                            _logger.logger.i(
                              'Decreasing person count',
                              tag: 'Checkout',
                            );
                            context.read<CheckoutCubit>().updateNoOfPersons(
                              state.noOfPersons - 1,
                            );
                          }
                          : null,
                  icon: Icon(
                    Icons.remove_circle,
                    color:
                        state.noOfPersons > 1 ? AppColors.primary : Colors.grey,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${state.noOfPersons}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed:
                      state.noOfPersons < 10
                          ? () {
                            _logger.logger.i(
                              'Increasing person count',
                              tag: 'Checkout',
                            );
                            context.read<CheckoutCubit>().updateNoOfPersons(
                              state.noOfPersons + 1,
                            );
                          }
                          : null,
                  icon: Icon(
                    Icons.add_circle,
                    color:
                        state.noOfPersons < 10
                            ? AppColors.primary
                            : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressSection(CheckoutActive state) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Delivery Address',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () {
                    _logger.logger.i(
                      'Refresh addresses pressed',
                      tag: 'Checkout',
                    );
                    context.read<CheckoutCubit>().refreshAddresses();
                  },
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Refresh'),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),

            if (state.isLoadingAddresses)
              const Center(child: CircularProgressIndicator())
            else if (state.addresses == null || state.addresses!.isEmpty)
              _buildNoAddresses()
            else
              _buildAddressList(state.addresses!, state.selectedAddressId),
          ],
        ),
      ),
    );
  }

  Widget _buildNoAddresses() {
    return Column(
      children: [
        Icon(Icons.location_off, size: 48, color: AppColors.textSecondary),
        SizedBox(height: AppSpacing.sm),
        const Text('No addresses found'),
        SizedBox(height: AppSpacing.md),
        PrimaryButton(
          text: 'Add Address',
          onPressed: () async {
            _logger.logger.i('Navigating to add address', tag: 'Checkout');
            await Navigator.pushNamed(context, AppRouter.addAddressRoute);
            if (mounted) {
              context.read<CheckoutCubit>().refreshAddresses();
            }
          },
        ),
      ],
    );
  }

  Widget _buildAddressList(List<Address> addresses, String? selectedId) {
    return Column(
      children: [
        ...addresses.map((address) => _buildAddressItem(address, selectedId)),
        SizedBox(height: AppSpacing.sm),
        TextButton.icon(
          onPressed: () async {
            _logger.logger.i('Add new address pressed', tag: 'Checkout');
            await Navigator.pushNamed(context, AppRouter.addAddressRoute);
            if (mounted) {
              context.read<CheckoutCubit>().refreshAddresses();
            }
          },
          icon: const Icon(Icons.add),
          label: const Text('Add New Address'),
        ),
      ],
    );
  }

  Widget _buildAddressItem(Address address, String? selectedId) {
    final isSelected = selectedId == address.id;

    return InkWell(
      onTap: () {
        _logger.logger.i('Address tapped: ${address.id}', tag: 'Checkout');
        context.read<CheckoutCubit>().selectAddress(address.id);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: AppSpacing.sm),
        padding: EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color:
              isSelected ? AppColors.primary.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: address.id,
              groupValue: selectedId,
              onChanged: (value) {
                if (value != null) {
                  context.read<CheckoutCubit>().selectAddress(value);
                }
              },
              activeColor: AppColors.primary,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address.street,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${address.city}, ${address.state} ${address.zipCode}',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionsSection(CheckoutActive state) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Special Instructions (Optional)',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppSpacing.md),
            TextField(
              onChanged: (value) {
                _logger.logger.d('Instructions: $value', tag: 'Checkout');
                context.read<CheckoutCubit>().updateInstructions(value);
              },
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Any special delivery instructions...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.borderRadiusMd,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Method',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppSpacing.md),
            _buildPaymentOption(
              title: 'UPI Payment',
              subtitle: 'Pay using any UPI app',
              icon: Icons.account_balance,
              value: PaymentMethod.upi,
            ),
            _buildPaymentOption(
              title: 'Credit Card',
              subtitle: 'Pay using credit card',
              icon: Icons.credit_card,
              value: PaymentMethod.creditCard,
            ),
            _buildPaymentOption(
              title: 'Debit Card',
              subtitle: 'Pay using debit card',
              icon: Icons.credit_card,
              value: PaymentMethod.debitCard,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required PaymentMethod value,
  }) {
    final isSelected = _selectedPaymentMethod == value;

    return InkWell(
      onTap: () {
        _logger.logger.i('Payment method selected: $value', tag: 'Checkout');
        setState(() => _selectedPaymentMethod = value);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: AppSpacing.sm),
        padding: EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color:
              isSelected ? AppColors.primary.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? AppColors.primary.withOpacity(0.1)
                        : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primary : Colors.grey.shade700,
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Radio<PaymentMethod>(
              value: value,
              groupValue: _selectedPaymentMethod,
              onChanged: (newValue) {
                if (newValue != null) {
                  setState(() => _selectedPaymentMethod = newValue);
                }
              },
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingSummary(CheckoutActive state) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pricing Summary',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppSpacing.md),
            _buildPriceRow('Base Price', '₹${state.basePrice.toInt()}'),
            _buildPriceRow('Number of Persons', '× ${state.noOfPersons}'),
            const Divider(),
            _buildPriceRow(
              'Total Amount',
              '₹${state.totalAmount.toInt()}',
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: FontWeight.bold,
              color: isTotal ? AppColors.primary : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Card(
          margin: EdgeInsets.all(AppSpacing.lg),
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                SizedBox(height: AppSpacing.md),
                const Text('Processing Payment...'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActions(CheckoutActive state) {
    final canProceed = state.canSubmit && !_isProcessingPayment;

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!canProceed)
            Text(
              state.missingFields.isEmpty
                  ? 'Processing...'
                  : 'Please select: ${state.missingFields.join(", ")}',
              style: TextStyle(
                color:
                    state.missingFields.isEmpty
                        ? AppColors.primary
                        : Colors.red,
                fontSize: 12,
              ),
            ),
          SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed:
                      _isProcessingPayment
                          ? null
                          : () {
                            _logger.logger.i(
                              'Back button pressed',
                              tag: 'Checkout',
                            );
                            Navigator.pop(context);
                          },
                  child: const Text('Back'),
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: PrimaryButton(
                  text: 'Confirm & Pay',
                  onPressed:
                      canProceed
                          ? () {
                            _logger.logger.i(
                              'Confirm & Pay pressed',
                              tag: 'Checkout',
                            );
                            context.read<CheckoutCubit>().createSubscription();
                          }
                          : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showPaymentSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Payment Successful!'),
            content: const Text('Your subscription has been activated.'),
            actions: [
              PrimaryButton(
                text: 'Go to Home',
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    AppRouter.mainRoute,
                    (route) => false,
                  );
                },
              ),
            ],
          ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  void _showErrorAndGoBack(String message) {
    _showErrorSnackBar(message);
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) Navigator.pop(context);
    });
  }
}
