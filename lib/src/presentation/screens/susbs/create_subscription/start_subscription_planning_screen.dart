// lib/src/presentation/screens/subscription/start_subscription_planning_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/constants/subscription_constants.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/route/app_router.dart';
import 'package:foodam/core/widgets/primary_button.dart';
import 'package:foodam/core/widgets/secondary_button.dart';
import 'package:foodam/src/presentation/cubits/subscription/planning/subscription_planning_cubit.dart';
import 'package:foodam/src/presentation/cubits/subscription/planning/subscription_planning_state.dart';
import 'package:intl/intl.dart';

class StartSubscriptionPlanningScreen extends StatefulWidget {
  const StartSubscriptionPlanningScreen({super.key});

  @override
  State<StartSubscriptionPlanningScreen> createState() =>
      _StartSubscriptionPlanningScreenState();
}

class _StartSubscriptionPlanningScreenState
    extends State<StartSubscriptionPlanningScreen> {
  DateTime? _selectedStartDate;
  String? _selectedDietaryPreference;
  int? _selectedDuration;
  int? _selectedMealPlan;

  @override
  void initState() {
    super.initState();
    // Initialize the planning form
    context.read<SubscriptionPlanningCubit>().initializePlanning();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text('Plan Your Meal'),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRouter.packagesRoute);
            },
            child: Text("View Plans", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: BlocConsumer<SubscriptionPlanningCubit, SubscriptionPlanningState>(
        listener: (context, state) {
          if (state is SubscriptionPlanningError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                duration: const Duration(seconds: 3),
              ),
            );
          } else if (state is WeekSelectionActive) {
            // FIXED: Use pushReplacementNamed to prevent stack buildup
            Navigator.pushReplacementNamed(
              context,
              AppRouter.weekSelectionFlowRoute,
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
                  Text('Setting up your meal planning...'),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(AppDimensions.marginMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section
                _buildWelcomeSection(),
                SizedBox(height: AppDimensions.marginLarge),

                // Planning Form
                _buildPlanningForm(),
                SizedBox(height: AppDimensions.marginLarge),

                // Action Buttons
                _buildActionButtons(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppColors.primaryLight.withOpacity(0.1),
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.marginMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Icon(
                    Icons.restaurant_menu,
                    color: AppColors.primary,
                    size: 30,
                  ),
                ),
                SizedBox(width: AppDimensions.marginMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome to Foodam!',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Let\'s create your perfect meal plan',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: AppDimensions.marginMedium),
            Text(
              'Choose your preferences and we\'ll customize a delicious meal plan just for you. You can select specific meals for each day of your subscription.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            SizedBox(height: AppDimensions.marginMedium),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRouter.packagesRoute);
                  },
                  icon: const Icon(Icons.visibility, size: 18),
                  label: const Text('View Our Catalog'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanningForm() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.marginMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Subscription Details',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppDimensions.marginMedium),

            // Start Date Selection
            _buildStartDateSelector(),
            SizedBox(height: AppDimensions.marginMedium),

            // Dietary Preference Selection
            _buildDietaryPreferenceSelector(),
            SizedBox(height: AppDimensions.marginMedium),

            // Duration Selection
            _buildDurationSelector(),
            SizedBox(height: AppDimensions.marginMedium),

            // Meal Plan Selection
            _buildMealPlanSelector(),
          ],
        ),
      ),
    );
  }

  Widget _buildStartDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Start Date',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectStartDate,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppDimensions.marginMedium),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade50,
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: AppColors.primary),
                SizedBox(width: AppDimensions.marginSmall),
                Text(
                  _selectedStartDate != null
                      ? DateFormat('MMMM d, yyyy').format(_selectedStartDate!)
                      : 'Select start date',
                  style: TextStyle(
                    color:
                        _selectedStartDate != null
                            ? Colors.black
                            : AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDietaryPreferenceSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dietary Preference',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Row(
          children:
              SubscriptionConstants.dietaryPreferences.map((preference) {
                final isSelected = _selectedDietaryPreference == preference;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right:
                          preference ==
                                  SubscriptionConstants.dietaryPreferences.last
                              ? 0
                              : AppDimensions.marginSmall,
                    ),
                    child: InkWell(
                      onTap: () => _selectDietaryPreference(preference),
                      child: Container(
                        padding: EdgeInsets.all(AppDimensions.marginMedium),
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
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            SubscriptionConstants.getDietaryPreferenceText(
                              preference,
                            ),
                            style: TextStyle(
                              color:
                                  isSelected ? AppColors.primary : Colors.black,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                            ),
                          ),
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

  Widget _buildDurationSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Duration',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        // 🔥 NEW: 2x2 Grid layout
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3.5,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: SubscriptionConstants.durations.length,
          itemBuilder: (context, index) {
            final duration = SubscriptionConstants.durations[index];
            final isSelected = _selectedDuration == duration;

            return InkWell(
              onTap: () => _selectDuration(duration),
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
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    SubscriptionConstants.getDurationText(duration),
                    style: TextStyle(
                      color: isSelected ? AppColors.primary : Colors.black,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMealPlanSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Meal Plan',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          'Choose how many meals you want per week',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 8),
        // 🔥 NEW: 2x2 Grid layout
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3.5,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: SubscriptionConstants.mealPlans.length,
          itemBuilder: (context, index) {
            final mealPlan = SubscriptionConstants.mealPlans[index];
            final isSelected = _selectedMealPlan == mealPlan;

            return InkWell(
              onTap: () => _selectMealPlan(mealPlan),
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
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    SubscriptionConstants.getMealPlanText(mealPlan),
                    style: TextStyle(
                      color: isSelected ? AppColors.primary : Colors.black,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    final isFormValid =
        _selectedStartDate != null &&
        _selectedDietaryPreference != null &&
        _selectedDuration != null &&
        _selectedMealPlan != null;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: SecondaryButton(
                text: 'View Catalog',
                onPressed: () {
                  Navigator.pushNamed(context, AppRouter.packagesRoute);
                },
              ),
            ),
            SizedBox(width: AppDimensions.marginMedium),
            Expanded(
              child: PrimaryButton(
                text: 'Start Planning',
                onPressed: isFormValid ? _startPlanning : null,
              ),
            ),
          ],
        ),
        if (!isFormValid) ...[
          const SizedBox(height: 8),
          Text(
            'Please complete all fields to continue',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedStartDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedStartDate) {
      setState(() {
        _selectedStartDate = picked;
      });
      _updateFormData();
    }
  }

  void _selectDietaryPreference(String preference) {
    if (_selectedDietaryPreference != preference) {
      setState(() {
        _selectedDietaryPreference = preference;
      });
      _updateFormData();
    }
  }

  void _selectDuration(int duration) {
    if (_selectedDuration != duration) {
      setState(() {
        _selectedDuration = duration;
      });
      _updateFormData();
    }
  }

  void _selectMealPlan(int mealPlan) {
    if (_selectedMealPlan != mealPlan) {
      setState(() {
        _selectedMealPlan = mealPlan;
      });
      _updateFormData();
    }
  }

  void _updateFormData() {
    context.read<SubscriptionPlanningCubit>().updateFormData(
      startDate: _selectedStartDate,
      dietaryPreference: _selectedDietaryPreference,
      duration: _selectedDuration,
      mealPlan: _selectedMealPlan,
    );
  }

  void _startPlanning() {
    // Show loading indicator briefly
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Delay to show loading, then start planning
    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.pop(context); // Remove loading dialog
      context.read<SubscriptionPlanningCubit>().startWeekSelection();
    });
  }
}
