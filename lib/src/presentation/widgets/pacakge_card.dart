// lib/src/presentation/widgets/package_card.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/theme/enhanced_app_them.dart';
import 'package:foodam/src/domain/entities/pacakge_entity.dart';

class PackageCard extends StatelessWidget {
  final Package package;
  final VoidCallback? onTap;

  const PackageCard({super.key, required this.package, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: AppDimensions.marginMedium),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
      ),
      child: Container(
        decoration: EnhancedTheme.cardDecoration,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Package header with gradient
              _buildPackageHeader(),

              // Package content
              _buildPackageContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPackageHeader() {
    return Stack(
      children: [
        Container(
          height: 140,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors:
                  package.isVegetarian
                      ? [
                        AppColors.vegetarian.withOpacity(0.7),
                        AppColors.vegetarian,
                      ]
                      : package.isNonVegetarian
                      ? [
                        AppColors.nonVegetarian.withOpacity(0.7),
                        AppColors.nonVegetarian,
                      ]
                      : [AppColors.primary.withOpacity(0.7), AppColors.primary],
            ),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppDimensions.borderRadiusLarge),
            ),
          ),
          child: Center(
            child: Icon(
              package.isVegetarian ? Icons.eco : Icons.restaurant,
              size: 48,
              color: Colors.white,
            ),
          ),
        ),

        // Dietary preference badge
        if (package.isVegetarian || package.isNonVegetarian)
          Positioned(
            top: AppDimensions.marginSmall,
            right: AppDimensions.marginSmall,
            child: _buildDietaryBadge(),
          ),

        // Package title at bottom
        Positioned(
          bottom: AppDimensions.marginSmall,
          left: AppDimensions.marginMedium,
          right: AppDimensions.marginMedium,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                package.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 2,
                      color: Colors.black26,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Week ${package.week}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPackageContent() {
    return Padding(
      padding: EdgeInsets.all(AppDimensions.marginMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          Text(
            package.description,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: AppDimensions.marginMedium),

          // Package stats
          Row(
            children: [
              _buildStatChip(
                icon: Icons.restaurant_menu,
                label: '${package.totalMealsInWeek} meals',
                color: AppColors.accent,
              ),
              SizedBox(width: AppDimensions.marginSmall),
              _buildStatChip(
                icon: Icons.calendar_month_outlined,
                label: '7 days',
                color: Colors.blue,
              ),
              SizedBox(width: AppDimensions.marginSmall),
              _buildStatChip(
                icon: Icons.local_dining,
                label: '${package.slots.length} sets',
                color: Colors.purple,
              ),
            ],
          ),
          SizedBox(height: AppDimensions.marginMedium),

          Divider(height: 1),
          SizedBox(height: AppDimensions.marginMedium),

          // Price and action
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Price Range',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      package.priceDisplayText,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.borderRadiusMedium,
                    ),
                  ),
                  elevation: 0,
                ),
                child: const Text('View Menu'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDietaryBadge() {
    if (!package.isVegetarian && !package.isNonVegetarian) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            package.isVegetarian ? Icons.eco : Icons.restaurant,
            size: 14,
            color:
                package.isVegetarian
                    ? AppColors.vegetarian
                    : AppColors.nonVegetarian,
          ),
          const SizedBox(width: 4),
          Text(
            package.isVegetarian ? 'Veg' : 'Non-Veg',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color:
                  package.isVegetarian
                      ? AppColors.vegetarian
                      : AppColors.nonVegetarian,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
