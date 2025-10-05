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
import 'package:intl/intl.dart';

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
      tag: 'Summary',
    );
    _initializeCheckout();
  }

  void _initializeCheckout() {
    _logger.logger.i(
      'Initializing checkout from planning data...',
      tag: 'Summary',
    );

    final planningState = context.read<MealPlanningCubit>().state;
    _logger.logger.d(
      'Planning state type: ${planningState.runtimeType}',
      tag: 'Summary',
    );

    if (planningState is! WeekGridLoaded) {
      _logger.logger.e(
        'Invalid planning state - cannot initialize checkout',
        tag: 'Summary',
      );
      _showErrorAndGoBack('Invalid planning data');
      return;
    }

    _logger.logger.i('Planning data validated successfully', tag: 'Summary');
    _logger.logger.d(
      'Total weeks: ${planningState.totalWeeks}',
      tag: 'Summary',
    );
    _logger.logger.d(
      'Total price: ₹${planningState.totalPrice}',
      tag: 'Summary',
    );

    final checkoutWeeks = <int, WeekCheckoutData>{};
    planningState.weekSelections.forEach((weekNum, weekData) {
      _logger.logger.d(
        'Processing week $weekNum: ${weekData.selectedSlotKeys.length} slots',
        tag: 'Summary',
      );

      checkoutWeeks[weekNum] = WeekCheckoutData(
        dietaryPreference: weekData.dietaryPreference,
        slots: weekData.selectedSlotKeys,
      );
    });

    _logger.logger.i(
      'Calling CheckoutCubit.initializeCheckout...',
      tag: 'Summary',
    );

    context.read<CheckoutCubit>().initializeCheckout(
      startDate: planningState.startDate,
      weeks: checkoutWeeks,
      basePrice: planningState.totalPrice,
    );
  }

  @override
  void dispose() {
    _logger.logger.i('Summary screen disposing', tag: 'Summary');
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
        builder: (context, checkoutState) {
          _logger.logger.d(
            'Building UI for checkout state: ${checkoutState.runtimeType}',
            tag: 'Summary',
          );

          if (checkoutState is CheckoutLoading) {
            return _buildLoadingState(checkoutState.message);
          } else if (checkoutState is CheckoutActive) {
            return _buildCheckoutContent(checkoutState);
          } else if (checkoutState is CheckoutSubscriptionCreated) {
            return _buildPaymentProcessing(checkoutState);
          } else if (checkoutState is CheckoutError) {
            return _buildErrorState(checkoutState);
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  void _handleCheckoutState(BuildContext context, CheckoutState state) {
    _logger.logger.i(
      'Checkout state changed: ${state.runtimeType}',
      tag: 'Summary',
    );

    if (state is CheckoutSubscriptionCreated) {
      _logger.logger.i(
        'Subscription created - triggering payment',
        tag: 'Summary',
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
                  _logger.logger.i('Retry button pressed', tag: 'Summary');
                  context.read<CheckoutCubit>().retryCreateSubscription();
                },
              ),
            SizedBox(height: AppSpacing.sm),
            OutlinedButton(
              onPressed: () {
                _logger.logger.i(
                  'Back button pressed from error',
                  tag: 'Summary',
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

  Widget _buildCheckoutContent(CheckoutActive checkoutState) {
    _logger.logger.d('Building checkout content', tag: 'Summary');
    _logger.logger.d('Can submit: ${checkoutState.canSubmit}', tag: 'Summary');

    final planningState = context.read<MealPlanningCubit>().state;

    if (planningState is! WeekGridLoaded) {
      _logger.logger.w(
        'Planning state lost - returning to planning',
        tag: 'Summary',
      );
      return const Center(child: Text('Planning data not available'));
    }

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
                    // SECTION 1: Success Banner
                    _buildSuccessBanner(planningState),
                    SizedBox(height: AppSpacing.lg),

                    // SECTION 2: Subscription Overview
                    _buildSubscriptionOverview(planningState),
                    SizedBox(height: AppSpacing.lg),

                    // SECTION 3: Week-by-Week Breakdown
                    _buildWeekBreakdown(planningState),
                    SizedBox(height: AppSpacing.lg),

                    // SECTION 4: Person Count
                    _buildPersonCountSection(checkoutState),
                    SizedBox(height: AppSpacing.lg),

                    // SECTION 5: Delivery Address
                    _buildAddressSection(checkoutState),
                    SizedBox(height: AppSpacing.lg),

                    // SECTION 6: Special Instructions
                    _buildInstructionsSection(checkoutState),
                    SizedBox(height: AppSpacing.lg),

                    // SECTION 7: Payment Method
                    _buildPaymentMethodSection(),
                    SizedBox(height: AppSpacing.lg),

                    // SECTION 8: Final Pricing Summary
                    _buildFinalPricingSummary(planningState, checkoutState),
                    SizedBox(height: AppSpacing.lg * 3),
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
          child: _buildBottomActions(checkoutState),
        ),
      ],
    );
  }

  // ========== SECTION 1: SUCCESS BANNER ==========
  Widget _buildSuccessBanner(WeekGridLoaded planningState) {
    _logger.logger.d('Building success banner', tag: 'Summary');

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 24),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plan Complete!',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  'You\'ve successfully planned meals for ${planningState.totalWeeks} week${planningState.totalWeeks > 1 ? 's' : ''} starting ${DateFormat('MMM dd, yyyy').format(planningState.startDate)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ========== SECTION 2: SUBSCRIPTION OVERVIEW ==========
  Widget _buildSubscriptionOverview(WeekGridLoaded planningState) {
    _logger.logger.d('Building subscription overview', tag: 'Summary');

    final totalMeals = planningState.weekSelections.values.fold(
      0,
      (sum, week) => sum + week.validation.selectedCount,
    );

    _logger.logger.d('Total meals calculated: $totalMeals', tag: 'Summary');

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Subscription Details',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildOverviewMetric(
                  'Start Date',
                  DateFormat('MMM dd').format(planningState.startDate),
                ),
                _buildOverviewMetric('Weeks', '${planningState.totalWeeks}'),
                _buildOverviewMetric('Meals', '$totalMeals'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewMetric(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
        SizedBox(height: AppSpacing.xs),
        Container(
          height: 2,
          width: 40,
          color: AppColors.primary.withOpacity(0.3),
        ),
        SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  // ========== SECTION 3: WEEK-BY-WEEK BREAKDOWN ==========
  Widget _buildWeekBreakdown(WeekGridLoaded planningState) {
    _logger.logger.d('Building week breakdown', tag: 'Summary');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Meal Plan',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: AppSpacing.md),
        ...planningState.weekSelections.entries.map((entry) {
          final weekNum = entry.key;
          final weekData = entry.value;

          _logger.logger.d(
            'Week $weekNum: ${weekData.validation.selectedCount} meals, ${weekData.dietaryPreference}',
            tag: 'Summary',
          );

          final weekStartDate = planningState.startDate.add(
            Duration(days: (weekNum - 1) * 7),
          );
          final weekEndDate = weekStartDate.add(const Duration(days: 6));

          return Container(
            margin: EdgeInsets.only(bottom: AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppDimensions.borderRadiusMd),
                      topRight: Radius.circular(AppDimensions.borderRadiusMd),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Week $weekNum',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '₹${weekData.weekPrice.toInt()}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    children: [
                      _buildWeekDetailRow(
                        Icons.restaurant_menu,
                        '${weekData.validation.selectedCount} meals',
                      ),
                      SizedBox(height: AppSpacing.sm),
                      _buildWeekDetailRow(
                        Icons.local_dining,
                        weekData.dietaryPreference,
                      ),
                      SizedBox(height: AppSpacing.sm),
                      _buildWeekDetailRow(
                        Icons.calendar_today,
                        '${DateFormat('MMM dd').format(weekStartDate)} - ${DateFormat('MMM dd').format(weekEndDate)}',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildWeekDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        SizedBox(width: AppSpacing.sm),
        Text(
          text,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
        ),
      ],
    );
  }

  // ========== SECTION 4: PERSON COUNT ==========
  Widget _buildPersonCountSection(CheckoutActive checkoutState) {
    _logger.logger.d(
      'Building person count section: ${checkoutState.noOfPersons}',
      tag: 'Summary',
    );

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
            SizedBox(height: AppSpacing.sm),
            Text(
              'This subscription will serve:',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
            SizedBox(height: AppSpacing.md),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed:
                        checkoutState.noOfPersons > 1
                            ? () {
                              _logger.logger.i(
                                'Decreasing person count',
                                tag: 'Summary',
                              );
                              context.read<CheckoutCubit>().updateNoOfPersons(
                                checkoutState.noOfPersons - 1,
                              );
                            }
                            : null,
                    icon: Icon(
                      Icons.remove_circle,
                      size: 40,
                      color:
                          checkoutState.noOfPersons > 1
                              ? AppColors.primary
                              : Colors.grey.shade300,
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    child: Text(
                      '${checkoutState.noOfPersons}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  IconButton(
                    onPressed:
                        checkoutState.noOfPersons < 10
                            ? () {
                              _logger.logger.i(
                                'Increasing person count',
                                tag: 'Summary',
                              );
                              context.read<CheckoutCubit>().updateNoOfPersons(
                                checkoutState.noOfPersons + 1,
                              );
                            }
                            : null,
                    icon: Icon(
                      Icons.add_circle,
                      size: 40,
                      color:
                          checkoutState.noOfPersons < 10
                              ? AppColors.primary
                              : Colors.grey.shade300,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Center(
              child: Text(
                'Price adjusts automatically',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== SECTION 5: DELIVERY ADDRESS ==========
  Widget _buildAddressSection(CheckoutActive checkoutState) {
    _logger.logger.d('Building address section', tag: 'Summary');
    _logger.logger.d(
      'Selected address: ${checkoutState.selectedAddressId ?? "None"}',
      tag: 'Summary',
    );

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
                      tag: 'Summary',
                    );
                    context.read<CheckoutCubit>().refreshAddresses();
                  },
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Refresh'),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            if (checkoutState.isLoadingAddresses)
              const Center(child: CircularProgressIndicator())
            else if (checkoutState.addresses == null ||
                checkoutState.addresses!.isEmpty)
              _buildNoAddresses()
            else
              _buildAddressList(
                checkoutState.addresses!,
                checkoutState.selectedAddressId,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoAddresses() {
    _logger.logger.w('No addresses available', tag: 'Summary');

    return Column(
      children: [
        Icon(Icons.location_off, size: 64, color: AppColors.textSecondary),
        SizedBox(height: AppSpacing.sm),
        Text(
          'No addresses found',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: AppSpacing.md),
        PrimaryButton(
          text: 'Add Your First Address',
          onPressed: () async {
            _logger.logger.i('Navigating to add address', tag: 'Summary');
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
    _logger.logger.d(
      'Building address list: ${addresses.length} addresses',
      tag: 'Summary',
    );

    return Column(
      children: [
        ...addresses.map((address) => _buildAddressItem(address, selectedId)),
        SizedBox(height: AppSpacing.md),
        OutlinedButton.icon(
          onPressed: () async {
            _logger.logger.i('Add new address pressed', tag: 'Summary');
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
        _logger.logger.i('Address tapped: ${address.id}', tag: 'Summary');
        context.read<CheckoutCubit>().selectAddress(address.id);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: EdgeInsets.only(bottom: AppSpacing.sm),
        padding: EdgeInsets.all(AppSpacing.md),
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
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address.street,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${address.city}, ${address.state} ${address.zipCode}',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== SECTION 6: SPECIAL INSTRUCTIONS ==========
  Widget _buildInstructionsSection(CheckoutActive checkoutState) {
    _logger.logger.d('Building instructions section', tag: 'Summary');

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
              'Delivery Instructions (Optional)',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppSpacing.md),
            TextField(
              onChanged: (value) {
                _logger.logger.d(
                  'Instructions updated: ${value.isEmpty ? "(empty)" : value}',
                  tag: 'Summary',
                );
                context.read<CheckoutCubit>().updateInstructions(value);
              },
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Any special instructions...',
                helperText:
                    'Example: "Ring twice", "Leave at door", "Gate code: 1234"',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.borderRadiusMd,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.borderRadiusMd,
                  ),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.borderRadiusMd,
                  ),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== SECTION 7: PAYMENT METHOD ==========
  Widget _buildPaymentMethodSection() {
    _logger.logger.d(
      'Building payment method section: $_selectedPaymentMethod',
      tag: 'Summary',
    );

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
            SizedBox(height: AppSpacing.sm),
            Text(
              'Select your preferred payment method',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
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
        _logger.logger.i('Payment method selected: $value', tag: 'Summary');
        setState(() => _selectedPaymentMethod = value);
      },
      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
      child: Container(
        margin: EdgeInsets.only(bottom: AppSpacing.sm),
        padding: EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color:
              isSelected ? AppColors.primary.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
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
                size: 20,
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
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

  // ========== SECTION 8: FINAL PRICING SUMMARY ==========
  Widget _buildFinalPricingSummary(
    WeekGridLoaded planningState,
    CheckoutActive checkoutState,
  ) {
    _logger.logger.d('Building final pricing summary', tag: 'Summary');

    final totalMeals = planningState.weekSelections.values.fold(
      0,
      (sum, week) => sum + week.validation.selectedCount,
    );

    final avgPricePerMeal =
        totalMeals > 0 ? checkoutState.basePrice / totalMeals : 0.0;

    _logger.logger.d('Total meals: $totalMeals', tag: 'Summary');
    _logger.logger.d(
      'Avg per meal: ₹${avgPricePerMeal.toStringAsFixed(2)}',
      tag: 'Summary',
    );
    _logger.logger.d('Base price: ₹${checkoutState.basePrice}', tag: 'Summary');
    _logger.logger.d('Persons: ${checkoutState.noOfPersons}', tag: 'Summary');
    _logger.logger.d('Total: ₹${checkoutState.totalAmount}', tag: 'Summary');

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
              'Price Summary',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppSpacing.md),

            // Metrics section
            _buildPricingRow('Total Meals', '$totalMeals meals'),
            _buildPricingRow(
              'Avg Price/Meal',
              '₹${avgPricePerMeal.toStringAsFixed(2)}',
            ),
            _buildPricingRow(
              'Duration',
              '${planningState.totalWeeks} week${planningState.totalWeeks > 1 ? 's' : ''}',
            ),

            SizedBox(height: AppSpacing.md),
            Divider(color: Colors.grey.shade300, thickness: 1),
            SizedBox(height: AppSpacing.md),

            // Calculation section
            _buildPricingRow(
              'Subscription Price',
              '₹${checkoutState.basePrice.toInt()}',
            ),
            _buildPricingRow(
              'Number of Persons',
              '× ${checkoutState.noOfPersons}',
            ),

            SizedBox(height: AppSpacing.md),
            Divider(color: Colors.grey.shade300, thickness: 2),
            SizedBox(height: AppSpacing.md),

            // Total section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Amount',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  '₹${checkoutState.totalAmount.toInt()}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              '(Pay via ${_getPaymentMethodName(_selectedPaymentMethod)})',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  String _getPaymentMethodName(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.upi:
        return 'UPI';
      case PaymentMethod.creditCard:
        return 'Credit Card';
      case PaymentMethod.debitCard:
        return 'Debit Card';
      default:
        return 'UPI';
    }
  }

  // ========== PAYMENT OVERLAY ==========
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
                Text(
                  'Processing Payment...',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'Please do not close the app',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ========== STICKY FOOTER: ACTIONS ==========
  Widget _buildBottomActions(CheckoutActive checkoutState) {
    final canProceed = checkoutState.canSubmit && !_isProcessingPayment;

    _logger.logger.d(
      'Bottom actions - Can proceed: $canProceed (submit: ${checkoutState.canSubmit}, processing: $_isProcessingPayment)',
      tag: 'Summary',
    );

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
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!canProceed) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color:
                        checkoutState.missingFields.isEmpty
                            ? AppColors.primary
                            : Colors.red,
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    checkoutState.missingFields.isEmpty
                        ? 'Processing...'
                        : 'Please select: ${checkoutState.missingFields.join(", ")}',
                    style: TextStyle(
                      color:
                          checkoutState.missingFields.isEmpty
                              ? AppColors.primary
                              : Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.sm),
            ],
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: OutlinedButton(
                    onPressed:
                        _isProcessingPayment
                            ? null
                            : () {
                              _logger.logger.i(
                                'Back button pressed',
                                tag: 'Summary',
                              );
                              Navigator.pop(context);
                            },
                    child: const Text('Back to Planning'),
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  flex: 3,
                  child: PrimaryButton(
                    text: 'Confirm & Pay',
                    onPressed:
                        canProceed
                            ? () {
                              _logger.logger.i(
                                '========== CONFIRM & PAY PRESSED ==========',
                                tag: 'Summary',
                              );
                              context
                                  .read<CheckoutCubit>()
                                  .createSubscription();
                            }
                            : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ========== DIALOGS & HELPERS ==========
  void _showPaymentSuccessDialog() {
    _logger.logger.i('Showing payment success dialog', tag: 'Summary');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
            ),
            title: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 24),
                ),
                SizedBox(width: AppSpacing.sm),
                const Text('Payment Successful!'),
              ],
            ),
            content: const Text(
              'Your subscription has been activated successfully.',
            ),
            actions: [
              PrimaryButton(
                text: 'Go to Home',
                onPressed: () {
                  _logger.logger.i('Navigating to home screen', tag: 'Summary');
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
    _logger.logger.w('Showing error: $message', tag: 'Summary');

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorAndGoBack(String message) {
    _showErrorSnackBar(message);
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) Navigator.pop(context);
    });
  }
}
