// lib/features/home/widgets/create_plan_cta.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/widgets/primary_button.dart';

class CreatePlanCTA extends StatelessWidget {
  final VoidCallback? onTap;
  
  const CreatePlanCTA({
    super.key,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.marginLarge),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.marginLarge),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
                child: Image.asset(
                  'assets/images/create_plan.jpg',
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback container if image is not available
                    return Container(
                      height: 180,
                      width: double.infinity,
                      color: AppColors.primaryLight,
                      child: Center(
                        child: Icon(
                          Icons.restaurant,
                          size: 48,
                          color: AppColors.primary,
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: AppDimensions.marginLarge),
              Text(
                'Create Your First Meal Plan',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppDimensions.marginMedium),
              Text(
                'Subscribe to a meal package and start enjoying delicious meals delivered to your doorstep.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppDimensions.marginLarge),
              PrimaryButton(
                text: 'Explore Packages',
                onPressed: onTap,
                icon: Icons.search,
              ),
            ],
          ),
        ),
      ),
    );
  }
}