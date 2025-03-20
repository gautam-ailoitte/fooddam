// lib/src/presentation/screens/subscription/meal_distributation_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/constants/app_route_constant.dart';
import 'package:foodam/core/layout/app_scaffold.dart';
import 'package:foodam/core/service/navigation_state_manager.dart';
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

class _MealDistributionScreenState extends State<MealDistributionScreen> with WidgetsBindingObserver {
  final DateFormatter _dateFormatter = DateFormatter();
  final NavigationStateManager _navigationManager = NavigationStateManager();
  
  int _totalMeals = 0;
  int _distributedMeals = 0;
  int _remainingMeals = 0;
  bool _allMealsDistributed = false;
  
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

  bool _isScreenInitialized = false;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Add this screen to navigation history
    _navigationManager.addToHistory(AppRoutes.mealDistribution);
    
    // Make sure we have the correct state
    _initializeScreenData();
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    if (!_isScreenInitialized) {
      _initializeScreenData();
    }
  }
  
  void _initializeScreenData() {
    // First check if we need to restore state
    final mealPlanCubit = context.read<MealPlanSelectionCubit>();
    final currentState = mealPlanCubit.state;
    
    // If we're not in the correct state, try to initialize from saved state
    if (currentState is! MealPlanDatesSelected && currentState is! MealPlanCompleted) {
      mealPlanCubit.initializeFromSavedState();
    }
    
    // Now get the updated state
    final updatedState = mealPlanCubit.state;
    
    if (updatedState is MealPlanDatesSelected) {
      _setupFromDatesState(updatedState);
      _isScreenInitialized = true;
    } else if (updatedState is MealPlanCompleted) {
      _setupFromCompletedState(updatedState);
      _isScreenInitialized = true;
    } else {
      // Still not in the right state, show error in build method
      _isScreenInitialized = false;
    }
  }
  
  void _setupFromDatesState(MealPlanDatesSelected state) {
    setState(() {
      _totalMeals = state.mealCount;
      _remainingMeals = _totalMeals;
      _availableDates = _generateDateRange(state.startDate, state.endDate);
      
      // Initialize meal distribution state
      context.read<MealDistributionCubit>().initializeDistribution(
        _totalMeals,
        state.startDate,
        state.endDate,
      );
    });
  }
  
  void _setupFromCompletedState(MealPlanCompleted state) {
    final distribution = state.mealPlanSelection.mealDistribution;
    
    // Get start and end date from saved state
    final startDate = _navigationManager.getSavedStartDate()!;
    final endDate = _navigationManager.getSavedEndDate()!;
    
    setState(() {
      _totalMeals = state.mealPlanSelection.totalMeals;
      _availableDates = _generateDateRange(startDate, endDate);
      
      // Rebuild selected dates from distribution
      _selectedDates.clear();
      _mealTypeAllocation.clear();
      
      distribution.forEach((mealType, distributions) {
        _selectedDates[mealType] = [];
        _mealTypeAllocation[mealType] = 0;
        
        for (var dist in distributions) {
          _selectedDates[mealType]!.add(dist.date);
          _mealTypeAllocation[mealType] = (_mealTypeAllocation[mealType] ?? 0) + 1;
        }
      });
      
      // Calculate distributed and remaining
      _distributedMeals = 0;
      _mealTypeAllocation.forEach((_, count) {
        _distributedMeals += count;
      });
      
      _remainingMeals = _totalMeals - _distributedMeals;
      _allMealsDistributed = _remainingMeals == 0;
      
      // Reinitialize the distribution cubit
      context.read<MealDistributionCubit>().initializeDistribution(
        _totalMeals,
        startDate,
        endDate,
      );
      
      // Add each distribution to the cubit
      distribution.forEach((mealType, distributions) {
        context.read<MealDistributionCubit>().updateMealTypeAllocation(
          mealType, 
          distributions.length
        );
        
        for (var dist in distributions) {
          context.read<MealDistributionCubit>().addMealDistribution(
            dist.mealType,
            dist.date,
            dist.mealId,
          );
        }
      });
    });
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
      onWillPop: () async {
        // Ensure state is preserved when going back
        return true;
      },
      body: BlocConsumer<MealPlanSelectionCubit, MealPlanSelectionState>(
        listener: (context, state) {
          if (state is MealPlanCompleted) {
            // Navigate to payment summary
            Navigator.pushNamed(context, AppRoutes.paymentSummary);
          } else if (state is MealPlanSelectionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, planState) {
          // Check if we're in the correct state
          if (!_isScreenInitialized) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Please complete previous steps first',
                    style: TextStyle(color: AppColors.error, fontSize: 18),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.planDuration),
                    child: const Text('Go to Plan Duration'),
                  ),
                ],
              ),
            );
          }
          
          // We're good to show the meal distribution screen
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
                  _buildProgressSection(),
                  
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
        },
      ),
    );
  }
  
  Widget _buildProgressSection() {
    // Get the plan name from the navigation manager
    final selectedPlan = _navigationManager.getSavedPlan();
    final startDate = _navigationManager.getSavedStartDate();
    final endDate = _navigationManager.getSavedEndDate();
    
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Plan summary
          if (selectedPlan != null) Text(
            'Plan: ${selectedPlan.name}',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (startDate != null && endDate != null) const SizedBox(height: 4),
          if (startDate != null && endDate != null) Text(
            'Duration: ${_dateFormatter.formatDate(startDate)} to ${_dateFormatter.formatDate(endDate)}',
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
                _allMealsDistributed 
                  ? 'All meals distributed!'
                  : 'Remaining: $_remainingMeals',
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
          child: _buildDateGrid(),
        ),
      ],
    );
  }
  
  Widget _buildMealTypeButton(String mealType, IconData icon) {
    final isSelected = _selectedMealType == mealType;
    final count = _mealTypeAllocation[mealType] ?? 0;
    
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedMealType = mealType;
          });
        },
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
    // Show status message when all meals are distributed but still allow interaction
    if (_allMealsDistributed) {
      return Stack(
        children: [
          GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _availableDates.length,
            itemBuilder: (context, index) => _buildDateGridItem(index),
          ),
          // Status overlay that doesn't block interaction
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'All meals distributed! You can still modify your selection.',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    }
    
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _availableDates.length,
      itemBuilder: (context, index) => _buildDateGridItem(index),
    );
  }
  
  Widget _buildDateGridItem(int index) {
    final date = _availableDates[index];
    final selectedDatesForType = _selectedDates[_selectedMealType] ?? [];
    
    final isSelected = selectedDatesForType.any((d) => 
        d.day == date.day && 
        d.month == date.month && 
        d.year == date.year
    );
    final isWeekend = date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
    
    return InkWell(
      onTap: () => _toggleDateSelection(date),
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
        // Enable the button as long as at least one meal is distributed
        onPressed: _distributedMeals > 0 
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
        _allMealsDistributed = false; // Update state flag
      } else {
        // Add the date if there are remaining meals
        if (_remainingMeals > 0) {
          _selectedDates[mealType] = [...selectedDatesForType, date];
          _mealTypeAllocation[mealType] = _mealTypeAllocation[mealType]! + 1;
          _remainingMeals--;
          
          // Check if all meals are now distributed
          if (_remainingMeals == 0) {
            _allMealsDistributed = true;
          }
        } else {
          // Show message but still allow modification of existing selections
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You have used all your meal allocations. Unselect some meals to make changes.'),
              backgroundColor: Colors.orange,
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
      _allMealsDistributed = false; // Update state flag
    });
  }
  
  void _finalizeMealDistribution() {
    // Convert the selected dates into MealDistribution objects
    final Map<String, List<MealDistribution>> distribution = {};
    
    _selectedDates.forEach((mealType, dates) {
      if (dates.isNotEmpty) {
        distribution[mealType] = dates.map((date) => 
          MealDistribution(
            mealType: mealType,
            date: date,
            mealId: null, // Will be assigned according to backend's weekly template
          ),
        ).toList();
      }
    });
    
    // Save to the MealDistributionCubit
    final cubit = context.read<MealDistributionCubit>();
    
    // First, reset the distribution
    cubit.resetDistribution();
    
    // Initialize with our new data
    final planState = context.read<MealPlanSelectionCubit>().state;
    DateTime startDate, endDate;
    
    if (planState is MealPlanDatesSelected) {
      startDate = planState.startDate;
      endDate = planState.endDate;
    } else {
      // Get from navigation manager
      startDate = _navigationManager.getSavedStartDate()!;
      endDate = _navigationManager.getSavedEndDate()!;
    }
    
    cubit.initializeDistribution(
      _totalMeals,
      startDate,
      endDate,
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
          null, // Meal ID will be assigned according to backend's weekly template
        );
      }
    });
    
    // Complete the distribution
    cubit.completeDistribution();
  }
}