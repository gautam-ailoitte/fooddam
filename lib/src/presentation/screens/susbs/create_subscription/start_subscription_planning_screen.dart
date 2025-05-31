// lib/src/presentation/screens/susbs/create_subscription/start_subscription_planning_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/constants/subscription_constants.dart';
import 'package:foodam/core/route/app_router.dart';
import 'package:foodam/core/widgets/primary_button.dart';
import 'package:foodam/core/widgets/secondary_button.dart';
import 'package:intl/intl.dart';

import '../../../../../core/layout/app_spacing.dart';
import '../../../cubits/subscription/week_selection/week_selection_cubit.dart';
import '../../../cubits/subscription/week_selection/week_selection_state.dart';

/// ===================================================================
/// 📝 FIXED: Updated class name and removed references to deleted states
/// Simplified planning screen with only essential fields
/// ===================================================================
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
  bool _isInitializing = false;

  @override
  void initState() {
    super.initState();
    // Set default values
    _selectedStartDate = DateTime.now().add(const Duration(days: 1));
    _selectedDietaryPreference = SubscriptionConstants.defaultDietaryPreference;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text('Plan Your Meals'),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRouter.packagesRoute);
            },
            child: const Text(
              "View Plans",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: BlocConsumer<WeekSelectionCubit, WeekSelectionState>(
        listener: (context, state) {
          if (state is WeekSelectionActive) {
            // Navigate to week selection flow when initialized
            Navigator.pushReplacementNamed(
              context,
              AppRouter.weekSelectionFlowRoute,
            );
          }
        },
        builder: (context, state) {
          // Show loading when initializing
          if (_isInitializing) {
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
            padding: EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section
                _buildWelcomeSection(),
                SizedBox(height: AppSpacing.lg),

                // Simplified Planning Form (only 2 fields)
                _buildSimplifiedPlanningForm(),
                SizedBox(height: AppSpacing.lg),

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
        padding: EdgeInsets.all(AppSpacing.md),
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
                SizedBox(width: AppSpacing.md),
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
            SizedBox(height: AppSpacing.md),

            // Updated description for new flow
            Text(
              'Start by selecting your preferred start date and dietary preference. You\'ll customize meal plans and choose specific dishes week by week.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            SizedBox(height: AppSpacing.md),

            // Added new flow features
            Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.accent.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: AppColors.accent,
                    size: 16,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'New: Configure each week individually with different meal plans!',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.md),

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

  /// Simplified form with only startDate + dietaryPreference
  Widget _buildSimplifiedPlanningForm() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Preferences',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Set your start date and default dietary preference. You can customize meal plans for each week during selection.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            SizedBox(height: AppSpacing.md),

            // Start Date Selection
            _buildStartDateSelector(),
            SizedBox(height: AppSpacing.md),

            // Dietary Preference Selection
            _buildDietaryPreferenceSelector(),
          ],
        ),
      ),
    );
  }

  Widget _buildStartDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Start Date',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(width: AppSpacing.sm),
            Icon(Icons.info_outline, size: 16, color: AppColors.textSecondary),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'When would you like your first meal delivery?',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectStartDate,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade50,
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: AppColors.primary),
                SizedBox(width: AppSpacing.sm),
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
        Row(
          children: [
            const Text(
              'Default Dietary Preference',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(width: AppSpacing.sm),
            Icon(Icons.info_outline, size: 16, color: AppColors.textSecondary),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'You can change this for individual weeks during meal selection',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
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
                              : AppSpacing.sm,
                    ),
                    child: InkWell(
                      onTap: () => _selectDietaryPreference(preference),
                      child: Container(
                        padding: EdgeInsets.all(AppSpacing.md),
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

  Widget _buildActionButtons() {
    final isFormValid =
        _selectedStartDate != null && _selectedDietaryPreference != null;

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
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: PrimaryButton(
                text: 'Start Weekly Planning',
                onPressed: isFormValid ? _startWeeklyPlanning : null,
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
    }
  }

  void _selectDietaryPreference(String preference) {
    if (_selectedDietaryPreference != preference) {
      setState(() {
        _selectedDietaryPreference = preference;
      });
    }
  }

  /// Updated to use new WeekSelectionCubit with simplified states
  void _startWeeklyPlanning() {
    if (_selectedStartDate == null || _selectedDietaryPreference == null) {
      return;
    }

    setState(() {
      _isInitializing = true;
    });

    // Create planning form data
    final planningData = PlanningFormData(
      startDate: _selectedStartDate!,
      dietaryPreference: _selectedDietaryPreference!,
    );

    // Initialize week selection (no delay needed)
    context.read<WeekSelectionCubit>().initializeWeekSelection(planningData);
  }
}
