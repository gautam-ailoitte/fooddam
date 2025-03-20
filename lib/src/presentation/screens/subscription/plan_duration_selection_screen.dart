// lib/src/presentation/screens/subscription/plan_duration_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/constants/app_route_constant.dart';
import 'package:foodam/core/constants/string_constants.dart';
import 'package:foodam/core/layout/app_scaffold.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/service/navigation_state_manager.dart';
import 'package:foodam/core/widgets/app_button.dart';
import 'package:foodam/core/widgets/app_card.dart';
import 'package:foodam/src/presentation/cubits/meal_plan/meal_plan_cubit.dart';
import 'package:foodam/src/presentation/cubits/meal_plan/meal_plan_state.dart';
import 'package:foodam/src/presentation/utlis/date_formatter.dart';
import 'package:table_calendar/table_calendar.dart';

class PlanDurationScreen extends StatefulWidget {
  const PlanDurationScreen({super.key});

  @override
  State<PlanDurationScreen> createState() => _PlanDurationScreenState();
}

class _PlanDurationScreenState extends State<PlanDurationScreen> with WidgetsBindingObserver {
  final DateFormatter _dateFormatter = DateFormatter();
  final NavigationStateManager _navigationManager = NavigationStateManager();
  
  late DateTime _startDate;
  late DateTime _endDate;
  DateTime _focusedDay = DateTime.now();
  
  // Available meal counts - these would come from backend
  final List<Map<String, dynamic>> _mealCountOptions = [
    {'count': 10, 'name': '10 Meal Plan'},
    {'count': 15, 'name': '15 Meal Plan'},
    {'count': 21, 'name': '21 Meal Plan'},
    {'count': 28, 'name': '28 Meal Plan'},
  ];
  
  // Available durations - these would come from backend
  final List<Map<String, dynamic>> _durationOptions = [
    {'days': 7, 'name': '7 Days'},
    {'days': 14, 'name': '14 Days'},
    {'days': 28, 'name': '28 Days'},
  ];
  
  // Selected options
  Map<String, dynamic>? _selectedMealOption;
  Map<String, dynamic>? _selectedDurationOption;
  
  bool _isScreenInitialized = false;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Add this screen to navigation history
    _navigationManager.addToHistory(AppRoutes.planDuration);
    
    _startDate = DateTime.now().add(const Duration(days: 1));
    _endDate = _startDate.add(const Duration(days: 6)); // Default to 7 days
    
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
    if (currentState is! MealPlanTypeSelected && 
        currentState is! MealPlanDurationSelected && 
        currentState is! MealPlanDatesSelected &&
        currentState is! MealPlanCompleted) {
      mealPlanCubit.initializeFromSavedState();
    }
    
    // Now get the updated state and initialize our local state from it
    final updatedState = mealPlanCubit.state;
    
    if (updatedState is MealPlanTypeSelected) {
      // We're good, just use defaults
      _restoreDefaultSelections();
      _isScreenInitialized = true;
    } else if (updatedState is MealPlanDurationSelected) {
      _restoreFromDurationState(updatedState);
      _isScreenInitialized = true;
    } else if (updatedState is MealPlanDatesSelected) {
      _restoreFromDatesState(updatedState);
      _isScreenInitialized = true;
    } else if (updatedState is MealPlanCompleted) {
      _restoreFromCompletedState();
      _isScreenInitialized = true;
    } else {
      // Still not in the right state, show error in build method
      _isScreenInitialized = false;
    }
  }
  
  void _restoreDefaultSelections() {
    // Set default selections
    if (_mealCountOptions.isNotEmpty) {
      _selectedMealOption = _mealCountOptions.first;
    }
    
    if (_durationOptions.isNotEmpty) {
      _selectedDurationOption = _durationOptions.first;
      
      // Calculate end date based on duration
      final durationDays = _selectedDurationOption!['days'];
      _endDate = _startDate.add(Duration(days: durationDays - 1)); // -1 because start date is inclusive
    }
  }
  
  void _restoreFromDurationState(MealPlanDurationSelected state) {
    // Find matching meal count option
    for (var option in _mealCountOptions) {
      if (option['count'] == state.mealCount) {
        _selectedMealOption = option;
        break;
      }
    }
    
    // Find matching duration option
    for (var option in _durationOptions) {
      if (option['days'] == state.durationDays) {
        _selectedDurationOption = option;
        break;
      }
    }
    
    // If we have saved dates, restore them
    final savedStartDate = _navigationManager.getSavedStartDate();
    final savedEndDate = _navigationManager.getSavedEndDate();
    
    if (savedStartDate != null && savedEndDate != null) {
      _startDate = savedStartDate;
      _endDate = savedEndDate;
    } else {
      // Otherwise calculate end date based on duration
      final durationDays = _selectedDurationOption!['days'];
      _endDate = _startDate.add(Duration(days: durationDays - 1));
    }
  }
  
  void _restoreFromDatesState(MealPlanDatesSelected state) {
    // Find matching meal count option
    for (var option in _mealCountOptions) {
      if (option['count'] == state.mealCount) {
        _selectedMealOption = option;
        break;
      }
    }
    
    // Find matching duration option
    for (var option in _durationOptions) {
      if (option['days'] == state.durationDays) {
        _selectedDurationOption = option;
        break;
      }
    }
    
    // Restore dates
    _startDate = state.startDate;
    _endDate = state.endDate;
  }
  
  void _restoreFromCompletedState() {
    // Get values from navigation manager
    final savedMealCount = _navigationManager.getSavedMealCount();
    final savedDurationDays = _navigationManager.getSavedDurationDays();
    final savedStartDate = _navigationManager.getSavedStartDate();
    final savedEndDate = _navigationManager.getSavedEndDate();
    
    if (savedMealCount != null) {
      // Find matching meal count option
      for (var option in _mealCountOptions) {
        if (option['count'] == savedMealCount) {
          _selectedMealOption = option;
          break;
        }
      }
    }
    
    if (savedDurationDays != null) {
      // Find matching duration option
      for (var option in _durationOptions) {
        if (option['days'] == savedDurationDays) {
          _selectedDurationOption = option;
          break;
        }
      }
    }
    
    // Restore dates
    if (savedStartDate != null && savedEndDate != null) {
      _startDate = savedStartDate;
      _endDate = savedEndDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: StringConstants.planDuration,
      body: BlocConsumer<MealPlanSelectionCubit, MealPlanSelectionState>(
        listener: (context, state) {
          if (state is MealPlanDatesSelected) {
            Navigator.pushNamed(context, AppRoutes.mealDistribution);
          } else if (state is MealPlanSelectionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
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
                    'Please select a plan first',
                    style: TextStyle(color: AppColors.error, fontSize: 18),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.planSelection),
                    child: const Text('Go to Plan Selection'),
                  ),
                ],
              ),
            );
          }
          
          final selectedPlan = _navigationManager.getSavedPlan();
          if (selectedPlan == null) {
            return Center(
              child: Text(
                'Error: No plan selected',
                style: TextStyle(color: AppColors.error),
              ),
            );
          }
                
          return SingleChildScrollView(
            padding: AppSpacing.pagePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Plan summary card
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected Plan',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        selectedPlan.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        selectedPlan.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                
                AppSpacing.vLg,
                
                // Number of meals selection
                Text(
                  'How many meals do you want?',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose the number of meals for your plan',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                
                _buildMealCountOptions(),
                
                AppSpacing.vLg,
                
                // Plan duration selection
                Text(
                  'Select Plan Duration',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose how long your plan will run',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                
                _buildDurationOptions(),
                
                AppSpacing.vLg,
                
                // Date selection
                Text(
                  'When do you want to start?',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _selectedDurationOption != null 
                      ? 'Your plan will run for ${_selectedDurationOption!['days']} days from the selected start date'
                      : 'Select a start date for your meal plan',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                
                _buildCalendar(),
                
                AppSpacing.vLg,
                
                // Selected summary
                if (_selectedMealOption != null && _selectedDurationOption != null) ...[
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Plan Summary',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Plan type
                        Row(
                          children: [
                            const Icon(
                              Icons.restaurant_menu,
                              size: 20,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Plan Type',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    selectedPlan.name,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Meal counts
                        Row(
                          children: [
                            const Icon(
                              Icons.lunch_dining,
                              size: 20,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Meal Plan',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    '${_selectedMealOption!['name']}',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Duration
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 20,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Duration',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    '${_selectedDurationOption!['name']}',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Date range
                        Row(
                          children: [
                            const Icon(
                              Icons.date_range,
                              size: 20,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Date Range',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    '${_dateFormatter.formatDate(_startDate)} to ${_dateFormatter.formatDate(_endDate)}',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
                
                AppSpacing.vXl,
                
                // Continue button
                AppButton(
                  label: 'Continue to Meal Distribution',
                  onPressed: (_selectedMealOption != null && _selectedDurationOption != null) 
                      ? _continueToMealDistribution 
                      : null,
                  isFullWidth: true,
                  buttonType: AppButtonType.primary,
                  buttonSize: AppButtonSize.large,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMealCountOptions() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _mealCountOptions.length,
      itemBuilder: (context, index) {
        final option = _mealCountOptions[index];
        final isSelected = _selectedMealOption == option;
        
        return InkWell(
          onTap: () {
            setState(() {
              _selectedMealOption = option;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.divider,
                width: isSelected ? 2 : 1,
              ),
              color: isSelected ? AppColors.primaryLight.withOpacity(0.1) : Colors.white,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${option['count']}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Meals',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDurationOptions() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _durationOptions.length,
      itemBuilder: (context, index) {
        final option = _durationOptions[index];
        final isSelected = _selectedDurationOption == option;
        
        return InkWell(
          onTap: () {
            setState(() {
              _selectedDurationOption = option;
              
              // Update end date based on duration
              final durationDays = option['days'];
              _endDate = _startDate.add(Duration(days: durationDays - 1));
            });
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.divider,
                width: isSelected ? 2 : 1,
              ),
              color: isSelected ? AppColors.primaryLight.withOpacity(0.1) : Colors.white,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${option['days']}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Days',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCalendar() {
    return AppCard(
      child: TableCalendar(
        firstDay: DateTime.now(),
        lastDay: DateTime.now().add(const Duration(days: 90)),
        focusedDay: _focusedDay,
        startingDayOfWeek: StartingDayOfWeek.monday,
        calendarFormat: CalendarFormat.month,
        availableCalendarFormats: const {CalendarFormat.month: 'Month'},
        
        // Selected date range
        selectedDayPredicate: (day) => isSameDay(day, _startDate),
        
        // Callbacks
        onDaySelected: (selectedDay, focusedDay) {
          // Ensure selected day is not before today
          if (selectedDay.isBefore(DateTime.now())) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Cannot select a date in the past'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
          
          setState(() {
            _startDate = selectedDay;
            _focusedDay = focusedDay;
            
            // Update end date based on selected start date and duration
            if (_selectedDurationOption != null) {
              final durationDays = _selectedDurationOption!['days'];
              _endDate = _startDate.add(Duration(days: durationDays - 1));
            }
          });
        },
        
        // Style
        headerStyle: HeaderStyle(
          titleCentered: true,
          formatButtonVisible: false,
          titleTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          weekendTextStyle: TextStyle(color: AppColors.textPrimary),
          holidayTextStyle: TextStyle(color: AppColors.textPrimary),
          
          // Selection styling
          selectedDecoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          // Highlight start date to end date range
          rangeHighlightColor: AppColors.primaryLight.withOpacity(0.2),
          // Disable dates before today
          disabledTextStyle: TextStyle(
            color: AppColors.textTertiary,
          ),
        ),
      ),
    );
  }

  void _continueToMealDistribution() {
    if (_selectedMealOption == null || _selectedDurationOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both meal count and duration'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Store meal count in the state
    final mealPlanCubit = context.read<MealPlanSelectionCubit>();
    
    // Call the cubit method with the proper values
    mealPlanCubit.selectMealCountAndDuration(
      _selectedMealOption!['count'],
      _selectedDurationOption!['days'],
    );
    
    // Store dates in the state
    mealPlanCubit.selectDates(_startDate, _endDate);
  }
}