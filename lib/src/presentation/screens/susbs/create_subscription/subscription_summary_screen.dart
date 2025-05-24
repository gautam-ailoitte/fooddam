// lib/src/presentation/screens/subscription/updated_subscription_summary_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/constants/subscription_constants.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/widgets/primary_button.dart';
import 'package:foodam/core/widgets/secondary_button.dart';
import 'package:intl/intl.dart';

import '../../../cubits/subscription/planning/subscription_planning_cubit.dart';
import '../../../cubits/subscription/planning/subscription_planning_state.dart';

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
          } else if (state is CheckoutActive) {
            // Navigation to checkout will be handled by the calling screen
            // This screen's job is just to display summary and trigger checkout
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
                      SizedBox(height: AppDimensions.marginMedium),

                      // Selected meals detail
                      _buildSelectedMealsDetail(state),
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
              '${state.totalSelectedMeals}',
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
              final weekCache = state.weekCache[week];
              final selectedCount = state.weeklyMealCounts[week] ?? 0;
              final isWeekValid = selectedCount == state.mealPlan;

              // Calculate week date range
              final weekStartDate = state.startDate.add(
                Duration(days: (week - 1) * 7),
              );
              final weekEndDate = weekStartDate.add(const Duration(days: 6));

              return Container(
                margin: EdgeInsets.only(bottom: AppDimensions.marginSmall),
                padding: EdgeInsets.all(AppDimensions.marginMedium),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isWeekValid ? AppColors.success : AppColors.warning,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color:
                            isWeekValid
                                ? AppColors.success.withOpacity(0.1)
                                : AppColors.warning.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          isWeekValid ? Icons.check : Icons.warning,
                          color:
                              isWeekValid
                                  ? AppColors.success
                                  : AppColors.warning,
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
                            '${DateFormat('MMM d').format(weekStartDate)} - ${DateFormat('MMM d').format(weekEndDate)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (weekCache?.packageId != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Package: ${weekCache!.packageId!.substring(0, 8)}...',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$selectedCount meals',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                isWeekValid
                                    ? AppColors.success
                                    : AppColors.warning,
                          ),
                        ),
                        if (!isWeekValid) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Expected: ${state.mealPlan}',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
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
              final count = state.mealTypeDistribution[mealType] ?? 0;
              final total = state.totalSelectedMeals;
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

  Widget _buildSelectedMealsDetail(PlanningComplete state) {
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
                const Text(
                  'Selected Meals',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '${state.selections.length} total',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppDimensions.marginMedium),

            // Group meals by week
            ...List.generate(state.duration, (index) {
              final week = index + 1;
              final weekSelections =
                  state.selections
                      .where((selection) => selection.week == week)
                      .toList();

              if (weekSelections.isEmpty) {
                return Container(
                  margin: EdgeInsets.only(bottom: AppDimensions.marginSmall),
                  padding: EdgeInsets.all(AppDimensions.marginSmall),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: AppColors.warning, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Week $week: No meals selected',
                        style: TextStyle(
                          color: AppColors.warning,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ExpansionTile(
                title: Text(
                  'Week $week (${weekSelections.length} meals)',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  _getWeekDateRange(state.startDate, week),
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                children:
                    weekSelections.map((selection) {
                      return ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: AppDimensions.marginMedium,
                        ),
                        leading: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: _getMealTypeColor(
                              selection.mealType,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getMealTypeIcon(selection.mealType),
                            color: _getMealTypeColor(selection.mealType),
                            size: 16,
                          ),
                        ),
                        title: Text(
                          selection.dishName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          '${_capitalize(selection.dayName)} ${selection.mealTypeDisplay}',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        trailing:
                            selection.isToday
                                ? Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.accent.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'TODAY',
                                    style: TextStyle(
                                      fontSize: 8,
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                                : null,
                      );
                    }).toList(),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Validation status
            if (!state.isValidForSubscription) ...[
              Container(
                padding: EdgeInsets.all(AppDimensions.marginSmall),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: AppColors.warning, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Please ensure all weeks have the correct number of meals before proceeding.',
                        style: TextStyle(
                          color: AppColors.warning,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Action buttons
            Row(
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
                    onPressed:
                        state.isValidForSubscription
                            ? () {
                              context
                                  .read<SubscriptionPlanningCubit>()
                                  .goToCheckout();
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

  // Helper methods
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

  IconData _getMealTypeIcon(String mealType) {
    switch (mealType.toLowerCase()) {
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

  String _getWeekDateRange(DateTime startDate, int week) {
    final weekStartDate = startDate.add(Duration(days: (week - 1) * 7));
    final weekEndDate = weekStartDate.add(const Duration(days: 6));
    return '${DateFormat('MMM d').format(weekStartDate)} - ${DateFormat('MMM d').format(weekEndDate)}';
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
