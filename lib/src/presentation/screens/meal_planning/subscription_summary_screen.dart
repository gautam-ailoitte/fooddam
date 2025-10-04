// lib/src/presentation/screens/meal_planning/subscription_summary_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/route/app_router.dart';
import 'package:foodam/core/widgets/primary_button.dart';
import 'package:foodam/src/presentation/cubits/meal_planning/meal_planning_cubit.dart';

class SubscriptionSummaryScreen extends StatefulWidget {
  const SubscriptionSummaryScreen({super.key});

  @override
  State<SubscriptionSummaryScreen> createState() =>
      _SubscriptionSummaryScreenState();
}

class _SubscriptionSummaryScreenState extends State<SubscriptionSummaryScreen> {
  String? selectedAddressId;
  final TextEditingController instructionsController = TextEditingController();

  @override
  void dispose() {
    instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Your Plan'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: BlocConsumer<MealPlanningCubit, MealPlanningState>(
        listener: (context, state) {
          if (state is MealPlanningError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is SubscriptionSuccess) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRouter.confirmationRoute,
              (route) => route.settings.name == AppRouter.mainRoute,
              arguments: state.subscriptionId,
            );
          }
        },
        builder: (context, state) {
          if (state is WeekGridLoaded) {
            return _buildSummaryContent(context, state);
          } else if (state is SubscriptionCreating) {
            return _buildCreatingState(state);
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildSummaryContent(BuildContext context, WeekGridLoaded state) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderSection(context, state),
                SizedBox(height: AppSpacing.lg),
                _buildMealPlanSummary(context, state),
                SizedBox(height: AppSpacing.lg),
                _buildPricingBreakdown(context, state),
                SizedBox(height: AppSpacing.lg),
                _buildAddressSection(context),
                SizedBox(height: AppSpacing.lg),
                _buildInstructionsSection(context),
              ],
            ),
          ),
        ),
        _buildBottomActions(context, state),
      ],
    );
  }

  Widget _buildCreatingState(SubscriptionCreating state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          SizedBox(height: AppSpacing.md),
          Text(
            state.message ?? 'Creating your subscription...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'This may take a few moments',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context, WeekGridLoaded state) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 24),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Plan Complete!',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'You have successfully planned your meals for ${state.totalWeeks} week${state.totalWeeks > 1 ? 's' : ''}. Review the details below and confirm your subscription.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildMealPlanSummary(BuildContext context, WeekGridLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Meal Plan Summary',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: AppSpacing.md),

        ...state.weekSelections.entries.map((entry) {
          final weekNum = entry.key;
          final weekData = entry.value;

          return Container(
            margin: EdgeInsets.only(bottom: AppSpacing.md),
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Week $weekNum',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
                        '₹${weekData.weekPrice.toInt()}',
                        style: Theme.of(
                          context,
                        ).textTheme.labelMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.sm),

                Row(
                  children: [
                    _buildWeekDetail(
                      'Meals',
                      '${weekData.validation.selectedCount}',
                    ),
                    SizedBox(width: AppSpacing.lg),
                    _buildWeekDetail('Preference', weekData.dietaryPreference),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildWeekDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildPricingBreakdown(BuildContext context, WeekGridLoaded state) {
    final totalMeals = state.weekSelections.values.fold(
      0,
      (sum, week) => sum + week.validation.selectedCount,
    );
    final avgPricePerMeal =
        totalMeals > 0 ? state.totalPrice / totalMeals : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pricing Breakdown',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: AppSpacing.md),

        Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              _buildPriceRow('Total Meals', '$totalMeals meals'),
              SizedBox(height: AppSpacing.sm),
              _buildPriceRow('Average per Meal', '₹${avgPricePerMeal.toInt()}'),
              SizedBox(height: AppSpacing.sm),
              _buildPriceRow(
                'Duration',
                '${state.totalWeeks} week${state.totalWeeks > 1 ? 's' : ''}',
              ),

              SizedBox(height: AppSpacing.md),
              Divider(color: Colors.grey.shade300),
              SizedBox(height: AppSpacing.md),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '₹${state.totalPrice.toInt()}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildAddressSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Delivery Address',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: AppSpacing.md),

        GestureDetector(
          onTap: _selectAddress,
          child: Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
              border: Border.all(
                color:
                    selectedAddressId != null
                        ? AppColors.primary
                        : Colors.grey.shade300,
                width: selectedAddressId != null ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_on,
                  color:
                      selectedAddressId != null
                          ? AppColors.primary
                          : Colors.grey,
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    selectedAddressId != null
                        ? 'Address Selected'
                        : 'Select delivery address',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color:
                          selectedAddressId != null
                              ? AppColors.textPrimary
                              : Colors.grey,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Special Instructions (Optional)',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: AppSpacing.md),

        TextField(
          controller: instructionsController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Any special delivery instructions...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions(BuildContext context, WeekGridLoaded state) {
    final canProceed = selectedAddressId != null;

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!canProceed) ...[
            Text(
              'Please select a delivery address to continue',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.sm),
          ],

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Back to Planning'),
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: PrimaryButton(
                  text: 'Confirm Subscription',
                  onPressed:
                      canProceed ? () => _confirmSubscription(context) : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _selectAddress() async {
    // Navigate to address selection screen
    final result = await Navigator.pushNamed(
      context,
      AppRouter.addAddressRoute,
    );

    if (result != null && result is String) {
      setState(() {
        selectedAddressId = result;
      });
    }
  }

  void _confirmSubscription(BuildContext context) {
    context.read<MealPlanningCubit>().createSubscription(
      addressId: selectedAddressId!,
      instructions: instructionsController.text.trim(),
    );
  }
}
