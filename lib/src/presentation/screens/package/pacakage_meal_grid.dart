// lib/src/presentation/widgets/package_meal_grid.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/src/domain/entities/day_meal.dart';
import 'package:foodam/src/domain/entities/meal_slot_entity.dart';
import 'package:foodam/src/domain/entities/pacakge_entity.dart';

import 'pacakage_meal_detail_screen.dart';

class PackageMealGrid extends StatelessWidget {
  final Package package;
  final bool isCompact;

  const PackageMealGrid({
    super.key,
    required this.package,
    this.isCompact = true,
  });

  @override
  Widget build(BuildContext context) {
    // Check if package has meal data
    if (package.dailyMeals == null || package.dailyMeals!.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.marginLarge),
          child: Text(
            'No meals included in this package',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
        ),
      );
    }

    // Create a list of meal slots from dailyMeals map
    final List<MealSlot> allSlots = _convertDailyMealsToSlots(
      package.dailyMeals!,
    );

    // Filter out slots without meals
    final slotsWithMeals = allSlots.where((slot) => slot.meal != null).toList();

    if (slotsWithMeals.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.marginLarge),
          child: Text(
            'No meals included in this package',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
        ),
      );
    }

    // Group slots by day
    final Map<String, List<MealSlot>> slotsByDay = {};
    for (final slot in slotsWithMeals) {
      if (!slotsByDay.containsKey(slot.day)) {
        slotsByDay[slot.day] = [];
      }
      slotsByDay[slot.day]!.add(slot);
    }

    // Sort days in correct order
    final List<String> sortedDays = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];
    final List<String> availableDays =
        slotsByDay.keys.toList()..sort(
          (a, b) =>
              sortedDays.indexOf(a.toLowerCase()) -
              sortedDays.indexOf(b.toLowerCase()),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Padding(
          padding: EdgeInsets.only(
            left: AppDimensions.marginMedium,
            bottom: AppDimensions.marginSmall,
          ),
          child: Row(
            children: [
              SizedBox(width: 80), // Space for day labels
              Expanded(
                child: Center(
                  child: _mealTypeLabel(
                    'Breakfast',
                    Icons.free_breakfast,
                    Colors.orange,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: _mealTypeLabel(
                    'Lunch',
                    Icons.lunch_dining,
                    AppColors.accent,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: _mealTypeLabel(
                    'Dinner',
                    Icons.dinner_dining,
                    Colors.purple,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Day rows
        ...availableDays.map((day) {
          final daySlots = slotsByDay[day]!;
          // Sort slots by meal timing
          daySlots.sort((a, b) {
            final timings = ['breakfast', 'lunch', 'dinner'];
            return timings.indexOf(a.timing.toLowerCase()) -
                timings.indexOf(b.timing.toLowerCase());
          });

          // Create a map for easy lookup of meal by timing
          final mealByTiming = {
            for (var slot in daySlots) slot.timing.toLowerCase(): slot,
          };

          return Padding(
            padding: EdgeInsets.only(bottom: AppDimensions.marginSmall),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Day label
                SizedBox(
                  width: 80,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      _formatDay(day),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),

                // Breakfast
                Expanded(
                  child: _buildMealCell(
                    context,
                    mealByTiming['breakfast'],
                    'breakfast',
                    package,
                  ),
                ),

                // Lunch
                Expanded(
                  child: _buildMealCell(
                    context,
                    mealByTiming['lunch'],
                    'lunch',
                    package,
                  ),
                ),

                // Dinner
                Expanded(
                  child: _buildMealCell(
                    context,
                    mealByTiming['dinner'],
                    'dinner',
                    package,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  // Convert dailyMeals to MealSlot list
  List<MealSlot> _convertDailyMealsToSlots(Map<String, DayMeal> dailyMeals) {
    final List<MealSlot> slots = [];

    // Iterate through each day/meal in the dailyMeals map
    // dailyMeals.forEach((day, dayMeal) {
    // Each day potentially has breakfast, lunch, and dinner
    //   if (dayMeal.hasBreakfast) {
    //     slots.add(
    //       MealSlot(day: day, timing: 'breakfast', meal: dayMeal.breakfastDish),
    //     );
    //   }
    //
    //   if (dayMeal.hasLunch) {
    //     slots.add(MealSlot(day: day, timing: 'lunch', meal: dayMeal.lunchDish));
    //   }
    //
    //   if (dayMeal.hasDinner) {
    //     slots.add(
    //       MealSlot(day: day, timing: 'dinner', meal: dayMeal.dinnerDish),
    //     );
    //   }
    // }); //todo:

    return slots;
  }

  Widget _mealTypeLabel(String label, IconData icon, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildMealCell(
    BuildContext context,
    MealSlot? slot,
    String timing,
    Package package,
  ) {
    if (slot == null || slot.meal == null) {
      // Empty cell
      return Container(
        height: 80,
        margin: EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Center(
          child: Text(
            'No meal',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 10),
          ),
        ),
      );
    }

    final meal = slot.meal!;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    PackageMealDetailScreen(slot: slot, package: package),
          ),
        );
      },
      child: Container(
        height: 80,
        margin: EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
              child: SizedBox(
                height: 40,
                width: double.infinity,
                child:
                    meal.imageUrl != null
                        ? Image.network(
                          meal.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => Container(
                                color: _getMealColor(timing).withOpacity(0.1),
                                child: Icon(
                                  _getMealIcon(timing),
                                  size: 20,
                                  color: _getMealColor(timing),
                                ),
                              ),
                        )
                        : Container(
                          color: _getMealColor(timing).withOpacity(0.1),
                          child: Icon(
                            _getMealIcon(timing),
                            size: 20,
                            color: _getMealColor(timing),
                          ),
                        ),
              ),
            ),

            // Meal name
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(
                  meal.name,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
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

  String _formatDay(String day) {
    return day.substring(0, 1).toUpperCase() + day.substring(1);
  }
}
