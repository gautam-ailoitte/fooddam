// lib/src/presentation/screens/subscription/plan_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/constants/app_constants.dart';
import 'package:foodam/core/constants/string_constants.dart';
import 'package:foodam/core/layout/app_scaffold.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/service/dialog_service.dart';
import 'package:foodam/core/widgets/app_card.dart';
import 'package:foodam/core/widgets/app_empty_state.dart';
import 'package:foodam/core/widgets/app_error_widget.dart';
import 'package:foodam/core/widgets/app_loading.dart';
import 'package:foodam/src/domain/entities/dish_entity.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';
import 'package:foodam/src/presentation/cubits/susbcription/subscription_cubit.dart';
import 'package:foodam/src/presentation/cubits/susbcription/susbcription_state.dart';
import 'package:foodam/src/presentation/screens/plan_details_screen.dart';
import 'package:foodam/src/presentation/widgets/common/app_button.dart';
import 'package:foodam/src/presentation/widgets/plan_duration_selector.dart';

class PlanSelectionScreen extends StatefulWidget {
  const PlanSelectionScreen({super.key});

  @override
  State<PlanSelectionScreen> createState() => _PlanSelectionScreenState();
}

class _PlanSelectionScreenState extends State<PlanSelectionScreen> {
  int _selectedDuration = AppConstants.sevenDayPlan;
  DietaryPreference _selectedDietaryPreference = DietaryPreference.vegetarian;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    context.read<SubscriptionCubit>().getAvailableSubscriptions();
    context.read<SubscriptionCubit>().getDraftSubscription();
  }

  void _selectDuration(int days) {
    setState(() {
      _selectedDuration = days;
    });
  }

  void _selectDietaryPreference(DietaryPreference preference) {
    setState(() {
      _selectedDietaryPreference = preference;
    });
  }

  void _navigateToPlanDetails(Subscription subscription) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PlanDetailsScreen(subscription: subscription),
      ),
    );
  }

  void _handleDraftPlan() {
    final subscriptionCubit = context.read<SubscriptionCubit>();
    final state = subscriptionCubit.state;

    if (state is DraftSubscriptionLoaded) {
      AppDialogs.showConfirmationDialog(
        context: context,
        title: StringConstants.draftPlanFound,
        message: StringConstants.draftPlanFoundMessage,
        confirmText: StringConstants.resumeDraftPlan,
        cancelText: StringConstants.startNewPlan,
      ).then((value) {
        if (value == true) {
          // Resume draft
          _navigateToPlanDetails(state.subscription);
        } else {
          // Start new plan (clear draft first)
          subscriptionCubit.clearDraftSubscription();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: StringConstants.selectPlan,
      body: BlocConsumer<SubscriptionCubit, SubscriptionState>(
        listener: (context, state) {
          if (state is DraftSubscriptionLoaded) {
            _handleDraftPlan();
          }
        },
        builder: (context, state) {
          if (state is SubscriptionLoading) {
            return const AppLoading(message: StringConstants.loadingPlans);
          } else if (state is SubscriptionError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: _loadData,
              retryText: StringConstants.retry,
            );
          } else if (state is AvailableSubscriptionsLoaded) {
            final filteredSubscriptions = state.subscriptions.where((sub) {
              // Filter by duration
              bool durationMatch = false;
              switch (_selectedDuration) {
                case AppConstants.sevenDayPlan:
                  durationMatch = sub.duration == SubscriptionDuration.sevenDays;
                  break;
                case AppConstants.fourteenDayPlan:
                  durationMatch = sub.duration == SubscriptionDuration.fourteenDays;
                  break;
                case AppConstants.twentyEightDayPlan:
                  durationMatch = sub.duration == SubscriptionDuration.twentyEightDays;
                  break;
              }
              
              return durationMatch;
            }).toList();

            return Column(
              children: [
                // Plan duration selector
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: PlanDurationSelector(
                    selectedDuration: _selectedDuration,
                    onDurationSelected: _selectDuration,
                  ),
                ),
                
                // Dietary preference selector
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Text(
                        StringConstants.selectMealType,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Spacer(),
                      DropdownButton<DietaryPreference>(
                        value: _selectedDietaryPreference,
                        onChanged: (value) {
                          if (value != null) {
                            _selectDietaryPreference(value);
                          }
                        },
                        items: [
                          DropdownMenuItem(
                            value: DietaryPreference.vegetarian,
                            child: Text(StringConstants.vegetarian),
                          ),
                          DropdownMenuItem(
                            value: DietaryPreference.nonVegetarian,
                            child: Text(StringConstants.nonVegetarian),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                AppSpacing.vMd,
                
                Expanded(
                  child: filteredSubscriptions.isEmpty
                      ? AppEmptyState(
                          message: StringConstants.noPlansForDuration,
                          icon: Icons.calendar_today,
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: filteredSubscriptions.length,
                          itemBuilder: (context, index) {
                            final subscription = filteredSubscriptions[index];
                            return _buildPlanCard(context, subscription);
                          },
                        ),
                ),
              ],
            );
          }
          
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, Subscription subscription) {
    // Calculate the price per day
    final pricePerDay = subscription.basePrice / subscription.durationInDays;
    
    return AppCard(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getPlanName(subscription),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (subscription.isCustomized)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    StringConstants.customizable,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                ),
            ],
          ),
          AppSpacing.vMd,
          Text(
            StringConstants.dailyBreakfastLunchDinner,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          AppSpacing.vSm,
          Text(
            '${StringConstants.duration}: ${subscription.durationInDays} days',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          AppSpacing.vMd,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '₹${pricePerDay.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                  ),
                  Text(
                    '${StringConstants.startingAt} / day',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              // Use the fixed button here
              FixedAppButton(
                label: StringConstants.selectPlan,
                onPressed: () => _navigateToPlanDetails(subscription),
                buttonType: FixedAppButtonType.primary,
                buttonSize: FixedAppButtonSize.medium,
                isFullWidth: false, // Important: Set to false for this context
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getPlanName(Subscription subscription) {
    // This is a simplified implementation
    // In a real app, you'd have more information on the subscription
    bool hasVegetarianMeals = subscription.mealPreferences.any(
      (pref) => pref.preferences.contains(DietaryPreference.vegetarian),
    );
    
    bool hasNonVegetarianMeals = subscription.mealPreferences.any(
      (pref) => pref.preferences.contains(DietaryPreference.nonVegetarian),
    );
    
    if (hasVegetarianMeals && !hasNonVegetarianMeals) {
      return StringConstants.vegetarianPlan;
    } else if (hasNonVegetarianMeals) {
      return StringConstants.nonVegetarianPlan;
    } else {
      return 'Custom Plan';
    }
  }
}