// lib/src/presentation/screens/package/dish_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/src/domain/entities/dish_entity.dart';
import 'package:foodam/src/domain/entities/pacakge_entity.dart';

class DishDetailScreen extends StatelessWidget {
  final Dish dish;
  final String mealType;
  final Package package;
  final String day;

  const DishDetailScreen({
    super.key,
    required this.dish,
    required this.mealType,
    required this.package,
    required this.day,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Custom App Bar with Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: _getMealTypeColor(mealType),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                dish.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 2,
                      color: Colors.black45,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Dish Image
                  if (dish.imageUrl != null && dish.imageUrl!.isNotEmpty)
                    Image.network(
                      dish.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildDefaultBackground();
                      },
                    )
                  else
                    _buildDefaultBackground(),

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
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getMealTypeIcon(mealType),
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      mealType,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(AppDimensions.marginMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dish header info
                  _buildDishHeader(),
                  SizedBox(height: AppDimensions.marginLarge),

                  // Description section
                  _buildDescriptionSection(),
                  SizedBox(height: AppDimensions.marginLarge),

                  // Dietary preferences section
                  if (dish.dietaryPreferences.isNotEmpty) ...[
                    _buildDietarySection(),
                    SizedBox(height: AppDimensions.marginLarge),
                  ],

                  // Availability section
                  _buildAvailabilitySection(),
                  SizedBox(height: AppDimensions.marginLarge),

                  // Context information
                  _buildContextSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getMealTypeColor(mealType).withOpacity(0.8),
            _getMealTypeColor(mealType),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          _getMealTypeIcon(mealType),
          size: 120,
          color: Colors.white.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildDishHeader() {
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
          border: Border.all(
            color: _getMealTypeColor(mealType).withOpacity(0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getMealTypeColor(mealType).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getMealTypeIcon(mealType),
                    color: _getMealTypeColor(mealType),
                    size: 20,
                  ),
                ),
                SizedBox(width: AppDimensions.marginSmall),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dish.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '$mealType • $day',
                        style: TextStyle(
                          fontSize: 14,
                          color: _getMealTypeColor(mealType),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (dish.dietaryPreferences.isNotEmpty) ...[
              SizedBox(height: AppDimensions.marginMedium),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    dish.dietaryPreferences.take(3).map((pref) {
                      return _buildDietaryChip(pref);
                    }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionSection() {
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
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.description, color: AppColors.primary),
                SizedBox(width: AppDimensions.marginSmall),
                const Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppDimensions.marginMedium),
            Text(
              dish.description,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDietarySection() {
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
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.eco, color: AppColors.vegetarian),
                SizedBox(width: AppDimensions.marginSmall),
                const Text(
                  'Dietary Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppDimensions.marginMedium),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children:
                  dish.dietaryPreferences.map((pref) {
                    return _buildDetailedDietaryCard(pref);
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilitySection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
      ),
      child: Container(
        padding: EdgeInsets.all(AppDimensions.marginMedium),
        decoration: BoxDecoration(
          color: dish.isAvailable ? Colors.green.shade50 : Colors.red.shade50,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
          border: Border.all(
            color:
                dish.isAvailable ? Colors.green.shade200 : Colors.red.shade200,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:
                    dish.isAvailable
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                dish.isAvailable ? Icons.check_circle : Icons.cancel,
                color:
                    dish.isAvailable
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                size: 20,
              ),
            ),
            SizedBox(width: AppDimensions.marginSmall),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dish.isAvailable ? 'Available' : 'Currently Unavailable',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color:
                          dish.isAvailable
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                    ),
                  ),
                  Text(
                    dish.isAvailable
                        ? 'This dish is available for ordering'
                        : 'This dish is temporarily unavailable',
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          dish.isAvailable
                              ? Colors.green.shade600
                              : Colors.red.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContextSection() {
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
                  'Meal Context',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppDimensions.marginMedium),
            _buildContextRow('Package', package.name),
            _buildContextRow('Week', 'Week ${package.week}'),
            _buildContextRow('Day', day),
            _buildContextRow('Meal Type', mealType),
            _buildContextRow(
              'Dietary Type',
              package.isVegetarian ? 'Vegetarian' : 'Non-Vegetarian',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContextRow(String label, String value) {
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

  Widget _buildDietaryChip(String preference) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getDietaryColor(preference).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getDietaryColor(preference).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getDietaryIcon(preference),
            size: 14,
            color: _getDietaryColor(preference),
          ),
          const SizedBox(width: 4),
          Text(
            preference,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _getDietaryColor(preference),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedDietaryCard(String preference) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.marginMedium),
      decoration: BoxDecoration(
        color: _getDietaryColor(preference).withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        border: Border.all(
          color: _getDietaryColor(preference).withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _getDietaryColor(preference).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              _getDietaryIcon(preference),
              size: 16,
              color: _getDietaryColor(preference),
            ),
          ),
          SizedBox(width: AppDimensions.marginSmall),
          Text(
            preference,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _getDietaryColor(preference),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  Color _getMealTypeColor(String mealType) {
    switch (mealType.toLowerCase()) {
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

  IconData _getMealTypeIcon(String mealType) {
    switch (mealType.toLowerCase()) {
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
