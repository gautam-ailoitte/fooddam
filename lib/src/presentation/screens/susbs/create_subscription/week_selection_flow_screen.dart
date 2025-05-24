// lib/src/presentation/screens/subscription/week_selection_flow_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/constants/subscription_constants.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/widgets/primary_button.dart';
import 'package:foodam/core/widgets/secondary_button.dart';
import 'package:foodam/src/domain/entities/dish_entity.dart';
import 'package:foodam/src/presentation/cubits/subscription/planning/subscription_planning_cubit.dart';
import 'package:foodam/src/presentation/cubits/subscription/planning/subscription_planning_state.dart';
import 'package:foodam/src/presentation/screens/susbs/create_subscription/subscription_summary_screen.dart';
import 'package:intl/intl.dart';

class WeekSelectionFlowScreen extends StatefulWidget {
  const WeekSelectionFlowScreen({super.key});

  @override
  State<WeekSelectionFlowScreen> createState() =>
      _WeekSelectionFlowScreenState();
}

class _WeekSelectionFlowScreenState extends State<WeekSelectionFlowScreen>
    with TickerProviderStateMixin {
  PageController? _pageController;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _pageController?.dispose();
    _tabController?.dispose();
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
      body: BlocConsumer<SubscriptionPlanningCubit, SubscriptionPlanningState>(
        listener: (context, state) {
          if (state is SubscriptionPlanningError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is PlanningComplete) {
            // Navigate to summary screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const SubscriptionSummaryScreen(),
              ),
            );
          } else if (state is WeekSelectionActive) {
            // Initialize PageController if needed
            _pageController ??= PageController(
              initialPage: state.currentWeek - 1,
            );
          }
        },
        builder: (context, state) {
          if (state is SubscriptionPlanningLoading) {
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

          if (state is! WeekSelectionActive) {
            return const Center(child: Text('Unable to load meal selection'));
          }

          return Column(
            children: [
              // Week Progress Header
              _buildWeekProgressHeader(state),

              // Week Content
              Expanded(child: _buildWeekContent(state)),

              // Bottom Navigation
              _buildBottomNavigation(state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWeekProgressHeader(WeekSelectionActive state) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(AppDimensions.marginMedium),
      child: Column(
        children: [
          // Week indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(state.duration, (index) {
              final week = index + 1;
              final isCurrentWeek = week == state.currentWeek;
              final isValidWeek = state.isWeekValid(week);
              final isCompletedWeek = week < state.currentWeek && isValidWeek;

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor:
                      isCurrentWeek
                          ? AppColors.primary
                          : isCompletedWeek
                          ? AppColors.success
                          : isValidWeek
                          ? AppColors.success
                          : Colors.grey.shade300,
                  child:
                      isCompletedWeek
                          ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          )
                          : Text(
                            '$week',
                            style: TextStyle(
                              color:
                                  isCurrentWeek || isValidWeek
                                      ? Colors.white
                                      : Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),

          // Current week info
          Text(
            'Week ${state.currentWeek} of ${state.duration}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),

          // Meal selection progress
          Text(
            '${state.getSelectedMealCount(state.currentWeek)}/${state.mealPlan} meals selected',
            style: TextStyle(
              color:
                  state.isWeekValid(state.currentWeek)
                      ? AppColors.success
                      : AppColors.warning,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Progress bar
          LinearProgressIndicator(
            value:
                state.getSelectedMealCount(state.currentWeek) / state.mealPlan,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              state.isWeekValid(state.currentWeek)
                  ? AppColors.success
                  : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekContent(WeekSelectionActive state) {
    if (!state.isCurrentWeekLoaded) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading week data...'),
          ],
        ),
      );
    }

    final calculatedPlan = state.currentWeekPlan!;
    final weekStartDate = calculatedPlan.startDate;

    return Column(
      children: [
        // Week date range
        Container(
          padding: EdgeInsets.all(AppDimensions.marginMedium),
          color: AppColors.primaryLight.withOpacity(0.1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_today, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                '${DateFormat('MMM d').format(weekStartDate)} - ${DateFormat('MMM d, yyyy').format(calculatedPlan.endDate)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),

        // Meal type tabs
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            tabs:
                SubscriptionConstants.mealTypes.map((mealType) {
                  final count = _getMealTypeSelectionCount(state, mealType);
                  final available = _getMealTypeAvailableCount(
                    calculatedPlan,
                    mealType,
                  );

                  return Tab(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          SubscriptionConstants.mealTypeDisplayNames[mealType]!,
                        ),
                        Text(
                          '$count/$available',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ),

        // Meal grid
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children:
                SubscriptionConstants.mealTypes.map((mealType) {
                  return _buildMealTypeGrid(state, calculatedPlan, mealType);
                }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMealTypeGrid(
    WeekSelectionActive state,
    dynamic calculatedPlan,
    String mealType,
  ) {
    final dailyMeals = calculatedPlan.dailyMeals as List;

    return ListView.builder(
      padding: EdgeInsets.all(AppDimensions.marginMedium),
      itemCount: dailyMeals.length,
      itemBuilder: (context, index) {
        final dailyMeal = dailyMeals[index];
        final date = DateTime(
          dailyMeal.date.year,
          dailyMeal.date.month,
          dailyMeal.date.day,
        );

        final dayName = _getDayName(date.weekday);
        final dish = dailyMeal.slot.meal?.dishes[mealType] as Dish?;

        if (dish == null) {
          return const SizedBox.shrink();
        }

        final isSelected =
            state.mealSelections[state.currentWeek]?[date]?[mealType] ?? false;
        final selectedCount = state.getSelectedMealCount(state.currentWeek);
        final canSelect = isSelected || selectedCount < state.mealPlan;

        return _buildMealCard(
          date: date,
          dayName: dayName,
          dish: dish,
          mealType: mealType,
          isSelected: isSelected,
          canSelect: canSelect,
          onTap: () {
            if (canSelect) {
              context.read<SubscriptionPlanningCubit>().toggleMealSelection(
                week: state.currentWeek,
                date: date,
                mealType: mealType,
              );
            }
          },
          onDetailTap: () => _showMealDetail(context, dish, mealType, dayName),
        );
      },
    );
  }

  Widget _buildMealCard({
    required DateTime date,
    required String dayName,
    required Dish dish,
    required String mealType,
    required bool isSelected,
    required bool canSelect,
    required VoidCallback onTap,
    required VoidCallback onDetailTap,
  }) {
    final isToday = _isToday(date);

    return Card(
      margin: EdgeInsets.only(bottom: AppDimensions.marginMedium),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color:
              isSelected
                  ? AppColors.primary
                  : isToday
                  ? AppColors.accent
                  : Colors.transparent,
          width: isSelected || isToday ? 2 : 0,
        ),
      ),
      child: InkWell(
        onTap: canSelect ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.marginMedium),
          child: Row(
            children: [
              // Dish image placeholder
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? AppColors.primary.withOpacity(0.1)
                          : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        isSelected ? AppColors.primary : Colors.grey.shade300,
                  ),
                ),
                child: Icon(
                  _getMealIcon(mealType),
                  color: isSelected ? AppColors.primary : Colors.grey.shade600,
                  size: 24,
                ),
              ),
              SizedBox(width: AppDimensions.marginMedium),

              // Meal info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _capitalize(dayName),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isToday) ...[
                          const SizedBox(width: 8),
                          Container(
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
                                fontSize: 10,
                                color: AppColors.accent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dish.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (dish.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        dish.description,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Actions
              Column(
                children: [
                  // Detail button
                  IconButton(
                    onPressed: onDetailTap,
                    icon: const Icon(Icons.info_outline),
                    iconSize: 20,
                    color: AppColors.primary,
                  ),

                  // Selection checkbox
                  Checkbox(
                    value: isSelected,
                    onChanged: canSelect ? (_) => onTap() : null,
                    activeColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation(WeekSelectionActive state) {
    final canGoNext = state.currentWeek < state.duration;
    final canGoPrevious = state.currentWeek > 1;
    final isCurrentWeekValid = state.isWeekValid(state.currentWeek);

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
            // Validation message
            if (!isCurrentWeekValid) ...[
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
                        'Please select exactly ${state.mealPlan} meals to continue',
                        style: TextStyle(
                          color: AppColors.warning,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Navigation buttons
            Row(
              children: [
                if (canGoPrevious) ...[
                  Expanded(
                    child: SecondaryButton(
                      text: 'Previous Week',
                      onPressed: () {
                        context
                            .read<SubscriptionPlanningCubit>()
                            .previousWeek();
                      },
                    ),
                  ),
                  SizedBox(width: AppDimensions.marginMedium),
                ],

                Expanded(
                  child: PrimaryButton(
                    text: canGoNext ? 'Next Week' : 'Complete Planning',
                    onPressed:
                        isCurrentWeekValid
                            ? () {
                              context
                                  .read<SubscriptionPlanningCubit>()
                                  .nextWeek();
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

  void _showMealDetail(
    BuildContext context,
    Dish dish,
    String mealType,
    String dayName,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildMealDetailSheet(dish, mealType, dayName),
    );
  }

  Widget _buildMealDetailSheet(Dish dish, String mealType, String dayName) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.marginMedium),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(_getMealIcon(mealType), color: AppColors.primary),
                ),
                SizedBox(width: AppDimensions.marginMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$dayName ${SubscriptionConstants.mealTypeDisplayNames[mealType]}',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        dish.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            SizedBox(height: AppDimensions.marginMedium),

            // Description
            if (dish.description.isNotEmpty) ...[
              Text(
                dish.description,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              SizedBox(height: AppDimensions.marginMedium),
            ],

            // Dietary preferences
            if (dish.dietaryPreferences != null &&
                dish.dietaryPreferences!.isNotEmpty) ...[
              const Text(
                'Dietary Information',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children:
                    dish.dietaryPreferences!.map((pref) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _capitalize(pref),
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Helper methods
  int _getMealTypeSelectionCount(WeekSelectionActive state, String mealType) {
    final weekSelections = state.mealSelections[state.currentWeek] ?? {};
    int count = 0;
    for (final daySelections in weekSelections.values) {
      if (daySelections[mealType] == true) count++;
    }
    return count;
  }

  int _getMealTypeAvailableCount(dynamic calculatedPlan, String mealType) {
    final dailyMeals = calculatedPlan.dailyMeals as List;
    int count = 0;
    for (final dailyMeal in dailyMeals) {
      if (dailyMeal.slot.meal?.dishes[mealType] != null) count++;
    }
    return count;
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

  String _getDayName(int weekday) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[weekday - 1];
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
