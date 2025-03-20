// lib/src/presentation/screens/plan/thali_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/constants/string_constants.dart';
import 'package:foodam/core/layout/app_scaffold.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/widgets/app_button.dart';
import 'package:foodam/core/widgets/app_card.dart';
import 'package:foodam/core/widgets/app_empty_state.dart';
import 'package:foodam/core/widgets/app_error_widget.dart';
import 'package:foodam/core/widgets/app_loading.dart';
import 'package:foodam/src/domain/entities/meal_entity.dart';
import 'package:foodam/src/domain/entities/meal_plan_selection.dart';
import 'package:foodam/src/presentation/cubits/meal_plan/meal_plan_cubit.dart';
import 'package:foodam/src/presentation/cubits/meal_plan/meal_plan_state.dart';
import 'package:foodam/src/presentation/cubits/thali_selection/thali_selection_cubit.dart';
import 'package:foodam/src/presentation/cubits/thali_selection/thali_selection_state.dart';
import 'package:foodam/src/presentation/utlis/date_formatter.dart';
import 'package:foodam/src/presentation/widgets/meal_card.dart';

class ThaliSelectionScreen extends StatefulWidget {
  const ThaliSelectionScreen({super.key});

  @override
  State<ThaliSelectionScreen> createState() => _ThaliSelectionScreenState();
}

class _ThaliSelectionScreenState extends State<ThaliSelectionScreen> {
  final DateFormatter _dateFormatter = DateFormatter();
  late MealPlanSelection _mealPlanSelection;
  int _currentStep = 0;
  int _totalSteps = 0;

  @override
  void initState() {
    super.initState();
    _initializeThaliSelection();
  }

  void _initializeThaliSelection() {
    final planState = context.read<MealPlanSelectionCubit>().state;
    if (planState is MealPlanCompleted) {
      _mealPlanSelection = planState.mealPlanSelection;
      
      // Initialize thali selection with the distribution
      context.read<ThaliSelectionCubit>().initializeThaliSelection(
        _mealPlanSelection.mealDistribution,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: StringConstants.selectThali,
      body: BlocConsumer<MealPlanSelectionCubit, MealPlanSelectionState>(
        listener: (context, planState) {
          if (planState is MealPlanCompleted) {
            _mealPlanSelection = planState.mealPlanSelection;
          }
        },
        builder: (context, planState) {
          if (planState is MealPlanCompleted) {
            return BlocConsumer<ThaliSelectionCubit, ThaliSelectionState>(
              listener: (context, state) {
                if (state is ThaliSelectionCompleted) {
                  // Navigate to payment summary
                  Navigator.pushNamed(context, '/payment-summary');
                } else if (state is ThaliSelecting) {
                  // Update progress
                  setState(() {
                    _currentStep++;
                  });
                }
              },
              builder: (context, state) {
                if (state is ThaliSelectionLoading) {
                  return const Center(
                    child: AppLoading(message: 'Loading available meals...'),
                  );
                } else if (state is ThaliSelectionError) {
                  return AppErrorWidget(
                    message: state.message,
                    retryText: StringConstants.retry,
                    onRetry: _initializeThaliSelection,
                  );
                } else if (state is ThaliSelecting) {
                  if (_totalSteps == 0) {
                    // Calculate total steps based on the selection slots
                    int totalSlots = 0;
                    _mealPlanSelection.mealDistribution.forEach((_, slots) {
                      totalSlots += slots.length;
                    });
                    _totalSteps = totalSlots;
                  }
                  
                  return _buildMealSelectionContent(state);
                } else if (state is ThaliSelectionCompleted) {
                  return const Center(
                    child: AppLoading(message: 'Preparing your order summary...'),
                  );
                }
                
                return AppEmptyState(
                  message: 'No meal selection data available.',
                  icon: Icons.restaurant_menu,
                  actionLabel: 'Go Back',
                  onAction: () => Navigator.pop(context),
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

  Widget _buildMealSelectionContent(ThaliSelecting state) {
    return Column(
      children: [
        // Progress indicator
        LinearProgressIndicator(
          value: _currentStep / _totalSteps,
          backgroundColor: AppColors.backgroundDark,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.success),
          minHeight: 4,
        ),
        
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step $_currentStep of $_totalSteps',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${(_currentStep / _totalSteps * 100).toInt()}% Complete',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        ),
        
        // Current slot info
        AppCard(
          margin: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${StringConstants.selectThaliFor} ${state.currentSlot.mealType}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Date: ${_dateFormatter.formatDate(state.currentSlot.date)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                'Day: ${_dateFormatter.getWeekday(state.currentSlot.date)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                StringConstants.selectThaliMessage,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        
        // Available meals
        Expanded(
          child: state.availableMeals.isEmpty
              ? AppEmptyState(
                  message: 'No meals available for this slot.',
                  icon: Icons.restaurant_menu,
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.availableMeals.length,
                  itemBuilder: (context, index) {
                    final meal = state.availableMeals[index];
                    return MealCard(
                      meal: meal,
                      isSelected: state.selectedMeal?.id == meal.id,
                      onSelect: () => _selectMeal(meal),
                    );
                  },
                ),
        ),
        
        // Action buttons
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Skip',
                  onPressed: _skipCurrentSlot,
                  buttonType: AppButtonType.outline,
                  buttonSize: AppButtonSize.medium,
                ),
              ),
              AppSpacing.hMd,
              Expanded(
                child: AppButton(
                  label: 'Select',
                  onPressed: state.selectedMeal != null
                      ? () => _confirmMealSelection(state.selectedMeal!.id)
                      : null,
                  buttonType: AppButtonType.primary,
                  buttonSize: AppButtonSize.medium,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _selectMeal(Meal meal) {
    setState(() {
      context.read<ThaliSelectionCubit>().state as ThaliSelecting;
    });
  }

  void _confirmMealSelection(String mealId) {
    context.read<ThaliSelectionCubit>().selectMeal(mealId);
  }

  void _skipCurrentSlot() {
    context.read<ThaliSelectionCubit>().skipCurrentSlot();
  }
}