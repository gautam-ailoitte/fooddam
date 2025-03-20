// lib/src/presentation/screens/plan/plan_duration_screen.dart
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
  String _selectedDuration = '7 days';
  late DateTime _startDate;
  late DateTime _endDate;
  DateTime _focusedDay = DateTime.now();
  final DateFormatter _dateFormatter = DateFormatter();
  final PlanDurationCalculator _durationCalculator = PlanDurationCalculator();
  
  final List<String> _durations = [
    '7 days',
    '14 days',
    '28 days',
  ];
  
  final Map<String, int> _durationMealCounts = {
    '7 days': 10,
    '14 days': 21,
    '28 days': 42,
  };

  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now().add(const Duration(days: 1));
    _endDate = _startDate.add(const Duration(days: 6)); // 7 days including start date
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
                          selectedPlan.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          selectedPlan.description,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '₹${selectedPlan.price.toStringAsFixed(0)}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  AppSpacing.vLg,
                  
                  // Duration selection
                  Text(
                    StringConstants.planDuration,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildDurationOptions(),
                  
                  AppSpacing.vLg,
                  
                  // Date selection
                  Text(
                    'Select Dates',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildCalendar(),
                  
                  AppSpacing.vLg,
                  
                  // Selected dates summary
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selected Dates',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Start Date',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    _dateFormatter.formatDate(_startDate),
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward,
                              color: AppColors.textSecondary,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'End Date',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    _dateFormatter.formatDate(_endDate),
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
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
                                    _selectedDuration,
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Total Meals',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    '${_durationMealCounts[_selectedDuration]} meals',
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
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
                  
                  AppSpacing.vXl,
                  
                  // Continue button
                  AppButton(
                    label: 'Continue',
                    onPressed: _continueToDurationSelection,
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
            child: Text(
              'Error: Please select a plan first',
              style: TextStyle(color: AppColors.error),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDurationOptions() {
    return Row(
      children: _durations.map((duration) {
        final isSelected = _selectedDuration == duration;
        final durationDays = _durationCalculator.getDurationDays(duration);
        final mealCount = _durationMealCounts[duration] ?? 0;
        
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedDuration = duration;
                _endDate = _durationCalculator.calculateEndDate2(
                  _startDate,
                  durationDays,
                );
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(8),
                border: isSelected
                    ? Border.all(color: AppColors.primary)
                    : Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  Text(
                    duration,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$mealCount meals',
                    style: TextStyle(
                      color: isSelected ? Colors.white.withOpacity(0.8) : AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendar() {
    return AppCard(
      child: TableCalendar(
        firstDay: DateTime.now(),
        lastDay: DateTime.now().add(const Duration(days: 365)),
        focusedDay: _focusedDay,
        startingDayOfWeek: StartingDayOfWeek.monday,
        calendarFormat: CalendarFormat.month,
        availableCalendarFormats: const {CalendarFormat.month: 'Month'},
        
        // Selected date range
        rangeStartDay: _startDate,
        rangeEndDay: _endDate,
        rangeSelectionMode: RangeSelectionMode.enforced,
        
        // Callbacks
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _startDate = selectedDay;
            _endDate = _durationCalculator.calculateEndDate2(
              _startDate,
              _durationCalculator.getDurationDays(_selectedDuration),
            );
            _focusedDay = focusedDay;
          });
        },
        onRangeSelected: (start, end, focusedDay) {
          if (start != null) {
            final durationDays = _durationCalculator.getDurationDays(_selectedDuration);
            
            setState(() {
              _startDate = start;
              // Calculate the end date based on the selected duration
              _endDate = _durationCalculator.calculateEndDate2(
                _startDate,
                durationDays,
              );
              _focusedDay = focusedDay;
            });
          }
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
          
          // Range styling
          rangeStartDecoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          rangeEndDecoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          rangeHighlightColor: AppColors.primaryLight.withOpacity(0.2),
          todayDecoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  void _continueToDurationSelection() {
    final durationDays = _durationCalculator.getDurationDays(_selectedDuration);
    final mealCount = _durationMealCounts[_selectedDuration] ?? 0;
    
    // Validate dates
    if (_startDate.isAfter(_endDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Start date cannot be after end date'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    
    // Validate duration
    final actualDays = _endDate.difference(_startDate).inDays + 1;
    if (actualDays != durationDays) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('The selected date range must be $durationDays days'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    
    // Store duration in the state
    final mealPlanCubit = context.read<MealPlanSelectionCubit>();
    
    if (mealPlanCubit.state is MealPlanTypeSelected) {
      mealPlanCubit.selectDuration(_selectedDuration, mealCount);
    }
    
    // Store dates in the state
    mealPlanCubit.selectDates(_startDate, _endDate);
  }
}