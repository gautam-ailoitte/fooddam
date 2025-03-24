// lib/features/packages/screens/package_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/route/app_router.dart';
import 'package:foodam/core/widgets/primary_button.dart';
import 'package:foodam/src/domain/entities/pacakge_entity.dart';
import 'package:foodam/src/presentation/widgets/person_count_selection_widget.dart';

class PackageDetailScreen extends StatefulWidget {
  final Package package;

  const PackageDetailScreen({
    Key? key,
    required this.package,
  }) : super(key: key);

  @override
  _PackageDetailScreenState createState() => _PackageDetailScreenState();
}

class _PackageDetailScreenState extends State<PackageDetailScreen> {
  int _personCount = 1;

  @override
  Widget build(BuildContext context) {
    final isVegetarian = widget.package.name.toLowerCase().contains('veg') &&
        !widget.package.name.toLowerCase().contains('non-veg');

    return Scaffold(
      appBar: AppBar(
        title: Text('Package Details'),
      ),
      body: Column(
        children: [
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Package image or placeholder
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Icon(
                            isVegetarian ? Icons.eco : Icons.restaurant,
                            size: 80,
                            color: isVegetarian
                                ? AppColors.vegetarian
                                : AppColors.nonVegetarian,
                          ),
                        ),
                        if (isVegetarian)
                          Positioned(
                            top: 16,
                            right: 16,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                    AppDimensions.borderRadiusMedium),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.eco,
                                    size: 18,
                                    color: AppColors.vegetarian,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Vegetarian',
                                    style: TextStyle(
                                      color: AppColors.vegetarian,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Package details
                  Padding(
                    padding: EdgeInsets.all(AppDimensions.marginLarge),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.package.name,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        SizedBox(height: AppDimensions.marginSmall),
                        Text(
                          widget.package.description,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        SizedBox(height: AppDimensions.marginLarge),

                        // Package stats
                        _buildPackageStats(context),
                        Divider(height: AppDimensions.marginLarge * 2),

                        // Person count selector
                        Text(
                          'Number of People',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        SizedBox(height: AppDimensions.marginMedium),
                        PersonCountSelector(
                          value: _personCount,
                          onChanged: (value) {
                            setState(() {
                              _personCount = value;
                            });
                          },
                        ),
                        Divider(height: AppDimensions.marginLarge * 2),

                        // Sample meals section
                        Text(
                          'Sample Meals',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        SizedBox(height: AppDimensions.marginMedium),
                        _buildSampleMeals(context),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom action area
          Container(
            padding: EdgeInsets.all(AppDimensions.marginLarge),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppDimensions.borderRadiusLarge),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Package Price',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        '₹${(widget.package.price * _personCount).toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (_personCount > 1)
                        Text(
                          '₹${widget.package.price.toStringAsFixed(0)} x $_personCount',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: PrimaryButton(
                    text: 'Choose Meals',
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        AppRouter.mealSelectionRoute,
                        arguments: {
                          'package': widget.package,
                          'personCount': _personCount,
                        },
                      );
                    },
                    icon: Icons.arrow_forward,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageStats(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.marginMedium),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatColumn(
            context,
            value: '${widget.package.slots.length}',
            label: 'Meals',
            icon: Icons.restaurant,
          ),
          _buildStatColumn(
            context,
            value: '7',
            label: 'Days',
            icon: Icons.calendar_today,
          ),
          _buildStatColumn(
            context,
            value: '3',
            label: 'Meal Types',
            icon: Icons.restaurant_menu,
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(
    BuildContext context, {
    required String value,
    required String label,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.primary,
        ),
        SizedBox(height: AppDimensions.marginSmall),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildSampleMeals(BuildContext context) {
    // Get unique meals from the package slots
    final mealIds = <String>{};
    final meals = widget.package.slots
        .where((slot) => slot.mealId != null && mealIds.add(slot.mealId!))
        .map((slot) => slot.meal)
        .toList();

    return Column(
      children: [
        for (var meal in meals.take(3))
          if (meal != null)
            MealPreviewCard(
              meal: meal,
              onTap: () {
                // Navigation to meal detail could be added here
              },
            ),
      ],
    );
  }
}