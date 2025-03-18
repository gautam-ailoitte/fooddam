// lib/src/presentation/views/meal_customization_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/string_constants.dart';
import 'package:foodam/src/domain/entities/daily_meals_entity.dart';
import 'package:foodam/src/domain/entities/dish_entity.dart';
import 'package:foodam/src/domain/entities/meal_entity.dart';
import 'package:foodam/src/presentation/cubits/draft_plan_cubit/draft_plan_cubit.dart';
import 'package:foodam/src/presentation/cubits/meal_customization_cubit/meal_customization_cubit.dart';
import 'package:foodam/src/presentation/cubits/plan_customization_cubit/plan_customization_cubit.dart';
import 'package:foodam/src/presentation/helpers/meal_customization_helper.dart';
import 'package:foodam/src/presentation/utlis/helper.dart';
import 'package:foodam/src/presentation/utlis/price_formatter_utility.dart';
import 'package:foodam/src/presentation/widgets/common/app_loading.dart';
import 'package:foodam/src/presentation/widgets/common/error_widget.dart';
import 'package:foodam/src/presentation/widgets/meal_item_widget.dart';

class MealCustomizationPage extends StatefulWidget {
  final Thali thali;
  final DayOfWeek dayOfWeek;
  final MealType mealType;
  
  const MealCustomizationPage({
    super.key,
    required this.thali,
    required this.dayOfWeek,
    required this.mealType,
  });
  
  @override
  State<MealCustomizationPage> createState() => _MealCustomizationPageState();
}

class _MealCustomizationPageState extends State<MealCustomizationPage> {
  @override
  void initState() {
    super.initState();
    
    // Check if the plan is being customized
    final planCustomizationState = context.read<PlanCustomizationCubit>().state;
    if (planCustomizationState is! PlanCustomizationActive) {
      // If not, show an error and navigate back
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(StringConstants.noPlanToCustomize)),
        );
        Navigator.of(context).pop();
      });
      return;
    }
    
    // Initialize customization with the current thali
    context.read<MealCustomizationCubit>().initialize(
      widget.thali,
      widget.dayOfWeek,
      widget.mealType,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(StringConstants.customizeThali),
          actions: [
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'save',
                  child: Text(StringConstants.saveDraft),
                ),
                PopupMenuItem(
                  value: 'reset',
                  child: Text(StringConstants.resetSelections),
                ),
              ],
              onSelected: (value) {
                if (value == 'save') {
                  _saveDraft();
                } else if (value == 'reset') {
                  context.read<MealCustomizationCubit>().resetToOriginal();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(StringConstants.selectionsReset)),
                  );
                }
              },
            ),
          ],
        ),
        body: BlocConsumer<MealCustomizationCubit, MealCustomizationState>(
          listener: (context, state) {
            if (state is MealCustomizationComplete) {
              // Update the plan with customized thali
              final customizationCubit = context.read<PlanCustomizationCubit>();
              if (customizationCubit.state is PlanCustomizationActive) {
                customizationCubit.updateMeal(
                  day: state.day,
                  mealType: state.mealType,
                  thali: state.customizedThali,
                );
                
                // Go back
                Navigator.of(context).pop();
              }
            }
          },
          builder: (context, state) {
            if (state is MealCustomizationLoading) {
              return AppLoading(message: 'Loading meal options...');
            } else if (state is MealCustomizationError) {
              return AppErrorWidget(
                message: state.message,
                onRetry: () => context.read<MealCustomizationCubit>().initialize(
                  widget.thali,
                  widget.dayOfWeek,
                  widget.mealType,
                ), retryText: '',
              );
            } else if (state is MealCustomizationActive) {
              // If saving, show loading overlay
              if (state is MealCustomizationSaving) {
                return Stack(
                  children: [
                    _buildMealOptions(context, state), // Show the UI underneath
                    Container(
                      color: Colors.black.withOpacity(0.3),
                      child: Center(
                        child: AppLoading(message: 'Saving changes...'),
                      ),
                    ),
                  ],
                );
              }
              return _buildMealOptions(context, state);
            }
            
            return AppLoading();
          },
        ),
        bottomNavigationBar: BlocBuilder<MealCustomizationCubit, MealCustomizationState>(
          builder: (context, state) {
            if (state is MealCustomizationActive && state is! MealCustomizationSaving) {
              return MealCustomizationHelper.buildBottomBar(context, state, () {
                context.read<MealCustomizationCubit>().saveCustomization();
              });
            }
            return SizedBox.shrink();
          },
        ),
      ),
    );
  }
  
  Future<bool> _onWillPop() async {
    // Check if there are unsaved changes
    final state = context.read<MealCustomizationCubit>().state;
    if (state is MealCustomizationActive && state.hasChanges) {
      final shouldDiscard = await DialogHelper.showDiscardConfirmation(context);
      return shouldDiscard ?? false;
    }
    
    // Don't allow back navigation during saving
    if (state is MealCustomizationSaving) {
      return false;
    }
    
    return true;
  }
  
  void _saveDraft() {
    final customizationCubit = context.read<PlanCustomizationCubit>();
    if (customizationCubit.state is PlanCustomizationActive) {
      final plan = (customizationCubit.state as PlanCustomizationActive).plan;
      context.read<DraftPlanCubit>().saveDraft(plan);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(StringConstants.draftSaved)),
      );
    }
  }

  Widget _buildMealOptions(BuildContext context, MealCustomizationActive state) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thali info card
          Card(
            margin: EdgeInsets.all(16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.originalThali.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${StringConstants.basePrice} ${PriceFormatter.formatPrice(state.originalThali.basePrice)}',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${StringConstants.additionalPrice} ${PriceFormatter.formatPrice(state.additionalPrice)}',
                    style: TextStyle(
                      fontSize: 16,
                      color: state.additionalPrice > 0 ? Colors.red : Colors.grey,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${StringConstants.totalPrice} ${PriceFormatter.formatPrice(state.totalPrice)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Divider(height: 16),
                  Text(
                    '${StringConstants.maxSelectionMessage} ${state.originalThali.maxCustomizations} items',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    '${StringConstants.selectedItems} ${state.currentSelection.length}/${state.originalThali.maxCustomizations}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: state.currentSelection.length >= state.originalThali.maxCustomizations
                          ? Colors.red
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Available meals heading
          Padding(
            padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
            child: Text(
              StringConstants.availableItems,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Available meals list
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: state.availableMeals.length,
            itemBuilder: (context, index) {
              final meal = state.availableMeals[index];
              // Check if meal is in current selection
              final isSelected = state.currentSelection.any((m) => m.id == meal.id);
              
              return MealItem(
                meal: meal,
                isSelected: isSelected,
                onToggle: () => context.read<MealCustomizationCubit>().toggleMeal(meal),
              );
            },
          ),
        ],
      ),
    );
  }
}