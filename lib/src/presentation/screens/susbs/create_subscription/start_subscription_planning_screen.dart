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
import '../../../cubits/banner/banner_cubits.dart';
import '../../../cubits/banner/banner_state.dart';
import '../../../cubits/subscription/week_selection/week_selection_cubit.dart';
import '../../../cubits/subscription/week_selection/week_selection_state.dart';
import '../../../widgets/banner_carousel_widget.dart';

/// ===================================================================
/// 📝 UPDATED: Added meal plan selection for Week 1
/// Now includes mandatory meal plan selection as third section
/// ===================================================================
class StartSubscriptionPlanningScreen extends StatefulWidget {
  const StartSubscriptionPlanningScreen({super.key});

  @override
  State<StartSubscriptionPlanningScreen> createState() =>
      _StartSubscriptionPlanningScreenState();
}

class _StartSubscriptionPlanningScreenState extends State<StartSubscriptionPlanningScreen> {
  DateTime? _selectedStartDate;
  String? _selectedDietaryPreference;
  String? _selectedMealPlan; // CHANGED: Now a String (e.g., '1_month')
  bool _isInitializing = false;
  bool _didInitDietPref = false;

  // Meal plan options
  final List<Map<String, dynamic>> mealPlans = [
    {
      'label': '1 Month',
      'value': '1_month',
      'subtitle': 'Best value, full month of meals',
      'icon': Icons.calendar_month,
      'highlight': true,
    },
    {
      'label': '2 Weeks',
      'value': '2_weeks',
      'subtitle': 'Flexible, try for 2 weeks',
      'icon': Icons.calendar_view_week,
      'highlight': false,
    },
    {
      'label': '1 Week',
      'value': '1_week',
      'subtitle': 'Short trial, 1 week only',
      'icon': Icons.calendar_today,
      'highlight': false,
    },
  ];

  DateTime getDefaultStartDate() {
    DateTime date = DateTime.now().add(const Duration(days: 5));
    // Find the next Monday after this date
    int daysToAdd = (DateTime.monday - date.weekday + 7) % 7;
    daysToAdd = daysToAdd == 0 ? 7 : daysToAdd; // Always move to the next Monday, not today if already Monday
    return date.add(Duration(days: daysToAdd));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInitDietPref) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['dietaryPreference'] != null) {
        _selectedDietaryPreference = args['dietaryPreference'] as String;
      } else {
        _selectedDietaryPreference = SubscriptionConstants.defaultDietaryPreference;
      }
      _selectedStartDate = getDefaultStartDate();
      _didInitDietPref = true;
    }
  }

  @override
  void initState() {
    super.initState();
    // Set default values - start date must be tomorrow (future date only)
    // _selectedStartDate = DateTime.now().add(const Duration(days: 1)); // Moved to didChangeDependencies
    // _selectedDietaryPreference = SubscriptionConstants.defaultDietaryPreference; // Moved to didChangeDependencies
    // Note: _selectedMealPlan intentionally left null to force user selection
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text('Start Your Subscription'),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: BlocConsumer<WeekSelectionCubit, WeekSelectionState>(
        listener: (context, state) {
          if (state is WeekSelectionActive) {
            Navigator.pushReplacementNamed(
              context,
              AppRouter.weekSelectionFlowRoute,
            );
          }
        },
        builder: (context, state) {
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
                // Welcome Card
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  color: AppColors.primaryLight.withOpacity(0.1),
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: const Icon(
                            Icons.restaurant_menu,
                            color: AppColors.primary,
                            size: 28,
                          ),
                        ),
                        SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome to Tiffin Dost!',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Let’s get you started with your perfect meal plan.',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.lg),

                // Step 1: Start Date
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Start Date',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            SizedBox(width: AppSpacing.sm),
                            Tooltip(
                              message: 'Earliest start date is the next eligible Monday (at least 5 days from today).',
                              child: Icon(Icons.info_outline, size: 16, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Choose when your first meal delivery should start.',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () async {
                            final DateTime minStartDate = getDefaultStartDate();
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedStartDate ?? minStartDate,
                              firstDate: minStartDate,
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: Theme.of(context).colorScheme.copyWith(primary: AppColors.primary),
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
                          },
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
                                      : 'Select start date (next eligible Monday)',
                                  style: TextStyle(
                                    color: _selectedStartDate != null ? Colors.black : AppColors.textSecondary,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.lg),

                // Step 2: Dietary Preference
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Dietary Preference',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            SizedBox(width: AppSpacing.sm),
                            Tooltip(
                              message: 'Choose your preferred diet for your subscription.',
                              child: Icon(Icons.info_outline, size: 16, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: SubscriptionConstants.dietaryPreferences.map((preference) {
                            final isSelected = _selectedDietaryPreference == preference;
                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  right: preference == SubscriptionConstants.dietaryPreferences.last ? 0 : AppSpacing.sm,
                                ),
                                child: InkWell(
                                  onTap: () => _selectDietaryPreference(preference),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: EdgeInsets.all(AppSpacing.md),
                                    decoration: BoxDecoration(
                                      color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.grey.shade50,
                                      border: Border.all(
                                        color: isSelected ? AppColors.primary : Colors.grey.shade300,
                                        width: isSelected ? 2 : 1,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          _getDietaryIcon(preference),
                                          color: isSelected ? AppColors.primary : Colors.grey.shade600,
                                          size: 28,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          SubscriptionConstants.getDietaryPreferenceText(preference),
                                          style: TextStyle(
                                            color: isSelected ? AppColors.primary : Colors.black,
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                            fontSize: 15,
                                          ),
                                          textAlign: TextAlign.center,
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
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.lg),

                // Step 3: Meal Plan
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Meal Plan',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            SizedBox(width: AppSpacing.sm),
                            Tooltip(
                              message: 'Select your preferred plan duration.',
                              child: Icon(Icons.info_outline, size: 16, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Attractive meal plan cards
                        Column(
                          children: mealPlans.map((plan) {
                            final isSelected = _selectedMealPlan == plan['value'];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: InkWell(
                                onTap: () => _selectMealPlan(plan['value']),
                                borderRadius: BorderRadius.circular(14),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary.withOpacity(0.08)
                                        : Colors.grey.shade50,
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primary
                                          : plan['highlight']
                                              ? AppColors.accent.withOpacity(0.7)
                                              : Colors.grey.shade300,
                                      width: isSelected ? 2.2 : 1.2,
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: AppColors.primary.withOpacity(0.08),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : [],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppColors.primary.withOpacity(0.15)
                                              : AppColors.primary.withOpacity(0.07),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          plan['icon'],
                                          color: isSelected ? AppColors.primary : AppColors.primary,
                                          size: 28,
                                        ),
                                      ),
                                      const SizedBox(width: 18),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  plan['label'],
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 17,
                                                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                                  ),
                                                ),
                                                if (plan['highlight']) ...[
                                                  const SizedBox(width: 8),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.accent.withOpacity(0.15),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Text(
                                                      'POPULAR',
                                                      style: TextStyle(
                                                        color: AppColors.accent,
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              plan['subtitle'],
                                              style: TextStyle(
                                                color: AppColors.textSecondary,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (isSelected)
                                        Icon(Icons.check_circle, color: AppColors.primary, size: 24),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.lg),

                // Action Buttons
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
                        text: 'Start Planning',
                        onPressed: (_selectedStartDate != null && _selectedDietaryPreference != null && _selectedMealPlan != null)
                            ? _startWeeklyPlanning
                            : null,
                      ),
                    ),
                  ],
                ),
                if (!(_selectedStartDate != null && _selectedDietaryPreference != null && _selectedMealPlan != null)) ...[
                  const SizedBox(height: 8),
                  Text(
                    _getValidationMessage(),
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBannerSection() {
    return BlocBuilder<BannerCubit, BannerState>(
      builder: (context, state) {
        if (state is BannerLoaded && state.hasBanners) {
          final banners = state.banners;

          // Only return if we have banners to show
          if (banners.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: BannerCarousel(
                banners: banners,
                height: 160,
                onTap: () {
                  // Handle banner tap - could open a specific screen or URL
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Banner promotion tapped'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
            );
          }
        }

        // Show loading indicator while banners are being fetched
        if (state is BannerInitial || state is BannerLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: SizedBox(
                height: 100,
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
            ),
          );
        }

        // Don't show anything for error states
        return const SizedBox.shrink();
      },
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
                        'Welcome to Tiffin Dost!',
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
              'Start by selecting your preferences for Week 1. Your first delivery will be scheduled for tomorrow or later.',
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
          ],
        ),
      ),
    );
  }

  /// UPDATED: Now includes 3 sections - Start Date, Dietary Preference, and Meal Plan
  Widget _buildPlanningForm() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Week 1 Configuration',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Set your preferences for the first week. Your start date must be tomorrow or later. You can add more weeks and customize them during meal selection.',
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
            SizedBox(height: AppSpacing.md),

            // NEW: Meal Plan Selection for Week 1
            _buildMealPlanSelector(),
          ],
        ),
      ),
    );
  }

  Widget _buildStartDateSelector() {
    final DateTime minStartDate = getDefaultStartDate();
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
          'When would you like your first meal delivery? (Earliest: next eligible Monday)',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: _selectedStartDate ?? minStartDate,
              firstDate: minStartDate,
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
          },
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
                      : 'Select start date (next eligible Monday)',
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
              'Dietary Preference',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(width: AppSpacing.sm),
            Icon(Icons.info_outline, size: 16, color: AppColors.textSecondary),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Choose your preferred diet for Week 1',
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
                        child: Column(
                          children: [
                            Icon(
                              _getDietaryIcon(preference),
                              color:
                                  isSelected
                                      ? AppColors.primary
                                      : Colors.grey.shade600,
                              size: 24,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              SubscriptionConstants.getDietaryPreferenceText(
                                preference,
                              ),
                              style: TextStyle(
                                color:
                                    isSelected
                                        ? AppColors.primary
                                        : Colors.black,
                                fontWeight:
                                    isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
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

  /// NEW: Meal Plan Selection for Week 1
  Widget _buildMealPlanSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Meal Plan for Week 1',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(width: AppSpacing.sm),
            Icon(Icons.info_outline, size: 16, color: AppColors.textSecondary),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'How many meals would you like for your first week?',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 8),

        // Meal plan grid (2x2)
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.0,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: SubscriptionConstants.mealPlans.length,
          itemBuilder: (context, index) {
            final mealPlan = SubscriptionConstants.mealPlans[index];
            final isSelected = _selectedMealPlan == mealPlan;
            final isPopular = mealPlan == 15; // 15 meals is popular choice

            return InkWell(
              onTap: () => _selectMealPlan(mealPlan as String),
              child: Container(
                padding: EdgeInsets.all(AppSpacing.sm),
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$mealPlan',
                      style: TextStyle(
                        color: isSelected ? AppColors.primary : Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'meals',
                      style: TextStyle(
                        color:
                            isSelected
                                ? AppColors.primary
                                : AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    // if (isPopular) ...[
                    //   const SizedBox(height: 4),
                    //   Container(
                    //     padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    //     decoration: BoxDecoration(
                    //       color: AppColors.accent.withOpacity(0.2),
                    //       borderRadius: BorderRadius.circular(8),
                    //     ),
                    //     child: Text(
                    //       'POPULAR',
                    //       style: TextStyle(
                    //         color: AppColors.accent,
                    //         fontSize: 9,
                    //         fontWeight: FontWeight.bold,
                    //       ),
                    //     ),
                    //   ),
                    // ],
                  ],
                ),
              ),
            );
          },
        ),

        // 21-meal plan special note
        if (_selectedMealPlan == 21) ...[
          SizedBox(height: AppSpacing.sm),
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.success.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.success, size: 16),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'All 21 meals will be automatically selected (7 days × 3 meals)',
                    style: TextStyle(
                      color: AppColors.success,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons() {
    // UPDATED: Now validates all 3 fields including meal plan with debugging
    final isFormValid =
        _selectedStartDate != null &&
        _selectedDietaryPreference != null &&
        _selectedMealPlan != null;

    // Debug logging for validation state
    debugPrint(
      '🔍 Form validation - Date: ${_selectedStartDate != null}, Diet: ${_selectedDietaryPreference != null}, MealPlan: ${_selectedMealPlan != null}',
    );
    debugPrint(
      '🔍 Selected values - Date: $_selectedStartDate, Diet: $_selectedDietaryPreference, MealPlan: $_selectedMealPlan',
    );

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
                text: 'Start Planning Week 1',
                onPressed: isFormValid ? _startWeeklyPlanning : null,
              ),
            ),
          ],
        ),
        if (!isFormValid) ...[
          const SizedBox(height: 8),
          Text(
            _getValidationMessage(),
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  /// UPDATED: Now includes meal plan validation message
  String _getValidationMessage() {
    if (_selectedStartDate == null) {
      return 'Please select a start date (tomorrow or later)';
    }

    // Check if selected date is not in the future
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDate = DateTime(
      _selectedStartDate!.year,
      _selectedStartDate!.month,
      _selectedStartDate!.day,
    );

    if (!selectedDate.isAfter(today)) {
      return 'Start date must be tomorrow or later';
    }

    if (_selectedDietaryPreference == null) {
      return 'Please select a dietary preference';
    }
    if (_selectedMealPlan == null) {
      return '';
    }
    return 'Please complete all fields to continue';
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedStartDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().add(
        const Duration(days: 1),
      ), // UPDATED: Start from tomorrow
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

  /// NEW: Meal plan selection handler
  void _selectMealPlan(String mealPlan) {
    debugPrint(
      '🍽️ Selecting meal plan: $mealPlan (current: $_selectedMealPlan)',
    );

    if (_selectedMealPlan != mealPlan) {
      setState(() {
        _selectedMealPlan = mealPlan;
      });

      debugPrint('✅ Meal plan updated to: $_selectedMealPlan');
    }
  }

  /// UPDATED: Now creates PlanningFormData with meal plan
  void _startWeeklyPlanning() {
    // Enhanced null safety validation
    if (_selectedStartDate == null) {
      _showErrorSnackBar('Please select a start date');
      return;
    }

    // UPDATED: Validate that start date is in the future
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDate = DateTime(
      _selectedStartDate!.year,
      _selectedStartDate!.month,
      _selectedStartDate!.day,
    );

    if (!selectedDate.isAfter(today)) {
      _showErrorSnackBar('Start date must be tomorrow or later');
      return;
    }

    if (_selectedDietaryPreference == null) {
      _showErrorSnackBar('Please select a dietary preference');
      return;
    }

    if (_selectedMealPlan == null) {
      _showErrorSnackBar('Please select a meal plan');
      return;
    }

    // Only allow valid string values
    if (!['1_month', '2_weeks', '1_week'].contains(_selectedMealPlan)) {
      _showErrorSnackBar('Invalid meal plan selected');
      return;
    }

    setState(() {
      _isInitializing = true;
    });

    try {
      // Create planning form data with meal plan
      final planningData = PlanningFormData(
        startDate: _selectedStartDate!,
        dietaryPreference: _selectedDietaryPreference!,
        mealPlan: _selectedMealPlan!, // Now a string
      );

      // Debug log to verify data
      debugPrint(
        '🔄 Creating planning data: ${planningData.mealPlan} plan, ${planningData.dietaryPreference}',
      );

      // Initialize week selection with meal plan
      context.read<WeekSelectionCubit>().initializeWeekSelection(planningData);
    } catch (e) {
      // Handle any errors during initialization
      setState(() {
        _isInitializing = false;
      });

      _showErrorSnackBar('Failed to start planning: $e');
      debugPrint('❌ Error starting weekly planning: $e');
    }
  }

  /// Show error message to user
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Helper method to get dietary preference icon
  IconData _getDietaryIcon(String preference) {
    switch (preference.toLowerCase()) {
      case 'vegetarian':
        return Icons.eco;
      case 'non-vegetarian':
        return Icons.restaurant;
      default:
        return Icons.restaurant;
    }
  }
}
