// lib/src/presentation/widgets/pacakge_carousel.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/route/app_router.dart';
import 'package:foodam/src/domain/entities/pacakge_entity.dart';
import 'package:foodam/src/presentation/widgets/pacakage_card_compact.dart';

class PackageCarousel extends StatelessWidget {
  final List<Package> packages;
  final VoidCallback? onSeeAllTap;

  const PackageCarousel({
    super.key,
    required this.packages,
    this.onSeeAllTap,
  });

  @override
  Widget build(BuildContext context) {
    if (packages.isEmpty) {
      return Container(); // Don't show anything if there are no packages
    }

    // Get screen dimensions for responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    // Card width takes different percentage of screen depending on device size
    final cardWidth = isTablet 
        ? screenWidth * 0.42  // 42% of screen width for tablets
        : screenWidth * 0.72; // 72% of screen width for phones

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.marginMedium, 
            vertical: AppDimensions.marginSmall
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Popular Packages',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: onSeeAllTap,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(horizontal: AppDimensions.marginSmall),
                ),
                child: Row(
                  children: const [
                    Text('See All'),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward, size: 14),
                  ],
                ),
              ),
            ],
          ),
        ),
        ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: AppDimensions.marginMedium),
          physics: const BouncingScrollPhysics(),
          itemCount: packages.length > 5 ? 5 : packages.length, // Limit to 5 items
          itemBuilder: (context, index) {
            return Container(
              height: 200,
              width: cardWidth,
              margin: EdgeInsets.only(right: AppDimensions.marginMedium),
              child: PackageCardCompact(
                package: packages[index],
                onTap: () {
                  Navigator.of(context).pushNamed(
                    AppRouter.packageDetailRoute,
                    arguments: packages[index],
                  );
                },
              ),
            );
          },
        ),
        // Add some bottom spacing
        const SizedBox(height: 8),
      ],
    );
  }
}