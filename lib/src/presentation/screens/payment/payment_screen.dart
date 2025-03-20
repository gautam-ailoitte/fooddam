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
import 'package:foodam/src/domain/entities/address_entity.dart';
import 'package:foodam/src/domain/entities/payment_entity.dart';
import 'package:foodam/src/domain/entities/subscription_plan_entity.dart';
import 'package:foodam/src/presentation/cubits/meal_plan/meal_plan_cubit.dart';
import 'package:foodam/src/presentation/cubits/meal_plan/meal_plan_state.dart';
import 'package:foodam/src/presentation/cubits/payment/payament_cubit.dart';
import 'package:foodam/src/presentation/cubits/payment/payament_state.dart';
import 'package:foodam/src/presentation/cubits/user_profile/user_profile_cubit.dart';
import 'package:foodam/src/presentation/cubits/user_profile/user_profile_state.dart';
import 'package:foodam/src/presentation/utlis/date_formatter.dart';
import 'package:foodam/src/presentation/utlis/price_calculator.dart';

class PaymentSummaryScreen extends StatefulWidget {
  const PaymentSummaryScreen({super.key});

  @override
  State<PaymentSummaryScreen> createState() => _PaymentSummaryScreenState();
}

class _PaymentSummaryScreenState extends State<PaymentSummaryScreen> {
  final DateFormatter _dateFormatter = DateFormatter();
  final PriceCalculator _priceCalculator = PriceCalculator();
  PaymentMethod _selectedPaymentMethod = PaymentMethod.creditCard;
  double _customizationCharges = 0.0; // This would be calculated based on customizations
  double _discount = 0.0; // This could be applied based on promotions or coupons

  @override
  void initState() {
    super.initState();
    // Load user profile if not already loaded
    final userProfileState = context.read<UserProfileCubit>().state;
    if (userProfileState is! UserProfileLoaded) {
      context.read<UserProfileCubit>().getUserProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: StringConstants.orderSummary,
      body: BlocListener<PaymentCubit, PaymentState>(
        listener: (context, state) {
          if (state is PaymentSuccess) {
            _showPaymentSuccessDialog(context);
          } else if (state is PaymentFailed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: BlocBuilder<MealPlanSelectionCubit, MealPlanSelectionState>(
          builder: (context, planState) {
            if (planState is MealPlanCompleted) {
              return BlocBuilder<PaymentCubit, PaymentState>(
                builder: (context, paymentState) {
                  if (paymentState is PaymentProcessing) {
                    return const Center(
                      child: AppLoading(message: 'Processing your payment...'),
                    );
                  }
                  
                  return BlocBuilder<UserProfileCubit, UserProfileState>(
                    builder: (context, userState) {
                      return SingleChildScrollView(
                        padding: AppSpacing.pagePadding,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Plan details section
                            _buildPlanDetailsSection(planState),
                            
                            AppSpacing.vLg,
                            
                            // Price details section
                            _buildPriceDetailsSection(planState),
                            
                            AppSpacing.vLg,
                            
                            // Daily breakdown (collapsible)
                            _buildDailyBreakdownSection(planState),
                            
                            AppSpacing.vLg,
                            
                            // Delivery address
                            _buildDeliveryAddressSection(userState),
                            
                            AppSpacing.vLg,
                            
                            // Payment method selection
                            _buildPaymentMethodSection(),
                            
                            AppSpacing.vXl,
                            
                            // Complete order button
                            _buildCompleteOrderButton(planState, userState),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            }
            
            // If state is not the expected one, show error
            return Center(
              child: Text(
                'Error: Please complete your plan selection first',
                style: TextStyle(color: AppColors.error),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPlanDetailsSection(MealPlanCompleted planState) {
    final mealPlanSelection = planState.mealPlanSelection;
       // Get total meals from plan
  final totalPlanMeals = mealPlanSelection.totalMeals;
  
  // Count actually distributed meals
  int actualSelectedMeals = 0;
  mealPlanSelection.mealDistribution.forEach((_, distributions) {
    actualSelectedMeals += distributions.length;
  });
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            StringConstants.planDetailsTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSpacing.vMd,
          
          _buildInfoRow(
            StringConstants.planName,
            mealPlanSelection.planType,
          ),
          _buildInfoRow(
            StringConstants.duration,
            mealPlanSelection.duration,
          ),
          _buildInfoRow(
            StringConstants.startDate,
            _dateFormatter.formatDate(mealPlanSelection.startDate),
          ),
          _buildInfoRow(
            StringConstants.endDate,
            _dateFormatter.formatDate(mealPlanSelection.endDate),
          ),
          _buildInfoRow(
            StringConstants.meals,
            actualSelectedMeals.toString()+r'/'+'$totalPlanMeals meals',
          ),
        ],
      ),
    );
  }

  Widget _buildPriceDetailsSection(MealPlanCompleted planState) {
    final mealPlanSelection = planState.mealPlanSelection;
    
 
    // Base price calculation - in a real app, this would come from backend
    final basePrice = mealPlanSelection.totalMeals * 120.0; // Assuming average meal price
    final totalPrice = _priceCalculator.calculateTotalPrice(
      basePrice,
      _customizationCharges,
      _discount,
    );
    
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            StringConstants.priceDetails,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSpacing.vMd,
          
          _buildPriceRow(
            StringConstants.basePrice,
            _priceCalculator.formatPrice(basePrice),
          ),
          
          if (_customizationCharges > 0) ...[
            _buildPriceRow(
              StringConstants.customizationCharges,
              _priceCalculator.formatPrice(_customizationCharges),
            ),
          ],
          
          if (_discount > 0) ...[
            _buildPriceRow(
              StringConstants.discount,
              '- ${_priceCalculator.formatPrice(_discount)}',
              isDiscount: true,
            ),
          ],
          
          Divider(color: AppColors.divider),
          
          _buildPriceRow(
            StringConstants.total,
            _priceCalculator.formatPrice(totalPrice),
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDailyBreakdownSection(MealPlanCompleted planState) {
    final mealDistribution = planState.mealPlanSelection.mealDistribution;
    
    return ExpansionTile(
      title: Text(
        StringConstants.dailyBreakdown,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: _buildDailyBreakdownList(mealDistribution),
    );
  }

  List<Widget> _buildDailyBreakdownList(Map<String, List<dynamic>> mealDistribution) {
    final List<Widget> items = [];
    
    // Group by date
    final Map<String, Map<String, int>> dateCount = {};
    
    mealDistribution.forEach((mealType, distributions) {
      for (final dist in distributions) {
        final date = _dateFormatter.formatShortDate(dist.date);
        
        if (!dateCount.containsKey(date)) {
          dateCount[date] = {'Breakfast': 0, 'Lunch': 0, 'Dinner': 0};
        }
        
        dateCount[date]![mealType] = (dateCount[date]![mealType] ?? 0) + 1;
      }
    });
    
    // Sort dates
    final dateKeys = dateCount.keys.toList()..sort();
    
    for (final date in dateKeys) {
      final counts = dateCount[date]!;
      
      items.add(
        Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                
                if (counts['Breakfast']! > 0) ...[
                  Row(
                    children: [
                      Icon(Icons.breakfast_dining, size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Breakfast',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const Spacer(),
                      Text(
                        '${counts['Breakfast']} ${counts['Breakfast']! > 1 ? 'meals' : 'meal'}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
                
                if (counts['Lunch']! > 0) ...[
                  Row(
                    children: [
                      Icon(Icons.lunch_dining, size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Lunch',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const Spacer(),
                      Text(
                        '${counts['Lunch']} ${counts['Lunch']! > 1 ? 'meals' : 'meal'}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
                
                if (counts['Dinner']! > 0) ...[
                  Row(
                    children: [
                      Icon(Icons.dinner_dining, size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Dinner',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const Spacer(),
                      Text(
                        '${counts['Dinner']} ${counts['Dinner']! > 1 ? 'meals' : 'meal'}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }
    
    return items;
  }

  Widget _buildDeliveryAddressSection(UserProfileState userState) {
    if (userState is UserProfileLoaded) {
      final user = userState.user;
      final address = user.address;
      
      return AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Delivery Address',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // Navigate to address selection/edit screen
                  },
                  child: Text('Change'),
                ),
              ],
            ),
            AppSpacing.vSm,
            
            Text(
              user.fullName,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              address.street,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              '${address.city}, ${address.state} ${address.zipCode}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Phone: ${user.phone}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    } else if (userState is UserProfileLoading) {
      return const AppCard(
        child: Center(
          child: AppLoading(message: 'Loading address...'),
        ),
      );
    } else {
      return AppCard(
        child: TextButton(
          onPressed: () {
            context.read<UserProfileCubit>().getUserProfile();
          },
          child: Text('Load Delivery Address'),
        ),
      );
    }
  }

  Widget _buildPaymentMethodSection() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            StringConstants.paymentMethod,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSpacing.vMd,
          
          // Payment method options
          _buildPaymentMethodOption(
            title: "0089",
            icon: Icons.credit_card,
            value: PaymentMethod.creditCard,
          ),
          
          _buildPaymentMethodOption(
            title: 'UPI',
            icon: Icons.phone_android,
            value: PaymentMethod.upi,
          ),
          
          _buildPaymentMethodOption(
            title: 'Net Banking',
            icon: Icons.account_balance,
            value: PaymentMethod.netBanking,
          ),
          
          _buildPaymentMethodOption(
            title: 'Wallet',
            icon: Icons.account_balance_wallet,
            value: PaymentMethod.wallet,
          ),
        ],
      ),
    );
  }

  Widget _buildCompleteOrderButton(MealPlanCompleted planState, UserProfileState userState) {
    if (userState is! UserProfileLoaded) {
      return AppButton(
        label: 'Please load your profile first',
        onPressed: null,
        isFullWidth: true,
        buttonType: AppButtonType.primary,
        buttonSize: AppButtonSize.large,
      );
    }
    
    final mealPlanSelection = planState.mealPlanSelection;
    final basePrice = mealPlanSelection.totalMeals * 120.0; // Assuming average meal price
    final totalPrice = _priceCalculator.calculateTotalPrice(
      basePrice,
      _customizationCharges,
      _discount,
    );
    
    return BlocBuilder<PaymentCubit, PaymentState>(
      builder: (context, state) {
        return AppButton(
          label: state is PaymentProcessing 
              ? 'Processing...' 
              : StringConstants.completeOrder,
          onPressed: state is PaymentProcessing 
              ? null 
              : () => _processPayment(
                  userState.user.address,
                  planState,
                  totalPrice,
                ),
          isFullWidth: true,
          buttonType: AppButtonType.primary,
          buttonSize: AppButtonSize.large,
          leadingIcon: state is PaymentProcessing ? null : Icons.shopping_cart,
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String amount, {bool isTotal = false, bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            amount,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isDiscount 
                  ? AppColors.success 
                  : (isTotal ? AppColors.primary : AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodOption({
    required String title,
    required IconData icon,
    required PaymentMethod value,
  }) {
    final isSelected = _selectedPaymentMethod == value;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            AppSpacing.hMd,
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const Spacer(),
            Radio<PaymentMethod>(
              value: value,
              groupValue: _selectedPaymentMethod,
              onChanged: (PaymentMethod? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedPaymentMethod = newValue;
                  });
                }
              },
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  void _processPayment(
    Address address,
    MealPlanCompleted planState,
    double totalPrice,
  ) {
    final paymentCubit = context.read<PaymentCubit>();
    final mealPlanSelection = planState.mealPlanSelection;
    
    // In a real app, you would create a subscription on the backend first
    // and then use the returned subscription ID for payment
    // For demo purposes, we'll use a fake subscription ID
    const subscriptionId = 'sub_demo_123456';
    
    // Get plan from selection
    // In a real app, this would come from the backend
    final plan = SubscriptionPlan(
      id: 'plan_001',
      name: mealPlanSelection.planType,
      description: 'Custom meal plan',
      price: totalPrice,
      weeklyMealTemplate: [], // This would come from backend
      breakdown: [], // This would come from backend
    );
    
    // Process payment
    paymentCubit.processPayment(
      subscriptionId: subscriptionId,
      amount: totalPrice,
      method: _selectedPaymentMethod,
      deliveryAddress: address,
      plan: plan,
    );
  }

  void _showPaymentSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(StringConstants.paymentSuccessful),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(StringConstants.paymentSuccessMessage),
              const SizedBox(height: 16),
              Icon(
                Icons.restaurant,
                color: AppColors.primary,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'Your first meal will be delivered soon!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            AppButton(
              label: StringConstants.goToHome,
              onPressed: () {
                // Reset cubits
                context.read<MealPlanSelectionCubit>().resetSelection();
                context.read<PaymentCubit>().resetPayment();
                
                // Navigate to home and clear stack
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              isFullWidth: true,
              buttonType: AppButtonType.primary,
              buttonSize: AppButtonSize.medium,
            ),
          ],
        );
      },
    );
  }
}