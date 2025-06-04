import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/constants/subscription_constants.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/widgets/primary_button.dart';
import 'package:foodam/core/widgets/secondary_button.dart';

import '../../../cubits/subscription/week_selection/week_selection_cubit.dart';

class WeekConfigurationBottomSheet extends StatefulWidget {
  final int week;
  final String defaultDietaryPreference;
  final VoidCallback? onDismiss;

  const WeekConfigurationBottomSheet({
    super.key,
    required this.week,
    required this.defaultDietaryPreference,
    this.onDismiss,
  });

  /// Show the bottom sheet and return the configuration result
  static Future<bool?> show(
    BuildContext context, {
    required int week,
    required String defaultDietaryPreference,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => WeekConfigurationBottomSheet(
            week: week,
            defaultDietaryPreference: defaultDietaryPreference,
          ),
    );
  }

  @override
  State<WeekConfigurationBottomSheet> createState() =>
      _WeekConfigurationBottomSheetState();
}

class _WeekConfigurationBottomSheetState
    extends State<WeekConfigurationBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  String? _selectedDietaryPreference;
  int? _selectedMealPlan;
  bool _isConfiguring = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _initializeDefaults();
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
    _animationController.forward();
  }

  void _initializeDefaults() {
    _selectedDietaryPreference = widget.defaultDietaryPreference;
    _selectedMealPlan =
        SubscriptionConstants.mealPlans.first; // Default to 10 meals
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: DraggableScrollableSheet(
              initialChildSize: 0.75,
              maxChildSize: 0.9,
              minChildSize: 0.5,
              expand: false,
              builder: (context, scrollController) {
                return _buildSheetContent(scrollController);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildSheetContent(ScrollController scrollController) {
    return Padding(
      padding: EdgeInsets.all(AppDimensions.marginMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          _buildHandleBar(),
          SizedBox(height: AppDimensions.marginMedium),

          // Header
          _buildHeader(),
          SizedBox(height: AppDimensions.marginLarge),

          // Content
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Week info card
                  _buildWeekInfoCard(),
                  SizedBox(height: AppDimensions.marginLarge),

                  // Dietary preference selection
                  _buildDietaryPreferenceSection(),
                  SizedBox(height: AppDimensions.marginLarge),

                  // Meal plan selection
                  _buildMealPlanSection(),
                  SizedBox(height: AppDimensions.marginLarge),

                  // Configuration summary
                  _buildConfigurationSummary(),
                ],
              ),
            ),
          ),

          // Action buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHandleBar() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Icon(Icons.settings, color: AppColors.primary, size: 30),
        ),
        SizedBox(width: AppDimensions.marginMedium),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Configure Week ${widget.week}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Set your dietary preference and meal plan',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: _closeBottomSheet,
          icon: Icon(Icons.close, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildWeekInfoCard() {
    return Container(
      padding: EdgeInsets.all(AppDimensions.marginMedium),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline, color: AppColors.accent, size: 20),
          SizedBox(width: AppDimensions.marginSmall),
          Expanded(
            child: Text(
              'Each week can have different settings. You can mix vegetarian and non-vegetarian weeks with different meal plans!',
              style: TextStyle(
                color: AppColors.accent,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDietaryPreferenceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.restaurant, color: AppColors.primary, size: 20),
            SizedBox(width: AppDimensions.marginSmall),
            Text(
              'Dietary Preference',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        SizedBox(height: AppDimensions.marginSmall),
        Text(
          'Choose your preferred diet for Week ${widget.week}',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        SizedBox(height: AppDimensions.marginMedium),

        // Dietary preference options
        Row(
          children:
              SubscriptionConstants.dietaryPreferences.map((preference) {
                final isSelected = _selectedDietaryPreference == preference;
                final isDefault = preference == widget.defaultDietaryPreference;

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
                            if (isDefault) ...[
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'DEFAULT',
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
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildMealPlanSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.restaurant_menu, color: AppColors.primary, size: 20),
            SizedBox(width: AppDimensions.marginSmall),
            Text(
              'Meal Plan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        SizedBox(height: AppDimensions.marginSmall),
        Text(
          'How many meals would you like for Week ${widget.week}?',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        SizedBox(height: AppDimensions.marginMedium),

        // Meal plan grid (2x2)
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: SubscriptionConstants.mealPlans.length,
          itemBuilder: (context, index) {
            final mealPlan = SubscriptionConstants.mealPlans[index];
            final isSelected = _selectedMealPlan == mealPlan;
            final isAllMeals = mealPlan == 21;

            return InkWell(
              onTap: () => _selectMealPlan(mealPlan),
              child: Container(
                padding: EdgeInsets.all(AppDimensions.marginMedium),
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
                    const SizedBox(height: 4),
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
                    // if (isAllMeals) ...[
                    //   const SizedBox(height: 4),
                    //   Container(
                    //     padding: const EdgeInsets.symmetric(
                    //       horizontal: 6,
                    //       vertical: 2,
                    //     ),
                    //     decoration: BoxDecoration(
                    //       color: AppColors.success.withOpacity(0.2),
                    //       borderRadius: BorderRadius.circular(8),
                    //     ),
                    //     child: Text(
                    //       'ALL',
                    //       style: TextStyle(
                    //         color: AppColors.success,
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
          SizedBox(height: AppDimensions.marginMedium),
          Container(
            padding: EdgeInsets.all(AppDimensions.marginMedium),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.success.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.success, size: 20),
                SizedBox(width: AppDimensions.marginSmall),
                Expanded(
                  child: Text(
                    'All 21 meals will be automatically selected for you (7 days × 3 meals)',
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

  Widget _buildConfigurationSummary() {
    if (_selectedDietaryPreference == null || _selectedMealPlan == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(AppDimensions.marginMedium),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.summarize, color: AppColors.primary, size: 20),
              SizedBox(width: AppDimensions.marginSmall),
              Text(
                'Configuration Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.marginMedium),

          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Week',
                  '${widget.week}',
                  Icons.calendar_today,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Diet',
                  SubscriptionConstants.getDietaryPreferenceText(
                    _selectedDietaryPreference!,
                  ),
                  _getDietaryIcon(_selectedDietaryPreference!),
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Meals',
                  '${_selectedMealPlan!}',
                  Icons.restaurant_menu,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    final isFormValid =
        _selectedDietaryPreference != null && _selectedMealPlan != null;

    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  text: 'Cancel',
                  onPressed: _isConfiguring ? null : _closeBottomSheet,
                ),
              ),
              SizedBox(width: AppDimensions.marginMedium),
              Expanded(
                child: PrimaryButton(
                  text:
                      _isConfiguring
                          ? 'Configuring...'
                          : 'Confirm Configuration',
                  onPressed:
                      isFormValid && !_isConfiguring
                          ? _confirmConfiguration
                          : null,
                  isLoading: _isConfiguring,
                ),
              ),
            ],
          ),
          if (!isFormValid) ...[
            const SizedBox(height: 8),
            Text(
              'Please select both dietary preference and meal plan',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  void _selectDietaryPreference(String preference) {
    if (_selectedDietaryPreference != preference) {
      setState(() {
        _selectedDietaryPreference = preference;
      });
    }
  }

  void _selectMealPlan(int mealPlan) {
    if (_selectedMealPlan != mealPlan) {
      setState(() {
        _selectedMealPlan = mealPlan;
      });
    }
  }

  void _closeBottomSheet() {
    _animationController.reverse().then((_) {
      if (mounted) {
        Navigator.pop(context, false);
        widget.onDismiss?.call();
      }
    });
  }

  Future<void> _confirmConfiguration() async {
    if (_selectedDietaryPreference == null || _selectedMealPlan == null) return;

    setState(() {
      _isConfiguring = true;
    });

    try {
      // Configure the week using the cubit
      await context.read<WeekSelectionCubit>().configureWeek(
        week: widget.week,
        dietaryPreference: _selectedDietaryPreference!,
        mealPlan: _selectedMealPlan!,
      );

      // Close the bottom sheet with success
      if (mounted) {
        _animationController.reverse().then((_) {
          if (mounted) {
            Navigator.pop(context, true);
          }
        });
      }
    } catch (e) {
      setState(() {
        _isConfiguring = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to configure week: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

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
