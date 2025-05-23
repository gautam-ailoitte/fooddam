// lib/src/presentation/screens/package/package_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/theme/enhanced_app_them.dart';
import 'package:foodam/core/widgets/app_loading.dart';
import 'package:foodam/core/widgets/error_display_wideget.dart';
import 'package:foodam/src/domain/entities/pacakge_entity.dart';
import 'package:foodam/src/domain/entities/package_slot_entity.dart';
import 'package:foodam/src/presentation/cubits/pacakge_cubits/pacakage_cubit.dart';
import 'package:foodam/src/presentation/cubits/pacakge_cubits/pacakage_state.dart';

class PackageDetailScreen extends StatefulWidget {
  final Package package;

  const PackageDetailScreen({super.key, required this.package});

  @override
  State<PackageDetailScreen> createState() => _PackageDetailScreenState();
}

class _PackageDetailScreenState extends State<PackageDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Always load fresh package details
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PackageCubit>().loadPackageDetail(widget.package.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) {
        if (didPop) {
          // When navigating back, restore the cached package list
          context.read<PackageCubit>().returnToPackageList();
        }
      },
      child: Scaffold(
        body: BlocBuilder<PackageCubit, PackageState>(
          builder: (context, state) {
            if (state is PackageLoading) {
              return const AppLoading(message: 'Loading meal details...');
            }

            if (state is PackageError) {
              return ErrorDisplayWidget(
                message: state.message,
                onRetry:
                    () => context.read<PackageCubit>().loadPackageDetail(
                      widget.package.id,
                    ),
              );
            }

            // Use detailed package if available, otherwise fallback to passed package
            final package =
                state is PackageDetailLoaded ? state.package : widget.package;

            return _buildPackageDetailContent(package);
          },
        ),
      ),
    );
  }

  Widget _buildPackageDetailContent(Package package) {
    return CustomScrollView(
      slivers: [
        // App bar with package image
        _buildSliverAppBar(package),

        // Main content
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(AppDimensions.marginMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Package description
                _buildDescriptionCard(package),
                SizedBox(height: AppDimensions.marginMedium),

                // Pricing information (view-only)
                _buildPricingCard(package),
                SizedBox(height: AppDimensions.marginMedium),

                // Weekly meal plan
                _buildWeeklyMealPlan(package),
                SizedBox(height: AppDimensions.marginLarge),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(Package package) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          package.name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                blurRadius: 2,
                color: Colors.black45,
                offset: Offset(0, 1),
              ),
            ],
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors:
                  package.isVegetarian
                      ? [
                        AppColors.vegetarian.withOpacity(0.8),
                        AppColors.vegetarian,
                      ]
                      : package.isNonVegetarian
                      ? [
                        AppColors.nonVegetarian.withOpacity(0.8),
                        AppColors.nonVegetarian,
                      ]
                      : [AppColors.primary.withOpacity(0.8), AppColors.primary],
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Center(
                child: Icon(
                  package.isVegetarian ? Icons.eco : Icons.restaurant,
                  size: 80,
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        if (package.isVegetarian || package.isNonVegetarian)
          Padding(
            padding: EdgeInsets.only(right: AppDimensions.marginMedium),
            child: Chip(
              label: Text(
                package.isVegetarian ? 'Vegetarian' : 'Non-Vegetarian',
                style: TextStyle(
                  color:
                      package.isVegetarian
                          ? AppColors.vegetarian
                          : AppColors.nonVegetarian,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              backgroundColor: Colors.white,
              avatar: Icon(
                package.isVegetarian ? Icons.eco : Icons.restaurant,
                color:
                    package.isVegetarian
                        ? AppColors.vegetarian
                        : AppColors.nonVegetarian,
                size: 16,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDescriptionCard(Package package) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
      ),
      child: Container(
        decoration: EnhancedTheme.cardDecoration,
        padding: EdgeInsets.all(AppDimensions.marginMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.primary),
                SizedBox(width: AppDimensions.marginSmall),
                const Text(
                  'About This Package',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: AppDimensions.marginSmall),
            Text(
              package.description,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            SizedBox(height: AppDimensions.marginMedium),

            // Package stats
            Row(
              children: [
                _buildInfoChip(
                  icon: Icons.calendar_month_outlined,
                  label: 'Week ${package.week}',
                  color: Colors.blue,
                ),
                SizedBox(width: AppDimensions.marginSmall),
                _buildInfoChip(
                  icon: Icons.restaurant_menu,
                  label: '${package.totalMealsInWeek} meals',
                  color: AppColors.accent,
                ),
                SizedBox(width: AppDimensions.marginSmall),
                _buildInfoChip(
                  icon: Icons.local_dining,
                  label: '${package.slots.length} days',
                  color: Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingCard(Package package) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
      ),
      child: Container(
        decoration: EnhancedTheme.cardDecoration,
        padding: EdgeInsets.all(AppDimensions.marginMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.attach_money, color: AppColors.primary),
                SizedBox(width: AppDimensions.marginSmall),
                const Text(
                  'Pricing Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'View Only',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppDimensions.marginMedium),

            // Price range
            Container(
              padding: EdgeInsets.all(AppDimensions.marginMedium),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(
                  AppDimensions.borderRadiusMedium,
                ),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.currency_rupee, color: AppColors.primary),
                  SizedBox(width: AppDimensions.marginSmall),
                  Text(
                    package.priceDisplayText,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'per week',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Price options if available
            if (package.priceOptions != null &&
                package.priceOptions!.isNotEmpty) ...[
              SizedBox(height: AppDimensions.marginMedium),
              const Text(
                'Available Plans:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: AppDimensions.marginSmall),
              ...package.priceOptions!
                  .map(
                    (option) => Padding(
                      padding: EdgeInsets.only(
                        bottom: AppDimensions.marginSmall,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: AppDimensions.marginSmall),
                          Text('${option.numberOfMeals} meals'),
                          const Spacer(),
                          Text(
                            '₹${option.price.toStringAsFixed(0)}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyMealPlan(Package package) {
    if (!package.hasSlots) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.marginLarge),
          child: const Center(
            child: Text('No meal plans available for this package.'),
          ),
        ),
      );
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
      ),
      child: Container(
        decoration: EnhancedTheme.cardDecoration,
        padding: EdgeInsets.all(AppDimensions.marginMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.restaurant_menu, color: AppColors.primary),
                SizedBox(width: AppDimensions.marginSmall),
                const Text(
                  'Weekly Meal Plan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: AppDimensions.marginSmall),
            const Text(
              'Tap on any day to see detailed meal information',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            SizedBox(height: AppDimensions.marginMedium),

            // Weekly calendar grid
            ...package.slots.asMap().entries.map((entry) {
              final index = entry.key;
              final slot = entry.value;

              return Column(
                children: [
                  _buildDayMealCard(slot, package),
                  if (index < package.slots.length - 1)
                    SizedBox(height: AppDimensions.marginSmall),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDayMealCard(PackageSlot slot, Package package) {
    if (!slot.hasMeal) {
      return Container(
        padding: EdgeInsets.all(AppDimensions.marginMedium),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Text(
              slot.formattedDay,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const Spacer(),
            Text(
              'No meal planned',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    final meal = slot.meal!;

    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/daily-meal-detail',
          arguments: {'slot': slot, 'package': package},
        );
      },
      child: Container(
        padding: EdgeInsets.all(AppDimensions.marginMedium),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            // Day info
            Container(
              width: 60,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    slot.formattedDay,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  if (slot.isWeekend)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Weekend',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            SizedBox(width: AppDimensions.marginMedium),

            // Meal info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    meal.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AppDimensions.marginSmall),

                  // Meal type indicators
                  Row(
                    children: [
                      if (meal.hasBreakfast)
                        _buildMealTypeIndicator('B', Colors.orange),
                      if (meal.hasLunch)
                        _buildMealTypeIndicator('L', AppColors.accent),
                      if (meal.hasDinner)
                        _buildMealTypeIndicator('D', Colors.purple),
                    ],
                  ),
                ],
              ),
            ),

            // Arrow indicator
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealTypeIndicator(String letter, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Center(
        child: Text(
          letter,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
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
