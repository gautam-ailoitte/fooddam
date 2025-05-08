// lib/src/presentation/screens/package/package_meal_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/src/domain/entities/meal_slot_entity.dart';
import 'package:foodam/src/domain/entities/pacakge_entity.dart';

class PackageMealDetailScreen extends StatelessWidget {
  final MealSlot slot;
  final Package package;

  const PackageMealDetailScreen({
    super.key,
    required this.slot,
    required this.package,
  });

  @override
  Widget build(BuildContext context) {
    final meal = slot.meal!;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Custom App Bar with Image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: _getMealColor(slot.timing),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                meal.name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Meal Image
                  if (meal.imageUrl != null && meal.imageUrl!.isNotEmpty)
                    Image.network(
                      meal.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: _getMealColor(slot.timing),
                          child: Icon(
                            _getMealIcon(slot.timing),
                            size: 80,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        );
                      },
                    )
                  else
                    Container(
                      color: _getMealColor(slot.timing),
                      child: Icon(
                        _getMealIcon(slot.timing),
                        size: 80,
                        color: Colors.white.withOpacity(0.7),
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
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            leading: Container(
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(AppDimensions.marginLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meal Type Badge
                  _buildMealBadge(slot.timing),
                  SizedBox(height: AppDimensions.marginMedium),

                  // Day Badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Served on ${_formatDay(slot.day)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  SizedBox(height: AppDimensions.marginLarge),

                  // Description Section
                  _buildSectionTitle('Description'),
                  SizedBox(height: AppDimensions.marginSmall),
                  Text(
                    meal.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: AppDimensions.marginLarge),

                  // Dietary Preferences
                  if (meal.dietaryPreferences != null &&
                      meal.dietaryPreferences!.isNotEmpty) ...[
                    _buildSectionTitle('Dietary Preferences'),
                    SizedBox(height: AppDimensions.marginSmall),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          meal.dietaryPreferences!.map<Widget>((pref) {
                            return Chip(
                              label: Text(
                                pref.toString(),
                                style: TextStyle(fontSize: 14),
                              ),
                              backgroundColor: Colors.grey.shade100,
                              avatar: Icon(
                                _getDietaryIcon(pref),
                                size: 16,
                                color: _getDietaryColor(pref),
                              ),
                            );
                          }).toList(),
                    ),
                    SizedBox(height: AppDimensions.marginLarge),
                  ],

                  // Price Section
                  _buildSectionTitle('Price'),
                  SizedBox(height: AppDimensions.marginSmall),
                  _buildPriceCard(meal.price),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildMealBadge(String timing) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getMealColor(timing).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getMealColor(timing).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getMealIcon(timing), size: 16, color: _getMealColor(timing)),
          SizedBox(width: 6),
          Text(
            _formatTiming(timing),
            style: TextStyle(
              color: _getMealColor(timing),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCard(double price) {
    return Card(
      elevation: 2,
      color: AppColors.primary.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        side: BorderSide(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.marginMedium),
        child: Row(
          children: [
            Icon(Icons.currency_rupee, color: AppColors.primary, size: 24),
            SizedBox(width: 8),
            Text(
              price.toStringAsFixed(2),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
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

  IconData _getDietaryIcon(String preference) {
    switch (preference.toLowerCase()) {
      case 'vegetarian':
        return Icons.eco;
      case 'vegan':
        return Icons.spa;
      case 'gluten-free':
        return Icons.spa;
      case 'non-vegetarian':
        return Icons.egg;
      default:
        return Icons.food_bank;
    }
  }

  Color _getDietaryColor(String preference) {
    switch (preference.toLowerCase()) {
      case 'vegetarian':
        return Colors.green;
      case 'vegan':
        return Colors.teal;
      case 'gluten-free':
        return Colors.amber;
      case 'non-vegetarian':
        return Colors.redAccent;
      default:
        return Colors.blueGrey;
    }
  }

  String _formatDay(String day) {
    return day.substring(0, 1).toUpperCase() + day.substring(1);
  }

  String _formatTiming(String timing) {
    return timing.substring(0, 1).toUpperCase() + timing.substring(1);
  }
}
