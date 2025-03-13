// lib/src/presentation/views/payment_summary_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/string_constants.dart';
import 'package:foodam/src/domain/entities/user_entity.dart';
import 'package:foodam/src/presentation/cubits/active_plan_cubit/active_plan_cubit.dart';
import 'package:foodam/src/presentation/cubits/draft_plan_cubit/draft_plan_cubit.dart';
import 'package:foodam/src/presentation/cubits/plan_customization_cubit/plan_customization_cubit.dart';
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
        title: Text('Order Summary'),
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
                      'Plan Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildInfoRow('Plan Name', widget.plan.name),
                    _buildInfoRow('Plan Type', widget.plan.isVeg ? 'Vegetarian' : 'Non-Vegetarian'),
                    _buildInfoRow('Duration', _getDurationText(widget.plan.duration)),
                    _buildInfoRow('Total Meals', _calculateTotalMeals()),
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
                      'Price Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildPriceRow('Base Price', widget.plan.basePrice),
                    _buildPriceRow('Customization Charges', _calculateCustomizationCharges()),
                    
                    // Apply discount based on duration
                    _buildDiscountRow(),
                    
                    Divider(height: 24),
                    _buildPriceRow(
                      'Total Amount', 
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
                      'Daily Breakdown',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    
                    // Show breakdown for each day
                    ...widget.plan.mealsByDay.entries.map(
                      (entry) => _buildDayPriceRow(
                        _getDayName(entry.key),
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
                      'Payment Method',
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
            label: 'Complete Order',
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
    DateTime endDate;
    
    switch (widget.plan.duration) {
      case PlanDuration.sevenDays:
        endDate = now.add(Duration(days: 7));
        break;
      case PlanDuration.fourteenDays:
        endDate = now.add(Duration(days: 14));
        break;
      case PlanDuration.twentyEightDays:
        endDate = now.add(Duration(days: 28));
        break;
    }
    
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
  
  // Helper methods
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPriceRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? Theme.of(context).colorScheme.primary : null,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDayPriceRow(String day, double amount) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(day),
          Text('₹${amount.toStringAsFixed(2)}'),
        ],
      ),
    );
  }
  
  Widget _buildDiscountRow() {
    double discountRate = 0.0;
    
    switch (widget.plan.duration) {
      case PlanDuration.sevenDays:
        return SizedBox.shrink(); // No discount
      case PlanDuration.fourteenDays:
        discountRate = 0.05; // 5% discount
        break;
      case PlanDuration.twentyEightDays:
        discountRate = 0.1; // 10% discount
        break;
    }
    
    final baseTotal = widget.plan.basePrice + _calculateCustomizationCharges();
    final discountAmount = baseTotal * discountRate;
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Discount (${(discountRate * 100).toInt()}%)',
            style: TextStyle(
              color: Colors.green,
            ),
          ),
          Text(
            '-₹${discountAmount.toStringAsFixed(2)}',
            style: TextStyle(
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
  
  // Calculate total customization charges across all meals
  double _calculateCustomizationCharges() {
    double total = 0.0;
    
    widget.plan.mealsByDay.forEach((day, dailyMeals) {
      if (dailyMeals.breakfast != null) {
        total += dailyMeals.breakfast!.additionalPrice;
      }
      if (dailyMeals.lunch != null) {
        total += dailyMeals.lunch!.additionalPrice;
      }
      if (dailyMeals.dinner != null) {
        total += dailyMeals.dinner!.additionalPrice;
      }
    });
    
    return total;
  }
  
  // Get total number of meals in the plan
  String _calculateTotalMeals() {
    int totalMeals = 0;
    
    widget.plan.mealsByDay.forEach((day, dailyMeals) {
      if (dailyMeals.breakfast != null) totalMeals++;
      if (dailyMeals.lunch != null) totalMeals++;
      if (dailyMeals.dinner != null) totalMeals++;
    });
    
    return totalMeals.toString();
  }
  
  String _getDurationText(PlanDuration duration) {
    switch (duration) {
      case PlanDuration.sevenDays:
        return '7 Days';
      case PlanDuration.fourteenDays:
        return '14 Days';
      case PlanDuration.twentyEightDays:
        return '28 Days';
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