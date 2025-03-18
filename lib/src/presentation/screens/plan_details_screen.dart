// lib/src/presentation/screens/subscription/plan_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/constants/string_constants.dart';
import 'package:foodam/core/layout/app_scaffold.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/service/dialog_service.dart';
import 'package:foodam/core/widgets/app_button.dart';
import 'package:foodam/core/widgets/app_card.dart';
import 'package:foodam/core/widgets/app_error_widget.dart';
import 'package:foodam/core/widgets/app_loading.dart';
import 'package:foodam/core/widgets/app_section_header.dart';
import 'package:foodam/src/domain/entities/dish_entity.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';
import 'package:foodam/src/presentation/cubits/susbcription/subscription_cubit.dart';
import 'package:foodam/src/presentation/cubits/susbcription/susbcription_state.dart';
import 'package:foodam/src/presentation/screens/meal_customization_screen.dart';
import 'package:foodam/src/presentation/screens/payment_summary_screen.dart';
import 'package:foodam/src/presentation/widgets/meal_preference_card.dart';
import 'package:intl/intl.dart';

class PlanDetailsScreen extends StatefulWidget {
  final Subscription subscription;

  const PlanDetailsScreen({
    Key? key,
    required this.subscription,
  }) : super(key: key);

  @override
  State<PlanDetailsScreen> createState() => _PlanDetailsScreenState();
}

class _PlanDetailsScreenState extends State<PlanDetailsScreen> {
  late Subscription _subscription;
  bool _hasChanges = false;
  DateTime _startDate = DateTime.now().add(const Duration(days: 1));

  @override
  void initState() {
    super.initState();
    _subscription = widget.subscription;
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
        _hasChanges = true;
      });
    }
  }

  void _customizeMealPreference(MealPreference preference) async {
    // Find a meal to customize based on the preference
    // In a real app, you'd fetch this from a repository
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MealCustomizationScreen(
          mealId: 'meal1', // This would come from your repository
          mealType: preference.mealType,
        ),
      ),
    );

    if (result != null) {
      // Handle customization result
      setState(() {
        // Update the meal preference with customized options
        // This is simplified - in a real app, you'd update the specific preference
        _hasChanges = true;
      });
    }
  }

  void _saveDraft() {
    // Update dates in subscription
    final updatedSubscription = Subscription(
      id: _subscription.id,
      userId: _subscription.userId,
      duration: _subscription.duration,
      startDate: _startDate,
      endDate: _startDate.add(Duration(days: _subscription.durationInDays)),
      status: _subscription.status,
      basePrice: _subscription.basePrice,
      totalPrice: _subscription.totalPrice,
      isCustomized: true,
      mealPreferences: _subscription.mealPreferences,
      deliverySchedule: _subscription.deliverySchedule,
      deliveryAddress: _subscription.deliveryAddress,
      paymentMethodId: _subscription.paymentMethodId,
      createdAt: _subscription.createdAt,
      updatedAt: DateTime.now(),
    );

    context.read<SubscriptionCubit>().saveDraftSubscription(updatedSubscription);
  }

  void _proceedToPayment() {
    // Update dates in subscription
    final updatedSubscription = Subscription(
      id: _subscription.id,
      userId: _subscription.userId,
      duration: _subscription.duration,
      startDate: _startDate,
      endDate: _startDate.add(Duration(days: _subscription.durationInDays)),
      status: _subscription.status,
      basePrice: _subscription.basePrice,
      totalPrice: _subscription.totalPrice,
      isCustomized: true,
      mealPreferences: _subscription.mealPreferences,
      deliverySchedule: _subscription.deliverySchedule,
      deliveryAddress: _subscription.deliveryAddress,
      paymentMethodId: _subscription.paymentMethodId,
      createdAt: _subscription.createdAt,
      updatedAt: DateTime.now(),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentSummaryScreen(
          subscription: updatedSubscription,
        ),
      ),
    );
  }

  void _handleBackPress() {
    if (_hasChanges) {
      AppDialogs.showConfirmationDialog(
        context: context,
        title: StringConstants.discardCustomizations,
        message: StringConstants.discardCustomizationsMessage,
        confirmText: StringConstants.saveDraft,
        cancelText: StringConstants.discard,
      ).then((value) {
        if (value == true) {
          // Save draft
          _saveDraft();
          Navigator.pop(context);
        } else {
          // Discard changes
          Navigator.pop(context);
        }
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: StringConstants.planDetails,
      onBackPressed: _handleBackPress,
      body: BlocListener<SubscriptionCubit, SubscriptionState>(
        listener: (context, state) {
          if (state is DraftSubscriptionSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(StringConstants.draftSaved),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.pop(context);
          } else if (state is SubscriptionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Plan info card
            _buildPlanInfoCard(),
            AppSpacing.vLg,
            
            // Start date selector
            AppSectionHeader(title: StringConstants.startDate),
            AppSpacing.vSm,
            _buildDateSelector(),
            AppSpacing.vLg,
            
            // Meal preferences
            AppSectionHeader(title: 'Meal Preferences'),
            AppSpacing.vSm,
            ...(_subscription.mealPreferences.map((pref) => _buildMealPreferenceCard(pref)).toList()),
            AppSpacing.vLg,
            
            // Buttons
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: StringConstants.saveDraft,
                    onPressed: _saveDraft,
                    buttonType: AppButtonType.outline,
                    buttonSize: AppButtonSize.medium,
                  ),
                ),
                AppSpacing.hMd,
                Expanded(
                  child: AppButton(
                    label: StringConstants.proceedToPayment,
                    onPressed: _proceedToPayment,
                    buttonType: AppButtonType.primary,
                    buttonSize: AppButtonSize.medium,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanInfoCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getPlanName(),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          AppSpacing.vSm,
          Text(
            '${StringConstants.duration}: ${_subscription.durationInDays} days',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          AppSpacing.vSm,
          Text(
            StringConstants.dailyBreakfastLunchDinner,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                StringConstants.totalPrice,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                '₹${_subscription.totalPrice.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    final formatter = DateFormat('dd MMM yyyy');
    
    return GestureDetector(
      onTap: _selectStartDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.divider),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              formatter.format(_startDate),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Icon(Icons.calendar_today, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildMealPreferenceCard(MealPreference preference) {
    // Format meal type for display (capitalize first letter)
    final formattedMealType =
        preference.mealType.substring(0, 1).toUpperCase() +
        preference.mealType.substring(1);
    
    return MealPreferenceCard(
      title: formattedMealType,
      dietaryPreferences: preference.preferences,
      quantity: preference.quantity,
      onCustomize: () => _customizeMealPreference(preference),
    );
  }

  String _getPlanName() {
    // This is a simplified implementation
    // In a real app, you'd have more information on the subscription
    bool hasVegetarianMeals = _subscription.mealPreferences.any(
      (pref) => pref.preferences.contains(DietaryPreference.vegetarian),
    );
    
    bool hasNonVegetarianMeals = _subscription.mealPreferences.any(
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