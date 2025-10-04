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
import 'package:foodam/src/presentation/screens/meal_planning/widgets/week_config_bottom_sheet.dart';

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
      toolbarHeight: 80,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
      title: BlocBuilder<MealPlanningCubit, MealPlanningState>(
        builder: (context, state) {
          if (state is WeekGridLoaded) {
            final weekData = state.currentWeekData;
            final isVeg =
                weekData.dietaryPreference.toLowerCase() == 'vegetarian';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Week ${state.currentWeek} Selection',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    // Dietary badge
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: isVeg ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      isVeg ? 'Vegetarian' : 'Non-Veg',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(fontSize: 13),
                    ),
                    SizedBox(width: 8),
                    Text('•', style: TextStyle(color: Colors.grey)),
                    SizedBox(width: 8),
                    Text(
                      '${weekData.validation.selectedCount}/${weekData.targetMealCount}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color:
                            weekData.validation.isComplete
                                ? AppColors.success
                                : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            );
          }
          return const Text('Meal Planning');
        },
      ),
      actions: [
        BlocBuilder<MealPlanningCubit, MealPlanningState>(
          builder: (context, state) {
            if (state is WeekGridLoaded) {
              return Padding(
                padding: EdgeInsets.only(right: AppSpacing.md),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(Icons.info_outline, size: 20),
                      onPressed: () => _showInfoDialog(context),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '₹${state.currentWeekData.weekPrice.toInt()}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                        fontSize: 14,
                      ),
                    ),
                  ],
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

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Meal Planning Guide'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• Tap meal cards to select/deselect'),
                SizedBox(height: 8),
                Text('• Complete all meals before moving to next week'),
                SizedBox(height: 8),
                Text('• Use settings icon to change week configuration'),
                SizedBox(height: 8),
                Text('• Tap on cards for more details about each meal'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Got it'),
              ),
            ],
          ),
    );
  }

  Widget _buildGridState(BuildContext context, WeekGridLoaded state) {
    return Column(
      children: [
        // Main grid content
        Expanded(
          child:
              state.currentWeekData.weekData != null
                  ? _buildMealGrid(context, state)
                  : const Center(child: CircularProgressIndicator()),
        ),

        // Bottom bar
        _buildBottomBar(context, state),
      ],
    );
  }

  Widget _buildMealGrid(BuildContext context, WeekGridLoaded state) {
    final calculatedPlan = state.currentWeekData.weekData!;
    const mealTypes = ['breakfast', 'lunch', 'dinner'];
    const days = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];

    final isHardLimitReached = !state.currentWeekValidation.canSelectMore;

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.sm),
      child: Column(
        children: [
          // Hard limit warning banner
          if (isHardLimitReached) ...[
            Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              margin: EdgeInsets.only(bottom: AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(
                  AppDimensions.borderRadiusMd,
                ),
                border: Border.all(color: AppColors.success.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.success, size: 20),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Week complete! Deselect a meal to choose another',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Column headers
          Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Row(
              children: [
                SizedBox(width: 60),
                ...mealTypes.map(
                  (mealType) => Expanded(
                    child: Center(
                      child: Text(
                        _formatMealType(mealType),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Meal grid rows
          ...days.map(
            (day) => Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 60,
                    child: Padding(
                      padding: EdgeInsets.only(top: AppSpacing.sm),
                      child: Text(
                        _formatDay(day),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  ...mealTypes.map(
                    (mealType) => Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2),
                        child: _buildDayMealCard(
                          context,
                          state,
                          calculatedPlan,
                          day,
                          mealType,
                          isHardLimitReached,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayMealCard(
    BuildContext context,
    WeekGridLoaded state,
    CalculatedPlan calculatedPlan,
    String dayName,
    String mealType,
    bool isHardLimitReached,
  ) {
    final slotKey = '${dayName}::${mealType}';
    final isSelected = state.currentWeekData.isSlotSelected(slotKey);

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
          child: Icon(Icons.no_meals, color: Colors.grey.shade400, size: 20),
        ),
      );
    }

    // Apply hard limit styling
    final isDisabled = isHardLimitReached && !isSelected;

    return Opacity(
      opacity: isDisabled ? 0.4 : 1.0,
      child: IgnorePointer(
        ignoring: isDisabled,
        child: MealCardWidget(
          key: Key('week_${state.currentWeek}_${dayName}_${mealType}_card'),
          dish: dish,
          slotKey: slotKey,
          dayName: dayName,
          mealType: mealType,
          isSelected: isSelected,
          onSelectionChanged: () {
            context.read<MealPlanningCubit>().toggleMealSlot(slotKey);
          },
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, WeekGridLoaded state) {
    final validation = state.currentWeekValidation;
    final isWeekComplete = validation.isValid;
    final canGoNext = state.canNavigateToNext();
    final canGoPrev = state.canNavigateToPrevious();
    final isCustomized = state.isWeekCustomized(state.currentWeek);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
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
      child: Row(
        children: [
          // Previous button
          _buildNavButton(
            context,
            icon: Icons.chevron_left,
            enabled: canGoPrev,
            onPressed:
                canGoPrev
                    ? () => context.read<MealPlanningCubit>().switchToWeek(
                      state.currentWeek - 1,
                    )
                    : null,
          ),

          SizedBox(width: AppSpacing.xs),

          // Settings button
          _buildNavButton(
            context,
            icon: Icons.settings,
            enabled: true,
            isCustomized: isCustomized,
            onPressed: () => _showConfigSheet(context, state),
          ),

          SizedBox(width: AppSpacing.xs),

          // Week indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Text(
              'Week ${state.currentWeek}',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          SizedBox(width: AppSpacing.xs),

          // Next button
          _buildNavButton(
            context,
            icon: Icons.chevron_right,
            enabled: canGoNext,
            onPressed: canGoNext ? () => _handleNextWeek(context, state) : null,
          ),

          SizedBox(width: AppSpacing.md),

          // Action button
          Expanded(child: _buildSmartActionButton(context, state)),
        ],
      ),
    );
  }

  Widget _buildNavButton(
    BuildContext context, {
    required IconData icon,
    required bool enabled,
    VoidCallback? onPressed,
    bool isCustomized = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color:
                enabled
                    ? (isCustomized
                        ? Colors.blue.withOpacity(0.1)
                        : AppColors.primary.withOpacity(0.1))
                    : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color:
                  enabled
                      ? (isCustomized
                          ? Colors.blue.withOpacity(0.3)
                          : AppColors.primary.withOpacity(0.3))
                      : Colors.grey.shade300,
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color:
                enabled
                    ? (isCustomized ? Colors.blue : AppColors.primary)
                    : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }

  Future<void> _handleNextWeek(
    BuildContext context,
    WeekGridLoaded state,
  ) async {
    final nextWeek = state.currentWeek + 1;

    // Check if need to show config prompt
    if (!state.hasSeenPromptForWeek(nextWeek)) {
      final result = await showModalBottomSheet<WeekConfigResult>(
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        enableDrag: false,
        builder:
            (context) => WeekConfigBottomSheet(
              weekNumber: nextWeek,
              defaultDietaryPreference: state.currentWeekData.dietaryPreference,
              defaultMealCount: state.currentWeekData.targetMealCount,
              showKeepSameOption: true,
            ),
      );

      if (result != null && context.mounted) {
        context.read<MealPlanningCubit>().markConfigPromptSeen(nextWeek);

        if (!result.keepSame) {
          await context.read<MealPlanningCubit>().updateWeekConfiguration(
            week: nextWeek,
            dietaryPreference: result.dietaryPreference,
            targetMealCount: result.mealCount,
            isSkipped: result.isSkipped,
          );
        } else {
          context.read<MealPlanningCubit>().switchToWeek(nextWeek);
        }
      }
    } else {
      context.read<MealPlanningCubit>().switchToWeek(nextWeek);
    }
  }

  Future<void> _showConfigSheet(
    BuildContext context,
    WeekGridLoaded state,
  ) async {
    final weekData = state.currentWeekData;
    final result = await showModalBottomSheet<WeekConfigResult>(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => WeekConfigBottomSheet(
            weekNumber: state.currentWeek,
            defaultDietaryPreference: weekData.dietaryPreference,
            defaultMealCount: weekData.targetMealCount,
            showKeepSameOption: false,
            currentSelections: weekData.validation.selectedCount,
          ),
    );

    if (result != null && context.mounted) {
      final hasSelections = weekData.validation.selectedCount > 0;

      if (hasSelections) {
        // Show confirmation
        final confirmed = await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Reset Week Selections?'),
                content: Text(
                  'You currently have ${weekData.validation.selectedCount}/${weekData.targetMealCount} meals selected. '
                  'Changing settings will clear all selections for Week ${state.currentWeek}.\n\n'
                  'Continue?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Yes, Reset'),
                  ),
                ],
              ),
        );

        if (confirmed == true && context.mounted) {
          await context.read<MealPlanningCubit>().updateWeekConfiguration(
            week: state.currentWeek,
            dietaryPreference: result.dietaryPreference,
            targetMealCount: result.mealCount,
            isSkipped: result.isSkipped,
          );
        }
      } else {
        // No selections, apply directly
        await context.read<MealPlanningCubit>().updateWeekConfiguration(
          week: state.currentWeek,
          dietaryPreference: result.dietaryPreference,
          targetMealCount: result.mealCount,
          isSkipped: result.isSkipped,
        );
      }
    }
  }

  Widget _buildSmartActionButton(BuildContext context, WeekGridLoaded state) {
    final validation = state.currentWeekValidation;
    final isWeekComplete = validation.isValid;
    final missingMeals = validation.missingMeals;
    final isLastWeek = state.currentWeek == state.totalWeeks;
    final allWeeksComplete = state.allWeeksComplete;

    String buttonText;
    VoidCallback? onPressed;
    Color? backgroundColor;

    if (!isWeekComplete) {
      buttonText = 'Select $missingMeals More';
      onPressed = null;
      backgroundColor = Colors.grey.shade300;
    } else if (isLastWeek && allWeeksComplete) {
      buttonText = 'Review & Confirm';
      backgroundColor = AppColors.success;
      onPressed =
          () =>
              Navigator.pushNamed(context, AppRouter.subscriptionSummaryRoute);
    } else if (isWeekComplete && !isLastWeek) {
      buttonText = 'Next Week →';
      backgroundColor = AppColors.primary;
      onPressed = () => _handleNextWeek(context, state);
    } else {
      buttonText = 'Continue';
      backgroundColor = AppColors.primary;
      onPressed =
          () =>
              Navigator.pushNamed(context, AppRouter.subscriptionSummaryRoute);
    }

    return PrimaryButton(
      text: buttonText,
      onPressed: onPressed,
      backgroundColor: backgroundColor,
    );
  }

  String _formatMealType(String mealType) {
    return mealType.substring(0, 1).toUpperCase() + mealType.substring(1);
  }

  String _formatDay(String day) {
    return day.substring(0, 3).substring(0, 1).toUpperCase() +
        day.substring(1, 3);
  }
}
