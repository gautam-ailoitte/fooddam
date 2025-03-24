// lib/src/domain/entities/meal_distribution_entity.dart
import 'package:equatable/equatable.dart';

class MealDistribution extends Equatable {
  final String day;
  final String mealTime;
  final String? mealId;
  
  const MealDistribution({
    required this.day,
    required this.mealTime,
    this.mealId,
  });
  
  @override
  List<Object?> get props => [day, mealTime, mealId];
  
  // Helper method to get a human-readable description
  String get description => '$day $mealTime';
  
  // Factory method to create a MealDistribution from a map
  factory MealDistribution.fromMap(Map<String, dynamic> map) {
    return MealDistribution(
      day: map['day'] as String,
      mealTime: map['timing'] as String,
      mealId: map['meal'] as String?,
    );
  }
  
  // Convert to a map
  Map<String, dynamic> toMap() {
    return {
      'day': day,
      'timing': mealTime,
      'meal': mealId,
    };
  }
}