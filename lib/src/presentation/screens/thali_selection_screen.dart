// lib/src/presentation/screens/meals/thali_selection_screen.dart
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
import 'package:foodam/src/presentation/cubits/meal_customization/meal_customization_cubit.dart';
import 'package:foodam/src/presentation/cubits/meal_customization/meal_customization_state.dart';
import 'package:foodam/src/presentation/screens/meal_customization_screen.dart';

class ThaliSelectionScreen extends StatefulWidget {
  const ThaliSelectionScreen({Key? key}) : super(key: key);

  @override
  State<ThaliSelectionScreen> createState() => _ThaliSelectionScreenState();
}

class _ThaliSelectionScreenState extends State<ThaliSelectionScreen> {
  int _selectedDayIndex = 0;
  final List<String> _mealTypes = ['breakfast', 'lunch', 'dinner'];
  String _selectedMealType = 'lunch'; // Default meal type
  
  final Map<String, List<String>> _thaliTypes = {
    'breakfast': [StringConstants.normalThali, 'Special Breakfast', 'Continental Breakfast'],
    'lunch': [StringConstants.normalThali, StringConstants.nonVegThali, StringConstants.deluxeThali],
    'dinner': [StringConstants.normalThali, StringConstants.nonVegThali, StringConstants.deluxeThali],
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Load available meals
    context.read<MealCustomizationCubit>().getAvailableMeals();
  }

  void _selectDay(int index) {
    setState(() {
      _selectedDayIndex = index;
    });
  }

  void _selectMealType(String mealType) {
    setState(() {
      _selectedMealType = mealType;
    });
  }

  void _navigateToMealCustomization(String mealId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MealCustomizationScreen(
          mealId: mealId,
          mealType: _selectedMealType,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: StringConstants.selectThali,
      body: Column(
        children: [
          // Meal type selector
          _buildMealTypeSelector(),
          
          // Day selector
          _buildDaySelector(),
          
          // Available thalis
          Expanded(
            child: _buildThaliList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMealTypeSelector() {
    return Container(
      height: 50,
      color: Colors.white,
      child: Row(
        children: _mealTypes.map((mealType) {
          final isSelected = mealType == _selectedMealType;
          final formattedType = '${mealType.substring(0, 1).toUpperCase()}${mealType.substring(1)}';
          
          return Expanded(
            child: InkWell(
              onTap: () => _selectMealType(mealType),
              child: Container(
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
                  formattedType,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDaySelector() {
    // Generate day names for a week
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    return Container(
      height: 50,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: List.generate(7, (index) {
          final isSelected = _selectedDayIndex == index;
          
          return Expanded(
            child: GestureDetector(
              onTap: () => _selectDay(index),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text(
                  days[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildThaliList() {
    return BlocBuilder<MealCustomizationCubit, MealCustomizationState>(
      builder: (context, state) {
        if (state is MealCustomizationLoading) {
          return const Center(child: AppLoading());
        } else if (state is MealCustomizationError) {
          return AppErrorWidget(
            message: state.message,
            onRetry: _loadData,
            retryText: StringConstants.retry,
          );
        } else if (state is MealsLoaded) {
          if (state.meals.isEmpty) {
            return Center(
              child: Text(StringConstants.noMealSelected),
            );
          }
          
          // Get day name
          final days = [StringConstants.monday, StringConstants.tuesday, StringConstants.wednesday, 
                        StringConstants.thursday, StringConstants.friday, StringConstants.saturday, 
                        StringConstants.sunday];
          final selectedDay = days[_selectedDayIndex];
          
          // Format meal type for display
          final formattedMealType = '${_selectedMealType.substring(0, 1).toUpperCase()}${_selectedMealType.substring(1)}';
          
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Selected day and meal type header
              AppSectionHeader(
                title: StringConstants.selectThaliFor,
                subtitle: '$selectedDay $formattedMealType',
              ),
              
              Text(
                StringConstants.selectThaliMessage,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              AppSpacing.vLg,
              
              // Thali options
              ..._thaliTypes[_selectedMealType]!.map((thaliType) {
                // Find a meal that matches this thali type (simplified for demo)
                final meal = state.meals.firstWhere(
                  (m) => m.name.contains(thaliType) || thaliType.contains(m.name),
                  orElse: () => state.meals.first,
                );
                
                return _buildThaliCard(meal, thaliType);
              }).toList(),
            ],
          );
        }
        
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildThaliCard(Meal meal, String thaliType) {
    // Determine vegetarian/non-vegetarian status
    final bool isVegetarian = meal.dietaryPreferences.contains(DietaryPreference.vegetarian);
    final bool isNonVegetarian = meal.dietaryPreferences.contains(DietaryPreference.nonVegetarian);
    
    return AppCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    thaliType,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  AppSpacing.hSm,
                  if (isVegetarian)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.vegetarian.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Veg',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.vegetarian,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    )
                  else if (isNonVegetarian)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.nonVegetarian.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Non-Veg',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.nonVegetarian,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                ],
              ),
              Text(
                '₹${meal.price.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          AppSpacing.vMd,
          
          // Included items
          Text(
            StringConstants.includes,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          AppSpacing.vSm,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(5, (index) {
              // Sample dish names for demonstration
              final dishNames = [
                'Rice', 'Dal', 'Roti', 'Sabji', 'Paneer', 'Chicken', 'Salad', 'Raita', 'Papad'
              ];
              
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  dishNames[index % dishNames.length],
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              );
            }),
          ),
          AppSpacing.vLg,
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: StringConstants.selectThali,
                  onPressed: () {
                    // Here you would handle direct selection without customization
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$thaliType selected for $selectedDay'),
                      ),
                    );
                    Navigator.pop(context);
                  },
                  buttonType: AppButtonType.outline,
                  buttonSize: AppButtonSize.medium,
                ),
              ),
              AppSpacing.hMd,
              Expanded(
                child: AppButton(
                  label: StringConstants.customize,
                  onPressed: () => _navigateToMealCustomization(meal.id),
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

  String get selectedDay {
    final days = [StringConstants.monday, StringConstants.tuesday, StringConstants.wednesday, 
                 StringConstants.thursday, StringConstants.friday, StringConstants.saturday, 
                 StringConstants.sunday];
    return days[_selectedDayIndex];
  }
}