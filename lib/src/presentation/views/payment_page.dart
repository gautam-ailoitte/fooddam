// Updated PaymentPage
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/string_constants.dart';
import 'package:foodam/src/domain/entities/user_entity.dart';
import 'package:foodam/src/presentation/cubits/active_plan_cubit/active_plan_cubit.dart';
import 'package:foodam/src/presentation/cubits/draft_plan_cubit/draft_plan_cubit.dart';
import 'package:foodam/src/presentation/cubits/plan_customization_cubit/plan_customization_cubit.dart';
import 'package:foodam/src/presentation/payment_cubit/payment_cubit.dart';
import 'package:foodam/src/presentation/utlis/helper.dart';
import 'package:foodam/src/presentation/widgets/common/app_button.dart';
import 'package:foodam/src/presentation/widgets/common/app_loading.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({Key? key}) : super(key: key);
  
  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  @override
  void initState() {
    super.initState();
    
    // Wait for widget to be built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check if we came from completed customization
      final customizationState = context.read<PlanCustomizationCubit>().state;
      if (customizationState is PlanCustomizationCompleted) {
        // Initiate payment with plan from customization
        context.read<PaymentCubit>().initiatePayment(customizationState.plan);
      } else {
        // No valid plan - go back
        Navigator.of(context).pop();
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Reset payment state when going back
        context.read<PaymentCubit>().reset();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(title: Text('Payment')),
        body: BlocConsumer<PaymentCubit, PaymentState>(
          listener: (context, state) {
            if (state is PaymentCompleted) {
              // Payment successful - show dialog and handle completion
              DialogHelper.showPaymentSuccess(context, () {
                // Update active plan
                context.read<ActivePlanCubit>().setActivePlan(state.plan);
                // Clear draft
                context.read<DraftPlanCubit>().clearDraft();
                // Reset customization
                context.read<PlanCustomizationCubit>().reset();
                // Go to home
                NavigationHelper.goToHome(context);
              });
            }
          },
          builder: (context, state) {
            if (state is PaymentProcessing) {
              return AppLoading(message: 'Processing payment...');
            } else if (state is PaymentReady) {
              return _buildPaymentSummary(context, state.plan, state.paymentUrl);
            } else if (state is PaymentError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Go Back'),
                    ),
                  ],
                ),
              );
            }
            
            return AppLoading(message: 'Preparing payment...');
          },
        ),
      ),
    );
  }

  Widget _buildPaymentSummary(BuildContext context, Plan plan, String? paymentUrl) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order summary card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Order Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getDurationText(plan.duration),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    plan.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: plan.isVeg ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      plan.isVeg ? 'Vegetarian' : 'Non-Vegetarian',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Divider(height: 32),
                  _buildPriceSummary(context, plan),
                ],
              ),
            ),
          ),

          SizedBox(height: 24),

          // Plan details
          Text(
            'Plan Details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),

          // Lists meals by day
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: plan.mealsByDay.length,
            itemBuilder: (context, index) {
              final dayOfWeek = plan.mealsByDay.keys.elementAt(index);
              final dailyMeals = plan.mealsByDay[dayOfWeek]!;

              return _buildDayMealsSummary(context, dayOfWeek, dailyMeals);
            },
          ),

          SizedBox(height: 24),

          // Payment method section
          Text(
            'Payment Method',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),

          // Mock payment methods
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildPaymentMethodOption(
                    context,
                    name: 'Credit / Debit Card',
                    icon: Icons.credit_card,
                    isSelected: true,
                  ),
                  Divider(height: 24),
                  _buildPaymentMethodOption(
                    context,
                    name: 'UPI Payment',
                    icon: Icons.account_balance,
                    isSelected: false,
                  ),
                  Divider(height: 24),
                  _buildPaymentMethodOption(
                    context,
                    name: 'Pay on Delivery',
                    icon: Icons.local_shipping,
                    isSelected: false,
                  ),
                ],
              ),
            ),
          ),

          // Payment URL info (if available)
          if (paymentUrl != null) ...[
            SizedBox(height: 24),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment URL',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'In a real app, you would be redirected to:',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      paymentUrl,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          SizedBox(height: 32),

          // Payment button
          AppButton(
            label: 'Pay Now',
            onPressed: () {
              // In a real app, this would initiate the payment process
              _showPaymentSuccessDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSummary(BuildContext context, Plan plan) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Plan Base Price'),
            Text('₹${plan.basePrice.toStringAsFixed(2)}'),
          ],
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Customization Charges'),
            Text('₹${(plan.totalPrice - plan.basePrice).toStringAsFixed(2)}'),
          ],
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text('Delivery Charges'), Text('FREE')],
        ),
        Divider(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total Amount',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              '₹${plan.totalPrice.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDayMealsSummary(
    BuildContext context,
    DayOfWeek dayOfWeek,
    DailyMeals dailyMeals,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getDayName(dayOfWeek),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 12),
              // Breakfast
              if (dailyMeals.breakfast != null)
                _buildMealSummary(
                  context,
                  title: StringConstants.breakfast,
                  thali: dailyMeals.breakfast!,
                ),

              // Lunch
              if (dailyMeals.lunch != null)
                _buildMealSummary(
                  context,
                  title: StringConstants.lunch,
                  thali: dailyMeals.lunch!,
                ),

              // Dinner
              if (dailyMeals.dinner != null)
                _buildMealSummary(
                  context,
                  title: StringConstants.dinner,
                  thali: dailyMeals.dinner!,
                ),

              // Daily total
              Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Daily Total: ',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '₹${dailyMeals.dailyTotal.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMealSummary(
    BuildContext context, {
    required String title,
    required Thali thali,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('$title: ', style: TextStyle(fontWeight: FontWeight.w500)),
            Text(
              thali.name,
              style: TextStyle(
                color: _getThaliColor(thali.type),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Padding(
          padding: EdgeInsets.only(left: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                thali.selectedMeals.map((meal) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 2),
                    child: Row(
                      children: [
                        Icon(
                          meal.isVeg ? Icons.eco : Icons.restaurant,
                          size: 14,
                          color: meal.isVeg ? Colors.green : Colors.red,
                        ),
                        SizedBox(width: 4),
                        Text(
                          meal.name,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ),
        SizedBox(height: 8),
      ],
    );
  }

  Widget _buildPaymentMethodOption(
    BuildContext context, {
    required String name,
    required IconData icon,
    required bool isSelected,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color:
              isSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
        ),
        SizedBox(width: 16),
        Text(
          name,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Spacer(),
        if (isSelected)
          Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
        else
          Radio(
            value: true,
            groupValue: false,
            onChanged: (_) {},
            activeColor: Theme.of(context).colorScheme.primary,
          ),
      ],
    );
  }

  void _showPaymentSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 64),
                  SizedBox(height: 16),
                  Text(
                    'Payment Successful!',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your meal plan has been activated successfully.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Navigate back to home page
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: Text('Go to Home'),
              ),
            ],
          ),
    );
  }

  Color _getThaliColor(ThaliType type) {
    switch (type) {
      case ThaliType.normal:
        return Colors.green;
      case ThaliType.nonVeg:
        return Colors.red;
      case ThaliType.deluxe:
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }

  String _getDurationText(PlanDuration duration) {
    switch (duration) {
      case PlanDuration.sevenDays:
        return '7 Days';
      case PlanDuration.fourteenDays:
        return '14 Days';
      case PlanDuration.twentyEightDays:
        return '28 Days';
      default:
        return '7 Days';
    }
  }

  String _getDayName(DayOfWeek day) {
    switch (day) {
      case DayOfWeek.monday:
        return StringConstants.monday;
      case DayOfWeek.tuesday:
        return StringConstants.tuesday;
      case DayOfWeek.wednesday:
        return StringConstants.wednesday;
      case DayOfWeek.thursday:
        return StringConstants.thursday;
      case DayOfWeek.friday:
        return StringConstants.friday;
      case DayOfWeek.saturday:
        return StringConstants.saturday;
      case DayOfWeek.sunday:
        return StringConstants.sunday;
    }
  }
}