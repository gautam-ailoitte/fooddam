
// lib/src/presentation/widgets/meal_type_selector.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/constants/string_constants.dart';

class MealTypeSelector extends StatelessWidget {
  final String selectedMealType;
  final Function(String) onMealTypeSelected;

  const MealTypeSelector({
    Key? key,
    required this.selectedMealType,
    required this.onMealTypeSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          _buildMealTypeOption(
            context,
            StringConstants.breakfast.toLowerCase(),
            StringConstants.breakfast,
            Icons.free_breakfast,
            Colors.orange,
          ),
          _buildMealTypeOption(
            context,
            StringConstants.lunch.toLowerCase(),
            StringConstants.lunch,
            Icons.lunch_dining,
            Colors.green,
          ),
          _buildMealTypeOption(
            context,
            StringConstants.dinner.toLowerCase(),
            StringConstants.dinner,
            Icons.dinner_dining,
            Colors.deepPurple,
          ),
        ],
      ),
    );
  }

  Widget _buildMealTypeOption(
    BuildContext context,
    String mealType,
    String label,
    IconData icon,
    Color color,
  ) {
    final isSelected = selectedMealType == mealType;

    return Expanded(
      child: GestureDetector(
        onTap: () => onMealTypeSelected(mealType),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : color,
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}