// lib/features/packages/widgets/package_card.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/src/domain/entities/pacakge_entity.dart';

class PackageCard extends StatelessWidget {
  final Package package;
  final VoidCallback? onTap;
  
  const PackageCard({
    super.key,
    required this.package,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final isVegetarian = package.name.toLowerCase().contains('veg') &&
        !package.name.toLowerCase().contains('non-veg');
    
    return Card(
      margin: EdgeInsets.only(bottom: AppDimensions.marginMedium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Package image or placeholder
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppDimensions.borderRadiusLarge),
                  topRight: Radius.circular(AppDimensions.borderRadiusLarge),
                ),
              ),
              child: Center(
                child: Icon(
                  isVegetarian ? Icons.eco : Icons.restaurant,
                  size: 64,
                  color: isVegetarian ? AppColors.vegetarian : AppColors.nonVegetarian,
                ),
              ),
            ),
            
            // Package details
            Padding(
              padding: EdgeInsets.all(AppDimensions.marginMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          package.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      if (isVegetarian) ...[
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.vegetarian.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.eco,
                                size: 12,
                                color: AppColors.vegetarian,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Veg',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.vegetarian,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: AppDimensions.marginSmall),
                  Text(
                    package.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: AppDimensions.marginMedium),
                  
                  // Package stats
                  Row(
                    children: [
                      _buildStatItem(
                        context,
                        icon: Icons.restaurant,
                        value: '${package.slots.length}',
                        label: 'meals',
                      ),
                      SizedBox(width: AppDimensions.marginLarge),
                      _buildStatItem(
                        context,
                        icon: Icons.access_time,
                        value: '7',
                        label: 'days',
                      ),
                    ],
                  ),
                  SizedBox(height: AppDimensions.marginMedium),
                  
                  // Price and Subscribe button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Price',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            '₹${package.price.toStringAsFixed(0)}',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: onTap,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppDimensions.marginMedium,
                            vertical: AppDimensions.marginSmall,
                          ),
                        ),
                        child: Text('Subscribe'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.textSecondary,
        ),
        SizedBox(width: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}