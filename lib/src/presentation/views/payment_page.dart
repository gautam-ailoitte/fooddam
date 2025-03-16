// lib/src/presentation/views/payment_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/string_constants.dart';
import 'package:foodam/src/domain/entities/plan_entity.dart';
import 'package:foodam/src/presentation/cubits/active_plan_cubit/active_plan_cubit.dart';
import 'package:foodam/src/presentation/cubits/draft_plan_cubit/draft_plan_cubit.dart';
import 'package:foodam/src/presentation/cubits/plan_customization_cubit/plan_customization_cubit.dart';
import 'package:foodam/src/presentation/helpers/payment_helper.dart';
import 'package:foodam/src/presentation/utlis/date_formatter_utility.dart';
import 'package:foodam/src/presentation/utlis/helper.dart';
import 'package:foodam/src/presentation/widgets/common/app_button.dart';

class PaymentSummaryPage extends StatefulWidget {
  final Plan plan;
  
  const PaymentSummaryPage({
    super.key,
    required this.plan,
  });
  
  @override
  State<PaymentSummaryPage> createState() => _PaymentSummaryPageState();
}

class _PaymentSummaryPageState extends State<PaymentSummaryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(StringConstants.orderSummary),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
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
                      StringConstants.planDetailsTitle,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    PaymentHelper.buildInfoRow(StringConstants.planName, widget.plan.name),
                    PaymentHelper.buildInfoRow(
                      StringConstants.planType, 
                      widget.plan.isVeg ? StringConstants.vegetarian : StringConstants.nonVegetarian
                    ),
                    PaymentHelper.buildInfoRow(
                      StringConstants.duration, 
                      PaymentHelper.getDurationText(widget.plan.duration)
                    ),
                    PaymentHelper.buildInfoRow(
                      StringConstants.totalMeals, 
                      PaymentHelper.calculateTotalMeals(widget.plan).toString()
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 20),
            
            // Price breakdown
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
                      StringConstants.priceDetails,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    PaymentHelper.buildPriceRow(context, StringConstants.basePrice, widget.plan.basePrice),
                    PaymentHelper.buildPriceRow(
                      context, 
                      StringConstants.customizationCharges, 
                      PaymentHelper.calculateCustomizationCharges(widget.plan)
                    ),
                    
                    // Apply discount based on duration
                    PaymentHelper.buildDiscountRow(context, widget.plan.duration, widget.plan),
                    
                    Divider(height: 24),
                    PaymentHelper.buildPriceRow(
                      context,
                      StringConstants.totalAmount, 
                      widget.plan.totalPrice,
                      isTotal: true
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 20),
            
            // Daily breakdown
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
                      StringConstants.dailyBreakdown,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    
                    // Show breakdown for each day
                    ...widget.plan.mealsByDay.entries.map(
                      (entry) => PaymentHelper.buildDayPriceRow(
                        DateFormatter.getDayName(entry.key),
                        entry.value.dailyTotal
                      )
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 20),
            
            // Payment method (mock)
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
                      StringConstants.paymentMethod,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    ListTile(
                      leading: Icon(Icons.credit_card, color: Theme.of(context).colorScheme.primary),
                      title: Text('Credit Card (ending 1234)'),
                      trailing: Radio(
                        value: true,
                        groupValue: true,
                        onChanged: null,
                        activeColor: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: AppButton(
            label: StringConstants.completeOrder,
            onPressed: _confirmPayment,
          ),
        ),
      ),
    );
  }
  
  // Complete payment and set as active plan
  void _confirmPayment() {
    // Create the final plan with start and end dates
    final now = DateTime.now();
    final endDate = PaymentHelper.calculateEndDate(now, widget.plan.duration);
    
    final completedPlan = widget.plan.copyWith(
      startDate: now,
      endDate: endDate,
      isDraft: false,
    );
    
    // Set as active plan
    context.read<ActivePlanCubit>().setActivePlan(completedPlan);
    
    // Clear any draft plans
    context.read<DraftPlanCubit>().clearDraft();
    
    // Reset customization state
    context.read<PlanCustomizationCubit>().reset();
    
    // Show success dialog
    DialogHelper.showPaymentSuccess(context, () {
      // Navigate to home
      NavigationHelper.goToHome(context);
    });
  }
}