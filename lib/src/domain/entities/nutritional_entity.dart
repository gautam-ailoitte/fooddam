// lib/src/domain/entities/nutritional_info.dart
import 'package:equatable/equatable.dart';

class NutritionalInfo extends Equatable {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  const NutritionalInfo({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  @override
  List<Object?> get props => [calories, protein, carbs, fat];
}