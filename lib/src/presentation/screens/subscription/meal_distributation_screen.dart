// lib/src/presentation/screens/plan/meal_distribution_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/layout/app_scaffold.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/widgets/app_button.dart';
import 'package:foodam/core/widgets/app_card.dart';
import 'package:foodam/src/presentation/cubits/meal_distributaion/meal_distributaion_cubit.dart';
import 'package:foodam/src/presentation/cubits/meal_distributaion/meal_distributaion_state.dart';
import 'package:foodam/src/presentation/cubits/meal_plan/meal_plan_cubit.dart';
import 'package:foodam/src/presentation/cubits/meal_plan/meal_plan_state.dart';
import 'package:foodam/src/presentation/utlis/date_formatter.dart';
import 'package:foodam/src/presentation/utlis/plan_duration_calcluator.dart';

class MealDistributionScreen extends StatefulWidget {
  const MealDistributionScreen({super.key});

  @override
  State<MealDistributionScreen> createState() => _MealDistributionScreenState();
}

class _MealDistributionScreenState extends State<MealDistributionScreen> {
  final DateFormatter _dateFormatter = DateFormatter();
  final PlanDurationCalculator _durationCalculator = PlanDurationCalculator();
  
  final Map<String, int> _mealTypeAllocation = {
    'Breakfast': 0,
    'Lunch': 0,
    'Dinner': 0,
  };
  
  int _totalMeals = 0;
  int _allocatedMeals = 0;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize with the plan selection data
    final planState = context.read<MealPlanSelectionCubit>().state;
    if (planState is MealPlanDatesSelected) {
      _totalMeals = planState.mealCount;
      
      // Get default distribution
      final defaultDistribution = _durationCalculator.defaultMealDistribution(_totalMeals);
      setState(() {
        _mealTypeAllocation['Breakfast'] = defaultDistribution['Breakfast'] ?? 0;
        _mealTypeAllocation['Lunch'] = defaultDistribution['Lunch'] ?? 0;
        _mealTypeAllocation['Dinner'] = defaultDistribution['Dinner'] ?? 0;
        _calculateAllocatedMeals();
      });
      
      // Initialize meal distribution state
      context.read<MealDistributionCubit>().initializeDistribution(
        _totalMeals,
        planState.startDate,
        planState.endDate,
      );
    }
  }

  void _calculateAllocatedMeals() {
    _allocatedMeals = 0;
    _mealTypeAllocation.forEach((_, count) {
      _allocatedMeals += count;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Distribute Meals',
      body: BlocConsumer<MealPlanSelectionCubit, MealPlanSelectionState>(
        listener: (context, state) {
          if (state is MealPlanCompleted) {
            Navigator.pushNamed(context, '/thali-selection');
          }
        },
        builder: (context, planState) {
          if (planState is MealPlanDatesSelected) {
            return BlocConsumer<MealDistributionCubit, MealDistributionState>(
              listener: (context, state) {
                if (state is MealDistributionCompleted) {
                  // Update the meal plan selection with the completed distribution
                  context.read<MealPlanSelectionCubit>().completeMealPlanSelection(
                    state.distribution,
                  );
                } else if (state is MealDistributionError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              builder: (context, state) {
                return SingleChildScrollView(
                  padding: AppSpacing.pagePadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Plan summary card
                      _buildPlanSummary(planState),
                      
                      AppSpacing.vLg,
                      
                      // Meal allocation section
                      _buildMealAllocationSection(),
                      
                      AppSpacing.vLg,
                      
                      // Distribution by date section
                      _buildDistributionByDateSection(planState, state),
                      
                      AppSpacing.vXl,
                      
                      // Continue button
                      _buildContinueButton(state),
                    ],
                  ),
                );
              },
            );
          }
          
          // If state is not the expected one, show error
          return Center(
            child: Text(
              'Error: Please complete previous steps first',
              style: TextStyle(color: AppColors.error),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlanSummary(MealPlanDatesSelected planState) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            planState.selectedPlan.name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Duration: ${planState.duration}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Dates: ${_dateFormatter.formatShortDate(planState.startDate)} to ${_dateFormatter.formatShortDate(planState.endDate)}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Total Meals: ${planState.mealCount}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealAllocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Allocate Your Meals',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Distribute your ${_totalMeals} meals across breakfast, lunch, and dinner.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        
        // Progress indicator
        LinearProgressIndicator(
          value: _allocatedMeals / _totalMeals,
          backgroundColor: AppColors.backgroundDark,
          valueColor: AlwaysStoppedAnimation<Color>(
            _allocatedMeals == _totalMeals ? AppColors.success : AppColors.primary,
          ),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 8),
        Text(
          'Allocated: $_allocatedMeals / $_totalMeals meals',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: _allocatedMeals == _totalMeals 
                ? AppColors.success 
                : AppColors.textSecondary,
            fontWeight: _allocatedMeals == _totalMeals 
                ? FontWeight.bold 
                : FontWeight.normal,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Meal type allocation cards
        Row(
          children: [
            _buildMealTypeAllocationCard('Breakfast', Icons.breakfast_dining),
            _buildMealTypeAllocationCard('Lunch', Icons.lunch_dining),
            _buildMealTypeAllocationCard('Dinner', Icons.dinner_dining),
          ],
        ),
      ],
    );
  }

  Widget _buildMealTypeAllocationCard(String mealType, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: AppCard(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    mealType,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCountButton(
                    icon: Icons.remove,
                    onPressed: _mealTypeAllocation[mealType]! > 0
                        ? () => _updateMealAllocation(mealType, -1)
                        : null,
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${_mealTypeAllocation[mealType]}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  _buildCountButton(
                    icon: Icons.add,
                    onPressed: _allocatedMeals < _totalMeals
                        ? () => _updateMealAllocation(mealType, 1)
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: onPressed != null ? AppColors.primary : AppColors.backgroundDark,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: onPressed != null ? Colors.white : AppColors.textTertiary,
          size: 16,
        ),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(
          minWidth: 24,
          minHeight: 24,
        ),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildDistributionByDateSection(
    MealPlanDatesSelected planState,
    MealDistributionState state,
  ) {
    if (state is! MealDistributing) {
      return const SizedBox.shrink();
    }
    
    final dates = _durationCalculator.generateDatesBetween(
      planState.startDate,
      planState.endDate,
    );
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Distribute By Date',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Select dates for each meal type based on your allocation.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        
        // Meal type tabs
        DefaultTabController(
          length: 3,
          child: Column(
            children: [
              TabBar(
                tabs: [
                  _buildMealTypeTab('Breakfast', Icons.breakfast_dining, state.mealTypeAllocation['Breakfast'] ?? 0),
                  _buildMealTypeTab('Lunch', Icons.lunch_dining, state.mealTypeAllocation['Lunch'] ?? 0),
                  _buildMealTypeTab('Dinner', Icons.dinner_dining, state.mealTypeAllocation['Dinner'] ?? 0),
                ],
                indicatorColor: AppColors.primary,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
              ),
              SizedBox(
                height: 400, // Fixed height for the tab content
                child: TabBarView(
                  children: [
                    _buildDateSelectionList('Breakfast', dates, state),
                    _buildDateSelectionList('Lunch', dates, state),
                    _buildDateSelectionList('Dinner', dates, state),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMealTypeTab(String mealType, IconData icon, int allocation) {
    // Show allocated count and used count
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(mealType),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$allocation',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelectionList(
    String mealType, 
    List<DateTime> dates,
    MealDistributing state,
  ) {
    final mealTypeAllocation = state.mealTypeAllocation[mealType] ?? 0;
    final currentDistribution = state.currentDistribution[mealType] ?? [];
    final int usedCount = currentDistribution.length;
    final int remainingCount = mealTypeAllocation - usedCount;
    
    // Get list of dates that already have this meal type
    final selectedDates = currentDistribution.map((dist) => dist.date.day).toSet();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Counter of used slots
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Selected: $usedCount / $mealTypeAllocation',
            style: TextStyle(
              color: usedCount == mealTypeAllocation
                  ? AppColors.success
                  : AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        Expanded(
          child: ListView.builder(
            itemCount: dates.length,
            itemBuilder: (context, index) {
              final date = dates[index];
              final isSelected = selectedDates.contains(date.day);
              
              return ListTile(
                title: Text(
                  _dateFormatter.formatDate(date),
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  _dateFormatter.getWeekday(date),
                  style: TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),
                trailing: isSelected
                    ? IconButton(
                        icon: const Icon(Icons.check_circle, color: AppColors.success),
                        onPressed: () {
                          // Find the distribution for this date and remove it
                          final distIndex = currentDistribution.indexWhere(
                            (dist) => dist.date.day == date.day,
                          );
                          if (distIndex >= 0) {
                            context.read<MealDistributionCubit>().removeMealDistribution(
                              mealType,
                              distIndex,
                            );
                          }
                        },
                      )
                    : remainingCount > 0
                        ? IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () {
                              // Add this date to the distribution
                              context.read<MealDistributionCubit>().addMealDistribution(
                                mealType,
                                date,
                                null, // Meal will be selected later
                              );
                            },
                          )
                        : null,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton(MealDistributionState state) {
    final bool isComplete = _allocatedMeals == _totalMeals;
    
    return AppButton(
      label: 'Continue to Meal Selection',
      onPressed: isComplete
          ? () {
              // Validate that all allocated meals have been distributed
              if (state is MealDistributing) {
                int distributedTotal = 0;
                state.currentDistribution.forEach((_, list) {
                  distributedTotal += list.length;
                });
                
                if (distributedTotal == _totalMeals) {
                  context.read<MealDistributionCubit>().completeDistribution();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please distribute all allocated meals across dates'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            }
          : null,
      isFullWidth: true,
      buttonType: AppButtonType.primary,
      buttonSize: AppButtonSize.large,
    );
  }

  void _updateMealAllocation(String mealType, int change) {
    // Check if change is valid
    if (_mealTypeAllocation[mealType]! + change < 0) {
      return;
    }
    
    if (_allocatedMeals + change > _totalMeals) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot allocate more than total meals'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    
    setState(() {
      _mealTypeAllocation[mealType] = _mealTypeAllocation[mealType]! + change;
      _calculateAllocatedMeals();
    });
    
    // Update the meal distribution state
    context.read<MealDistributionCubit>().updateMealTypeAllocation(
      mealType,
      _mealTypeAllocation[mealType]!,
    );
  }
}