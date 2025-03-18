// lib/src/presentation/widgets/subscription/delivery_schedule_card.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/widgets/app_card.dart';
import 'package:foodam/src/domain/entities/address_entity.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';

class DeliveryScheduleCard extends StatelessWidget {
  final DeliverySchedule deliverySchedule;
  final Address address;

  const DeliveryScheduleCard({
    Key? key,
    required this.deliverySchedule,
    required this.address,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Delivery days
          Text(
            'Delivery Days',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          _buildDaysSelector(context),
          const SizedBox(height: 16),
          
          // Time slot
          Text(
            'Preferred Time Slot',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          _buildTimeSlot(context),
          const SizedBox(height: 16),
          
          // Address
          Text(
            'Delivery Address',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  address.fullAddress,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDaysSelector(BuildContext context) {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(
        7,
        (index) {
          final dayIndex = index + 1; // 1-based index for DeliverySchedule
          final isSelected = deliverySchedule.daysOfWeek.contains(dayIndex);
          
          return Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? AppColors.primary : Colors.transparent,
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.divider,
                width: isSelected ? 0 : 1,
              ),
            ),
            child: Center(
              child: Text(
                weekdays[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeSlot(BuildContext context) {
    final String timeSlotText;
    final IconData timeSlotIcon;
    
    switch (deliverySchedule.preferredTimeSlot.toLowerCase()) {
      case 'morning':
        timeSlotText = '8:00 AM - 11:00 AM';
        timeSlotIcon = Icons.wb_sunny;
        break;
      case 'afternoon':
        timeSlotText = '12:00 PM - 3:00 PM';
        timeSlotIcon = Icons.wb_cloudy;
        break;
      case 'evening':
        timeSlotText = '4:00 PM - 7:00 PM';
        timeSlotIcon = Icons.nights_stay;
        break;
      default:
        timeSlotText = 'Any Time';
        timeSlotIcon = Icons.access_time;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            timeSlotIcon,
            size: 20,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Text(
            timeSlotText,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}