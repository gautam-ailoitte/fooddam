// lib/src/presentation/screens/subscription/subscription_meal_schedule_screen.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/theme/enhanced_app_them.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';
import 'package:intl/intl.dart';

class SubscriptionMealScheduleScreen extends StatefulWidget {
  final Subscription subscription;

  const SubscriptionMealScheduleScreen({super.key, required this.subscription});

  @override
  State<SubscriptionMealScheduleScreen> createState() =>
      _SubscriptionMealScheduleScreenState();
}

class _SubscriptionMealScheduleScreenState
    extends State<SubscriptionMealScheduleScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedWeekIndex = 0;

  @override
  void initState() {
    super.initState();

    // Initialize tab controller based on available weeks
    final weekCount = widget.subscription.weeks?.length ?? 0;
    _tabController = TabController(
      length: weekCount > 0 ? weekCount : 1,
      vsync: this,
    );

    // Listen to tab changes
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedWeekIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Schedule'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom:
            widget.subscription.weeks != null &&
                    widget.subscription.weeks!.isNotEmpty
                ? TabBar(
                  controller: _tabController,
                  isScrollable: widget.subscription.weeks!.length > 3,
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  tabs:
                      widget.subscription.weeks!.asMap().entries.map((entry) {
                        final index = entry.key;
                        final week = entry.value;
                        return Tab(
                          text: 'Week ${week.week}',
                          icon: Icon(
                            Icons.calendar_view_week,
                            size: 16,
                            color:
                                _selectedWeekIndex == index
                                    ? Colors.white
                                    : Colors.white70,
                          ),
                        );
                      }).toList(),
                )
                : null,
      ),
      body:
          widget.subscription.weeks == null ||
                  widget.subscription.weeks!.isEmpty
              ? _buildEmptyState()
              : TabBarView(
                controller: _tabController,
                children:
                    widget.subscription.weeks!
                        .map((week) => _buildWeekSchedule(week))
                        .toList(),
              ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.marginLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 80,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            SizedBox(height: AppDimensions.marginLarge),
            Text(
              'No Meal Schedule Available',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppDimensions.marginMedium),
            const Text(
              'Your meal schedule will be available once your subscription is activated.',
              style: TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekSchedule(dynamic week) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppDimensions.marginMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Week header with package info
          _buildWeekHeader(week),
          SizedBox(height: AppDimensions.marginLarge),

          // Days list
          if (week.slots != null && week.slots.isNotEmpty) ...[
            _buildDaysList(week.slots),
          ] else ...[
            _buildEmptyWeekState(),
          ],
        ],
      ),
    );
  }

  Widget _buildWeekHeader(dynamic week) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
      ),
      child: Container(
        decoration: EnhancedTheme.cardDecoration,
        padding: EdgeInsets.all(AppDimensions.marginMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.calendar_view_week,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                SizedBox(width: AppDimensions.marginSmall),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Week ${week.week}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (week.package != null) ...[
                        Text(
                          week.package.name ?? 'Package',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${week.slots?.length ?? 0} meals',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
            if (week.package?.description != null) ...[
              SizedBox(height: AppDimensions.marginMedium),
              Text(
                week.package.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDaysList(List<dynamic> slots) {
    // Group slots by date
    final Map<DateTime, List<dynamic>> slotsByDate = {};

    for (final slot in slots) {
      if (slot.date != null) {
        final date = DateTime(slot.date.year, slot.date.month, slot.date.day);
        slotsByDate.putIfAbsent(date, () => []);
        slotsByDate[date]!.add(slot);
      }
    }

    // Sort dates
    final sortedDates = slotsByDate.keys.toList()..sort();

    return Column(
      children:
          sortedDates.map((date) {
            final daySlots = slotsByDate[date]!;
            // Sort slots by timing (breakfast, lunch, dinner)
            daySlots.sort(
              (a, b) => _getMealTimeOrder(
                a.timing,
              ).compareTo(_getMealTimeOrder(b.timing)),
            );

            return Column(
              children: [
                _buildDayCard(date, daySlots),
                SizedBox(height: AppDimensions.marginMedium),
              ],
            );
          }).toList(),
    );
  }

  Widget _buildDayCard(DateTime date, List<dynamic> daySlots) {
    final isToday = _isToday(date);
    final isPast = date.isBefore(DateTime.now()) && !isToday;
    final dayName = DateFormat('EEEE').format(date);
    final dateFormatted = DateFormat('MMM d, yyyy').format(date);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
      ),
      child: Container(
        decoration: EnhancedTheme.cardDecoration.copyWith(
          border: Border.all(
            color:
                isToday
                    ? AppColors.primary.withOpacity(0.5)
                    : isPast
                    ? AppColors.textSecondary.withOpacity(0.2)
                    : AppColors.primary.withOpacity(0.2),
            width: isToday ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            // Day header
            Container(
              padding: EdgeInsets.all(AppDimensions.marginMedium),
              decoration: BoxDecoration(
                color:
                    isToday
                        ? AppColors.primary.withOpacity(0.1)
                        : isPast
                        ? AppColors.textSecondary.withOpacity(0.05)
                        : AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppDimensions.borderRadiusLarge),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          isToday
                              ? AppColors.primary.withOpacity(0.2)
                              : isPast
                              ? AppColors.textSecondary.withOpacity(0.1)
                              : AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isToday ? Icons.today : Icons.calendar_today,
                      color:
                          isToday
                              ? AppColors.primary
                              : isPast
                              ? AppColors.textSecondary
                              : AppColors.primary,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: AppDimensions.marginSmall),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              dayName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color:
                                    isToday
                                        ? AppColors.primary
                                        : isPast
                                        ? AppColors.textSecondary
                                        : AppColors.textPrimary,
                              ),
                            ),
                            if (isToday) ...[
                              SizedBox(width: AppDimensions.marginSmall),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'TODAY',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          dateFormatted,
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                isToday
                                    ? AppColors.primary.withOpacity(0.7)
                                    : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${daySlots.length} meals',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Meals for the day
            Padding(
              padding: EdgeInsets.all(AppDimensions.marginMedium),
              child: Column(
                children:
                    daySlots
                        .map(
                          (slot) => _buildMealSlotCard(
                            slot,
                            isPast: isPast,
                            isToday: isToday,
                          ),
                        )
                        .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealSlotCard(
    dynamic slot, {
    bool isPast = false,
    bool isToday = false,
  }) {
    final mealColor = _getMealTypeColor(slot.timing);
    final mealIcon = _getMealTypeIcon(slot.timing);

    return Container(
      margin: EdgeInsets.only(bottom: AppDimensions.marginSmall),
      child: InkWell(
        onTap:
            slot.meal != null
                ? () {
                  // Navigate to meal detail screen
                  Navigator.pushNamed(
                    context,
                    '/meal-detail', // TODO: Add this route if needed
                    arguments: {
                      'meal': slot.meal,
                      'timing': slot.timing,
                      'date': slot.date,
                      'subscription': widget.subscription,
                    },
                  );
                }
                : null,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        child: Container(
          padding: EdgeInsets.all(AppDimensions.marginMedium),
          decoration: BoxDecoration(
            color:
                isPast
                    ? Colors.grey.shade50
                    : isToday
                    ? mealColor.withOpacity(0.05)
                    : Colors.white,
            borderRadius: BorderRadius.circular(
              AppDimensions.borderRadiusMedium,
            ),
            border: Border.all(
              color: isPast ? Colors.grey.shade200 : mealColor.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: mealColor.withOpacity(isPast ? 0.1 : 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  mealIcon,
                  color: isPast ? Colors.grey.shade600 : mealColor,
                  size: 18,
                ),
              ),
              SizedBox(width: AppDimensions.marginSmall),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _formatTiming(slot.timing),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isPast ? Colors.grey.shade600 : mealColor,
                          ),
                        ),
                        SizedBox(width: AppDimensions.marginSmall),
                        Text(
                          _getMealTimeRange(slot.timing),
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    if (slot.meal != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        slot.meal.name ?? 'Meal',
                        style: TextStyle(
                          fontSize: 13,
                          color:
                              isPast
                                  ? AppColors.textSecondary
                                  : AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ] else ...[
                      const SizedBox(height: 4),
                      Text(
                        'No meal planned',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (slot.meal != null) ...[
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: AppColors.textSecondary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyWeekState() {
    return Container(
      padding: EdgeInsets.all(AppDimensions.marginLarge),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 48,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            SizedBox(height: AppDimensions.marginMedium),
            const Text(
              'No meals scheduled for this week',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Meals will be scheduled once your subscription is activated.',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  int _getMealTimeOrder(String timing) {
    switch (timing.toLowerCase()) {
      case 'breakfast':
        return 0;
      case 'lunch':
        return 1;
      case 'dinner':
        return 2;
      default:
        return 3;
    }
  }

  Color _getMealTypeColor(String timing) {
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

  IconData _getMealTypeIcon(String timing) {
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

  String _formatTiming(String timing) {
    return timing.substring(0, 1).toUpperCase() +
        timing.substring(1).toLowerCase();
  }

  String _getMealTimeRange(String timing) {
    switch (timing.toLowerCase()) {
      case 'breakfast':
        return '7:00 AM - 10:00 AM';
      case 'lunch':
        return '12:00 PM - 3:00 PM';
      case 'dinner':
        return '7:00 PM - 10:00 PM';
      default:
        return '';
    }
  }
}
