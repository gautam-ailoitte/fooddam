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
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Package header with gradient based on dietary preference
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _getDietaryColors(),
                ),
              ),
              child: Stack(
                children: [
                  // Background pattern
                  Positioned(
                    right: -10,
                    top: -10,
                    child: Icon(
                      _getDietaryIcon(),
                      size: 60,
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Dietary badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _getDietaryDotColor(),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _getDietaryText(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: _getDietaryDotColor(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        // Package name
                        Text(
                          package.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // Week info and meal count
                        Text(
                          'Week ${package.week} • ${package.noOfSlots} meals',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Package content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Description
                    Expanded(
                      child: Text(
                        package.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.3,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Price and CTA
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Price
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Starting from',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              _getPriceDisplayText(),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        // View button
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            'View',
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
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods for new API structure

  /// Get gradient colors based on dietary preferences
  List<Color> _getDietaryColors() {
    if (_isVegetarian) {
      return [Colors.green.shade400, Colors.green.shade600];
    } else if (_isNonVegetarian) {
      return [Colors.red.shade400, Colors.red.shade600];
    }
    // Mixed or unknown
    return [AppColors.primary.withOpacity(0.7), AppColors.primary];
  }

  /// Get dietary preference icon
  IconData _getDietaryIcon() {
    if (_isVegetarian) {
      return Icons.eco;
    } else if (_isNonVegetarian) {
      return Icons.restaurant;
    }
    return Icons.restaurant_menu;
  }

  /// Get dietary preference dot color
  Color _getDietaryDotColor() {
    if (_isVegetarian) {
      return Colors.green;
    } else if (_isNonVegetarian) {
      return Colors.red;
    }
    return AppColors.primary;
  }

  /// Get dietary preference text
  String _getDietaryText() {
    if (_isVegetarian) {
      return 'VEG';
    } else if (_isNonVegetarian) {
      return 'NON-VEG';
    }
    return 'MIXED';
  }

  /// Check if package is vegetarian
  bool get _isVegetarian {
    return package.dietaryPreferences?.contains('vegetarian') ?? false;
  }

  /// Check if package is non-vegetarian
  bool get _isNonVegetarian {
    return package.dietaryPreferences?.contains('non-vegetarian') ?? false;
  }

  /// Get price display text from new API structure
  String _getPriceDisplayText() {
    // Try to use priceRange first for quick display
    if (package.priceRange != null &&
        package.priceRange!.min > 0 &&
        package.priceRange!.max > 0) {
      if (package.priceRange!.min == package.priceRange!.max) {
        return '₹${package.priceRange!.min.toStringAsFixed(0)}';
      }
      return '₹${package.priceRange!.min.toStringAsFixed(0)} - ₹${package.priceRange!.max.toStringAsFixed(0)}';
    }

    // Fallback to price options array
    if (package.priceOptions != null && package.priceOptions!.isNotEmpty) {
      // Find the minimum price from the price options
      final minPrice = package.priceOptions!
          .map((option) => option.price)
          .reduce((a, b) => a < b ? a : b);

      return '₹${minPrice.toStringAsFixed(0)}';
    }

    return 'Contact us';
  }
}
