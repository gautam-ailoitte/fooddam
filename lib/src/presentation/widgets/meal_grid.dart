// lib/src/presentation/widgets/meal_grid.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/src/domain/entities/meal_slot_entity.dart';
import 'package:foodam/src/domain/entities/order_entity.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';
import 'package:intl/intl.dart';

import '../screens/orders/meal_detail_screen.dart';

class MealGrid extends StatelessWidget {
  final List<MealSlot> mealSlots;
  final Subscription subscription;
  final bool isCompact;

  const MealGrid({
    super.key,
    required this.mealSlots,
    required this.subscription,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    // Filter out slots without meals
    final slotsWithMeals =
        mealSlots.where((slot) => slot.meal != null).toList();

    print(
      '🔍 DEBUG: Total meal slots: ${mealSlots.length}, with meals: ${slotsWithMeals.length}',
    );
    print('🔍 DEBUG: Subscription start date: ${subscription.startDate}');

    if (slotsWithMeals.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.marginLarge),
          child: Text(
            'No meals scheduled',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
        ),
      );
    }

    return isCompact
        ? _buildCompactGrid(slotsWithMeals)
        : _buildDateOrganizedList(slotsWithMeals);
  }

  Widget _buildCompactGrid(List<MealSlot> slots) {
    print('🔍 DEBUG: Building compact grid with ${slots.length} slots');

    // Sort slots by date and timing
    slots.sort((a, b) {
      // First sort by date if available
      if (a.date != null && b.date != null) {
        final dateComparison = a.date!.compareTo(b.date!);
        if (dateComparison != 0) return dateComparison;
      }

      // Then by timing
      final timings = {'breakfast': 0, 'lunch': 1, 'dinner': 2};
      return (timings[a.timing.toLowerCase()] ?? 3).compareTo(
        timings[b.timing.toLowerCase()] ?? 3,
      );
    });

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.9, // Adjusted to prevent overflow
        crossAxisSpacing: AppDimensions.marginMedium,
        mainAxisSpacing: AppDimensions.marginMedium,
      ),
      itemCount: slots.length,
      itemBuilder: (context, index) {
        final slot = slots[index];
        return MealGridItem(
          slot: slot,
          subscription: subscription,
          isCompact: true,
        );
      },
    );
  }

  Widget _buildDateOrganizedList(List<MealSlot> slots) {
    print('🔍 DEBUG: Building date organized list with ${slots.length} slots');

    // Group slots by their actual date
    final Map<String, List<MealSlot>> slotsByDate = {};

    for (final slot in slots) {
      // Determine the slot date
      DateTime slotDate;

      if (slot.date != null) {
        // Use the date from the slot
        slotDate = slot.date!;
      } else {
        // Calculate date from day and subscription start date
        slotDate = _calculateDateFromDay(slot.day, subscription.startDate);
      }

      // Format as "YYYY-MM-DD" for unique grouping
      String dateKey = DateFormat('yyyy-MM-dd').format(slotDate);
      print('🔍 DEBUG: Date key for slot: $dateKey (${slot.meal?.name})');

      if (!slotsByDate.containsKey(dateKey)) {
        slotsByDate[dateKey] = [];
        print('🔍 DEBUG: Created new date group: $dateKey');
      }

      // Create a new slot with the calculated date
      final updatedSlot = MealSlot(
        day: slot.day,
        timing: slot.timing,
        meal: slot.meal,
        mealId: slot.mealId,
        date: slotDate,
      );

      slotsByDate[dateKey]!.add(updatedSlot);
    }

    // Sort date keys chronologically
    final sortedDateKeys = slotsByDate.keys.toList()..sort();

    print(
      '🔍 DEBUG: Grouped into ${sortedDateKeys.length} date groups: ${sortedDateKeys.join(', ')}',
    );

    if (sortedDateKeys.isEmpty) {
      return Center(child: Text('No meal information available'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: sortedDateKeys.length,
      itemBuilder: (context, index) {
        final dateKey = sortedDateKeys[index];
        final dateSlots = slotsByDate[dateKey]!;
        final date = DateTime.parse(dateKey);

        print(
          '🔍 DEBUG: Building section for date: $dateKey with ${dateSlots.length} meals',
        );

        // Sort slots by meal timing
        dateSlots.sort((a, b) {
          final timings = {'breakfast': 0, 'lunch': 1, 'dinner': 2};
          return (timings[a.timing.toLowerCase()] ?? 3).compareTo(
            timings[b.timing.toLowerCase()] ?? 3,
          );
        });

        // Format the date for display
        final dateFormat = DateFormat('EEEE, MMMM d');
        final displayDate = dateFormat.format(date);

        return Card(
          margin: EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Enhanced date header
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getDateColor(date).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: _getDateColor(date),
                      ),
                      SizedBox(width: 6),
                      Text(
                        displayDate,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: _getDateColor(date),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(height: 1),
              // Meals for this day
              ...dateSlots.map(
                (slot) => MealGridItem(
                  slot: slot,
                  subscription: subscription,
                  isCompact: false,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Calculate which day of the week a slot falls on based on the subscription start date
  DateTime _calculateDateFromDay(String day, DateTime startDate) {
    final days = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];

    print(
      '🔍 DEBUG: Calculating date from day: $day with start date: $startDate',
    );

    // If day is unknown or invalid, assume it's the start date
    if (!days.contains(day.toLowerCase())) {
      print('🔍 DEBUG: Unknown day "$day", using start date: $startDate');
      return startDate;
    }

    final targetDayIndex = days.indexOf(day.toLowerCase());
    // Start from subscription start date
    final startDayIndex = startDate.weekday - 1; // 0-6 for Mon-Sun

    // Calculate how many days to add to get to the target day
    int daysToAdd = (targetDayIndex - startDayIndex) % 7;
    final date = startDate.add(Duration(days: daysToAdd));

    print(
      '🔍 DEBUG: Calculated date for $day: $date (weekday: ${date.weekday})',
    );
    return date;
  }

  Color _getDateColor(DateTime date) {
    // Check if date is today
    final now = DateTime.now();
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;

    if (isToday) {
      return AppColors.primary;
    }

    // Color based on weekday
    switch (date.weekday) {
      case 1:
        return Colors.blue; // Monday
      case 2:
        return Colors.green; // Tuesday
      case 3:
        return Colors.purple; // Wednesday
      case 4:
        return Colors.orange; // Thursday
      case 5:
        return Colors.teal; // Friday
      case 6:
        return Colors.indigo; // Saturday
      case 7:
        return Colors.red; // Sunday
      default:
        return AppColors.primary;
    }
  }
}

class MealGridItem extends StatelessWidget {
  final MealSlot slot;
  final Subscription subscription;
  final bool isCompact;

  const MealGridItem({
    Key? key,
    required this.slot,
    required this.subscription,
    this.isCompact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final meal = slot.meal!;

    return InkWell(
      onTap: () {
        // Convert MealSlot to Order for the detail screen
        final order = _createOrderFromSlot(slot, subscription);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderMealDetailScreen(order: order),
          ),
        );
      },
      child: Card(
        elevation: isCompact ? 0.5 : 0,
        margin: isCompact ? EdgeInsets.zero : EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            isCompact ? AppDimensions.borderRadiusMedium : 0,
          ),
        ),
        child: isCompact ? _buildCompactContent() : _buildFullContent(),
      ),
    );
  }

  Widget _buildCompactContent() {
    final meal = slot.meal!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image with fixed height
        ClipRRect(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.borderRadiusMedium),
          ),
          child: SizedBox(
            height: 100,
            width: double.infinity,
            child:
                meal.imageUrl != null
                    ? Image.network(
                      meal.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => Container(
                            color: AppColors.primary.withOpacity(0.1),
                            child: Icon(
                              _getMealIcon(slot.timing),
                              size: 40,
                              color: AppColors.primary,
                            ),
                          ),
                    )
                    : Container(
                      color: AppColors.primary.withOpacity(0.1),
                      child: Icon(
                        _getMealIcon(slot.timing),
                        size: 40,
                        color: AppColors.primary,
                      ),
                    ),
          ),
        ),
        // Content area with expanded to contain text
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Meal name limited to 1 line with ellipsis
                Text(
                  meal.name,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                // Timing with icon in a row
                Row(
                  children: [
                    Icon(
                      _getMealIcon(slot.timing),
                      size: 12,
                      color: _getMealColor(slot.timing),
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _formatTiming(slot.timing),
                        style: TextStyle(
                          fontSize: 11,
                          color: _getMealColor(slot.timing),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                // Add date for clarity
                if (slot.date != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      DateFormat('MMM d').format(slot.date!),
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFullContent() {
    final meal = slot.meal!;

    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 80, // Fixed width
              height: 80, // Fixed height
              child:
                  meal.imageUrl != null
                      ? Image.network(
                        meal.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => Container(
                              color: AppColors.primary.withOpacity(0.1),
                              child: Icon(
                                _getMealIcon(slot.timing),
                                size: 30,
                                color: AppColors.primary,
                              ),
                            ),
                      )
                      : Container(
                        color: AppColors.primary.withOpacity(0.1),
                        child: Icon(
                          _getMealIcon(slot.timing),
                          size: 30,
                          color: AppColors.primary,
                        ),
                      ),
            ),
          ),

          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getMealColor(slot.timing).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getMealIcon(slot.timing),
                              size: 14,
                              color: _getMealColor(slot.timing),
                            ),
                            SizedBox(width: 4),
                            Text(
                              _formatTiming(slot.timing),
                              style: TextStyle(
                                fontSize: 12,
                                color: _getMealColor(slot.timing),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Text(
                    meal.name,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    maxLines: 2, // Allow 2 lines
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2),
                  if (meal.description.isNotEmpty)
                    Text(
                      meal.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1, // Limit to 1 line
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ),

          // Price
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '₹${meal.price.toStringAsFixed(0)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Order _createOrderFromSlot(MealSlot slot, Subscription subscription) {
    // Use the date from the slot if available, otherwise calculate it
    final date =
        slot.date ?? _calculateDateFromDay(slot.day, subscription.startDate);

    return Order();
    // return Order(
    //   dish: slot.meal!!,
    //   timing: slot.timing,
    //   subscriptionId: subscription.id,
    //   date: date,
    //   status: _determineOrderStatus(date),
    //   deliveredAt: null,
    // );
  }

  DateTime _calculateDateFromDay(String day, DateTime startDate) {
    final days = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];

    // If day is unknown or invalid, assume it's the start date
    if (!days.contains(day.toLowerCase())) {
      return startDate;
    }

    final targetDayIndex = days.indexOf(day.toLowerCase());
    final startDayIndex = startDate.weekday - 1; // 0-6 for Mon-Sun

    // Calculate how many days to add to get to the target day
    int daysToAdd = (targetDayIndex - startDayIndex) % 7;
    return startDate.add(Duration(days: daysToAdd));
  }

  OrderStatus _determineOrderStatus(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final orderDate = DateTime(date.year, date.month, date.day);

    if (orderDate.isBefore(today)) {
      return OrderStatus.delivered;
    } else if (orderDate.isAtSameMomentAs(today)) {
      return OrderStatus.onTheWay;
    } else {
      return OrderStatus.pending;
    }
  }

  IconData _getMealIcon(String timing) {
    switch (timing.toLowerCase()) {
      case 'breakfast':
        return Icons.free_breakfast;
      case 'lunch':
        return Icons.lunch_dining;
      case 'dinner':
        return Icons.dinner_dining;
      default:
        return Icons.restaurant;
    }
  }

  Color _getMealColor(String timing) {
    switch (timing.toLowerCase()) {
      case 'breakfast':
        return Colors.orange;
      case 'lunch':
        return AppColors.accent;
      case 'dinner':
        return Colors.purple;
      default:
        return AppColors.primary;
    }
  }

  String _formatTiming(String timing) {
    if (timing.isEmpty) return 'Meal';
    return timing.substring(0, 1).toUpperCase() + timing.substring(1);
  }
}
