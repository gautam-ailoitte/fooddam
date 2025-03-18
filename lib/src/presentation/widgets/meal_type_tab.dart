// lib/src/presentation/widgets/menu/meal_type_tabs.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/constants/string_constants.dart';

class MealTypeTabs extends StatelessWidget {
  final String selectedMealType;
  final Function(String) onMealTypeSelected;

  const MealTypeTabs({
    super.key,
    required this.selectedMealType,
    required this.onMealTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    const mealTypes = [
      {'id': 'breakfast', 'name': StringConstants.breakfast},
      {'id': 'lunch', 'name': StringConstants.lunch},
      {'id': 'dinner', 'name': StringConstants.dinner},
    ];

    return Container(
      height: 50,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: mealTypes.map((mealType) {
          final isSelected = mealType['id'] == selectedMealType;
          return _buildMealTypeTab(
            mealType['id']!,
            mealType['name']!,
            isSelected,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMealTypeTab(String id, String name, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onMealTypeSelected(id),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? AppColors.primary : Colors.grey,
                  ),
                ),
              ),
            ),
            // Indicator bar at the bottom
            Container(
              height: 3,
              color: isSelected ? AppColors.primary : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}