// lib/src/presentation/screens/package/daily_meal_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/src/domain/entities/day_meal.dart';
import 'package:foodam/src/domain/entities/dish_entity.dart';
import 'package:foodam/src/domain/entities/pacakge_entity.dart';
import 'package:foodam/src/domain/entities/package_slot_entity.dart';

class DailyMealDetailScreen extends StatefulWidget {
  final PackageSlot slot;
  final Package package;

  const DailyMealDetailScreen({
    super.key,
    required this.slot,
    required this.package,
  });

  @override
  State<DailyMealDetailScreen> createState() => _DailyMealDetailScreenState();
}

class _DailyMealDetailScreenState extends State<DailyMealDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final meal = widget.slot.meal!;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Custom App Bar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: _getDayColor(widget.slot.day),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                '${widget.slot.formattedDay} Menu',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          _getDayColor(widget.slot.day).withOpacity(0.8),
                          _getDayColor(widget.slot.day),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: Icon(
                      widget.slot.isWeekend ? Icons.weekend : Icons.today,
                      size: 80,
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(AppDimensions.marginMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meal set header
                  _buildMealSetHeader(meal),
                  SizedBox(height: AppDimensions.marginLarge),

                  // Breakfast section
                  if (meal.hasBreakfast) ...[
                    _buildMealSection(
                      context: context,
                      title: 'Breakfast',
                      dish: meal.breakfastDish!,
                      icon: Icons.free_breakfast,
                      color: Colors.orange,
                      timeRange: '7:00 AM - 10:00 AM',
                    ),
                    SizedBox(height: AppDimensions.marginLarge),
                  ],

                  // Lunch section
                  if (meal.hasLunch) ...[
                    _buildMealSection(
                      context: context,
                      title: 'Lunch',
                      dish: meal.lunchDish!,
                      icon: Icons.lunch_dining,
                      color: AppColors.accent,
                      timeRange: '12:00 PM - 3:00 PM',
                    ),
                    SizedBox(height: AppDimensions.marginLarge),
                  ],

                  // Dinner section
                  if (meal.hasDinner) ...[
                    _buildMealSection(
                      context: context,
                      title: 'Dinner',
                      dish: meal.dinnerDish!,
                      icon: Icons.dinner_dining,
                      color: Colors.purple,
                      timeRange: '7:00 PM - 10:00 PM',
                    ),
                    SizedBox(height: AppDimensions.marginLarge),
                  ],

                  // Package info
                  _buildPackageInfoCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealSetHeader(DayMeal meal) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
      ),
      child: Container(
        padding: EdgeInsets.all(AppDimensions.marginMedium),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
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
                  child: Icon(
                    Icons.restaurant_menu,
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
                        meal.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (widget.slot.isWeekend)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Weekend Special',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: AppDimensions.marginMedium),
            Text(
              meal.description,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            if (meal.dietaryPreferences != null &&
                meal.dietaryPreferences!.isNotEmpty) ...[
              SizedBox(height: AppDimensions.marginMedium),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    meal.dietaryPreferences!.map((pref) {
                      return _buildDietaryChip(pref);
                    }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMealSection({
    required String title,
    required Dish dish,
    required IconData icon,
    required Color color,
    required String timeRange,
    required BuildContext context,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Container(
              padding: EdgeInsets.all(AppDimensions.marginMedium),
              decoration: BoxDecoration(
                color: color.withOpacity(0.05),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppDimensions.borderRadiusLarge),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  SizedBox(width: AppDimensions.marginSmall),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        Text(
                          timeRange,
                          style: TextStyle(
                            fontSize: 12,
                            color: color.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                        context, //todo:
                        '/dish-detail',
                        arguments: {
                          'dish': dish,
                          'mealType': title,
                          'package': widget.package,
                          'day': widget.slot.formattedDay,
                        },
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'View Details',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Dish content
            Padding(
              padding: EdgeInsets.all(AppDimensions.marginMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dish.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: AppDimensions.marginSmall),
                  Text(
                    dish.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  if (dish.dietaryPreferences.isNotEmpty) ...[
                    SizedBox(height: AppDimensions.marginSmall),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children:
                          dish.dietaryPreferences.take(3).map((pref) {
                            return _buildDietaryChip(pref, isSmall: true);
                          }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageInfoCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
      ),
      child: Container(
        padding: EdgeInsets.all(AppDimensions.marginMedium),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.textSecondary),
                SizedBox(width: AppDimensions.marginSmall),
                const Text(
                  'Package Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppDimensions.marginMedium),
            _buildInfoRow('Package', widget.package.name),
            _buildInfoRow('Week', 'Week ${widget.package.week}'),
            _buildInfoRow(
              'Dietary Type',
              widget.package.isVegetarian ? 'Vegetarian' : 'Non-Vegetarian',
            ),
            _buildInfoRow('Price Range', widget.package.priceDisplayText),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppDimensions.marginSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Text(': ', style: TextStyle(color: AppColors.textSecondary)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDietaryChip(String preference, {bool isSmall = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 6 : 8,
        vertical: isSmall ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: _getDietaryColor(preference).withOpacity(0.1),
        borderRadius: BorderRadius.circular(isSmall ? 8 : 12),
        border: Border.all(
          color: _getDietaryColor(preference).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getDietaryIcon(preference),
            size: isSmall ? 12 : 14,
            color: _getDietaryColor(preference),
          ),
          SizedBox(width: 4),
          Text(
            preference,
            style: TextStyle(
              fontSize: isSmall ? 10 : 12,
              fontWeight: FontWeight.w600,
              color: _getDietaryColor(preference),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  Color _getDayColor(String day) {
    switch (day.toLowerCase()) {
      case 'sunday':
        return Colors.red;
      case 'monday':
        return Colors.blue;
      case 'tuesday':
        return Colors.green;
      case 'wednesday':
        return Colors.orange;
      case 'thursday':
        return Colors.purple;
      case 'friday':
        return Colors.teal;
      case 'saturday':
        return Colors.indigo;
      default:
        return AppColors.primary;
    }
  }

  IconData _getDietaryIcon(String preference) {
    switch (preference.toLowerCase()) {
      case 'vegetarian':
        return Icons.eco;
      case 'vegan':
        return Icons.spa;
      case 'gluten-free':
        return Icons.grain;
      case 'non-vegetarian':
        return Icons.restaurant;
      default:
        return Icons.food_bank;
    }
  }

  Color _getDietaryColor(String preference) {
    switch (preference.toLowerCase()) {
      case 'vegetarian':
        return AppColors.vegetarian;
      case 'vegan':
        return Colors.teal;
      case 'gluten-free':
        return Colors.amber;
      case 'non-vegetarian':
        return AppColors.nonVegetarian;
      default:
        return Colors.blueGrey;
    }
  }
}
