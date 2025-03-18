// lib/src/presentation/widgets/menu/meal_list.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/src/domain/entities/dish_entity.dart';
import 'package:foodam/src/presentation/widgets/dish_card.dart';

class MealList extends StatelessWidget {
  final List<Dish> dishes;
  final String mealType;
  final DateTime selectedDate;

  const MealList({
    super.key,
    required this.dishes,
    required this.mealType,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    if (dishes.isEmpty) {
      return const Center(
        child: Text('No dishes available for this meal type'),
      );
    }

    return Container(
      color: AppColors.backgroundLight,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: dishes.length,
        itemBuilder: (context, index) {
          final dish = dishes[index];
          return DishCard(dish: dish);
        },
      ),
    );
  }
}