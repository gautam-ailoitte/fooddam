// lib/features/subscriptions/widgets/subscription_status_card.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/widgets/primary_button.dart';
import 'package:foodam/core/widgets/secondary_button.dart';
import 'package:foodam/src/domain/entities/address_entity.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';

class SubscriptionStatusCard extends StatelessWidget {
  final Subscription subscription;
  final int daysRemaining;

  const SubscriptionStatusCard({
    super.key,
    required this.subscription,
    required this.daysRemaining,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = subscription.status == SubscriptionStatus.active && !subscription.isPaused;
    final bool isPaused = subscription.isPaused || subscription.status == SubscriptionStatus.paused;
    
    return Card(
      child: Container(
        padding: EdgeInsets.all(AppDimensions.marginMedium),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildStatusIndicator(subscription),
                SizedBox(width: AppDimensions.marginSmall),
                Expanded(
                  child: Text(
                    'Weekly Subscription',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppDimensions.marginMedium),
            
            if (isActive) ...[
              _buildInfoRow(
                context, 
                'Status', 
                'Active', 
                valueColor: AppColors.success
              ),
              SizedBox(height: AppDimensions.marginSmall),
              _buildInfoRow(
                context, 
                'Next Delivery', 
                _calculateNextDeliveryText(subscription),
              ),
            ] else if (isPaused) ...[
              _buildInfoRow(
                context, 
                'Status', 
                'Paused', 
                valueColor: AppColors.warning
              ),
              SizedBox(height: AppDimensions.marginSmall),
              _buildInfoRow(
                context, 
                'Resumes On', 
                'Manually paused', // Ideally would show the resume date
              ),
            ] else ...[
              _buildInfoRow(
                context, 
                'Status', 
                _getStatusText(subscription.status), 
                valueColor: _getStatusColor(subscription.status)
              ),
            ],
            
            SizedBox(height: AppDimensions.marginSmall),
            _buildInfoRow(
              context, 
              'Subscription Ends In', 
              '$daysRemaining days',
            ),
            
            SizedBox(height: AppDimensions.marginMedium),
            
            // Progress indicator for subscription duration
            if (subscription.durationDays > 0) ...[
              LinearProgressIndicator(
                value: _calculateProgressValue(subscription, daysRemaining),
                backgroundColor: Colors.grey,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isActive ? AppColors.primary : 
                  isPaused ? AppColors.warning : 
                  AppColors.textSecondary,
                ),
              ),
              SizedBox(height: AppDimensions.marginSmall),
              Text(
                '${subscription.durationDays - daysRemaining} days completed out of ${subscription.durationDays} days',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(Subscription subscription) {
    Color color;
    if (subscription.isPaused || subscription.status == SubscriptionStatus.paused) {
      color = AppColors.warning;
    } else if (subscription.status == SubscriptionStatus.active) {
      color = AppColors.success;
    } else if (subscription.status == SubscriptionStatus.cancelled) {
      color = AppColors.error;
    } else if (subscription.status == SubscriptionStatus.expired) {
      color = AppColors.textSecondary;
    } else {
      color = AppColors.warning;
    }
    
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, 
    String label, 
    String value, {
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  String _calculateNextDeliveryText(Subscription subscription) {
    // This would calculate the next delivery date based on the subscription
    // For now, just return a placeholder
    final now = DateTime.now();
    now.add(Duration(days: 1));
    return 'Tomorrow';
  }

  String _getStatusText(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.pending:
        return 'Pending';
      case SubscriptionStatus.active:
        return 'Active';
      case SubscriptionStatus.paused:
        return 'Paused';
      case SubscriptionStatus.cancelled:
        return 'Cancelled';
      case SubscriptionStatus.expired:
        return 'Expired';
    }
  }

  Color _getStatusColor(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.pending:
        return AppColors.warning;
      case SubscriptionStatus.active:
        return AppColors.success;
      case SubscriptionStatus.paused:
        return AppColors.warning;
      case SubscriptionStatus.cancelled:
        return AppColors.error;
      case SubscriptionStatus.expired:
        return AppColors.textSecondary;
    }
  }

  double _calculateProgressValue(Subscription subscription, int daysRemaining) {
    if (subscription.durationDays <= 0) return 0.0;
    
    final daysCompleted = subscription.durationDays - daysRemaining;
    return daysCompleted / subscription.durationDays;
  }
}



class SubscriptionActionCard extends StatelessWidget {
  final bool isActive;
  final bool isPaused;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onCancel;

  const SubscriptionActionCard({
    super.key,
    required this.isActive,
    required this.isPaused,
    required this.onPause,
    required this.onResume,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.marginMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Subscription Actions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: AppDimensions.marginMedium),

            // First button - Pause or Resume based on status
            if (isActive) ...[
              _buildActionButton(
                context,
                'Pause Subscription',
                Icons.pause,
                AppColors.warning,
                onPause,
              ),
              SizedBox(height: AppDimensions.marginMedium),
            ] else if (isPaused) ...[
              _buildActionButton(
                context,
                'Resume Subscription',
                Icons.play_arrow,
                AppColors.success,
                onResume,
              ),
              SizedBox(height: AppDimensions.marginMedium),
            ],

            // Cancel button - Always available for active or paused subscriptions
            if (isActive || isPaused) ...[
              _buildActionButton(
                context,
                'Cancel Subscription',
                Icons.cancel,
                AppColors.error,
                onCancel,
              ),
            ] else ...[
              // For cancelled or expired subscriptions
              Center(
                child: Text(
                  'No actions available for this subscription',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: color),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: color, side: BorderSide(color: color),
        padding: EdgeInsets.symmetric(
          vertical: AppDimensions.marginSmall,
          horizontal: AppDimensions.marginMedium,
        ),
        minimumSize: Size(double.infinity, 48),
      ),
    );
  }
}


typedef DateCallback = void Function(DateTime);

class PauseDialog extends StatefulWidget {
  final DateCallback onConfirm;

  const PauseDialog({
    super.key,
    required this.onConfirm,
  });

  @override
  _PauseDialogState createState() => _PauseDialogState();
}

class _PauseDialogState extends State<PauseDialog> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    // Default pause until 7 days from now
    _selectedDate = DateTime.now().add(Duration(days: 7));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Pause Subscription'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your subscription will be paused until the selected date. No deliveries will be made during this period.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(height: AppDimensions.marginLarge),
          Text(
            'Pause Until:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppDimensions.marginSmall),
          _buildDatePicker(context),
        ],
      ),
      actions: [
        SecondaryButton(
          text: 'Cancel',
          onPressed: () => Navigator.pop(context),
        ),
        PrimaryButton(
          text: 'Pause',
          onPressed: () => widget.onConfirm(_selectedDate),
        ),
      ],
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return InkWell(
      onTap: () => _showDatePicker(context),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.marginMedium,
          vertical: AppDimensions.marginSmall,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.textSecondary),
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatDate(_selectedDate),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Icon(
              Icons.calendar_today,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().add(Duration(days: 1)),
      lastDate: DateTime.now().add(Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}


class CalendarView extends StatelessWidget {
  final Subscription subscription;

  const CalendarView({
    Key? key,
    required this.subscription,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Group slots by day
    final Map<String, List<dynamic>> slotsByDay = {};
    for (final slot in subscription.slots) {
      if (!slotsByDay.containsKey(slot.day)) {
        slotsByDay[slot.day] = [];
      }
      slotsByDay[slot.day]!.add({
        'timing': slot.timing,
        'mealId': slot.mealId,
        'meal': slot.meal,
      });
    }

    // Sort days of the week in order
    final List<String> sortedDays = _getSortedDays(slotsByDay.keys.toList());

    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.marginMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...sortedDays.map((day) => _buildDayRow(context, day, slotsByDay[day]!)),
          ],
        ),
      ),
    );
  }

  Widget _buildDayRow(BuildContext context, String day, List<dynamic> slots) {
    // Sort slots by timing
    slots.sort((a, b) => _compareTiming(a['timing'], b['timing']));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Day header
        Container(
          padding: EdgeInsets.symmetric(
            vertical: AppDimensions.marginSmall,
          ),
          child: Text(
            _formatDay(day),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        
        // Meals for this day
        Padding(
          padding: EdgeInsets.only(left: AppDimensions.marginMedium),
          child: Column(
            children: slots.map((slot) => _buildMealRow(context, slot)).toList(),
          ),
        ),
        
        Divider(),
      ],
    );
  }

  Widget _buildMealRow(BuildContext context, Map<String, dynamic> slot) {
    final mealName = slot['meal']?.name ?? 'Selected Meal';
    
    return Padding(
      padding: EdgeInsets.only(bottom: AppDimensions.marginSmall),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: _getTimingColor(slot['timing']).withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
            ),
            child: Text(
              _formatTiming(slot['timing']),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _getTimingColor(slot['timing']),
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          SizedBox(width: AppDimensions.marginSmall),
          Expanded(
            child: Text(
              mealName,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getSortedDays(List<String> days) {
    final List<String> sortedDays = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    return sortedDays.where((day) => days.contains(day)).toList();
  }

  int _compareTiming(String a, String b) {
    final List<String> order = ['breakfast', 'lunch', 'dinner'];
    return order.indexOf(a.toLowerCase()) - order.indexOf(b.toLowerCase());
  }

  String _formatDay(String day) {
    return day.substring(0, 1).toUpperCase() + day.substring(1);
  }

  String _formatTiming(String timing) {
    return timing.substring(0, 1).toUpperCase() + timing.substring(1);
  }

  Color _getTimingColor(String timing) {
    switch (timing.toLowerCase()) {
      case 'breakfast':
        return Colors.orange;
      case 'lunch':
        return AppColors.primary;
      case 'dinner':
        return Colors.purple;
      default:
        return AppColors.textSecondary;
    }
  }
}



class DeliveryAddressCard extends StatelessWidget {
  final Address address;

  const DeliveryAddressCard({
    Key? key,
    required this.address,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.marginMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: AppColors.primary,
                ),
                SizedBox(width: AppDimensions.marginSmall),
                Expanded(
                  child: Text(
                    'Delivery Location',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppDimensions.marginMedium),
            Padding(
              padding: EdgeInsets.only(left: AppDimensions.marginLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address.street,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${address.city}, ${address.state} ${address.zipCode}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}