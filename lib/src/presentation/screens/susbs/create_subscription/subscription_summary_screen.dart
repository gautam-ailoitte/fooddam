// lib/src/presentation/screens/subscription/subscription_summary_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/constants/subscription_constants.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/route/app_router.dart';
import 'package:foodam/core/widgets/primary_button.dart';
import 'package:foodam/core/widgets/secondary_button.dart';
import 'package:intl/intl.dart';

import '../../../cubits/subscription/planning/subscription_planning_cubit.dart';
import '../../../cubits/subscription/planning/subscription_planning_state.dart';

class SubscriptionSummaryScreen extends StatefulWidget {
  const SubscriptionSummaryScreen({super.key});

  @override
  State<SubscriptionSummaryScreen> createState() =>
      _SubscriptionSummaryScreenState();
}

class _SubscriptionSummaryScreenState extends State<SubscriptionSummaryScreen> {
  bool _isNavigating = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) {
        if (didPop && !_isNavigating) {
          _navigateBackToWeekSelection(context);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: _buildAppBar(context),
        body:
            BlocConsumer<SubscriptionPlanningCubit, SubscriptionPlanningState>(
              listener: (context, state) => _handleStateChanges(context, state),
              builder: (context, state) => _buildContent(context, state),
            ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        'Subscription Summary',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      backgroundColor: AppColors.primary,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => _navigateBackToWeekSelection(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () {
            // Refresh summary data if needed
            _showRefreshDialog(context);
          },
        ),
      ],
    );
  }

  void _handleStateChanges(
    BuildContext context,
    SubscriptionPlanningState state,
  ) {
    if (state is SubscriptionPlanningError) {
      _showErrorMessage(context, state.message);
    } else if (state is CheckoutActive) {
      _navigateToCheckout(context);
    } else if (state is WeekSelectionActive && _isNavigating) {
      _navigateToWeekSelection(context);
    } else if (state is SubscriptionPlanningLoading) {
      // Show loading indicator in UI
    }
  }

  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        action:
            message.contains('start over') || message.contains('Redirecting')
                ? SnackBarAction(
                  label: 'Start Over',
                  textColor: Colors.white,
                  onPressed: () {
                    context.read<SubscriptionPlanningCubit>().reset();
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRouter.startSubscriptionPlanningRoute,
                      (route) => false,
                    );
                  },
                )
                : null,
      ),
    );
  }

  void _navigateToCheckout(BuildContext context) {
    if (!_isNavigating) {
      setState(() => _isNavigating = true);

      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRouter.checkoutRoute);
        }
      });
    }
  }

  void _navigateToWeekSelection(BuildContext context) {
    if (!_isNavigating) {
      setState(() => _isNavigating = true);

      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          Navigator.pushReplacementNamed(
            context,
            AppRouter.weekSelectionFlowRoute,
          );
        }
      });
    }
  }

  Widget _buildContent(BuildContext context, SubscriptionPlanningState state) {
    if (state is SubscriptionPlanningLoading) {
      return _buildLoadingContent();
    }

    if (state is! PlanningComplete) {
      return _buildErrorContent(context, state);
    }

    return _buildSummaryContent(context, state);
  }

  Widget _buildLoadingContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: AppDimensions.marginMedium),
          const Text(
            'Preparing your summary...',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: AppDimensions.marginSmall),
          Text(
            'Please wait while we organize your meal plan',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorContent(
    BuildContext context,
    SubscriptionPlanningState state,
  ) {
    String errorMessage = 'Unable to load summary';
    String actionText = 'Go Back';
    VoidCallback? onPressed;

    if (state is SubscriptionPlanningError) {
      errorMessage = state.message;
      actionText = 'Retry';
      onPressed = () => _navigateBackToWeekSelection(context);
    } else {
      onPressed = () => _navigateBackToWeekSelection(context);
    }

    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.marginMedium),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: AppColors.error),
            SizedBox(height: AppDimensions.marginMedium),
            Text(
              'Summary Error',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.error,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppDimensions.marginSmall),
            Text(
              errorMessage,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppDimensions.marginSmall),
            const Text(
              'Please go back and complete your meal selection.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppDimensions.marginLarge),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SecondaryButton(
                  text: 'Start Over',
                  onPressed: () {
                    context.read<SubscriptionPlanningCubit>().reset();
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRouter.startSubscriptionPlanningRoute,
                      (route) => false,
                    );
                  },
                ),
                SizedBox(width: AppDimensions.marginMedium),
                PrimaryButton(text: actionText, onPressed: onPressed),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryContent(BuildContext context, PlanningComplete state) {
    return Column(
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

                // Week-by-week breakdown
                _buildWeekBreakdown(state),
                SizedBox(height: AppDimensions.marginMedium),

                // Meal selection summary
                _buildMealSelectionSummary(state),
                SizedBox(height: AppDimensions.marginMedium),

                // Selected meals detail
                _buildSelectedMealsDetail(state),

                // Add bottom padding for better scrolling
                SizedBox(height: AppDimensions.marginLarge),
              ],
            ),
          ),
        ),

        // Fixed bottom action bar
        _buildBottomActionBar(context, state),
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
                    'Your meal plan is ready for checkout',
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

  Widget _buildSubscriptionOverview(PlanningComplete state) {
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

            _buildSummaryRow(
              'Start Date',
              DateFormat('MMMM d, yyyy').format(state.startDate),
              Icons.calendar_today,
            ),
            _buildSummaryRow(
              'Duration',
              SubscriptionConstants.getDurationText(state.duration),
              Icons.schedule,
            ),
            _buildSummaryRow(
              'Dietary Preference',
              SubscriptionConstants.getDietaryPreferenceText(
                state.dietaryPreference,
              ),
              Icons.restaurant_menu,
            ),
            _buildSummaryRow(
              'Meals per Week',
              SubscriptionConstants.getMealPlanText(state.mealPlan),
              Icons.food_bank,
            ),
            _buildSummaryRow(
              'Total Meals Selected',
              '${state.totalSelectedMeals}',
              Icons.check_circle_outline,
              isHighlighted: true,
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
            Row(
              children: [
                const Text(
                  'Week Breakdown',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${state.duration} weeks',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
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
                  color:
                      isWeekValid
                          ? AppColors.success.withOpacity(0.05)
                          : AppColors.warning.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        isWeekValid
                            ? AppColors.success.withOpacity(0.3)
                            : AppColors.warning.withOpacity(0.3),
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
                          isWeekValid ? Icons.check : Icons.warning_amber,
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
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
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
                              'Package: ${weekCache!.packageId!.length > 8 ? '${weekCache.packageId!.substring(0, 8)}...' : weekCache.packageId!}',
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
                            fontSize: 16,
                            color:
                                isWeekValid
                                    ? AppColors.success
                                    : AppColors.warning,
                          ),
                        ),
                        Text(
                          'of ${state.mealPlan}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
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
                margin: EdgeInsets.only(bottom: AppDimensions.marginMedium),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: _getMealTypeColor(
                                  mealType,
                                ).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _getMealTypeIcon(mealType),
                                color: _getMealTypeColor(mealType),
                                size: 18,
                              ),
                            ),
                            SizedBox(width: AppDimensions.marginSmall),
                            Text(
                              SubscriptionConstants
                                  .mealTypeDisplayNames[mealType]!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '$count meals ($percentage%)',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: total > 0 ? count / total : 0,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getMealTypeColor(mealType),
                      ),
                      minHeight: 6,
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${state.selections.length} total',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
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
                    border: Border.all(
                      color: AppColors.warning.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber,
                        color: AppColors.warning,
                        size: 16,
                      ),
                      SizedBox(width: AppDimensions.marginSmall),
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

              return Card(
                margin: EdgeInsets.only(bottom: AppDimensions.marginSmall),
                elevation: 0,
                color: Colors.grey.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ExpansionTile(
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
            color: Colors.black.withOpacity(0.1),
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
                padding: EdgeInsets.all(AppDimensions.marginMedium),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: AppColors.error, size: 24),
                    SizedBox(width: AppDimensions.marginSmall),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Planning Incomplete',
                            style: TextStyle(
                              color: AppColors.error,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Please ensure all weeks have the correct number of meals before proceeding.',
                            style: TextStyle(
                              color: AppColors.error,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppDimensions.marginMedium),
            ],

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    text: 'Edit Selection',
                    icon: Icons.edit,
                    onPressed: () => _navigateBackToWeekSelection(context),
                  ),
                ),
                SizedBox(width: AppDimensions.marginMedium),
                Expanded(
                  child: PrimaryButton(
                    text: 'Proceed to Checkout',
                    icon: Icons.arrow_forward,
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

  Widget _buildSummaryRow(
    String label,
    String value,
    IconData icon, {
    bool isHighlighted = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppDimensions.marginSmall),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: isHighlighted ? AppColors.primary : AppColors.textSecondary,
          ),
          SizedBox(width: AppDimensions.marginSmall),
          Text(
            label,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w600,
              color: isHighlighted ? AppColors.primary : Colors.black87,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateBackToWeekSelection(BuildContext context) {
    if (_isNavigating) return;

    setState(() => _isNavigating = true);

    final cubit = context.read<SubscriptionPlanningCubit>();

    // Resume week selection state
    cubit.resumeWeekSelection();

    // Small delay to allow state to update
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted && !_isNavigating) {
        Navigator.pushReplacementNamed(
          context,
          AppRouter.weekSelectionFlowRoute,
        );
      }
    });
  }

  void _showRefreshDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Refresh Summary'),
            content: const Text(
              'Are you sure you want to refresh the summary? This will reload all meal selections.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Trigger refresh logic here if needed
                },
                child: const Text('Refresh'),
              ),
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
