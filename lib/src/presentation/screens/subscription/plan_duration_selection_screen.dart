// lib/src/presentation/screens/subscription/plan_duration_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/constants/string_constants.dart';
import 'package:foodam/core/layout/app_scaffold.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/widgets/app_button.dart';
import 'package:foodam/core/widgets/app_card.dart';
import 'package:foodam/src/presentation/cubits/meal_plan/meal_plan_cubit.dart';
import 'package:foodam/src/presentation/cubits/meal_plan/meal_plan_state.dart';
import 'package:foodam/src/presentation/utlis/date_formatter.dart';
import 'package:foodam/src/presentation/utlis/plan_duration_calcluator.dart';
import 'package:table_calendar/table_calendar.dart';

class PlanDurationScreen extends StatefulWidget {
  const PlanDurationScreen({super.key});

  @override
  State<PlanDurationScreen> createState() => _PlanDurationScreenState();
}

class _PlanDurationScreenState extends State<PlanDurationScreen> {
  final DateFormatter _dateFormatter = DateFormatter();
  final PlanDurationCalculator _durationCalculator = PlanDurationCalculator();
  
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
  
  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now().add(const Duration(days: 1));
    
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

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: StringConstants.planDuration,
      body: BlocConsumer<MealPlanSelectionCubit, MealPlanSelectionState>(
        listener: (context, state) {
          if (state is MealPlanDatesSelected) {
            Navigator.pushNamed(context, '/meal-distribution');
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
          if (state is MealPlanTypeSelected || state is MealPlanDurationSelected) {
            final selectedPlan = state is MealPlanTypeSelected 
                ? state.selectedPlan 
                : (state as MealPlanDurationSelected).selectedPlan;
                
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
          }
          
          // If state is not the expected one, show error
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
                  'Error: Please select a plan first',
                  style: TextStyle(color: AppColors.error),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Go Back'),
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
    // Note: We need to pass both meal count and duration separately
    mealPlanCubit.selectMealCountAndDuration(
      _selectedMealOption!['count'],
      _selectedDurationOption!['days'],
    );
    
    // Store dates in the state
    mealPlanCubit.selectDates(_startDate, _endDate);
  }
}