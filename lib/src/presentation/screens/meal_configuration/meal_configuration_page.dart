// lib/src/presentation/pages/subscription/meal_configuration_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/constants/string_constants.dart';
import 'package:foodam/core/layout/app_scaffold.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/widgets/app_button.dart';
import 'package:foodam/core/widgets/app_card.dart';
import 'package:foodam/core/widgets/app_error_widget.dart';
import 'package:foodam/core/widgets/app_loading.dart';
import 'package:foodam/core/widgets/app_section_header.dart';
import 'package:foodam/src/domain/entities/dish_entity.dart';
import 'package:foodam/src/domain/entities/meal_entity.dart';
import 'package:foodam/src/presentation/cubits/meal_configuration/meal_configuration_cubit.dart';
import 'package:foodam/src/presentation/cubits/meal_configuration/meal_configuration_state.dart';
import 'package:foodam/src/presentation/cubits/subscription/subscription_cubit.dart';
import 'package:foodam/src/presentation/screens/checkout/checkout_page.dart';
import 'package:foodam/src/presentation/widgets/day_selector.dart';
import 'package:foodam/src/presentation/widgets/meal_type_selector.dart';

class MealConfigurationPage extends StatefulWidget {
  static const routeName = '/meal-configuration';

  const MealConfigurationPage({super.key});

  @override
  State<MealConfigurationPage> createState() => _MealConfigurationPageState();
}

class _MealConfigurationPageState extends State<MealConfigurationPage> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MealConfigurationCubit, MealConfigurationState>(
      listener: (context, state) {
        if (state.status == MealConfigurationStatus.error && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
            ),
          );
        }

        if (state.status == MealConfigurationStatus.completed) {
          // Navigate to checkout
       // show snack bar
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Meal configuration saved successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state.status == MealConfigurationStatus.initial ||
            state.status == MealConfigurationStatus.loading) {
          return const Scaffold(
            body: Center(
              child: AppLoading(message: 'Initializing meal configuration...'),
            ),
          );
        }

        if (state.status == MealConfigurationStatus.error && state.dayMealsMap.isEmpty) {
          return Scaffold(
            body: Center(
              child: AppErrorWidget(
                message: state.errorMessage ?? 'Failed to initialize meal configuration',
                onRetry: () {
                  // Re-initialize with vegetarian preference (default)
                  context.read<MealConfigurationCubit>().initializeMealConfiguration(
                        DietaryPreference.vegetarian,
                      );
                },
                retryText: 'Retry',
              ),
            ),
          );
        }

        return AppScaffold(
          title: StringConstants.customizePlan,
          type: ScaffoldType.withAppBar,
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                _showInfoDialog(context);
              },
            ),
          ],
          body: Column(
            children: [
              // Fixed section at the top
              _buildTopControls(context, state),
              // Scrollable content
              Expanded(
                child: _buildMealCustomizationContent(context, state),
              ),
              // Fixed bottom actions
              _buildBottomActions(context, state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopControls(BuildContext context, MealConfigurationState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Day selector
          DaySelector(
            selectedDayIndex: state.selectedDayIndex,
            onDaySelected: (dayIndex) {
              context.read<MealConfigurationCubit>().selectDay(dayIndex);
            },
          ),
          AppSpacing.vMd,
          // Meal type selector
          MealTypeSelector(
            selectedMealType: state.selectedMealType,
            onMealTypeSelected: (mealType) {
              context.read<MealConfigurationCubit>().selectMealType(mealType);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMealCustomizationContent(BuildContext context, MealConfigurationState state) {
    final meal = state.selectedMeal;
    
    if (meal == null) {
      return const Center(
        child: Text('No meal found for this selection.'),
      );
    }

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSectionHeader(
                  title: meal.name,
                  subtitle: meal.description,
                ),
                AppSpacing.vMd,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${StringConstants.basePrice} ₹${meal.basePrice.toInt()}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (state.totalAdditionalCost > 0) ...[
                      Text(
                        '${StringConstants.additionalPrice} +₹${state.totalAdditionalCost.toInt()}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.accent,
                            ),
                      ),
                    ],
                  ],
                ),
                if (state.totalAdditionalCost > 0) ...[
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${StringConstants.totalPrice} ₹${(meal.basePrice + state.totalAdditionalCost).toInt()}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: _buildCategorySelectionInfo(context),
        ),
        ...meal.categories.map((category) {
          return SliverToBoxAdapter(
            child: _buildCategorySection(context, state, category),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildCategorySelectionInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: AppCard(
        backgroundColor: AppColors.info.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.info,
                size: 24,
              ),
              AppSpacing.hMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How meal customization works:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.info,
                      ),
                    ),
                    AppSpacing.vXs,
                    Text(
                      '• No extra charge for swapping dishes within the same category\n'
                      '• Additional charges apply only for dishes added beyond minimum requirements',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.info,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection(
    BuildContext context,
    MealConfigurationState state,
    MealCategory category,
  ) {
    // Get all dishes for this category
    final categorySelections = state.currentSelections
        .where((entry) => entry.categoryName == category.name)
        .toList();

    // Count how many selections we have for this category
    final selectedCount = categorySelections.length;

    // Check if we're at max selections for this category
    final isMaxReached = selectedCount >= category.maxSelections;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      AppSpacing.vXs,
                      Text(
                        category.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Selected: $selectedCount/${category.maxSelections}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            if (category.minSelections > 0) ...[
              AppSpacing.vXs,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: selectedCount < category.minSelections
                      ? AppColors.error.withOpacity(0.1)
                      : AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Required: ${category.minSelections} ${category.minSelections == 1 ? 'item' : 'items'}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: selectedCount < category.minSelections
                        ? AppColors.error
                        : AppColors.success,
                  ),
                ),
              ),
            ],
            AppSpacing.vMd,
            ...category.options.map((option) {
              final isSelected = state.isDishSelected(option.dishId);
              final dish = state.dishesCache[option.dishId];
              
              // Determine if this dish is a default (original) selection
              final isOriginal = categorySelections.any(
                (entry) => entry.dishId == option.dishId && entry.isOriginal,
              );
              
              // Determine if this dish is an additional selection (beyond min requirements)
              final isAdditional = categorySelections.any(
                (entry) => entry.dishId == option.dishId && entry.isAdditional,
              );

              return _buildDishOption(
                context,
                dish: dish,
                dishId: option.dishId,
                categoryName: category.name,
                isSelected: isSelected,
                isOriginal: isOriginal,
                isAdditional: isAdditional,
                isEnabled: isSelected || !isMaxReached,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDishOption(
    BuildContext context, {
    required Dish? dish,
    required String dishId,
    required String categoryName,
    required bool isSelected,
    required bool isOriginal,
    required bool isAdditional,
    required bool isEnabled,
  }) {
    final name = dish?.name ?? 'Loading...';
    final description = dish?.description ?? '';
    final price = dish?.price ?? 0.0;

    return ListTile(
      enabled: isEnabled,
      contentPadding: EdgeInsets.zero,
      leading: SizedBox(
        width: 48,
        height: 48,
        child: Stack(
          children: [
            dish != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: dish.imageUrl.startsWith('http')
                        ? Image.network(
                            dish.imageUrl,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (context, _, __) => Container(
                              width: 48,
                              height: 48,
                              color: AppColors.backgroundLight,
                              child: const Icon(Icons.restaurant),
                            ),
                          )
                        : Image.asset(
                            dish.imageUrl,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (context, _, __) => Container(
                              width: 48,
                              height: 48,
                              color: AppColors.backgroundLight,
                              child: const Icon(Icons.restaurant),
                            ),
                          ),
                  )
                : Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
            if (isSelected)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
      title: Text(
        name,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          if (isSelected) ...[
            AppSpacing.vXs,
            isOriginal
                ? const Text(
                    'Default selection',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  )
                : isAdditional
                    ? Text(
                        'Additional item (+₹${price.toInt()})',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accent,
                        ),
                      )
                    : const Text(
                        'Swapped item (no extra charge)',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.info,
                        ),
                      ),
          ],
        ],
      ),
      trailing: price > 0
          ? Text(
              '₹${price.toInt()}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isAdditional && isSelected ? AppColors.accent : null,
              ),
            )
          : null,
      onTap: isEnabled
          ? () {
              context
                  .read<MealConfigurationCubit>()
                  .toggleDishSelection(dishId, categoryName);
            }
          : null,
    );
  }

  Widget _buildBottomActions(BuildContext context, MealConfigurationState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: AppButton(
              label: 'reset',
              onPressed: () {
                context.read<MealConfigurationCubit>().resetCurrentMeal();
              },
              buttonType: AppButtonType.outline,
              buttonSize: AppButtonSize.medium,
            ),
          ),
          AppSpacing.hMd,
          Expanded(
            child: AppButton(
              label: 'Apply to All Days',
              onPressed: () {
                _showApplyToAllConfirmation(context);
              },
              buttonType: AppButtonType.secondary,
              buttonSize: AppButtonSize.medium,
            ),
          ),
          AppSpacing.hMd,
          Expanded(
            child: AppButton(
              label: StringConstants.saveDraft,
              onPressed: () {
                _saveDraft(context);
              },
              buttonType: AppButtonType.primary,
              buttonSize: AppButtonSize.medium,
            ),
          ),
        ],
      ),
    );
  }

  void _showApplyToAllConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apply to All Days'),
        content: const Text(
            'Would you like to apply this meal configuration to all days?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(StringConstants.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<MealConfigurationCubit>().applyCurrentMealToAll();
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Meal configuration applied to all days'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _saveDraft(BuildContext context) {
    // Create a simple subscription from the current configuration
    // In a real app, you'd have proper mapping logic here
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(StringConstants.draftSaved),
        backgroundColor: AppColors.success,
      ),
    );
    
    // Complete meal configuration
    context.read<MealConfigurationCubit>().completeMealConfiguration();
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Meal Customization Guide'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoSection(
                'Free Swaps',
                'You can swap dishes within the same category at no extra cost. Just make sure to meet the minimum required selections for each category.',
                Icons.swap_horiz,
                AppColors.info,
              ),
              const Divider(),
              _buildInfoSection(
                'Additional Charges',
                'Charges apply only when you add dishes beyond the minimum requirements. The price of each additional dish will be shown when selected.',
                Icons.add_circle_outline,
                AppColors.accent,
              ),
              const Divider(),
              _buildInfoSection(
                'Required Selections',
                'Some categories have minimum requirements. Make sure to select at least the required number of dishes.',
                Icons.check_circle_outline,
                AppColors.success,
              ),
              const Divider(),
              _buildInfoSection(
                'Apply to All Days',
                'Use the "Apply to All Days" button to quickly copy your current meal configuration to all days of your subscription.',
                Icons.calendar_today_outlined,
                AppColors.primary,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          AppSpacing.hMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                AppSpacing.vXs,
                Text(
                  description,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
