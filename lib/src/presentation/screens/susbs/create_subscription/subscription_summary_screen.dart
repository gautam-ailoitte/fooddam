// lib/src/presentation/screens/subscription/subscription_summary_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/constants/subscription_constants.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/route/app_router.dart';
import 'package:foodam/core/widgets/primary_button.dart';
import 'package:foodam/core/widgets/secondary_button.dart';
import 'package:foodam/src/presentation/cubits/subscription/planning/subscription_planning_cubit.dart';
import 'package:foodam/src/presentation/cubits/subscription/planning/subscription_planning_state.dart';
import 'package:intl/intl.dart';

class SubscriptionSummaryScreen extends StatelessWidget {
  const SubscriptionSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Summary'),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: BlocConsumer<SubscriptionPlanningCubit, SubscriptionPlanningState>(
        listener: (context, state) {
          if (state is SubscriptionPlanningError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is! PlanningComplete) {
            return const Center(child: Text('Unable to load summary'));
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(AppDimensions.marginMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Subscription overview
                      _buildSubscriptionOverview(state),
                      SizedBox(height: AppDimensions.marginMedium),

                      // Week-by-week breakdown
                      _buildWeekBreakdown(state),
                      SizedBox(height: AppDimensions.marginMedium),

                      // Meal selection summary
                      _buildMealSelectionSummary(state),
                    ],
                  ),
                ),
              ),

              // Bottom action bar
              _buildBottomActionBar(context, state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSubscriptionOverview(PlanningComplete state) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.marginMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success, size: 24),
                SizedBox(width: AppDimensions.marginSmall),
                Text(
                  'Planning Complete!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppDimensions.marginMedium),

            _buildSummaryRow(
              'Start Date',
              DateFormat('MMMM d, yyyy').format(state.startDate),
            ),
            _buildSummaryRow(
              'Duration',
              SubscriptionConstants.getDurationText(state.duration),
            ),
            _buildSummaryRow(
              'Dietary Preference',
              SubscriptionConstants.getDietaryPreferenceText(
                state.dietaryPreference,
              ),
            ),
            _buildSummaryRow(
              'Meals per Week',
              SubscriptionConstants.getMealPlanText(state.mealPlan),
            ),
            _buildSummaryRow(
              'Total Meals Selected',
              '${_getTotalSelectedMeals(state)}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekBreakdown(PlanningComplete state) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.marginMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Week Breakdown',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppDimensions.marginMedium),

            ...List.generate(state.duration, (index) {
              final week = index + 1;
              final weekData = state.weeksData[week]!;
              final selectedCount = _getWeekSelectedMeals(state, week);

              return Container(
                margin: EdgeInsets.only(bottom: AppDimensions.marginSmall),
                padding: EdgeInsets.all(AppDimensions.marginMedium),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.success, width: 1),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.check,
                          color: AppColors.success,
                          size: 20,
                        ),
                      ),
                    ),
                    SizedBox(width: AppDimensions.marginMedium),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Week $week',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${DateFormat('MMM d').format(weekData.weekStartDate)} - ${DateFormat('MMM d').format(weekData.weekEndDate)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '$selectedCount meals',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMealSelectionSummary(PlanningComplete state) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.marginMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Meal Distribution',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppDimensions.marginMedium),

            ...SubscriptionConstants.mealTypes.map((mealType) {
              final count = _getMealTypeCount(state, mealType);
              final total = _getTotalSelectedMeals(state);
              final percentage = total > 0 ? (count / total * 100).round() : 0;

              return Container(
                margin: EdgeInsets.only(bottom: AppDimensions.marginSmall),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          SubscriptionConstants.mealTypeDisplayNames[mealType]!,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '$count meals ($percentage%)',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: total > 0 ? count / total : 0,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getMealTypeColor(mealType),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActionBar(BuildContext context, PlanningComplete state) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.marginMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: SecondaryButton(
                text: 'Edit Selection',
                onPressed: () => Navigator.pop(context),
              ),
            ),
            SizedBox(width: AppDimensions.marginMedium),
            Expanded(
              child: PrimaryButton(
                text: 'Proceed to Checkout',
                onPressed: () {
                  Navigator.pushNamed(context, AppRouter.checkoutRoute);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppDimensions.marginSmall),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  int _getTotalSelectedMeals(PlanningComplete state) {
    int total = 0;
    for (final weekSelections in state.mealSelections.values) {
      for (final daySelections in weekSelections.values) {
        total += daySelections.values.where((selected) => selected).length;
      }
    }
    return total;
  }

  int _getWeekSelectedMeals(PlanningComplete state, int week) {
    final weekSelections = state.mealSelections[week] ?? {};
    int count = 0;
    for (final daySelections in weekSelections.values) {
      count += daySelections.values.where((selected) => selected).length;
    }
    return count;
  }

  int _getMealTypeCount(PlanningComplete state, String mealType) {
    int count = 0;
    for (final weekSelections in state.mealSelections.values) {
      for (final daySelections in weekSelections.values) {
        if (daySelections[mealType] == true) count++;
      }
    }
    return count;
  }

  Color _getMealTypeColor(String mealType) {
    switch (mealType.toLowerCase()) {
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
}
