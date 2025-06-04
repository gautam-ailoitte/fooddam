// lib/src/presentation/screens/subscription/enhanced_week_selection_flow_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/constants/subscription_constants.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/route/app_router.dart';
import 'package:foodam/core/widgets/primary_button.dart';
import 'package:foodam/core/widgets/secondary_button.dart';
import 'package:foodam/src/domain/entities/meal_plan_item.dart';
import 'package:foodam/src/presentation/screens/susbs/create_subscription/week_configuration_bottom_sheet.dart';

import '../../../cubits/subscription/week_selection/week_selection_cubit.dart';
import '../../../cubits/subscription/week_selection/week_selection_state.dart';

class EnhancedWeekSelectionFlowScreen extends StatefulWidget {
  const EnhancedWeekSelectionFlowScreen({super.key});

  @override
  State<EnhancedWeekSelectionFlowScreen> createState() =>
      _EnhancedWeekSelectionFlowScreenState();
}

class _EnhancedWeekSelectionFlowScreenState
    extends State<EnhancedWeekSelectionFlowScreen>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  final Map<String, bool> _isTogglingDay = {};
  final Map<String, bool> _isTogglingMealType = {};

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return PopScope(
      onPopInvoked: (didPop) {
        if (didPop) {
          Navigator.pushReplacementNamed(
            context,
            AppRouter.startSubscriptionPlanningRoute,
          );
        }
      },
      child: BlocConsumer<WeekSelectionCubit, WeekSelectionState>(
        listener: _handleStateChanges,
        builder: _buildScreenContent,
      ),
    );
  }

  void _handleStateChanges(BuildContext context, WeekSelectionState state) {
    // Handle any state-specific actions here
  }

  Widget _buildScreenContent(BuildContext context, WeekSelectionState state) {
    if (state is! WeekSelectionActive) {
      return _buildErrorScreen(context, state);
    }

    return _buildMainScreen(context, state);
  }

  Widget _buildErrorScreen(BuildContext context, WeekSelectionState state) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Meal Selection'),
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(
              context,
              AppRouter.startSubscriptionPlanningRoute,
            );
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 80, color: AppColors.error),
              SizedBox(height: AppSpacing.md),
              Text(
                'Unable to Load',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.error,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                'Unable to load meal selection',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SecondaryButton(
                    text: 'Start Over',
                    onPressed: () {
                      context.read<WeekSelectionCubit>().reset();
                      Navigator.pushReplacementNamed(
                        context,
                        AppRouter.startSubscriptionPlanningRoute,
                      );
                    },
                  ),
                  SizedBox(width: AppSpacing.md),
                  PrimaryButton(
                    text: 'Try Again',
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                        context,
                        AppRouter.startSubscriptionPlanningRoute,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainScreen(BuildContext context, WeekSelectionActive state) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildCompactAppBar(state),
      body: Column(
        children: [
          // Compact week progress
          _buildCompactWeekProgress(state),

          // Clickable meal type tabs
          _buildClickableMealTabs(state),

          // Main content area
          Expanded(child: _buildWeekContent(context, state)),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(context, state),
    );
  }

  PreferredSizeWidget _buildCompactAppBar(WeekSelectionActive state) {
    final validation = state.validateCurrentWeek();

    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      toolbarHeight: 50, // Reduced height
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          Navigator.pushReplacementNamed(
            context,
            AppRouter.startSubscriptionPlanningRoute,
          );
        },
      ),
      title: Row(
        children: [
          Text(
            'Week ${state.currentWeek} ',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const Spacer(),
          // Compact progress indicator
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRouter.packagesRoute);
            },
            child: const Text(
              "View Plans",
              style: TextStyle(color: Colors.white),
            ),
          ),
          // const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${validation.selectedMeals}/${validation.requiredMeals}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed:
              () => _showWeekConfigurationBottomSheet(
                context,
                state.currentWeek,
                state.planningData.dietaryPreference,
              ),
          icon: const Icon(Icons.settings, color: Colors.white, size: 20),
        ),
      ],
    );
  }

  Widget _buildCompactWeekProgress(WeekSelectionActive state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        border: Border(
          bottom: BorderSide(
            color: AppColors.primary.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Week indicators (compact)
          ...List.generate(4, (index) {
            final week = index + 1;
            final isConfigured = state.weekConfigs.containsKey(week);
            final isCurrentWeek = week == state.currentWeek;
            final isComplete =
                isConfigured && (state.weekConfigs[week]?.isComplete ?? false);

            return GestureDetector(
              onTap:
                  isConfigured
                      ? () => context.read<WeekSelectionCubit>().navigateToWeek(
                        week,
                      )
                      : null,
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                width: isCurrentWeek ? 24 : 20,
                height: isCurrentWeek ? 24 : 20,
                decoration: BoxDecoration(
                  color:
                      isCurrentWeek
                          ? AppColors.primary
                          : isComplete
                          ? AppColors.success
                          : isConfigured
                          ? AppColors.accent
                          : Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child:
                      isComplete
                          ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 12,
                          )
                          : Text(
                            '$week',
                            style: TextStyle(
                              color:
                                  isConfigured
                                      ? Colors.white
                                      : Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                ),
              ),
            );
          }),

          const Spacer(),

          // Add week or checkout button
          if (state.maxWeeksConfigured < 4 &&
              state.validateCurrentWeek().isValid)
            _buildAddWeekButton(state),
          //
          // // Show checkout button if any week is complete
          // if (context
          //     .read<WeekSelectionCubit>()
          //     .getCompletedWeeks()
          //     .isNotEmpty) ...[
          //   if (state.maxWeeksConfigured < 4 &&
          //       state.validateCurrentWeek().isValid)
          //     const SizedBox(width: 8),
          //   _buildCheckoutButton(),
          // ],
        ],
      ),
    );
  }

  Widget _buildAddWeekButton(WeekSelectionActive state) {
    return TextButton.icon(
      onPressed:
          () => _showWeekConfigurationBottomSheet(
            context,
            state.maxWeeksConfigured + 1,
            state.planningData.dietaryPreference,
          ),
      icon: Icon(Icons.add, size: 14, color: AppColors.primary),
      label: Text(
        '+Week ${state.maxWeeksConfigured + 1}',
        style: TextStyle(color: AppColors.primary, fontSize: 12),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
    );
  }

  Widget _buildCheckoutButton() {
    return TextButton.icon(
      onPressed: () async {
        final cubit = context.read<WeekSelectionCubit>();
        final currentState = cubit.state;

        if (currentState is WeekSelectionActive) {
          // Flexible checkout: Allow if at least one week is complete
          final completedWeeks = cubit.getCompletedWeeks();
          if (completedWeeks.isNotEmpty) {
            await AppRouter.navigateToCheckoutSummary(context, currentState);
          } else {
            _showValidationSnackBar(
              context,
              'Please complete at least one week before checkout',
            );
          }
        }
      },
      icon: Icon(Icons.shopping_cart, size: 14, color: AppColors.success),
      label: Text(
        'Checkout',
        style: TextStyle(color: AppColors.success, fontSize: 12),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
    );
  }

  Widget _buildClickableMealTabs(WeekSelectionActive state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        children:
            SubscriptionConstants.mealTypes.map((mealType) {
              final currentWeekSelections = state.getSelectionsForWeek(
                state.currentWeek,
              );
              final typeSelections =
                  currentWeekSelections
                      .where(
                        (selection) =>
                            selection.timing.toLowerCase() ==
                            mealType.toLowerCase(),
                      )
                      .length;

              final weekData = state.currentWeekData;
              final availableMeals =
                  weekData?.availableMeals
                      ?.where(
                        (meal) =>
                            meal.timing.toLowerCase() == mealType.toLowerCase(),
                      )
                      .length ??
                  0;

              final isToggling = _isTogglingMealType[mealType] ?? false;

              return Expanded(
                child: GestureDetector(
                  onTap:
                      isToggling ? null : () => _handleMealTypeToggle(mealType),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color:
                          typeSelections > 0
                              ? AppColors.primary.withOpacity(0.1)
                              : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            typeSelections > 0
                                ? AppColors.primary
                                : Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getMealIcon(mealType),
                          size: 16,
                          color:
                              typeSelections > 0
                                  ? AppColors.primary
                                  : Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        if (isToggling)
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                            ),
                          )
                        else
                          Text(
                            '$typeSelections/$availableMeals',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color:
                                  typeSelections > 0
                                      ? AppColors.primary
                                      : Colors.grey.shade600,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildWeekContent(BuildContext context, WeekSelectionActive state) {
    if (!state.isCurrentWeekConfigured) {
      return _buildWeekNotConfiguredState(state);
    }

    if (state.currentWeekData == null) {
      return _buildWeekLoadingState();
    }

    final weekData = state.currentWeekData!;
    if (!weekData.isValid || weekData.availableMeals?.isEmpty == true) {
      return _buildWeekErrorState(context, state);
    }

    return _buildDayBasedMealLayout(state);
  }

  Widget _buildDayBasedMealLayout(WeekSelectionActive state) {
    final weekData = state.currentWeekData!;
    final mealsByDay = _groupMealsByDay(weekData.availableMeals!);

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 16),
      itemCount: mealsByDay.keys.length + 1, // +1 for week header
      itemBuilder: (context, index) {
        // Show week header as first item
        if (index == 0) {
          return _buildWeekHeader(state);
        }

        // Show day rows
        final dayIndex = index - 1;
        final day = mealsByDay.keys.elementAt(dayIndex);
        final dayMeals = mealsByDay[day]!;

        return _buildDayRow(state, day, dayMeals);
      },
    );
  }

  Widget _buildDayRow(
    WeekSelectionActive state,
    String day,
    Map<String, MealPlanItem> dayMeals,
  ) {
    final currentWeekSelections = state.getSelectionsForWeek(state.currentWeek);
    final daySelections =
        currentWeekSelections
            .where(
              (selection) => selection.day.toLowerCase() == day.toLowerCase(),
            )
            .length;

    final maxMealsForDay = dayMeals.length;
    final isToggling = _isTogglingDay[day] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Day header with toggle
          GestureDetector(
            onTap: isToggling ? null : () => _handleDayToggle(day),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color:
                    daySelections > 0
                        ? AppColors.primary.withOpacity(0.05)
                        : Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color:
                        daySelections > 0
                            ? AppColors.primary
                            : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getShortDayName(day),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color:
                          daySelections > 0
                              ? AppColors.primary
                              : Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getFormattedDate(state, day),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  if (isToggling)
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            daySelections == maxMealsForDay
                                ? AppColors.success
                                : daySelections > 0
                                ? AppColors.warning
                                : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$daySelections/$maxMealsForDay',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color:
                              daySelections > 0
                                  ? Colors.white
                                  : Colors.grey.shade600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Meal cards row
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildMealCard(state, dayMeals['breakfast'], 'breakfast'),
                const SizedBox(width: 12),
                _buildMealCard(state, dayMeals['lunch'], 'lunch'),
                const SizedBox(width: 12),
                _buildMealCard(state, dayMeals['dinner'], 'dinner'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealCard(
    WeekSelectionActive state,
    MealPlanItem? item,
    String mealType,
  ) {
    if (item == null) {
      return Expanded(
        child: Container(
          height: 90,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Center(
            child: Text(
              'No ${mealType.toLowerCase()}',
              style: TextStyle(fontSize: 9, color: Colors.grey.shade500),
            ),
          ),
        ),
      );
    }

    final isSelected = state.isDishSelected(
      state.currentWeek,
      item.dishId,
      item.day,
      item.timing,
    );

    final validation = state.validateCurrentWeek();
    final canSelect = isSelected || validation.missingMeals > 0;

    return Expanded(
      child: GestureDetector(
        onTap: canSelect ? () => _handleMealSelection(state, item) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 90,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                // Full background image or placeholder
                Positioned.fill(
                  child:
                      item.imageUrl?.isNotEmpty == true
                          ? Image.network(
                            item.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildImagePlaceholder();
                            },
                          )
                          : _buildImagePlaceholder(),
                ),

                // Dark overlay for better text readability
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.6),
                        ],
                      ),
                    ),
                  ),
                ),

                // Selection overlay
                if (isSelected)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.2),
                      ),
                    ),
                  ),

                // Dish name text at bottom
                Positioned(
                  bottom: 4,
                  left: 4,
                  right: 20, // Leave space for info icon
                  child: Text(
                    item.dishName,
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 1.1,
                      shadows: [
                        Shadow(
                          offset: const Offset(0, 1),
                          blurRadius: 2,
                          color: Colors.black.withOpacity(0.8),
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Selection indicator
                if (isSelected)
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 10,
                      ),
                    ),
                  ),

                // Info button
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => _showMealDetails(item),
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.info_outline,
                        color: AppColors.primary,
                        size: 10,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: Icon(Icons.restaurant, size: 24, color: Colors.grey.shade400),
      ),
    );
  }

  Widget _buildWeekHeader(WeekSelectionActive state) {
    final weekData = state.currentWeekData;
    if (weekData?.calculatedPlan?.package == null) {
      return const SizedBox.shrink();
    }

    final package = weekData!.calculatedPlan!.package!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            package.name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            package.description,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Helper methods
  Map<String, Map<String, MealPlanItem>> _groupMealsByDay(
    List<MealPlanItem> meals,
  ) {
    final grouped = <String, Map<String, MealPlanItem>>{};

    for (final meal in meals) {
      if (!grouped.containsKey(meal.day)) {
        grouped[meal.day] = {};
      }
      grouped[meal.day]![meal.timing.toLowerCase()] = meal;
    }

    // Sort by day order
    final sortedGrouped = <String, Map<String, MealPlanItem>>{};
    const dayOrder = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];

    for (final day in dayOrder) {
      if (grouped.containsKey(day)) {
        sortedGrouped[day] = grouped[day]!;
      }
    }

    return sortedGrouped;
  }

  String _getShortDayName(String day) {
    switch (day.toLowerCase()) {
      case 'monday':
        return 'Mon';
      case 'tuesday':
        return 'Tue';
      case 'wednesday':
        return 'Wed';
      case 'thursday':
        return 'Thu';
      case 'friday':
        return 'Fri';
      case 'saturday':
        return 'Sat';
      case 'sunday':
        return 'Sun';
      default:
        return day.substring(0, 3);
    }
  }

  String _getFormattedDate(WeekSelectionActive state, String day) {
    // Calculate date for this day in current week
    final dayOffset = _getDayOffset(day);
    final weekStartDate = state.planningData.startDate.add(
      Duration(days: (state.currentWeek - 1) * 7),
    );
    final date = weekStartDate.add(Duration(days: dayOffset));

    // Format as "2 Jun" instead of "2/6"
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} ${months[date.month - 1]}';
  }

  int _getDayOffset(String day) {
    switch (day.toLowerCase()) {
      case 'monday':
        return 0;
      case 'tuesday':
        return 1;
      case 'wednesday':
        return 2;
      case 'thursday':
        return 3;
      case 'friday':
        return 4;
      case 'saturday':
        return 5;
      case 'sunday':
        return 6;
      default:
        return 0;
    }
  }

  IconData _getMealIcon(String mealType) {
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

  // Event handlers
  Future<void> _handleMealTypeToggle(String mealType) async {
    setState(() {
      _isTogglingMealType[mealType] = true;
    });

    try {
      await context.read<WeekSelectionCubit>().toggleMealType(mealType);
    } finally {
      if (mounted) {
        setState(() {
          _isTogglingMealType[mealType] = false;
        });
      }
    }
  }

  Future<void> _handleDayToggle(String day) async {
    setState(() {
      _isTogglingDay[day] = true;
    });

    try {
      await context.read<WeekSelectionCubit>().toggleDayMeals(day);
    } finally {
      if (mounted) {
        setState(() {
          _isTogglingDay[day] = false;
        });
      }
    }
  }

  void _handleMealSelection(WeekSelectionActive state, MealPlanItem item) {
    final packageId = state.currentWeekData?.packageId ?? '';
    context.read<WeekSelectionCubit>().toggleMealSelection(
      week: state.currentWeek,
      item: item,
      packageId: packageId,
    );
  }

  void _showMealDetails(MealPlanItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildMealDetailsModal(item),
    );
  }

  Widget _buildMealDetailsModal(MealPlanItem item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7, // Increased from 0.6
        maxChildSize: 0.9, // Increased from 0.8
        minChildSize: 0.5, // Increased from 0.4
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Large image section
              Container(
                height: 200, // Dedicated space for image
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child:
                      item.imageUrl?.isNotEmpty == true
                          ? Image.network(
                            item.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildLargeImagePlaceholder();
                            },
                          )
                          : _buildLargeImagePlaceholder(),
                ),
              ),

              // Content section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with close button
                      Row(
                        children: [
                          Icon(
                            _getMealIcon(item.timing),
                            color: AppColors.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${item.formattedDay} ${item.formattedTiming}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.dishName,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              Icons.close,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Scrollable content
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (item.dishDescription.isNotEmpty) ...[
                                Text(
                                  'Description',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  item.dishDescription,
                                  style: TextStyle(
                                    fontSize: 16,
                                    height: 1.5,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],

                              if (item.dietaryPreferences.isNotEmpty) ...[
                                Text(
                                  'Dietary Information',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  children:
                                      item.dietaryPreferences.map((pref) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.success
                                                .withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            border: Border.all(
                                              color: AppColors.success
                                                  .withOpacity(0.3),
                                            ),
                                          ),
                                          child: Text(
                                            pref,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.success,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                ),
                                const SizedBox(height: 20),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Helper method for large image placeholder in modal
  Widget _buildLargeImagePlaceholder() {
    return Container(
      color: Colors.grey.shade100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_menu, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          Text(
            'No image available',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Loading/error states
  Widget _buildWeekNotConfiguredState(WeekSelectionActive state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.settings, size: 80, color: AppColors.textSecondary),
            const SizedBox(height: 20),
            Text(
              'Configure Week ${state.currentWeek}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Set your dietary preference and meal plan for this week',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            PrimaryButton(
              text: 'Configure Week ${state.currentWeek}',
              onPressed:
                  () => _showWeekConfigurationBottomSheet(
                    context,
                    state.currentWeek,
                    state.planningData.dietaryPreference,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 20),
          const Text(
            'Loading week data...',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekErrorState(BuildContext context, WeekSelectionActive state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 20),
            Text(
              'Failed to load week data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Unable to load meal data for this week',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 30),
            PrimaryButton(
              text: 'Retry',
              onPressed:
                  () => context.read<WeekSelectionCubit>().retryCurrentWeek(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation(
    BuildContext context,
    WeekSelectionActive state,
  ) {
    final cubit = context.read<WeekSelectionCubit>();
    final hasCompletedWeeks = cubit.getCompletedWeeks().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
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
            // Previous Week
            if (state.canGoToPreviousWeek) ...[
              Expanded(
                child: SecondaryButton(
                  text: 'Previous Week',
                  onPressed: () => cubit.previousWeek(),
                ),
              ),
              const SizedBox(width: 16),
            ],

            // Checkout - Validate ALL configured weeks
            if (hasCompletedWeeks)
              Expanded(
                child: PrimaryButton(
                  text: 'Checkout',
                  icon: Icons.shopping_cart,
                  onPressed: () => _validateAndCheckout(context, state, cubit),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Validate ALL configured weeks before proceeding to checkout
  void _validateAndCheckout(
    BuildContext context,
    WeekSelectionActive state,
    WeekSelectionCubit cubit,
  ) async {
    // Get all configured weeks
    final configuredWeeks = state.weekConfigs.keys.toList()..sort();

    // Find incomplete weeks
    final incompleteWeeks = <int>[];
    for (final week in configuredWeeks) {
      final config = state.weekConfigs[week]!;
      if (!config.isComplete) {
        incompleteWeeks.add(week);
      }
    }

    // Block checkout if any configured week is incomplete
    if (incompleteWeeks.isNotEmpty) {
      _showIncompleteWeeksValidation(context, incompleteWeeks);
      return;
    }

    // All configured weeks are complete - proceed to checkout
    final currentState = cubit.state;
    if (currentState is WeekSelectionActive) {
      await AppRouter.navigateToCheckoutSummary(context, currentState);
    }
  }

  /// Show validation message for incomplete weeks
  void _showIncompleteWeeksValidation(
    BuildContext context,
    List<int> incompleteWeeks,
  ) {
    String message;

    if (incompleteWeeks.length == 1) {
      message = 'Complete Week ${incompleteWeeks.first} before checkout';
    } else if (incompleteWeeks.length == 2) {
      message =
          'Complete Weeks ${incompleteWeeks.join(' and ')} before checkout';
    } else {
      final lastWeek = incompleteWeeks.removeLast();
      message =
          'Complete Weeks ${incompleteWeeks.join(', ')} and $lastWeek before checkout';
    }

    _showValidationSnackBar(context, message);
  }

  void _showValidationSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.warning,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }
  // void _showValidationSnackBar(BuildContext context, String message) {
  //   ScaffoldMessenger.of(context).clearSnackBars();
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text(message),
  //       backgroundColor: AppColors.warning,
  //       behavior: SnackBarBehavior.floating,
  //       duration: const Duration(seconds: 2),
  //     ),
  //   );
  // }

  Future<void> _showWeekConfigurationBottomSheet(
    BuildContext context,
    int week,
    String defaultDietaryPreference,
  ) async {
    final result = await WeekConfigurationBottomSheet.show(
      context,
      week: week,
      defaultDietaryPreference: defaultDietaryPreference,
    );

    if (result == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Week $week configured successfully!'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
