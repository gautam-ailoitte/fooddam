// / lib/src/presentation/pages/subscription/subscription_details_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/constants/string_constants.dart';
import 'package:foodam/core/layout/app_scaffold.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/widgets/app_button.dart';
import 'package:foodam/core/widgets/app_card.dart';
import 'package:foodam/core/widgets/app_section_header.dart';
import 'package:foodam/src/domain/entities/dish_entity.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';
import 'package:foodam/src/presentation/cubits/subscription/subscription_cubit.dart';
import 'package:intl/intl.dart';

class SubscriptionDetailsPage extends StatelessWidget {
  static const routeName = '/subscription-details';

  final Subscription subscription;

  const SubscriptionDetailsPage({
    super.key,
    required this.subscription,
  });

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: StringConstants.planDetails,
      type: ScaffoldType.withAppBar,
      body: SingleChildScrollView(
        padding: AppSpacing.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSubscriptionOverview(context),
            AppSpacing.vLg,
            _buildMealPreferences(context),
            AppSpacing.vLg,
            _buildDeliverySchedule(context),
            AppSpacing.vLg,
            _buildDeliveryAddress(context),
            AppSpacing.vLg,
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionOverview(BuildContext context) {
    final daysRemaining = subscription.endDate.difference(DateTime.now()).inDays;
    final isExpired = daysRemaining < 0;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getSubscriptionTitle(),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isExpired ? AppColors.error : _getStatusColor(subscription.status),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getStatusText(subscription.status),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.vMd,
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  context,
                  label: 'Start Date',
                  value: DateFormat('MMM dd, yyyy').format(subscription.startDate),
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  context,
                  label: 'End Date',
                  value: DateFormat('MMM dd, yyyy').format(subscription.endDate),
                ),
              ),
            ],
          ),
          AppSpacing.vSm,
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  context,
                  label: 'Duration',
                  value: _getDurationText(subscription.duration),
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  context,
                  label: 'Price',
                  value: '₹${subscription.totalPrice.toInt()}',
                ),
              ),
            ],
          ),
          AppSpacing.vMd,
          if (!isExpired) ...[
            LinearProgressIndicator(
              value: 1 - (daysRemaining / subscription.durationInDays),
              backgroundColor: AppColors.backgroundLight,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            AppSpacing.vSm,
            Text(
              '$daysRemaining ${StringConstants.daysRemaining}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.accent,
              ),
            ),
          ] else ...[
            Text(
              StringConstants.planExpired,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.error,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        AppSpacing.vXs,
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildMealPreferences(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          title: 'Meal Preferences',
        ),
        ...subscription.mealPreferences.map(
          (pref) => AppCard(
            margin: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _getMealTypeIcon(pref.mealType),
                    AppSpacing.hSm,
                    Text(
                      _getMealTypeText(pref.mealType),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                AppSpacing.vSm,
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: pref.preferences.map(
                    (dietPref) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getDietaryPreferenceColor(dietPref).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getDietaryPreferenceText(dietPref),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getDietaryPreferenceColor(dietPref),
                        ),
                      ),
                    ),
                  ).toList(),
                ),
                if (pref.excludedIngredients != null &&
                    pref.excludedIngredients!.isNotEmpty) ...[
                  AppSpacing.vSm,
                  Text(
                    'Excluded Ingredients:',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  AppSpacing.vXs,
                  Text(
                    pref.excludedIngredients!.join(', '),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
        ).toList(),
      ],
    );
  }

  Widget _buildDeliverySchedule(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          title: 'Delivery Schedule',
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Delivery Days:',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              AppSpacing.vXs,
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: subscription.deliverySchedule.daysOfWeek.map(
                  (day) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getDayText(day),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ).toList(),
              ),
              AppSpacing.vSm,
              Text(
                'Preferred Time Slot:',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              AppSpacing.vXs,
              Text(
                _getTimeSlotText(subscription.deliverySchedule.preferredTimeSlot),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryAddress(BuildContext context) {
    final address = subscription.deliveryAddress;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          title: 'Delivery Address',
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    color: AppColors.primary,
                  ),
                  AppSpacing.hSm,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          address.street,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          '${address.city}, ${address.state} ${address.zipCode}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          address.country,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final isActive = subscription.status == SubscriptionStatus.active;
    final isPaused = subscription.status == SubscriptionStatus.paused;

    return Row(
      children: [
        Expanded(
          child: AppButton(
            label: isPaused ? 'Resume' : 'Pause',
            onPressed: isActive || isPaused
                ? () {
                    if (isPaused) {
                      context
                          .read<SubscriptionCubit>()
                          .resumeSubscription(subscription.id);
                    } else {
                      _showPauseDialog(context);
                    }
                  }
                : null,
            buttonType: AppButtonType.outline,
            buttonSize: AppButtonSize.medium,
            leadingIcon: isPaused ? Icons.play_arrow : Icons.pause,
          ),
        ),
        AppSpacing.hMd,
        Expanded(
          child: AppButton(
            label: 'Cancel',
            onPressed: isActive || isPaused
                ? () {
                    _showCancelDialog(context);
                  }
                : null,
            buttonType: AppButtonType.secondary,
            buttonSize: AppButtonSize.medium,
            backgroundColor: AppColors.error,
            leadingIcon: Icons.cancel_outlined,
          ),
        ),
      ],
    );
  }

  void _showPauseDialog(BuildContext context) {
    DateTime resumeDate = DateTime.now().add(const Duration(days: 1));

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Pause Subscription'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('When would you like to resume your deliveries?'),
                AppSpacing.vMd,
                InkWell(
                  onTap: () async {
                    final DateTime now = DateTime.now();
                    final DateTime firstDate = now.add(const Duration(days: 1));
                    final DateTime lastDate = now.add(const Duration(days: 30));

                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: resumeDate,
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

                    if (picked != null) {
                      setState(() {
                        resumeDate = picked;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.divider),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 20),
                        AppSpacing.hSm,
                        Text(DateFormat('EEE, MMM d, yyyy').format(resumeDate)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context
                      .read<SubscriptionCubit>()
                      .pauseSubscription(subscription.id, resumeDate);
                },
                child: const Text('Pause'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    String reason = 'No longer needed';

    final reasons = [
      'No longer needed',
      'Too expensive',
      'Food quality issues',
      'Delivery issues',
      'Moving away',
      'Other',
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Cancel Subscription'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                    'Are you sure you want to cancel your subscription? This action cannot be undone.'),
                AppSpacing.vMd,
                const Text('Please tell us why you\'re cancelling:'),
                AppSpacing.vSm,
                DropdownButtonFormField<String>(
                  value: reason,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: reasons
                      .map((r) => DropdownMenuItem<String>(
                            value: r,
                            child: Text(r),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        reason = value;
                      });
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Back'),
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () {
                  Navigator.of(context).pop();
                  context
                      .read<SubscriptionCubit>()
                      .cancelSubscription(subscription.id, reason);
                },
                child: const Text('Cancel Subscription'),
              ),
            ],
          );
        },
      ),
    );
  }

  String _getSubscriptionTitle() {
    final hasDietaryPreferences = subscription.mealPreferences.isNotEmpty;
    
    if (hasDietaryPreferences) {
      final firstPref = subscription.mealPreferences.first;
      if (firstPref.preferences.contains(DietaryPreference.vegetarian)) {
        return StringConstants.vegetarianPlan;
      } else if (firstPref.preferences.contains(DietaryPreference.nonVegetarian)) {
        return StringConstants.nonVegetarianPlan;
      }
    }
    
    return 'Meal Subscription';
  }

  String _getDurationText(SubscriptionDuration duration) {
    switch (duration) {
      case SubscriptionDuration.sevenDays:
        return '7 Days';
      case SubscriptionDuration.fourteenDays:
        return '14 Days';
      case SubscriptionDuration.twentyEightDays:
        return '28 Days';
      case SubscriptionDuration.monthly:
        return 'Monthly';
      case SubscriptionDuration.quarterly:
        return 'Quarterly';
      case SubscriptionDuration.halfYearly:
        return 'Half Yearly';
      case SubscriptionDuration.yearly:
        return 'Yearly';
      case SubscriptionDuration.days30:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  Color _getStatusColor(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.active:
        return AppColors.success;
      case SubscriptionStatus.paused:
        return AppColors.warning;
      case SubscriptionStatus.cancelled:
        return AppColors.error;
      case SubscriptionStatus.expired:
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusText(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.active:
        return 'Active';
      case SubscriptionStatus.paused:
        return 'Paused';
      case SubscriptionStatus.cancelled:
        return 'Cancelled';
      case SubscriptionStatus.expired:
        return 'Expired';
      default:
        return 'Unknown';
    }
  }

  Widget _getMealTypeIcon(String mealType) {
    IconData icon;
    Color color;

    switch (mealType.toLowerCase()) {
      case 'breakfast':
        icon = Icons.free_breakfast;
        color = Colors.orange;
        break;
      case 'lunch':
        icon = Icons.lunch_dining;
        color = Colors.green;
        break;
      case 'dinner':
        icon = Icons.dinner_dining;
        color = Colors.deepPurple;
        break;
      default:
        icon = Icons.restaurant;
        color = AppColors.primary;
    }

    return Icon(icon, color: color);
  }

  String _getMealTypeText(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return 'Breakfast';
      case 'lunch':
        return 'Lunch';
      case 'dinner':
        return 'Dinner';
      default:
        return mealType;
    }
  }

  Color _getDietaryPreferenceColor(DietaryPreference preference) {
    switch (preference) {
      case DietaryPreference.vegetarian:
        return AppColors.vegetarian;
      case DietaryPreference.nonVegetarian:
        return AppColors.nonVegetarian;
      case DietaryPreference.vegan:
        return Colors.green.shade800;
      case DietaryPreference.glutenFree:
        return Colors.amber.shade800;
      case DietaryPreference.dairyFree:
        return Colors.lightBlue;
      case DietaryPreference.nutFree:
        return Colors.brown;
      case DietaryPreference.pescatarian:
        return Colors.blue;
      case DietaryPreference.keto:
        return Colors.purple;
      case DietaryPreference.paleo:
        return Colors.orange.shade800;
    }
  }

  String _getDietaryPreferenceText(DietaryPreference preference) {
    switch (preference) {
      case DietaryPreference.vegetarian:
        return 'Vegetarian';
      case DietaryPreference.nonVegetarian:
        return 'Non-Vegetarian';
      case DietaryPreference.vegan:
        return 'Vegan';
      case DietaryPreference.glutenFree:
        return 'Gluten Free';
      case DietaryPreference.dairyFree:
        return 'Dairy Free';
      case DietaryPreference.nutFree:
        return 'Nut Free';
      case DietaryPreference.pescatarian:
        return 'Pescatarian';
      case DietaryPreference.keto:
        return 'Keto';
      case DietaryPreference.paleo:
        return 'Paleo';
    }
  }

  String _getDayText(int day) {
    switch (day) {
      case 1:
        return StringConstants.monday;
      case 2:
        return StringConstants.tuesday;
      case 3:
        return StringConstants.wednesday;
      case 4:
        return StringConstants.thursday;
      case 5:
        return StringConstants.friday;
      case 6:
        return StringConstants.saturday;
      case 7:
        return StringConstants.sunday;
      default:
        return 'Day $day';
    }
  }

  String _getTimeSlotText(String timeSlot) {
    switch (timeSlot.toLowerCase()) {
      case 'morning':
        return '7:00 AM - 10:00 AM';
      case 'afternoon':
        return '12:00 PM - 3:00 PM';
      case 'evening':
        return '6:00 PM - 9:00 PM';
      default:
        return timeSlot;
    }
  }
}