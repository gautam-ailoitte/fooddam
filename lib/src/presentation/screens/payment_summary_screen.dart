// lib/src/presentation/screens/payment/payment_summary_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/constants/string_constants.dart';
import 'package:foodam/core/layout/app_scaffold.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/widgets/app_button.dart';
import 'package:foodam/core/widgets/app_card.dart';
import 'package:foodam/core/widgets/app_loading.dart';
import 'package:foodam/core/widgets/app_section_header.dart';
import 'package:foodam/core/widgets/app_text_field.dart';
import 'package:foodam/src/domain/entities/dish_entity.dart';
import 'package:foodam/src/domain/entities/payment_entity.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';
import 'package:foodam/src/presentation/cubits/payment/payment_cubit.dart';
import 'package:foodam/src/presentation/cubits/payment/payment_state.dart';
import 'package:foodam/src/presentation/screens/payment_successful_screen.dart';
import 'package:intl/intl.dart';

class PaymentSummaryScreen extends StatefulWidget {
  final Subscription subscription;

  const PaymentSummaryScreen({
    Key? key,
    required this.subscription,
  }) : super(key: key);

  @override
  State<PaymentSummaryScreen> createState() => _PaymentSummaryScreenState();
}

class _PaymentSummaryScreenState extends State<PaymentSummaryScreen> {
  final TextEditingController _couponController = TextEditingController();
  
  // Payment variables
  PaymentMethod _selectedPaymentMethod = PaymentMethod.creditCard;
  Coupon? _appliedCoupon;
  bool _isApplyingCoupon = false;
  bool _processingPayment = false;
  double _discountAmount = 0.0;
  double _finalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _finalAmount = widget.subscription.totalPrice;
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  void _applyCoupon() {
    if (_couponController.text.isEmpty) {
      return;
    }

    setState(() {
      _isApplyingCoupon = true;
    });

    context
        .read<PaymentCubit>()
        .verifyCoupon(_couponController.text, widget.subscription.totalPrice);
  }

  void _processPayment() {
    setState(() {
      _processingPayment = true;
    });

    // In a real app, you'd create an order first, then process payment
    // Here we're simulating a direct subscription payment
    final Map<String, dynamic> paymentDetails = {
      'amount': _finalAmount,
      'currency': 'INR',
      'paymentMethod': _selectedPaymentMethod.toString(),
      'subscriptionId': widget.subscription.id,
    };

    // For simplicity, we're using a mocked orderId
    context.read<PaymentCubit>().processPayment(
          orderId: 'ord-${DateTime.now().millisecondsSinceEpoch}',
          paymentMethod: _selectedPaymentMethod,
          couponCode: _appliedCoupon?.code,
          paymentDetails: paymentDetails,
        );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: StringConstants.orderSummary,
      body: BlocConsumer<PaymentCubit, PaymentState>(
        listener: (context, state) {
          if (state is CouponVerified) {
            setState(() {
              _isApplyingCoupon = false;
              _appliedCoupon = state.coupon;
              
              // Calculate discount
              if (state.coupon.discountType == 'percentage') {
                _discountAmount = (state.coupon.discountValue / 100) * widget.subscription.totalPrice;
                
                // Apply max discount if specified
                if (state.coupon.maxDiscountAmount != null) {
                  _discountAmount = _discountAmount > state.coupon.maxDiscountAmount!
                      ? state.coupon.maxDiscountAmount!
                      : _discountAmount;
                }
              } else {
                // Fixed discount
                _discountAmount = state.coupon.discountValue;
              }
              
              // Calculate final amount
              _finalAmount = widget.subscription.totalPrice - _discountAmount;
              if (_finalAmount < 0) _finalAmount = 0;
            });
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Coupon applied successfully!'),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (state is PaymentError) {
            setState(() {
              _isApplyingCoupon = false;
              _processingPayment = false;
            });
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is PaymentProcessed) {
            // Navigate to success screen
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => PaymentSuccessfulScreen(
                  payment: state.payment,
                  subscription: widget.subscription,
                ),
              ),
              (route) => route.isFirst,
            );
          }
        },
        builder: (context, state) {
          if (state is PaymentLoading || _processingPayment) {
            return const Center(
              child: AppLoading(message: 'Processing payment...'),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Plan details card
              AppSectionHeader(title: StringConstants.planDetailsTitle),
              AppSpacing.vSm,
              _buildPlanDetailsCard(),
              AppSpacing.vLg,
              
              // Coupon code
              AppSectionHeader(title: 'Apply Coupon'),
              AppSpacing.vSm,
              _buildCouponField(),
              AppSpacing.vLg,
              
              // Price details
              AppSectionHeader(title: StringConstants.priceDetails),
              AppSpacing.vSm,
              _buildPriceDetailsCard(),
              AppSpacing.vLg,
              
              // Payment method
              AppSectionHeader(title: StringConstants.paymentMethod),
              AppSpacing.vSm,
              _buildPaymentMethodSelector(),
              AppSpacing.vLg,
              
              // Complete order button
              AppButton(
                label: StringConstants.completeOrder,
                onPressed: _processPayment,
                buttonType: AppButtonType.primary,
                buttonSize: AppButtonSize.large,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPlanDetailsCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getPlanName(),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${StringConstants.duration}: ${widget.subscription.durationInDays} days',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Text(
                '₹${widget.subscription.basePrice.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          
          // Date range
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16),
              const SizedBox(width: 8),
              Text(
                '${_formatDate(widget.subscription.startDate)} to ${_formatDate(widget.subscription.endDate)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Meal preferences summary
          ...widget.subscription.mealPreferences.map((pref) {
            final mealType = pref.mealType.substring(0, 1).toUpperCase() + pref.mealType.substring(1);
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.restaurant, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$mealType: ${pref.preferences.map((p) => p.toString().split('.').last).join(', ')} (Qty: ${pref.quantity})',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          
          if (widget.subscription.isCustomized) ...[
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Customization charges',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Additional items',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                Text(
                  '₹${(widget.subscription.totalPrice - widget.subscription.basePrice).toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCouponField() {
    return Row(
      children: [
        Expanded(
          child: AppTextField(
            controller: _couponController,
            label: 'Coupon Code',
            prefix: const Icon(Icons.local_offer),
            // enabled: !_isApplyingCoupon && _appliedCoupon == null,
          ),
        ),
        const SizedBox(width: 16),
        _appliedCoupon != null
            ? TextButton.icon(
                onPressed: () {
                  setState(() {
                    _appliedCoupon = null;
                    _discountAmount = 0;
                    _finalAmount = widget.subscription.totalPrice;
                    _couponController.clear();
                  });
                },
                icon: const Icon(Icons.close),
                label: const Text('Remove'),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
              )
            : AppButton(
                label: 'Apply',
                onPressed: _applyCoupon,
                isLoading: _isApplyingCoupon,
                isFullWidth: false,
                buttonType: AppButtonType.outline,
                buttonSize: AppButtonSize.small,
              ),
      ],
    );
  }

  Widget _buildPriceDetailsCard() {
    return AppCard(
      child: Column(
        children: [
          // Base price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Plan Price',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                '₹${widget.subscription.totalPrice.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          
          // Discount (if applied)
          if (_appliedCoupon != null) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Discount (${_appliedCoupon!.code})',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.success,
                      ),
                ),
                Text(
                  '-₹${_discountAmount.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.success,
                      ),
                ),
              ],
            ),
          ],
          
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          
          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                StringConstants.total,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                '₹${_finalAmount.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSelector() {
    return Column(
      children: [
        _buildPaymentMethodTile(
          PaymentMethod.creditCard,
          'Credit Card',
          Icons.credit_card,
        ),
        _buildPaymentMethodTile(
          PaymentMethod.debitCard,
          'Debit Card',
          Icons.credit_card,
        ),
        _buildPaymentMethodTile(
          PaymentMethod.paypal,
          'PayPal',
          Icons.account_balance_wallet,
        ),
        _buildPaymentMethodTile(
          PaymentMethod.bankTransfer,
          'UPI / Bank Transfer',
          Icons.account_balance,
        ),
      ],
    );
  }

  Widget _buildPaymentMethodTile(
    PaymentMethod method,
    String title,
    IconData icon,
  ) {
    final isSelected = _selectedPaymentMethod == method;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = method;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }

  String _getPlanName() {
    // This is a simplified implementation
    // In a real app, you'd have more information on the subscription
    bool hasVegetarianMeals = widget.subscription.mealPreferences.any(
      (pref) => pref.preferences.contains(DietaryPreference.vegetarian),
    );
    
    bool hasNonVegetarianMeals = widget.subscription.mealPreferences.any(
      (pref) => pref.preferences.contains(DietaryPreference.nonVegetarian),
    );
    
    if (hasVegetarianMeals && !hasNonVegetarianMeals) {
      return StringConstants.vegetarianPlan;
    } else if (hasNonVegetarianMeals) {
      return StringConstants.nonVegetarianPlan;
    } else {
      return 'Custom Plan';
    }
  }

  String _formatDate(DateTime date) {
    final formatter = DateFormat('dd MMM yyyy');
    return formatter.format(date);
  }
}