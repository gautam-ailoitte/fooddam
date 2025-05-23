// lib/src/presentation/screens/meal_selection/meal_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/route/app_router.dart';
import 'package:foodam/core/widgets/primary_button.dart';
import 'package:foodam/core/widgets/secondary_button.dart';
import 'package:foodam/src/presentation/cubits/subscription/create_subcription/create_subcription_cubit.dart';
import 'package:foodam/src/presentation/cubits/subscription/create_subcription/create_subcription_state.dart';
import 'package:intl/intl.dart';

class MealSelectionScreen extends StatefulWidget {
  const MealSelectionScreen({super.key});

  @override
  State<MealSelectionScreen> createState() => _MealSelectionScreenState();
}

class _MealSelectionScreenState extends State<MealSelectionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentWeekIndex = 0;

  @override
  void initState() {
    super.initState();
    // Tab controller will be initialized based on number of weeks
    _initializeTabController();
  }

  void _initializeTabController() {
    final state = context.read<SubscriptionCreationCubit>().state;
    if (state is MealSelectionActive) {
      _tabController = TabController(
        length: state.weekSelections.length,
        vsync: this,
      );
      _tabController.addListener(() {
        if (!_tabController.indexIsChanging) {
          setState(() {
            _currentWeekIndex = _tabController.index;
          });
        }
      });
    } else {
      // Default to 1 tab if state is not ready
      _tabController = TabController(length: 1, vsync: this);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Meals'),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: BlocConsumer<SubscriptionCreationCubit, SubscriptionCreationState>(
        listener: (context, state) {
          if (state is SubscriptionCreationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is MealSelectionActive &&
              _tabController.length != state.weekSelections.length) {
            // Reinitialize tab controller if number of weeks changed
            _tabController.dispose();
            _initializeTabController();
          }
        },
        builder: (context, state) {
          if (state is CalculatedPlanLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading your meal plan...'),
                ],
              ),
            );
          }

          if (state is! MealSelectionActive) {
            return const Center(child: Text('Unable to load meal selection'));
          }

          return Column(
            children: [
              // Week tabs
              Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  isScrollable: state.weekSelections.length > 3,
                  indicatorColor: AppColors.primary,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  tabs:
                      state.weekSelections.map((week) {
                        return Tab(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Week ${week.weekNumber}'),
                              Text(
                                '${week.selectedMealCount}/${week.requiredMealCount}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      week.isValid
                                          ? AppColors.success
                                          : AppColors.warning,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                ),
              ),

              // Week content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children:
                      state.weekSelections.asMap().entries.map((entry) {
                        final weekIndex = entry.key;
                        final week = entry.value;
                        return _buildWeekView(context, state, week, weekIndex);
                      }).toList(),
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

  Widget _buildWeekView(
    BuildContext context,
    MealSelectionActive state,
    WeekSelection week,
    int weekIndex,
  ) {
    return Column(
      children: [
        // Week info header
        Container(
          padding: EdgeInsets.all(AppDimensions.marginMedium),
          color: AppColors.primaryLight.withOpacity(0.1),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${DateFormat('MMM d').format(week.weekStartDate)} - ${DateFormat('MMM d, yyyy').format(week.weekEndDate)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          week.isValid
                              ? AppColors.success.withOpacity(0.1)
                              : AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      week.isValid ? 'Complete' : 'Incomplete',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color:
                            week.isValid
                                ? AppColors.success
                                : AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: week.selectedMealCount / week.requiredMealCount,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  week.isValid ? AppColors.success : AppColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Select ${week.requiredMealCount} meals for this week',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),

        // Days grid
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(AppDimensions.marginMedium),
            itemCount: week.daySelections.length,
            itemBuilder: (context, dayIndex) {
              final day = week.daySelections[dayIndex];
              return _buildDayCard(
                context,
                state,
                week,
                weekIndex,
                day,
                dayIndex,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDayCard(
    BuildContext context,
    MealSelectionActive state,
    WeekSelection week,
    int weekIndex,
    DaySelection day,
    int dayIndex,
  ) {
    final isToday = _isToday(day.date);

    return Card(
      margin: EdgeInsets.only(bottom: AppDimensions.marginMedium),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isToday ? AppColors.primary : Colors.transparent,
          width: isToday ? 2 : 0,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.marginMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _capitalize(day.day),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isToday ? AppColors.primary : null,
                      ),
                    ),
                    Text(
                      DateFormat('MMMM d, yyyy').format(day.date),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                if (isToday)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Today',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Meal selections
            ...['breakfast', 'lunch', 'dinner'].map((mealType) {
              final meal = day.mealSelections[mealType];
              if (meal == null || !meal.isAvailable) {
                return const SizedBox.shrink();
              }

              return _buildMealOption(context, mealType, meal, () {
                context.read<SubscriptionCreationCubit>().toggleMealSelection(
                  weekIndex: weekIndex,
                  dayIndex: dayIndex,
                  mealType: mealType,
                );
              });
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildMealOption(
    BuildContext context,
    String mealType,
    MealSelection meal,
    VoidCallback onTap,
  ) {
    final Color mealColor = _getMealColor(mealType);

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: AppDimensions.marginSmall),
        padding: EdgeInsets.all(AppDimensions.marginSmall),
        decoration: BoxDecoration(
          color:
              meal.isSelected
                  ? mealColor.withOpacity(0.1)
                  : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: meal.isSelected ? mealColor : Colors.grey.shade300,
            width: meal.isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: meal.isSelected ? mealColor : Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getMealIcon(mealType),
                size: 18,
                color: meal.isSelected ? Colors.white : Colors.grey.shade600,
              ),
            ),
            SizedBox(width: AppDimensions.marginSmall),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _capitalize(mealType),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: meal.isSelected ? mealColor : Colors.grey.shade700,
                    ),
                  ),
                  if (meal.mealName != null)
                    Text(
                      meal.mealName!,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Checkbox(
              value: meal.isSelected,
              onChanged: (_) => onTap(),
              activeColor: mealColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActionBar(
    BuildContext context,
    MealSelectionActive state,
  ) {
    final allWeeksValid = state.isValid;
    final totalSelected = state.totalSelectedMeals;
    final totalRequired = state.requiredTotalMeals;

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
            // Summary
            Container(
              padding: EdgeInsets.all(AppDimensions.marginSmall),
              decoration: BoxDecoration(
                color:
                    allWeeksValid
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    allWeeksValid ? Icons.check_circle : Icons.info,
                    size: 20,
                    color:
                        allWeeksValid ? AppColors.success : AppColors.warning,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    allWeeksValid
                        ? 'All weeks complete!'
                        : 'Selected $totalSelected of $totalRequired meals',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color:
                          allWeeksValid ? AppColors.success : AppColors.warning,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppDimensions.marginMedium),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    text: 'Back',
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                SizedBox(width: AppDimensions.marginMedium),
                Expanded(
                  child: PrimaryButton(
                    text: 'Continue',
                    onPressed:
                        allWeeksValid
                            ? () => _proceedToCheckout(context, state)
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

  void _proceedToCheckout(BuildContext context, MealSelectionActive state) {
    Navigator.pushNamed(
      context,
      AppRouter.checkoutRoute,
      arguments: {
        'packageId': state.packageId,
        'startDate': state.startDate,
        'durationDays': state.durationDays,
        'personCount': state.personCount,
      },
    );
  }

  // Helper methods
  Color _getMealColor(String mealType) {
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

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
