// lib/src/presentation/screens/meals/meal_customization_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/constants/string_constants.dart';
import 'package:foodam/core/layout/app_scaffold.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/service/dialog_service.dart';
import 'package:foodam/core/widgets/app_button.dart';
import 'package:foodam/core/widgets/app_card.dart';
import 'package:foodam/core/widgets/app_error_widget.dart';
import 'package:foodam/core/widgets/app_loading.dart';
import 'package:foodam/core/widgets/app_section_header.dart';
import 'package:foodam/src/domain/entities/dish_entity.dart';
import 'package:foodam/src/domain/entities/meal_entity.dart';
import 'package:foodam/src/presentation/cubits/meal_customization/meal_customization_cubit.dart';
import 'package:foodam/src/presentation/cubits/meal_customization/meal_customization_state.dart';
import 'package:foodam/src/presentation/widgets/dish_selection_item.dart';
class MealCustomizationScreen extends StatefulWidget {
  final String mealId;
  final String mealType; // breakfast, lunch, dinner

  const MealCustomizationScreen({
    Key? key,
    required this.mealId,
    required this.mealType,
  }) : super(key: key);

  @override
  State<MealCustomizationScreen> createState() => _MealCustomizationScreenState();
}

class _MealCustomizationScreenState extends State<MealCustomizationScreen> {
  late final TabController _tabController;
  late final List<MealCategory> _categories;
  int _currentCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    _startCustomization();
  }

  Future<void> _startCustomization() async {
    context.read<MealCustomizationCubit>().startCustomizingMeal(widget.mealId);
  }

  void _selectDish(String categoryName, String dishId) {
    context.read<MealCustomizationCubit>().selectDish(categoryName, dishId);
  }

  void _removeDish(String categoryName, String dishId) {
    context.read<MealCustomizationCubit>().removeDish(categoryName, dishId);
  }

  void _resetCustomization() {
    AppDialogs.showConfirmationDialog(
      context: context,
      title: StringConstants.resetSelections,
      message: StringConstants.resetPlanConfirmation,
      isDestructiveAction: true,
    ).then((confirm) {
      if (confirm == true) {
        context.read<MealCustomizationCubit>().resetCustomization();
      }
    });
  }

  void _completeCustomization() {
    context.read<MealCustomizationCubit>().completeCustomization();
  }

  void _changeCategory(int index) {
    setState(() {
      _currentCategoryIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: StringConstants.customizeThali,
      body: BlocConsumer<MealCustomizationCubit, MealCustomizationState>(
        listener: (context, state) {
          if (state is MealCustomizationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is MealCustomizationCompleted) {
            // Navigate back with result
            Navigator.of(context).pop(state);
          }
        },
        builder: (context, state) {
          if (state is MealCustomizationLoading) {
            return const Center(child: AppLoading());
          } else if (state is MealCustomizationError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: _startCustomization,
              retryText: StringConstants.retry,
            );
          } else if (state is MealCustomizationReady) {
            // Store categories for tab controller
            _categories = state.meal.categories;
            
            return Column(
              children: [
                // Meal info header
                _buildMealHeader(state.meal, widget.mealType),
                
                // Categories tabs
                _buildCategoryTabs(state.meal.categories),
                
                // Current category content
                Expanded(
                  child: IndexedStack(
                    index: _currentCategoryIndex,
                    children: state.meal.categories.map((category) {
                      return _buildCategoryContent(
                        category,
                        state.selectedDishIds[category.name] ?? [],
                        state.availableAdditionalDishes[category.name] ?? [],
                      );
                    }).toList(),
                  ),
                ),
                
                // Bottom bar with pricing
                _buildBottomBar(state.meal.basePrice, state.totalCustomizationPrice),
              ],
            );
          }
          
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildMealHeader(Meal meal, String mealType) {
    // Format meal type for display (capitalize first letter)
    final formattedMealType = mealType.substring(0, 1).toUpperCase() + mealType.substring(1);
    
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$formattedMealType: ${meal.name}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          AppSpacing.vXs,
          Text(
            meal.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          AppSpacing.vSm,
          Row(
            children: meal.dietaryPreferences.map((pref) {
              return Container(
                margin: const EdgeInsets.only(right: 8.0),
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: pref == DietaryPreference.vegetarian
                      ? AppColors.vegetarian
                      : AppColors.nonVegetarian,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Text(
                  pref.toString().split('.').last,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs(List<MealCategory> categories) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = index == _currentCategoryIndex;
          
          return InkWell(
            onTap: () => _changeCategory(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
              child: Text(
                category.name,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryContent(
    MealCategory category, 
    List<String> selectedDishIds,
    List<Dish> availableDishes,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Category description
        Text(
          category.description,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        AppSpacing.vSm,
        
        // Selection constraints
        Text(
          '${StringConstants.maxSelectionMessage} ${category.maxSelections} items. '
          '${StringConstants.pleaseSelectItems} ${category.minSelections} items.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        AppSpacing.vMd,
        
        // Standard options
        AppSectionHeader(title: StringConstants.selectedItems),
        AppSpacing.vSm,
        ...category.options.map((option) {
          final isSelected = selectedDishIds.contains(option.dishId);
          
          return FutureBuilder<Dish>(
            // In a real app, you'd fetch the dish data with a repository
            // Here we're simulating it with a Future.delayed
            future: Future.delayed(
              Duration(milliseconds: 100),
              () => _findDishById(option.dishId),
            ),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox(
                  height: 80,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              
              final dish = snapshot.data!;
              
              return DishSelectionItem(
                dish: dish,
                isSelected: isSelected,
                onSelect: () => _selectDish(category.name, dish.id),
                onRemove: () => _removeDish(category.name, dish.id),
                showQuantity: true,
                quantity: option.defaultQuantity,
              );
            },
          );
        }).toList(),
        
        AppSpacing.vLg,
        
        // Additional options
        if (availableDishes.isNotEmpty) ...[
          AppSectionHeader(title: StringConstants.availableItems),
          AppSpacing.vSm,
          ...availableDishes.map((dish) {
            final isSelected = selectedDishIds.contains(dish.id);
            
            return DishSelectionItem(
              dish: dish,
              isSelected: isSelected,
              onSelect: () => _selectDish(category.name, dish.id),
              onRemove: () => _removeDish(category.name, dish.id),
              isAdditionalItem: true,
            );
          }).toList(),
        ],
      ],
    );
  }

  Widget _buildBottomBar(double basePrice, double additionalPrice) {
    final totalPrice = basePrice + additionalPrice;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Price breakdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                StringConstants.basePrice,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                '₹${basePrice.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          if (additionalPrice > 0) ...[
            AppSpacing.vXs,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  StringConstants.additionalPrice,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '₹${additionalPrice.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ],
          AppSpacing.vXs,
          const Divider(),
          AppSpacing.vXs,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                StringConstants.totalPrice,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                '₹${totalPrice.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          AppSpacing.vMd,
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: StringConstants.resetSelections,
                  onPressed: _resetCustomization,
                  buttonType: AppButtonType.outline,
                  buttonSize: AppButtonSize.medium,
                ),
              ),
              AppSpacing.hMd,
              Expanded(
                child: AppButton(
                  label: StringConstants.done,
                  onPressed: _completeCustomization,
                  buttonType: AppButtonType.primary,
                  buttonSize: AppButtonSize.medium,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // This is just a mock function to find dishes by ID
  // In a real app, this would come from a repository
  Dish _findDishById(String id) {
    // This is simplified - in a real app, you'd lookup the dish in a repo
    // For mock purposes, let's create a dummy dish
    return Dish(
      id: id,
      name: 'Dish $id',
      description: 'Delicious dish for your meal',
      price: 100.0,
      category: FoodCategory.mainCourse,
      dietaryPreferences: [DietaryPreference.vegetarian],
      imageUrl: 'assets/images/dishes/placeholder.jpg',
      quantity: const Quantity(value: 1, unit: QuantityUnit.servings),
      ingredients: ['Ingredient 1', 'Ingredient 2'],
    );
  }
}