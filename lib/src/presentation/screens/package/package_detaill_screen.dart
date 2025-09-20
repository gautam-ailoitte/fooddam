// lib/src/presentation/screens/package/package_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/theme/enhanced_app_them.dart';
import 'package:foodam/core/widgets/app_loading.dart';
import 'package:foodam/core/widgets/error_display_wideget.dart';
import 'package:foodam/src/domain/entities/package/package_entity.dart';
import 'package:foodam/src/domain/entities/package/package_slot_entity.dart';
import 'package:foodam/src/presentation/cubits/cloud_kitchen/cloud_kitchen_cubit.dart';
import 'package:foodam/src/presentation/cubits/cloud_kitchen/cloud_kitchen_state.dart';
import 'package:foodam/src/presentation/cubits/pacakge_cubits/pacakage_cubit.dart';
import 'package:foodam/src/presentation/cubits/pacakge_cubits/pacakage_state.dart';

import '../../../../core/route/app_router.dart';
import '../../../domain/entities/meal/meal_entity.dart';

class PackageDetailScreen extends StatefulWidget {
  final Package package;

  const PackageDetailScreen({super.key, required this.package});

  @override
  State<PackageDetailScreen> createState() => _PackageDetailScreenState();
}

class _PackageDetailScreenState extends State<PackageDetailScreen> {
  late ScrollController _scrollController;
  final GlobalKey _mealPlanKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PackageCubit>().loadPackageDetail(widget.package.id);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Method to animate scroll to meal plan section
  void _scrollToMealPlan() async {
    try {
      final RenderBox? renderBox =
          _mealPlanKey.currentContext?.findRenderObject() as RenderBox?;

      if (renderBox != null) {
        final position = renderBox.localToGlobal(Offset.zero);
        final scrollOffset = _scrollController.offset;
        final targetOffset = scrollOffset + position.dy - 100;

        await _scrollController.animateTo(
          targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      } else {
        final approximatePosition = _estimateScrollPosition();
        await _scrollController.animateTo(
          approximatePosition,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    } catch (e) {
      // Scroll animation failed - silently continue
    }
  }

  // Helper method to estimate scroll position
  double _estimateScrollPosition() {
    double estimatedPosition = 0;
    estimatedPosition += 56.0; // App bar height
    estimatedPosition += 180.0; // Description card
    estimatedPosition += 200.0; // Pricing card
    estimatedPosition += (AppDimensions.marginMedium * 3);
    estimatedPosition += AppDimensions.marginMedium;
    estimatedPosition -= 50.0;
    return estimatedPosition;
  }

  // Helper method to check if day is weekend
  bool _isWeekend(String day) {
    final lowerDay = day.toLowerCase();
    return lowerDay == 'saturday' || lowerDay == 'sunday';
  }

  // Helper method to get dietary preferences as list
  List<String> _getDietaryPreferences(Meal meal) {
    return meal.dietaryPreference.isNotEmpty ? [meal.dietaryPreference] : [];
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) {
        if (didPop) {
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

            final package =
                state is PackageDetailLoaded ? state.package : widget.package;

            return _buildPackageDetailContent(package);
          },
        ),
        floatingActionButton: _buildConditionalFAB(),
      ),
    );
  }

  Widget? _buildConditionalFAB() {
    return BlocBuilder<CloudKitchenCubit, CloudKitchenState>(
      builder: (context, state) {
        bool showFAB = false;

        if (state is CloudKitchenLoaded) {
          showFAB = state.isServiceable;
        } else {
          showFAB = true; // Hardcoded for now
        }

        if (!showFAB) {
          return SizedBox.shrink();
        }

        return ElevatedButton.icon(
          onPressed: () {
            Navigator.pushNamed(
              context,
              AppRouter.startSubscriptionPlanningRoute,
            );
          },
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'Start Planning',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 4,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPackageDetailContent(Package package) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        _buildSliverAppBar(package),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(AppDimensions.marginMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDescriptionCard(package),
                SizedBox(height: AppDimensions.marginMedium),
                _buildPricingCard(package),
                SizedBox(height: AppDimensions.marginMedium),
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
                        AppColors.vegetarian.withOpacity(0.5),
                        AppColors.vegetarian,
                      ]
                      : package.isNonVegetarian
                      ? [
                        AppColors.nonVegetarian.withOpacity(0.5),
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
            Row(
              children: [
                _buildClickableInfoChip(
                  icon: Icons.calendar_month_outlined,
                  label: 'Week ${package.week}',
                  color: Colors.blue,
                  onTap: _scrollToMealPlan,
                ),
                SizedBox(width: AppDimensions.marginSmall),
                _buildClickableInfoChip(
                  icon: Icons.restaurant_menu,
                  label: '${package.totalMealsInWeek} meals',
                  color: AppColors.accent,
                  onTap: _scrollToMealPlan,
                ),
                SizedBox(width: AppDimensions.marginSmall),
                _buildClickableInfoChip(
                  icon: Icons.local_dining,
                  label: '${package.slots.length} days',
                  color: Colors.purple,
                  onTap: _scrollToMealPlan,
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
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyMealPlan(Package package) {
    if (!package.hasSlots) {
      return Card(
        key: _mealPlanKey,
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.marginLarge),
          child: const Center(
            child: Text('No meal plans available for this package.'),
          ),
        ),
      );
    }

    return Card(
      key: _mealPlanKey,
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
            LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = 2;
                if (constraints.maxWidth > 900) {
                  crossAxisCount = 4;
                } else if (constraints.maxWidth > 600) {
                  crossAxisCount = 3;
                }
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: AppDimensions.marginSmall,
                    mainAxisSpacing: AppDimensions.marginSmall,
                    childAspectRatio: 0.90,
                  ),
                  itemCount: package.slots.length,
                  itemBuilder: (context, index) {
                    return _buildDayMealCard(package.slots[index], package);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayMealCard(PackageSlot slot, Package package) {
    if (!slot.hasMeal) {
      return Container(
        padding: EdgeInsets.all(AppDimensions.marginSmall),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _capitalizeFirstLetter(slot.day),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const Spacer(),
            Center(
              child: Column(
                children: [
                  Icon(Icons.no_meals, color: Colors.grey.shade400, size: 24),
                  SizedBox(height: AppDimensions.marginSmall),
                  Text(
                    'No meal planned',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const Spacer(),
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
      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
      child: Container(
        padding: EdgeInsets.all(AppDimensions.marginSmall),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _capitalizeFirstLetter(slot.day),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                if (_isWeekend(slot.day))
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Weekend',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange,
                      ),
                    ),
                  ),
              ],
            ),
            _buildMealDishList(meal),
            Spacer(),
            _buildDietaryIndicators(meal),
          ],
        ),
      ),
    );
  }

  Widget _buildMealDishList(Meal meal) {
    List<Widget> dishWidgets = [];

    // Add meal name at the top
    dishWidgets.add(
      Text(
        meal.name,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );

    dishWidgets.add(SizedBox(height: 4));

    // Add dishes based on available meal dishes
    if (meal.dishes != null) {
      if (meal.dishes!.hasBreakfast && meal.dishes!.breakfast != null) {
        dishWidgets.add(
          _buildDishItem('B', meal.dishes!.breakfast!.name, Colors.orange),
        );
      }
      if (meal.dishes!.hasLunch && meal.dishes!.lunch != null) {
        dishWidgets.add(
          _buildDishItem('L', meal.dishes!.lunch!.name, Colors.green),
        );
      }
      if (meal.dishes!.hasDinner && meal.dishes!.dinner != null) {
        dishWidgets.add(
          _buildDishItem('D', meal.dishes!.dinner!.name, Colors.purple),
        );
      }
    }

    // If no dishes found, show meal name as fallback
    if (dishWidgets.length <= 2) {
      return Text(
        meal.name,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: dishWidgets,
    );
  }

  Widget _buildDishItem(String mealType, String dishName, Color color) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: color.withOpacity(0.3), width: 0.5),
            ),
            child: Center(
              child: Text(
                mealType,
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
          SizedBox(width: 4),
          Expanded(
            child: Text(
              dishName,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDietaryIndicators(Meal meal) {
    final dietaryPreferences = _getDietaryPreferences(meal);

    if (dietaryPreferences.isNotEmpty) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children:
                dietaryPreferences.take(2).map((pref) {
                  return _buildCompactDietaryChip(pref);
                }).toList(),
          ),
          Icon(Icons.arrow_forward_ios_outlined, size: 12, color: Colors.grey),
        ],
      );
    }

    return SizedBox.shrink();
  }

  Widget _buildClickableInfoChip({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      splashColor: color.withOpacity(0.2),
      highlightColor: color.withOpacity(0.1),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3), width: 0.5),
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
            const SizedBox(width: 2),
            Icon(
              Icons.keyboard_arrow_down,
              size: 12,
              color: color.withOpacity(0.7),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactDietaryChip(String preference) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: _getDietaryColor(preference).withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: _getDietaryColor(preference).withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Text(
        preference,
        style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w600,
          color: _getDietaryColor(preference),
        ),
      ),
    );
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

  String _capitalizeFirstLetter(String input) {
    if (input.isEmpty) {
      return input;
    }
    return input[0].toUpperCase() + input.substring(1);
  }
}
