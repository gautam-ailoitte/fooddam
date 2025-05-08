// lib/src/presentation/widgets/package_card_compact.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/src/domain/entities/pacakge_entity.dart';

class PackageCardCompact extends StatelessWidget {
  final Package package;
  final VoidCallback? onTap;

  const PackageCardCompact({super.key, required this.package, this.onTap});

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

    final totalMeals = package.slots.isNotEmpty ? package.slots.length : 21;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Package header with color based on type
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color:
                    isVegetarian
                        ? AppColors.vegetarian
                        : isNonVeg
                        ? AppColors.nonVegetarian
                        : AppColors.primary,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isVegetarian ? Icons.eco : Icons.restaurant,
                    size: 40,
                    color: Colors.white,
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      package.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Meal counts with icons
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // _buildMealIcon(Icons.restaurant_menu, totalMeals, 'Meals'), todo:
                    _buildMealIcon(
                      Icons.free_breakfast,
                      breakfastCount,
                      'Breakfast',
                    ),
                    _buildMealIcon(Icons.lunch_dining, lunchCount, 'Lunch'),
                    _buildMealIcon(Icons.dinner_dining, dinnerCount, 'Dinner'),
                  ],
                ),
              ),
            ),

            // Price banner at bottom
            Container(
              width: double.infinity,
              height: 24, // Fixed height to avoid overflow
              color: Colors.yellow.shade700,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '₹${package.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '• Fresh Ingredients • Healthy Food',
                    style: TextStyle(fontSize: 10, color: Colors.black87),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealIcon(IconData icon, int count, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min, // Use minimum space needed
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(height: 2),
        // Text(
        //   count.toString(),
        //   style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        // ),
        Text(
          label,
          style: TextStyle(fontSize: 9, color: AppColors.textSecondary),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
