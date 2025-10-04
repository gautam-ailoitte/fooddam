// lib/src/presentation/screens/meal_planning/start_meal_planning_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/route/app_router.dart';
import 'package:foodam/core/widgets/primary_button.dart';
import 'package:foodam/core/widgets/secondary_button.dart';
import 'package:foodam/src/presentation/cubits/meal_planning/meal_planning_cubit.dart';

class StartMealPlanningScreen extends StatefulWidget {
  const StartMealPlanningScreen({super.key});

  @override
  State<StartMealPlanningScreen> createState() =>
      _StartMealPlanningScreenState();
}

class _StartMealPlanningScreenState extends State<StartMealPlanningScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MealPlanningCubit>().initializePlanning();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan Your Meals'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: BlocConsumer<MealPlanningCubit, MealPlanningState>(
        listener: (context, state) {
          if (state is MealPlanningError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is WeekGridLoaded) {
            Navigator.pushNamed(context, AppRouter.weekGridRoute);
          }
        },
        builder: (context, state) {
          if (state is StartPlanningActive) {
            return _buildPlanningForm(context, state);
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildPlanningForm(BuildContext context, StartPlanningActive state) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeSection(),
          SizedBox(height: AppSpacing.xl),
          _buildDateSelection(context, state),
          SizedBox(height: AppSpacing.lg),
          _buildDietaryPreferenceSection(context, state),
          SizedBox(height: AppSpacing.lg),
          _buildMealCountSection(context, state),
          SizedBox(height: AppSpacing.lg),
          _buildWeekCountSection(context, state), // NEW
          SizedBox(height: AppSpacing.xl),
          _buildActionButtons(context, state),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Start Your Meal Journey',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Text(
          'Choose your preferences and let us create the perfect meal plan for you.',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildDateSelection(BuildContext context, StartPlanningActive state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'When do you want to start?',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: AppSpacing.sm),
        InkWell(
          onTap: () => _selectStartDate(context),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              border: Border.all(
                color:
                    state.selectedStartDate != null
                        ? AppColors.primary
                        : Colors.grey.shade300,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color:
                      state.selectedStartDate != null
                          ? AppColors.primary
                          : Colors.grey,
                ),
                SizedBox(width: AppSpacing.sm),
                Text(
                  state.selectedStartDate != null
                      ? _formatDate(state.selectedStartDate!)
                      : 'Select start date (minimum 5 days from today)',
                  style: TextStyle(
                    color:
                        state.selectedStartDate != null
                            ? AppColors.textPrimary
                            : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDietaryPreferenceSection(
    BuildContext context,
    StartPlanningActive state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dietary Preference',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _buildDietaryOption(
                context,
                'Vegetarian',
                'vegetarian',
                state.selectedDietaryPreference,
                Icons.eco,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildDietaryOption(
                context,
                'Non-Vegetarian',
                'non-vegetarian',
                state.selectedDietaryPreference,
                Icons.restaurant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDietaryOption(
    BuildContext context,
    String title,
    String value,
    String? selectedValue,
    IconData icon,
  ) {
    final isSelected = selectedValue == value;

    return InkWell(
      onTap:
          () =>
              context.read<MealPlanningCubit>().updateDietaryPreference(value),
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.primary.withOpacity(0.1)
                  : Colors.grey.shade50,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : Colors.grey,
              size: 32,
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealCountSection(
    BuildContext context,
    StartPlanningActive state,
  ) {
    const mealCounts = [10, 15, 21];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How many meals per week?',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: AppSpacing.sm),
        Text(
          'Each week includes breakfast, lunch, and dinner options',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
        SizedBox(height: AppSpacing.md),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: mealCounts.length,
          itemBuilder: (context, index) {
            final count = mealCounts[index];
            final isSelected = state.selectedMealCount == count;
            final isPopular = count == 15;

            return InkWell(
              onTap:
                  () =>
                      context.read<MealPlanningCubit>().updateMealCount(count),
              child: Container(
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? AppColors.primary.withOpacity(0.1)
                          : Colors.grey.shade50,
                  border: Border.all(
                    color:
                        isSelected ? AppColors.primary : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(
                    AppDimensions.borderRadiusMd,
                  ),
                ),
                child: Stack(
                  children: [
                    if (isPopular)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Popular',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: Colors.white, fontSize: 10),
                          ),
                        ),
                      ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$count',
                            style: Theme.of(
                              context,
                            ).textTheme.headlineMedium?.copyWith(
                              color:
                                  isSelected
                                      ? AppColors.primary
                                      : AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'meals',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color:
                                  isSelected
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // NEW: Week count selection
  Widget _buildWeekCountSection(
    BuildContext context,
    StartPlanningActive state,
  ) {
    const weekCounts = [1, 2, 3, 4];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How many weeks?',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: AppSpacing.sm),
        Text(
          'Plan meals for multiple weeks in advance (minimum 1, maximum 4)',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
        SizedBox(height: AppSpacing.md),
        Row(
          children:
              weekCounts.map((count) {
                final isSelected = state.selectedWeekCount == count;

                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: InkWell(
                      onTap:
                          () => context
                              .read<MealPlanningCubit>()
                              .updateWeekCount(count),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? AppColors.primary.withOpacity(0.1)
                                  : Colors.grey.shade50,
                          border: Border.all(
                            color:
                                isSelected
                                    ? AppColors.primary
                                    : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.borderRadiusMd,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '$count',
                              style: Theme.of(
                                context,
                              ).textTheme.headlineSmall?.copyWith(
                                color:
                                    isSelected
                                        ? AppColors.primary
                                        : AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              count == 1 ? 'week' : 'weeks',
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color:
                                    isSelected
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, StartPlanningActive state) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: SecondaryButton(
                text: 'View Menu Catalog',
                onPressed:
                    () => Navigator.pushNamed(context, AppRouter.packagesRoute),
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: PrimaryButton(
                text: 'Start Planning',
                onPressed:
                    state.isFormValid
                        ? () => _startPlanning(context, state)
                        : null,
              ),
            ),
          ],
        ),
        if (!state.isFormValid) ...[
          SizedBox(height: AppSpacing.sm),
          Text(
            _getValidationMessage(state),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final minimumDate = DateTime.now().add(const Duration(days: 5));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: minimumDate,
      firstDate: minimumDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      context.read<MealPlanningCubit>().updateStartDate(picked);
    }
  }

  void _startPlanning(BuildContext context, StartPlanningActive state) {
    context.read<MealPlanningCubit>().startWeekPlanning(
      startDate: state.selectedStartDate!,
      dietaryPreference: state.selectedDietaryPreference!,
      mealCount: state.selectedMealCount!,
      numberOfWeeks: state.selectedWeekCount!, // Pass week count
    );
  }

  String _formatDate(DateTime date) {
    final months = [
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
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }

  String _getValidationMessage(StartPlanningActive state) {
    if (state.selectedStartDate == null) {
      return 'Please select a start date (minimum 5 days from today)';
    }
    if (state.selectedDietaryPreference == null) {
      return 'Please select your dietary preference';
    }
    if (state.selectedMealCount == null) {
      return 'Please select number of meals per week';
    }
    if (state.selectedWeekCount == null) {
      return 'Please select number of weeks';
    }
    return 'Please complete all fields to continue';
  }
}
