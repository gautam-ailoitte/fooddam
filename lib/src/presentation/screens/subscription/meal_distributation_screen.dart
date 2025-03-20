// lib/src/presentation/screens/subscription/meal_distributation_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/constants/string_constants.dart';
import 'package:foodam/core/layout/app_scaffold.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/widgets/app_button.dart';
import 'package:foodam/core/widgets/app_card.dart';
import 'package:foodam/src/domain/entities/meal_plan_selection.dart';
import 'package:foodam/src/presentation/cubits/meal_distributaion/meal_distributaion_cubit.dart';
import 'package:foodam/src/presentation/cubits/meal_distributaion/meal_distributaion_state.dart';
import 'package:foodam/src/presentation/cubits/meal_plan/meal_plan_cubit.dart';
import 'package:foodam/src/presentation/cubits/meal_plan/meal_plan_state.dart';
import 'package:foodam/src/presentation/utlis/date_formatter.dart';

class MealDistributionScreen extends StatefulWidget {
  const MealDistributionScreen({super.key});

  @override
  State<MealDistributionScreen> createState() => _MealDistributionScreenState();
}

class _MealDistributionScreenState extends State<MealDistributionScreen> {
  final DateFormatter _dateFormatter = DateFormatter();
  
  int _totalMeals = 0;
  int _distributedMeals = 0;
  int _remainingMeals = 0;
  
  // Meal type allocation
  final Map<String, int> _mealTypeAllocation = {
    'Breakfast': 0,
    'Lunch': 0,
    'Dinner': 0,
  };
  
  // Currently selected dates for each meal type
  final Map<String, List<DateTime>> _selectedDates = {
    'Breakfast': [],
    'Lunch': [],
    'Dinner': [],
  };
  
  // Date range for the plan
  late List<DateTime> _availableDates;
  
  // Selected meal type for adding
  String _selectedMealType = 'Breakfast';
  
  @override
  void initState() {
    super.initState();
    
    // Initialize with the plan selection data
    final planState = context.read<MealPlanSelectionCubit>().state;
    if (planState is MealPlanDatesSelected) {
      _totalMeals = planState.mealCount;
      _remainingMeals = _totalMeals;
      _availableDates = _generateDateRange(planState.startDate, planState.endDate);
      
      // Initialize meal distribution state
      context.read<MealDistributionCubit>().initializeDistribution(
        _totalMeals,
        planState.startDate,
        planState.endDate,
      );
    }
  }
  
  List<DateTime> _generateDateRange(DateTime start, DateTime end) {
    List<DateTime> dates = [];
    DateTime current = start;
    
    while (current.isBefore(end.add(const Duration(days: 1)))) {
      dates.add(current);
      current = current.add(const Duration(days: 1));
    }
    
    return dates;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Distribute Your Meals',
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
                return Column(
                  children: [
                    // Progress and summary section
                    _buildProgressSection(planState),
                    
                    // Main distribution section
                    Expanded(
                      child: _buildDistributionSection(),
                    ),
                    
                    // Continue button
                    _buildBottomActions(),
                  ],
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
  
  Widget _buildProgressSection(MealPlanDatesSelected planState) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Plan summary
          Text(
            'Plan: ${planState.selectedPlan.name}',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Duration: ${_dateFormatter.formatDate(planState.startDate)} to ${_dateFormatter.formatDate(planState.endDate)}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          
          // Progress indicator
          Row(
            children: [
              Text(
                'Total Meals: $_totalMeals',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                'Remaining: $_remainingMeals',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: _remainingMeals > 0 ? AppColors.textSecondary : AppColors.success,
                  fontWeight: _remainingMeals > 0 ? FontWeight.normal : FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          LinearProgressIndicator(
            value: (_totalMeals - _remainingMeals) / _totalMeals,
            backgroundColor: AppColors.backgroundDark,
            valueColor: AlwaysStoppedAnimation<Color>(
              _remainingMeals == 0 ? AppColors.success : AppColors.primary,
            ),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDistributionSection() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          // Tab bar
          TabBar(
            tabs: const [
              Tab(text: 'Distribute Meals'),
              Tab(text: 'Review Selection'),
            ],
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
          
          // Tab content
          Expanded(
            child: TabBarView(
              children: [
                _buildMealDistributionTab(),
                _buildReviewSelectionTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMealDistributionTab() {
    return Column(
      children: [
        // Meal type selector
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose meal type to add',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 12),
              
              Row(
                children: [
                  _buildMealTypeButton('Breakfast', Icons.breakfast_dining),
                  const SizedBox(width: 12),
                  _buildMealTypeButton('Lunch', Icons.lunch_dining),
                  const SizedBox(width: 12),
                  _buildMealTypeButton('Dinner', Icons.dinner_dining),
                ],
              ),
            ],
          ),
        ),
        
        // Dates grid
        Expanded(
          child: _remainingMeals > 0 
              ? _buildDateGrid()
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        size: 64,
                        color: AppColors.success,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'All meals have been distributed!',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You can review your selection in the next tab',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
  
  Widget _buildMealTypeButton(String mealType, IconData icon) {
    final isSelected = _selectedMealType == mealType;
    final count = _mealTypeAllocation[mealType] ?? 0;
    
    return Expanded(
      child: InkWell(
        onTap: _remainingMeals > 0 ? () {
          setState(() {
            _selectedMealType = mealType;
          });
        } : null,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.divider,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
              const SizedBox(height: 8),
              Text(
                mealType,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white.withOpacity(0.2) : AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$count selected',
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildDateGrid() {
    final selectedDatesForType = _selectedDates[_selectedMealType] ?? [];
    
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _availableDates.length,
      itemBuilder: (context, index) {
        final date = _availableDates[index];
        final isSelected = selectedDatesForType.any((d) => 
            d.day == date.day && 
            d.month == date.month && 
            d.year == date.year
        );
        final isWeekend = date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
        
        return InkWell(
          onTap: _remainingMeals > 0 ? () => _toggleDateSelection(date) : null,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected 
                  ? AppColors.primaryLight.withOpacity(0.2) 
                  : (isWeekend ? AppColors.backgroundLight : Colors.white),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.divider,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _dateFormatter.getShortWeekday(date),
                      style: TextStyle(
                        color: isWeekend ? AppColors.accent : AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (isSelected)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                  ],
                ),
                const Spacer(),
                Text(
                  date.day.toString(),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_dateFormatter.getMonthYear(date)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildReviewSelectionTab() {
    // Check if any meals have been distributed
    bool hasMeals = false;
    _mealTypeAllocation.forEach((_, count) {
      if (count > 0) hasMeals = true;
    });
    
    if (!hasMeals) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.info_outline,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No meals distributed yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Go to the Distribute Meals tab to start adding meals',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Meal Distribution',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Review your meal selection before continuing',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          
          // Breakfast section
          if (_mealTypeAllocation['Breakfast']! > 0)
            _buildMealTypeReviewSection('Breakfast', Icons.breakfast_dining),
          
          // Lunch section
          if (_mealTypeAllocation['Lunch']! > 0)
            _buildMealTypeReviewSection('Lunch', Icons.lunch_dining),
          
          // Dinner section
          if (_mealTypeAllocation['Dinner']! > 0)
            _buildMealTypeReviewSection('Dinner', Icons.dinner_dining),
        ],
      ),
    );
  }
  
  Widget _buildMealTypeReviewSection(String mealType, IconData icon) {
    final dates = _selectedDates[mealType] ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              mealType,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${dates.length} meals',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        // Dates list
        AppCard(
          margin: const EdgeInsets.only(bottom: 20),
          child: Column(
            children: dates.map((date) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Text(
                      _dateFormatter.formatDate(date),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _dateFormatter.getWeekday(date),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: 20,
                      ),
                      onPressed: () => _removeDateSelection(mealType, date),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
  
  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: AppButton(
        label: 'Continue',
        buttonType: AppButtonType.primary,
        buttonSize: AppButtonSize.large,
        isFullWidth: true,
        onPressed: _remainingMeals == 0 
            ? () => _finalizeMealDistribution()
            : null,
      ),
    );
  }
  
  void _toggleDateSelection(DateTime date) {
    setState(() {
      final mealType = _selectedMealType;
      final selectedDatesForType = _selectedDates[mealType] ?? [];
      
      // Check if this date is already selected for this meal type
      final alreadySelected = selectedDatesForType.any((d) => 
          d.day == date.day && 
          d.month == date.month && 
          d.year == date.year
      );
      
      if (alreadySelected) {
        // Remove the date
        _selectedDates[mealType] = selectedDatesForType.where((d) => 
            !(d.day == date.day && 
              d.month == date.month && 
              d.year == date.year)
        ).toList();
        
        _mealTypeAllocation[mealType] = _mealTypeAllocation[mealType]! - 1;
        _remainingMeals++;
      } else {
        // Add the date
        if (_remainingMeals > 0) {
          _selectedDates[mealType] = [...selectedDatesForType, date];
          _mealTypeAllocation[mealType] = _mealTypeAllocation[mealType]! + 1;
          _remainingMeals--;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You have used all your meal allocations'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
      
      _distributedMeals = _totalMeals - _remainingMeals;
    });
  }
  
  void _removeDateSelection(String mealType, DateTime date) {
    setState(() {
      final selectedDatesForType = _selectedDates[mealType] ?? [];
      
      // Remove the date
      _selectedDates[mealType] = selectedDatesForType.where((d) => 
          !(d.day == date.day && 
            d.month == date.month && 
            d.year == date.year)
      ).toList();
      
      _mealTypeAllocation[mealType] = _mealTypeAllocation[mealType]! - 1;
      _remainingMeals++;
      _distributedMeals = _totalMeals - _remainingMeals;
    });
  }
  
  void _finalizeMealDistribution() {
    // Convert the selected dates into MealDistribution objects
    final Map<String, List<MealDistribution>> distribution = {};
    
    _selectedDates.forEach((mealType, dates) {
      distribution[mealType] = dates.map((date) => 
        MealDistribution(
          mealType: mealType,
          date: date,
          mealId: null, // Will be assigned in the next step
        ),
      ).toList();
    });
    
    // Save to the MealDistributionCubit
    final cubit = context.read<MealDistributionCubit>();
    
    // First, reset the distribution
    cubit.resetDistribution();
    
    // Initialize with our new data
    final planState = context.read<MealPlanSelectionCubit>().state as MealPlanDatesSelected;
    cubit.initializeDistribution(
      _totalMeals,
      planState.startDate,
      planState.endDate,
    );
    
    // For each meal type, add the distributions
    distribution.forEach((mealType, distributions) {
      // First update the allocation
      cubit.updateMealTypeAllocation(mealType, distributions.length);
      
      // Then add each distribution
      for (final dist in distributions) {
        cubit.addMealDistribution(
          dist.mealType,
          dist.date,
          null, // Meal ID will be assigned in the next step
        );
      }
    });
    
    // Complete the distribution
    cubit.completeDistribution();
  }
}