// lib/src/presentation/widgets/modified_package_card.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/theme/enhanced_app_them.dart';
import 'package:foodam/src/domain/entities/pacakge_entity.dart';

class PackageCard extends StatelessWidget {
  final Package package;
  final VoidCallback? onTap;

  const PackageCard({super.key, required this.package, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isVegetarian =
        package.name.toLowerCase().contains('veg') &&
        !package.name.toLowerCase().contains('non-veg');

    final isNonVeg = package.name.toLowerCase().contains('non-veg');

    // Calculate meals per meal type
    int breakfastCount = 7;
    int lunchCount = 7;
    int dinnerCount = 7;

    for (var slot in package.slots) {
      if (slot.timing.toLowerCase() == 'breakfast') {
        breakfastCount++;
      } else if (slot.timing.toLowerCase() == 'lunch') {
        lunchCount++;
      } else if (slot.timing.toLowerCase() == 'dinner') {
        dinnerCount++;
      }
    }

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: EnhancedTheme.cardDecoration,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Package image header with gradient overlay
              Stack(
                children: [
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors:
                            isVegetarian
                                ? [
                                  AppColors.vegetarian.withOpacity(0.7),
                                  AppColors.vegetarian,
                                ]
                                : isNonVeg
                                ? [
                                  AppColors.nonVegetarian.withOpacity(0.7),
                                  AppColors.nonVegetarian,
                                ]
                                : [
                                  AppColors.primary.withOpacity(0.7),
                                  AppColors.primary,
                                ],
                      ),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        isVegetarian ? Icons.eco : Icons.restaurant,
                        size: 64,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child:
                        isVegetarian || isNonVeg
                            ? EnhancedTheme.mealTypeTag(
                              isVegetarian ? 'Vegetarian' : 'Non-Vegetarian',
                            )
                            : Container(),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          package.name,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 2,
                                color: Colors.black.withOpacity(0.3),
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${package.slots.length} meals',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '7 days',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Package details
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      package.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 16),

                    // Meal distribution chart
                    Text(
                      'Meal Distribution',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMealTypeStat(
                            context,
                            label: 'Breakfast',
                            count: breakfastCount,
                            icon: Icons.free_breakfast,
                            color: Colors.orange,
                          ),
                        ),
                        Expanded(
                          child: _buildMealTypeStat(
                            context,
                            label: 'Lunch',
                            count: lunchCount,
                            icon: Icons.lunch_dining,
                            color: AppColors.accent,
                          ),
                        ),
                        Expanded(
                          child: _buildMealTypeStat(
                            context,
                            label: 'Dinner',
                            count: dinnerCount,
                            icon: Icons.dinner_dining,
                            color: Colors.purple,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Divider(),
                    SizedBox(height: 16),

                    // Price and action button
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Package Price',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              '₹${package.price.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        ElevatedButton(
                          onPressed: onTap,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: AppColors.primary,
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text('Subscribe Now'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMealTypeStat(
    BuildContext context, {
    required String label,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        SizedBox(height: 8),
        Text(
          '$count',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
