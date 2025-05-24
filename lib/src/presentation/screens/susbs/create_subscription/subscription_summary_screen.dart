// lib/src/presentation/screens/susbs/create_subscription/subscription_summary_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/constants/subscription_constants.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/route/app_router.dart';
import 'package:foodam/core/widgets/primary_button.dart';
import 'package:foodam/core/widgets/secondary_button.dart';
import 'package:foodam/src/domain/services/meal_selection_service.dart';
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
  late MealSelectionService _selectionService;

  @override
  void initState() {
    super.initState();
    _initializeSelectionService();
  }

  void _initializeSelectionService() {
    final state = context.read<SubscriptionPlanningCubit>().state;
    if (state is PlanningComplete) {
      _selectionService = MealSelectionService(
        startDate: state.startDate,
        durationWeeks: state.duration,
        mealsPerWeek: state.mealPlan,
        dietaryPreference: state.dietaryPreference,
      );
    }
  }

  @override
  void dispose() {
    _selectionService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(context),
      body: BlocConsumer<SubscriptionPlanningCubit, SubscriptionPlanningState>(
        listener: (context, state) => _handleStateChanges(context, state),
        builder: (context, state) => _buildContent(context, state),
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
        onPressed: () => _discardAndStartOver(context),
      ),
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
    }
  }

  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _navigateToCheckout(BuildContext context) {
    Navigator.pushReplacementNamed(context, AppRouter.checkoutRoute);
  }

  Widget _buildContent(BuildContext context, SubscriptionPlanningState state) {
    if (state is SubscriptionPlanningLoading) {
      return _buildLoadingContent();
    }

    if (state is! PlanningComplete) {
      return _buildErrorContent(context);
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
        ],
      ),
    );
  }

  Widget _buildErrorContent(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.marginMedium),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: AppColors.error),
            SizedBox(height: AppDimensions.marginMedium),
            Text(
              'Summary Not Available',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.error,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppDimensions.marginSmall),
            const Text(
              'Unable to load summary. Please start planning again.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppDimensions.marginLarge),
            PrimaryButton(
              text: 'Start Planning',
              onPressed: () => _discardAndStartOver(context),
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

                // Selection summary (from service)
                ListenableBuilder(
                  listenable: _selectionService,
                  builder: (context, child) {
                    return Column(
                      children: [
                        _buildSelectionSummary(),
                        SizedBox(height: AppDimensions.marginMedium),
                        _buildMealDistribution(),
                      ],
                    );
                  },
                ),

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
              'End Date',
              DateFormat('MMMM d, yyyy').format(state.calculatedEndDate),
              Icons.event,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionSummary() {
    final stats = _selectionService.getSummaryStats();
    final totalSelections = stats['totalSelections'] as int;
    final totalRequired = stats['totalRequired'] as int;
    final isComplete = stats['isReadyForSubmission'] as bool;

    return Card(
      elevation: 0,
      color:
          isComplete
              ? AppColors.success.withOpacity(0.05)
              : AppColors.warning.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color:
              isComplete
                  ? AppColors.success.withOpacity(0.3)
                  : AppColors.warning.withOpacity(0.3),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.marginMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isComplete ? Icons.check_circle : Icons.warning_amber,
                  color: isComplete ? AppColors.success : AppColors.warning,
                ),
                SizedBox(width: AppDimensions.marginSmall),
                Text(
                  'Selection Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isComplete ? AppColors.success : AppColors.warning,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppDimensions.marginSmall),
            Text(
              isComplete
                  ? 'All weeks completed successfully!'
                  : 'Some weeks are incomplete',
              style: TextStyle(
                color: isComplete ? AppColors.success : AppColors.warning,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: AppDimensions.marginMedium),

            _buildSummaryRow(
              'Total Meals Selected',
              '$totalSelections',
              Icons.restaurant,
              isHighlighted: true,
            ),
            _buildSummaryRow(
              'Total Required',
              '$totalRequired',
              Icons.assignment,
            ),
            _buildSummaryRow(
              'Progress',
              '${((stats['completionProgress'] as double) * 100).round()}%',
              Icons.timeline,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealDistribution() {
    final distribution = _selectionService.mealTypeDistribution;

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
              final count = distribution[mealType] ?? 0;
              final totalSelections =
                  _selectionService.getAllSelections().length;
              final percentage =
                  totalSelections > 0
                      ? (count / totalSelections * 100).round()
                      : 0;

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
                      value: totalSelections > 0 ? count / totalSelections : 0,
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
        child: ListenableBuilder(
          listenable: _selectionService,
          builder: (context, child) {
            final isReadyForCheckout = _selectionService.isAllWeeksComplete;
            final validationError = _selectionService.validateForSubmission();

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Validation status
                if (!isReadyForCheckout && validationError != null) ...[
                  Container(
                    padding: EdgeInsets.all(AppDimensions.marginMedium),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.error.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: AppColors.error,
                          size: 24,
                        ),
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
                                validationError,
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
                        text: 'Discard & Start Over',
                        icon: Icons.restart_alt,
                        onPressed: () => _discardAndStartOver(context),
                      ),
                    ),
                    SizedBox(width: AppDimensions.marginMedium),
                    Expanded(
                      child: PrimaryButton(
                        text: 'Proceed to Checkout',
                        icon: Icons.arrow_forward,
                        onPressed:
                            isReadyForCheckout
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
            );
          },
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

  void _discardAndStartOver(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Discard Planning?'),
            content: const Text(
              'This will discard all your meal selections and return to the beginning. Are you sure?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  _selectionService.reset();
                  context.read<SubscriptionPlanningCubit>().reset();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRouter.startSubscriptionPlanningRoute,
                    (route) => false,
                  );
                },
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: const Text('Discard'),
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
}
