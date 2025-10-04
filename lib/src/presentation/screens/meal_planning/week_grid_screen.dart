// lib/src/presentation/screens/meal_planning/week_grid_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/route/app_router.dart';
import 'package:foodam/core/widgets/primary_button.dart';
import 'package:foodam/src/domain/entities/meal_planning/calculated_plan_entity.dart';
import 'package:foodam/src/presentation/cubits/meal_planning/meal_planning_cubit.dart';
import 'package:foodam/src/presentation/screens/meal_planning/widgets/meal_card_widget.dart';
import 'package:foodam/src/presentation/screens/meal_planning/widgets/price_summary_widget.dart';
import 'package:foodam/src/presentation/screens/meal_planning/widgets/validation_chip_widget.dart';
import 'package:foodam/src/presentation/screens/meal_planning/widgets/week_progress_indicator.dart';

class WeekGridScreen extends StatelessWidget {
  const WeekGridScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          final shouldDiscard = await _showDiscardDialog(context);
          if (shouldDiscard == true) {
            if (context.mounted) {
              context.read<MealPlanningCubit>().reset();
              Navigator.of(context).pop();
            }
          }
        }
      },
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: BlocConsumer<MealPlanningCubit, MealPlanningState>(
          listener: (context, state) {
            print('📊 Week Grid State: ${state.runtimeType}');
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
            if (state is WeekGridLoading) {
              return _buildLoadingState(state);
            } else if (state is WeekGridLoaded) {
              return _buildGridState(context, state);
            } else if (state is SubscriptionCreating) {
              return _buildCreatingSubscriptionState(state);
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: BlocBuilder<MealPlanningCubit, MealPlanningState>(
        builder: (context, state) {
          if (state is WeekGridLoaded) {
            return Text('Week ${state.currentWeek} Planning');
          }
          return const Text('Meal Planning');
        },
      ),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 1,
      actions: [
        BlocBuilder<MealPlanningCubit, MealPlanningState>(
          builder: (context, state) {
            if (state is WeekGridLoaded) {
              return Padding(
                padding: EdgeInsets.only(right: AppSpacing.md),
                child: PriceSummaryWidget(
                  totalPrice: state.totalPrice,
                  isCompact: true,
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildLoadingState(WeekGridLoading state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (state.message != null) ...[
            SizedBox(height: AppSpacing.md),
            Text(
              state.message!,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCreatingSubscriptionState(SubscriptionCreating state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          SizedBox(height: AppSpacing.md),
          Text(
            state.message ?? 'Creating your subscription...',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showDiscardDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Discard Changes?'),
            content: const Text(
              'You have unsaved meal selections. Going back will discard all changes. Are you sure?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Discard'),
              ),
            ],
          ),
    );
  }

  Widget _buildGridState(BuildContext context, WeekGridLoaded state) {
    return Column(
      children: [
        // Progress and validation section
        Container(
          color: Colors.grey.shade50,
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              WeekProgressIndicator(
                currentWeek: state.currentWeek,
                totalWeeks: state.totalWeeks,
                overallProgress: state.overallProgress,
              ),
              SizedBox(height: AppSpacing.sm),
              ValidationChipWidget(validation: state.currentWeekValidation),
            ],
          ),
        ),

        // Main grid content
        Expanded(
          child:
              state.currentWeekData.weekData != null
                  ? _buildMealGrid(context, state)
                  : const Center(child: CircularProgressIndicator()),
        ),

        // Bottom navigation and actions
        _buildBottomActions(context, state),
      ],
    );
  }

  Widget _buildMealGrid(BuildContext context, WeekGridLoaded state) {
    final calculatedPlan = state.currentWeekData.weekData!;

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWeekInfo(context, calculatedPlan),
          SizedBox(height: AppSpacing.lg),
          _buildGridHeader(context),
          SizedBox(height: AppSpacing.md),
          _buildMealSelectionGrid(context, state, calculatedPlan),
        ],
      ),
    );
  }

  Widget _buildWeekInfo(BuildContext context, CalculatedPlan calculatedPlan) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.restaurant_menu, color: AppColors.primary),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  calculatedPlan.package?.name ?? 'Week Menu',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                if (calculatedPlan.package?.description != null) ...[
                  SizedBox(height: 4),
                  Text(
                    calculatedPlan.package!.description!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridHeader(BuildContext context) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const meals = ['Breakfast', 'Lunch', 'Dinner'];

    return Column(
      children: [
        // Days header
        Row(
          children: [
            SizedBox(width: 80), // Space for meal labels
            ...days.map(
              (day) => Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.sm),

        // Grid rows
        ...meals.asMap().entries.map((entry) {
          final mealIndex = entry.key;
          final mealType = entry.value.toLowerCase();

          return Column(
            children: [
              _buildMealRow(context, mealType, days, entry.key),
              if (mealIndex < meals.length - 1) SizedBox(height: AppSpacing.sm),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildMealRow(
    BuildContext context,
    String mealType,
    List<String> days,
    int mealIndex,
  ) {
    return BlocBuilder<MealPlanningCubit, MealPlanningState>(
      builder: (context, state) {
        if (state is! WeekGridLoaded) return const SizedBox.shrink();

        final calculatedPlan = state.currentWeekData.weekData!;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Meal type label
            SizedBox(
              width: 80,
              child: Padding(
                padding: EdgeInsets.only(top: AppSpacing.sm),
                child: Text(
                  mealType.substring(0, 1).toUpperCase() +
                      mealType.substring(1),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),

            // Meal cards for each day
            ...days.asMap().entries.map((dayEntry) {
              final dayIndex = dayEntry.key;
              final dayName = _getDayName(dayIndex);

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2),
                  child: _buildDayMealCard(
                    context,
                    state,
                    calculatedPlan,
                    dayName,
                    mealType,
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildDayMealCard(
    BuildContext context,
    WeekGridLoaded state,
    CalculatedPlan calculatedPlan,
    String dayName,
    String mealType,
  ) {
    final slotKey = '${dayName}::${mealType}';
    final isSelected = state.currentWeekData.isSlotSelected(slotKey);

    // Find the meal for this day
    final dailyMeal = calculatedPlan.dailyMeals?.firstWhere(
      (meal) => meal.day?.toLowerCase() == dayName,
      orElse: () => const DailyMeal(),
    );

    final dish = dailyMeal?.meal?.dishes?[mealType];

    if (dish == null) {
      return Container(
        height: 120,
        margin: EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Center(
          child: Text(
            'Not Available',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return MealCardWidget(
      key: Key('week_${state.currentWeek}_${dayName}_${mealType}_card'),
      dish: dish,
      slotKey: slotKey,
      dayName: dayName,
      mealType: mealType,
      isSelected: isSelected,
      onSelectionChanged: () {
        context.read<MealPlanningCubit>().toggleMealSlot(slotKey);
      },
    );
  }

  Widget _buildMealSelectionGrid(
    BuildContext context,
    WeekGridLoaded state,
    CalculatedPlan calculatedPlan,
  ) {
    // This method is kept for potential alternative grid layout
    // Currently using the row-based layout above
    return const SizedBox.shrink();
  }

  Widget _buildBottomActions(BuildContext context, WeekGridLoaded state) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
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
          // Week navigation
          if (state.totalWeeks > 1) ...[
            _buildWeekNavigation(context, state),
            SizedBox(height: AppSpacing.md),
          ],

          // Price summary and action buttons
          Row(
            children: [
              Expanded(
                child: PriceSummaryWidget(
                  totalPrice: state.totalPrice,
                  weekPrice: state.currentWeekData.weekPrice,
                  isCompact: false,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(child: _buildActionButton(context, state)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeekNavigation(BuildContext context, WeekGridLoaded state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton.icon(
          onPressed:
              state.currentWeek > 1
                  ? () => context.read<MealPlanningCubit>().switchToWeek(
                    state.currentWeek - 1,
                  )
                  : null,
          icon: const Icon(Icons.chevron_left),
          label: const Text('Previous Week'),
        ),

        Text(
          'Week ${state.currentWeek} of ${state.totalWeeks}',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),

        TextButton.icon(
          onPressed:
              state.currentWeek < state.totalWeeks
                  ? () => context.read<MealPlanningCubit>().switchToWeek(
                    state.currentWeek + 1,
                  )
                  : null,
          label: const Text('Next Week'),
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, WeekGridLoaded state) {
    if (!state.currentWeekValidation.isValid) {
      return PrimaryButton(
        text: 'Select ${state.currentWeekValidation.missingMeals} More',
        onPressed: null, // Disabled when validation fails
      );
    }

    if (state.allWeeksComplete) {
      return PrimaryButton(
        text: 'Continue to Summary',
        onPressed:
            () => Navigator.pushNamed(
              context,
              AppRouter.subscriptionSummaryRoute,
            ),
      );
    }

    if (state.currentWeek < state.totalWeeks) {
      return PrimaryButton(
        text: 'Next Week',
        onPressed:
            () => context.read<MealPlanningCubit>().switchToWeek(
              state.currentWeek + 1,
            ),
      );
    }

    return PrimaryButton(
      text: 'Complete Planning',
      onPressed:
          () =>
              Navigator.pushNamed(context, AppRouter.subscriptionSummaryRoute),
    );
  }

  String _getDayName(int dayIndex) {
    const dayNames = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];
    return dayNames[dayIndex];
  }
}
