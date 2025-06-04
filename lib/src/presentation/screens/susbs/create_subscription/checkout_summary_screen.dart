// lib/src/presentation/screens/checkout/checkout_summary_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/route/app_router.dart';
import 'package:foodam/core/widgets/primary_button.dart';
import 'package:foodam/core/widgets/secondary_button.dart';
import 'package:foodam/src/domain/entities/address_entity.dart';
import 'package:foodam/src/domain/entities/payment_entity.dart';
import 'package:foodam/src/presentation/cubits/checkout/checkout_cubit.dart';
import 'package:foodam/src/presentation/cubits/checkout/checkout_state.dart';
import 'package:foodam/src/presentation/cubits/payment/razor_pay_cubit/razor_pay_cubit/razor_pay_cubit_cubit.dart';
import 'package:foodam/src/presentation/cubits/payment/razor_pay_cubit/razor_pay_cubit/razor_pay_cubit_state.dart';
// FIXED: Import DishSelection with specific import path and alias
import 'package:foodam/src/presentation/cubits/subscription/week_selection/week_selection_state.dart'
    as WeekSelection;
import 'package:intl/intl.dart';

class CheckoutSummaryScreen extends StatefulWidget {
  const CheckoutSummaryScreen({super.key});

  @override
  State<CheckoutSummaryScreen> createState() => _CheckoutSummaryScreenState();
}

class _CheckoutSummaryScreenState extends State<CheckoutSummaryScreen> {
  PaymentMethod _selectedPaymentMethod = PaymentMethod.upi;
  bool _isProcessingPayment = false;
  bool _showAllAddresses = false;
  static const int _maxVisibleAddresses = 3;

  @override
  void initState() {
    super.initState();
    // Load addresses when screen initializes
    context.read<CheckoutCubit>().refreshAddresses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: BlocConsumer<CheckoutCubit, CheckoutState>(
        listener: _handleCheckoutStateChanges,
        builder: _buildContent,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Review & Checkout',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      backgroundColor: AppColors.primary,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => _handleBackNavigation(),
      ),
    );
  }

  void _handleCheckoutStateChanges(BuildContext context, CheckoutState state) {
    if (state is CheckoutSubscriptionCreated) {
      // 🔥 PRESERVED: Trigger payment exactly like old checkout
      _triggerPayment(state.subscription.id);
    } else if (state is CheckoutError) {
      _showErrorSnackBar(state.message);
    }
  }

  void _triggerPayment(String subscriptionId) {
    setState(() => _isProcessingPayment = true);

    context.read<RazorpayPaymentCubit>().processPaymentForSubscription(
      subscriptionId,
      _selectedPaymentMethod,
    );
  }

  Widget _buildContent(BuildContext context, CheckoutState state) {
    // Handle loading states
    if (state is CheckoutLoading) {
      return _buildLoadingScreen(state.message);
    }

    // Handle error states
    if (state is CheckoutError) {
      return _buildErrorScreen(state);
    }

    // Handle main checkout states
    if (state is CheckoutActive) {
      return _buildCheckoutContent(state);
    }

    if (state is CheckoutSubscriptionCreated) {
      return _buildProcessingPayment(state);
    }

    // Handle initial state
    return _buildInitialScreen();
  }

  Widget _buildLoadingScreen(String? message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: AppDimensions.marginMedium),
          Text(
            message ?? 'Loading checkout...',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorScreen(CheckoutError state) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.marginMedium),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: AppColors.error),
            SizedBox(height: AppDimensions.marginMedium),
            Text(
              'Checkout Error',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.error,
              ),
            ),
            SizedBox(height: AppDimensions.marginSmall),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            SizedBox(height: AppDimensions.marginLarge),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SecondaryButton(
                  text: 'Back to Selection',
                  onPressed: _handleBackNavigation,
                ),
                SizedBox(width: AppDimensions.marginMedium),
                if (state.canRetry)
                  PrimaryButton(
                    text: 'Retry',
                    onPressed:
                        () =>
                            context
                                .read<CheckoutCubit>()
                                .retryCreateSubscription(),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: AppDimensions.marginMedium),
          const Text(
            'Preparing checkout...',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingPayment(CheckoutSubscriptionCreated state) {
    return BlocListener<RazorpayPaymentCubit, RazorpayPaymentState>(
      listener: _handlePaymentStateChanges,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: AppDimensions.marginMedium),
            const Text(
              'Processing payment...',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppDimensions.marginSmall),
            Text(
              'Total: ₹${state.totalAmount.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handlePaymentStateChanges(
    BuildContext context,
    RazorpayPaymentState state,
  ) {
    if (state is RazorpayPaymentSuccessWithId) {
      setState(() => _isProcessingPayment = false);
      _showPaymentSuccessDialog();
    } else if (state is RazorpayPaymentError) {
      setState(() => _isProcessingPayment = false);
      _showErrorSnackBar('Payment failed. Please try again.');
      // Navigate to home after delay
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(AppRouter.mainRoute, (route) => false);
      });
    }
  }

  Widget _buildCheckoutContent(CheckoutActive state) {
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppDimensions.marginMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Success header
                    _buildSuccessHeader(),
                    SizedBox(height: AppDimensions.marginMedium),

                    // Subscription overview
                    _buildSubscriptionOverview(state),
                    SizedBox(height: AppDimensions.marginMedium),

                    // Weekly selections summary
                    _buildWeeklySelections(state),
                    SizedBox(height: AppDimensions.marginMedium),

                    // Person count section
                    _buildPersonCountSection(state),
                    SizedBox(height: AppDimensions.marginMedium),

                    // Address selection
                    _buildAddressSelectionSection(state),
                    SizedBox(height: AppDimensions.marginMedium),

                    // Delivery instructions
                    _buildDeliveryInstructionsSection(state),
                    SizedBox(height: AppDimensions.marginMedium),

                    // Payment method
                    _buildPaymentMethodSection(),
                    SizedBox(height: AppDimensions.marginMedium),

                    // Price breakdown
                    _buildPriceBreakdown(state),

                    // Bottom padding for floating button
                    SizedBox(height: AppDimensions.marginLarge * 3),
                  ],
                ),
              ),
            ),
          ],
        ),

        // Loading overlay during submission
        if (state.isSubmitting || _isProcessingPayment) _buildLoadingOverlay(),

        // Fixed bottom action bar
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _buildBottomActionBar(state),
        ),
      ],
    );
  }

  Widget _buildSuccessHeader() {
    return Card(
      elevation: 0,
      color: AppColors.success.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.marginMedium),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 28,
              ),
            ),
            SizedBox(width: AppDimensions.marginMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Planning Complete!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Review your order and complete checkout',
                    style: TextStyle(
                      color: AppColors.success.withOpacity(0.8),
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

  Widget _buildSubscriptionOverview(CheckoutActive state) {
    final endDate = state.weekData.endDate;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.marginMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Subscription Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppDimensions.marginMedium),

            _buildOverviewRow(
              'Start Date',
              DateFormat('MMMM d, yyyy').format(state.weekData.startDate),
              Icons.calendar_today,
            ),
            _buildOverviewRow(
              'Duration',
              '${state.weekData.totalDuration} week${state.weekData.totalDuration > 1 ? 's' : ''}',
              Icons.schedule,
            ),
            _buildOverviewRow(
              'Dietary Preference',
              _capitalize(state.weekData.defaultDietaryPreference),
              Icons.restaurant_menu,
            ),
            _buildOverviewRow(
              'Total Meals',
              '${state.weekData.totalMeals} meals',
              Icons.food_bank,
            ),
            _buildOverviewRow(
              'End Date',
              DateFormat('MMMM d, yyyy').format(endDate),
              Icons.event,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklySelections(CheckoutActive state) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.marginMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly Meal Selections',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppDimensions.marginMedium),

            ...state.weekData.groupedSelections.entries.map((entry) {
              final week = entry.key;
              final selections = entry.value;
              final weekConfig = state.weekData.weekConfigs[week];

              return _buildWeekAccordion(
                week: week,
                selections: selections,
                weekConfig: weekConfig, // FIXED: Now using CheckoutWeekConfig?
                startDate: state.weekData.startDate,
              );
            }),
          ],
        ),
      ),
    );
  }

  // FIXED: Updated method parameter to use CheckoutWeekConfig?
  Widget _buildWeekAccordion({
    required int week,
    required List<WeekSelection.DishSelection> selections,
    required CheckoutWeekConfig?
    weekConfig, // FIXED: Changed from WeekConfig? to CheckoutWeekConfig?
    required DateTime startDate,
  }) {
    final weekStartDate = startDate.add(Duration(days: (week - 1) * 7));
    final weekEndDate = weekStartDate.add(const Duration(days: 6));

    return Container(
      margin: EdgeInsets.only(bottom: AppDimensions.marginMedium),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(
          horizontal: AppDimensions.marginSmall,
        ),
        childrenPadding: EdgeInsets.symmetric(
          horizontal: AppDimensions.marginMedium,
          vertical: AppDimensions.marginSmall,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '$week',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            SizedBox(width: AppDimensions.marginSmall),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Week $week',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${DateFormat('MMM d').format(weekStartDate)} - ${DateFormat('MMM d').format(weekEndDate)}',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        subtitle: Text(
          '${selections.length} meals selected • ${weekConfig?.dietaryPreference ?? 'Mixed'}',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        children: [
          if (selections.isEmpty)
            Padding(
              padding: EdgeInsets.all(AppDimensions.marginMedium),
              child: Text(
                'No meals selected for this week',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            ...selections.map((selection) => _buildSelectionItem(selection)),
        ],
      ),
    );
  }

  Widget _buildSelectionItem(WeekSelection.DishSelection selection) {
    return Container(
      margin: EdgeInsets.only(bottom: AppDimensions.marginSmall),
      padding: EdgeInsets.all(AppDimensions.marginSmall),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            _getMealIcon(selection.timing),
            size: 16,
            color: _getMealColor(selection.timing),
          ),
          SizedBox(width: AppDimensions.marginSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selection.dishName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${_capitalize(selection.day)} • ${_capitalize(selection.timing)}',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonCountSection(CheckoutActive state) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.marginMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Number of Persons',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppDimensions.marginSmall),
            Text(
              'How many people will this subscription serve?',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            SizedBox(height: AppDimensions.marginMedium),

            Row(
              children: [
                IconButton(
                  onPressed:
                      state.noOfPersons > 1
                          ? () => context
                              .read<CheckoutCubit>()
                              .updateNoOfPersons(state.noOfPersons - 1)
                          : null,
                  icon: Icon(
                    Icons.remove_circle,
                    color:
                        state.noOfPersons > 1 ? AppColors.primary : Colors.grey,
                  ),
                ),
                SizedBox(width: AppDimensions.marginSmall),
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
                SizedBox(width: AppDimensions.marginSmall),
                IconButton(
                  onPressed:
                      state.noOfPersons < 10
                          ? () => context
                              .read<CheckoutCubit>()
                              .updateNoOfPersons(state.noOfPersons + 1)
                          : null,
                  icon: Icon(
                    Icons.add_circle,
                    color:
                        state.noOfPersons < 10
                            ? AppColors.primary
                            : Colors.grey,
                  ),
                ),
                const Spacer(),
                Text(
                  state.noOfPersons == 1 ? 'Person' : 'Persons',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressSelectionSection(CheckoutActive state) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.marginMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Delivery Address',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed:
                      () => context.read<CheckoutCubit>().refreshAddresses(),
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Refresh'),
                ),
              ],
            ),
            SizedBox(height: AppDimensions.marginMedium),

            if (state.addresses == null)
              const Center(child: CircularProgressIndicator())
            else if (state.addresses!.isEmpty)
              _buildNoAddressesWidget()
            else
              _buildSmartAddressList(state.addresses!, state.selectedAddressId),
          ],
        ),
      ),
    );
  }

  Widget _buildSmartAddressList(
    List<Address> addresses,
    String? selectedAddressId,
  ) {
    final hasMoreAddresses = addresses.length > _maxVisibleAddresses;
    final displayedAddresses =
        _showAllAddresses
            ? addresses
            : addresses.take(_maxVisibleAddresses).toList();

    return Column(
      children: [
        // Display limited/all addresses with unique keys
        ...displayedAddresses.asMap().entries.map((entry) {
          final index = entry.key;
          final address = entry.value;
          return _buildAddressItem(
            address,
            selectedAddressId,
            key: ValueKey(
              'address_${address.id}_$index',
            ), // Unique key per address
          );
        }),

        // Show more/less button
        if (hasMoreAddresses) ...[
          SizedBox(height: AppDimensions.marginSmall),
          _buildShowMoreButton(addresses.length),
        ],

        // Add new address button
        SizedBox(height: AppDimensions.marginMedium),
        _buildAddNewAddressButton(),
      ],
    );
  }

  Widget _buildShowMoreButton(int totalCount) {
    final hiddenCount = totalCount - _maxVisibleAddresses;

    return InkWell(
      onTap: () => setState(() => _showAllAddresses = !_showAllAddresses),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: AppDimensions.marginSmall,
          horizontal: AppDimensions.marginMedium,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _showAllAddresses ? Icons.expand_less : Icons.expand_more,
              color: AppColors.primary,
              size: 20,
            ),
            SizedBox(width: AppDimensions.marginSmall),
            Text(
              _showAllAddresses ? 'Show Less' : '+ $hiddenCount more addresses',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressItem(
    Address address,
    String? selectedAddressId, {
    required Key key,
  }) {
    final isSelected = selectedAddressId == address.id;

    return Container(
      key: key, // 🔥 CRITICAL: Unique key prevents selection bugs
      margin: EdgeInsets.only(bottom: AppDimensions.marginSmall),
      child: InkWell(
        onTap: () => context.read<CheckoutCubit>().selectAddress(address.id),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(AppDimensions.marginSmall),
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
                key: ValueKey('radio_${address.id}'), // Unique radio key
                value: address.id,
                groupValue: selectedAddressId,
                onChanged: (value) {
                  if (value != null) {
                    context.read<CheckoutCubit>().selectAddress(value);
                  }
                },
                activeColor: AppColors.primary,
              ),
              SizedBox(width: AppDimensions.marginSmall),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      address.street,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${address.city}, ${address.state} ${address.zipCode}',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
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
      ),
    );
  }

  Widget _buildAddNewAddressButton() {
    return InkWell(
      onTap: () => _navigateToAddAddress(), // 🔥 Use custom navigation method
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: AppDimensions.marginSmall),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: AppColors.primary, size: 20),
            SizedBox(width: AppDimensions.marginSmall),
            Text(
              'Add New Address',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 NEW: Handle navigation result and auto-refresh
  Future<void> _navigateToAddAddress() async {
    await Navigator.pushNamed(context, AppRouter.addAddressRoute);

    // If address was added successfully, refresh the list
    if (mounted) {
      context.read<CheckoutCubit>().refreshAddresses();
    }
  }

  Widget _buildNoAddressesWidget() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(AppDimensions.marginLarge),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                Icons.location_off,
                size: 48,
                color: AppColors.textSecondary,
              ),
              SizedBox(height: AppDimensions.marginMedium),
              const Text(
                'No addresses found',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: AppDimensions.marginSmall),
              Text(
                'Please add a delivery address to continue',
                style: TextStyle(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppDimensions.marginMedium),
              ElevatedButton.icon(
                onPressed:
                    () =>
                        Navigator.pushNamed(context, AppRouter.addAddressRoute),
                icon: const Icon(Icons.add),
                label: const Text('Add Address'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryInstructionsSection(CheckoutActive state) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.marginMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Delivery Instructions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppDimensions.marginSmall),
            Text(
              'Add any special instructions for delivery (optional)',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            SizedBox(height: AppDimensions.marginMedium),
            TextFormField(
              initialValue: state.instructions,
              onChanged:
                  (value) =>
                      context.read<CheckoutCubit>().updateInstructions(value),
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'e.g., Ring the bell, call when at gate, etc.',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.marginMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppDimensions.marginMedium),

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
      onTap: () => setState(() => _selectedPaymentMethod = value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: EdgeInsets.only(bottom: AppDimensions.marginSmall),
        padding: EdgeInsets.all(AppDimensions.marginSmall),
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
            SizedBox(width: AppDimensions.marginSmall),
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

  Widget _buildPriceBreakdown(CheckoutActive state) {
    final weekPricing = state.pricing.weekPricing;
    final subtotal = state.pricing.totalPrice;
    final total = state.totalAmount;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.marginMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Price Breakdown',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppDimensions.marginMedium),

            // Week-wise pricing
            ...weekPricing.entries.map((entry) {
              final week = entry.key;
              final price = entry.value;
              final details = state.pricing.getWeekDetails(week);

              return _buildPriceRow(
                'Week $week (${details?.mealCount ?? 0} meals)',
                '₹${price.toStringAsFixed(0)}',
              );
            }),

            if (weekPricing.length > 1) ...[
              const Divider(height: 24),
              _buildPriceRow('Subtotal', '₹${subtotal.toStringAsFixed(0)}'),
            ],

            if (state.noOfPersons > 1) ...[
              _buildCalculationRow('× Persons', '${state.noOfPersons}'),
              const Divider(height: 24),
            ],

            _buildPriceRow(
              'Total Amount',
              '₹${total.toStringAsFixed(0)}',
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Processing your order...',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActionBar(CheckoutActive state) {
    final canProceed = state.canSubmit && !_isProcessingPayment;
    final total = state.totalAmount;

    return Container(
      padding: EdgeInsets.all(AppDimensions.marginMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: SecondaryButton(
                text: 'Back',
                icon: Icons.arrow_back,
                onPressed: _handleBackNavigation,
              ),
            ),
            SizedBox(width: AppDimensions.marginMedium),
            Expanded(
              flex: 2,
              child: PrimaryButton(
                text: 'Pay ₹${total.toStringAsFixed(0)}',
                icon: Icons.payment,
                onPressed: canProceed ? _handlePlaceOrder : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widgets and methods
  Widget _buildOverviewRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppDimensions.marginSmall),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          SizedBox(width: AppDimensions.marginSmall),
          Text(
            label,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String amount, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppDimensions.marginSmall),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? null : AppColors.textSecondary,
            ),
          ),
          Text(
            amount,
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

  Widget _buildCalculationRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppDimensions.marginSmall),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.close, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // Helper methods
  IconData _getMealIcon(String timing) {
    switch (timing.toLowerCase()) {
      case 'breakfast':
        return Icons.free_breakfast;
      case 'lunch':
        return Icons.lunch_dining;
      case 'dinner':
        return Icons.dinner_dining;
      default:
        return Icons.restaurant;
    }
  }

  Color _getMealColor(String timing) {
    switch (timing.toLowerCase()) {
      case 'breakfast':
        return Colors.orange;
      case 'lunch':
        return AppColors.accent;
      case 'dinner':
        return Colors.purple;
      default:
        return AppColors.primary;
    }
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  // Event handlers
  void _handleBackNavigation() {
    // Reset checkout and go back to week selection
    context.read<CheckoutCubit>().returnToWeekSelection();
    Navigator.pop(context);
  }

  void _handlePlaceOrder() {
    print('🔍 DEBUG: _handlePlaceOrder called');

    final state = context.read<CheckoutCubit>().state;
    print('🔍 DEBUG: Current state type: ${state.runtimeType}');

    if (state is! CheckoutActive) {
      print('❌ DEBUG: State is not CheckoutActive!');
      _showErrorSnackBar('Invalid checkout state');
      return;
    }

    print('🔍 DEBUG: CheckoutActive state - canSubmit: ${state.canSubmit}');

    if (!state.canSubmit) {
      final missingFields = state.missingFields;
      print('❌ DEBUG: Cannot submit - missing: $missingFields');
      _showErrorSnackBar('Please complete: ${missingFields.join(', ')}');
      return;
    }

    print('✅ DEBUG: All validations passed, showing dialog');

    // Show confirmation dialog
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Order'),
            content: Text(
              'Total amount: ₹${state.totalAmount.toStringAsFixed(0)}\n\nProceed with payment?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  print('🔍 DEBUG: Place Order in dialog pressed');
                  Navigator.pop(context);
                  print('🔍 DEBUG: About to call createSubscription');
                  context.read<CheckoutCubit>().createSubscription();
                  print('🔍 DEBUG: createSubscription called');
                },
                child: const Text('Place Order'),
              ),
            ],
          ),
    );
  }

  void _showErrorSnackBar(String message) {
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

  void _showPaymentSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Payment Successful!'),
            content: const Text(
              'Your subscription has been activated successfully.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    AppRouter.mainRoute,
                    (route) => false,
                  );
                },
                child: const Text('Go to Home'),
              ),
            ],
          ),
    );
  }
}
