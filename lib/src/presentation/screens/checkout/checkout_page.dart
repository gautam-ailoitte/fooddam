// lib/src/presentation/pages/subscription/plan_selection_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/constants/app_constants.dart';
import 'package:foodam/core/constants/string_constants.dart';
import 'package:foodam/core/layout/app_scaffold.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/widgets/app_button.dart';
import 'package:foodam/core/widgets/app_card.dart';
import 'package:foodam/core/widgets/app_empty_state.dart';
import 'package:foodam/core/widgets/app_error_widget.dart';
import 'package:foodam/core/widgets/app_loading.dart';
import 'package:foodam/core/widgets/app_section_header.dart';
import 'package:foodam/src/domain/entities/dish_entity.dart';
import 'package:foodam/src/domain/entities/dish_entity.dart' as entity;
import 'package:foodam/src/domain/entities/susbcription_entity.dart' as entity;
import 'package:foodam/src/presentation/cubits/meal_configuration/meal_configuration_cubit.dart';
import 'package:foodam/src/presentation/cubits/subscription/subscription_cubit.dart';
import 'package:foodam/src/presentation/cubits/subscription/subscription_state.dart';
import 'package:foodam/src/presentation/screens/meal_configuration/meal_configuration_page.dart';
import 'package:intl/intl.dart';

class PlanSelectionPage extends StatefulWidget {
  static const routeName = '/plan-selection';

  const PlanSelectionPage({Key? key}) : super(key: key);

  @override
  State<PlanSelectionPage> createState() => _PlanSelectionPageState();
}

class _PlanSelectionPageState extends State<PlanSelectionPage> {
  entity.SubscriptionDuration _selectedDuration = entity.SubscriptionDuration.sevenDays;
  entity.DietaryPreference _selectedPreference = entity.DietaryPreference.vegetarian;
  DateTime _startDate = DateTime.now().add(const Duration(days: 1));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SubscriptionCubit>().loadAvailableSubscriptions();
      context.read<SubscriptionCubit>().loadDraftSubscription();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: StringConstants.chooseAPlan,
      type: ScaffoldType.withAppBar,
      body: BlocConsumer<SubscriptionCubit, SubscriptionState>(
        listener: (context, state) {
          if (state.hasDraftSubscription && state.status == SubscriptionStatus.draft) {
            _showDraftFoundDialog(context, state.draftSubscription!);
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.availableSubscriptions.isEmpty) {
            return const Center(
              child: AppLoading(message: StringConstants.loadingPlans),
            );
          }

          if (state.status == SubscriptionStatus.error &&
              state.availableSubscriptions.isEmpty) {
            return Center(
              child: AppErrorWidget(
                message: state.errorMessage ?? 'Failed to load plans',
                onRetry: () =>
                    context.read<SubscriptionCubit>().loadAvailableSubscriptions(),
                retryText: StringConstants.retry,
              ),
            );
          }

          return SingleChildScrollView(
            padding: AppSpacing.pagePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDurationSelector(),
                AppSpacing.vLg,
                _buildPreferenceSelector(),
                AppSpacing.vLg,
                _buildStartDateSelector(),
                AppSpacing.vLg,
                _buildAvailablePlans(state),
                AppSpacing.vLg,
                AppButton(
                  label: StringConstants.continueWithSelectedPlan,
                  onPressed: _handleContinue,
                  buttonType: AppButtonType.primary,
                  trailingIcon: Icons.arrow_forward,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDurationSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          title: StringConstants.planDuration,
        ),
        AppSpacing.vSm,
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildDurationChip(entity.SubscriptionDuration.sevenDays, '7 Days'),
            _buildDurationChip(entity.SubscriptionDuration.fourteenDays, '14 Days'),
            _buildDurationChip(entity.SubscriptionDuration.twentyEightDays, '28 Days'),
          ],
        ),
      ],
    );
  }

  Widget _buildDurationChip(entity.SubscriptionDuration duration, String label) {
    final isSelected = _selectedDuration == duration;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedDuration = duration;
          });
        }
      },
    );
  }

  Widget _buildPreferenceSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          title: StringConstants.selectMealType,
        ),
        AppSpacing.vSm,
        Row(
          children: [
            Expanded(
              child: _buildPreferenceOption(
                entity.DietaryPreference.vegetarian,
                StringConstants.vegetarian,
                Icons.spa,
              ),
            ),
            AppSpacing.hMd,
            Expanded(
              child: _buildPreferenceOption(
                entity.DietaryPreference.nonVegetarian,
                StringConstants.nonVegetarian,
                Icons.restaurant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPreferenceOption(
      entity.DietaryPreference preference, String label, IconData icon) {
    final isSelected = _selectedPreference == preference;
    final color = preference == entity.DietaryPreference.vegetarian
        ? AppColors.vegetarian
        : AppColors.nonVegetarian;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedPreference = preference;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? color : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            AppSpacing.vSm,
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          title: 'Start Date',
        ),
        AppSpacing.vSm,
        InkWell(
          onTap: () => _selectDate(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.divider),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: AppColors.primary),
                AppSpacing.hMd,
                Text(
                  DateFormat('EEE, MMM d, yyyy').format(_startDate),
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime firstDate = now.add(const Duration(days: 1));
    final DateTime lastDate = now.add(const Duration(days: 30));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Widget _buildAvailablePlans(SubscriptionState state) {
    final filteredPlans = state.availableSubscriptions.where((plan) {
      // Filter by duration and preference
      final hasDuration = plan.duration == _selectedDuration;
      final hasPreference = plan.mealPreferences.any((pref) =>
          pref.preferences.contains(_selectedPreference));
      
      return hasDuration && hasPreference;
    }).toList();

    if (filteredPlans.isEmpty) {
      return const AppEmptyState(
        message: StringConstants.noPlansForDuration,
        icon: Icons.calendar_today_outlined,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          title: StringConstants.availablePlans,
        ),
        AppSpacing.vSm,
        ...filteredPlans.map((plan) => _buildPlanCard(plan)).toList(),
      ],
    );
  }

  Widget _buildPlanCard(entity.Subscription plan) {
    final planDays = _getDurationInDays(plan.duration);
    final pricePerDay = plan.basePrice / planDays;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedPreference == DietaryPreference.vegetarian
                          ? StringConstants.vegetarianPlan
                          : StringConstants.nonVegetarianPlan,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    AppSpacing.vXs,
                    Text(
                      StringConstants.dailyBreakfastLunchDinner,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    AppSpacing.vSm,
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${_getDurationText(plan.duration)}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        AppSpacing.hSm,
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 12,
                                color: AppColors.accent,
                              ),
                              AppSpacing.hXs,
                              Text(
                                StringConstants.customizable,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.accent,
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  RichText(
                    text: TextSpan(
                      text: '₹${pricePerDay.toInt()}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                      children: [
                        TextSpan(
                          text: '/day',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.vXs,
                  Text(
                    'Total: ₹${plan.basePrice.toInt()}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ],
          ),
          AppSpacing.vMd,
          AppButton(
            label: StringConstants.customizePlan,
            onPressed: () => _handleContinue(),
            buttonType: AppButtonType.primary,
            leadingIcon: Icons.edit_outlined,
          ),
        ],
      ),
    );
  }

  void _handleContinue() {
    // Initialize the meal configuration with the selected preference
    context.read<MealConfigurationCubit>().initializeMealConfiguration(_selectedPreference);
    
    // Navigate to meal configuration page
    Navigator.of(context).pushNamed(MealConfigurationPage.routeName);
  }

  void _showDraftFoundDialog(BuildContext context, entity.Subscription draftSubscription) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text(StringConstants.draftPlanFound),
        content: const Text(StringConstants.draftPlanFoundMessage),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<SubscriptionCubit>().clearDraftSubscription();
            },
            child: const Text(StringConstants.startNewPlan),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to draft customization
              Navigator.of(context).pushNamed(MealConfigurationPage.routeName);
            },
            child: const Text(StringConstants.resumeDraftPlan),
          ),
        ],
      ),
    );
  }

  String _getDurationText(entity.SubscriptionDuration duration) {
    switch (duration) {
      case entity.SubscriptionDuration.sevenDays:
        return '7 Days';
      case entity.SubscriptionDuration.fourteenDays:
        return '14 Days';
      case entity.SubscriptionDuration.twentyEightDays:
        return '28 Days';
      case entity.SubscriptionDuration.monthly:
        return 'Monthly';
      case entity.SubscriptionDuration.quarterly:
        return 'Quarterly';
      case entity.SubscriptionDuration.halfYearly:
        return 'Half Yearly';
      case entity.SubscriptionDuration.yearly:
        return 'Yearly';
      case entity.SubscriptionDuration.days30:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  int _getDurationInDays(entity.SubscriptionDuration duration) {
    switch (duration) {
      case entity.SubscriptionDuration.sevenDays:
        return AppConstants.sevenDayPlan;
      case entity.SubscriptionDuration.fourteenDays:
        return AppConstants.fourteenDayPlan;
      case entity.SubscriptionDuration.twentyEightDays:
        return AppConstants.twentyEightDayPlan;
      case entity.SubscriptionDuration.monthly:
        return 30;
      case entity.SubscriptionDuration.quarterly:
        return 90;
      case entity.SubscriptionDuration.halfYearly:
        return 180;
      case entity.SubscriptionDuration.yearly:
        return 365;
      case entity.SubscriptionDuration.days30:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }
}

