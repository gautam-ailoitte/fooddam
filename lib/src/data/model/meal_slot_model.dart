// lib/src/data/model/meal_slot_model.dart
import 'package:foodam/src/data/model/meal_model.dart';
import 'package:foodam/src/domain/entities/meal_slot_entity.dart';

class MealSlotModel {
  final String day;
  final String timing;
  final MealModel? meal;
  final String? mealId;
  final DateTime? date;

  MealSlotModel({
    required this.day,
    required this.timing,
    this.meal,
    this.mealId,
    this.date,
  });

  factory MealSlotModel.fromJson(Map<String, dynamic> json) {
    // Parse the date if available
    DateTime? slotDate;
    String day = json['day'] ?? 'unknown';

    if (json['date'] != null) {
      try {
        slotDate = DateTime.parse(json['date'].toString());
        // Update day based on the parsed date if day is unknown
        if (day == 'unknown') {
          final days = [
            'monday',
            'tuesday',
            'wednesday',
            'thursday',
            'friday',
            'saturday',
            'sunday',
          ];
          day = days[slotDate.weekday - 1];
        }
      } catch (e) {
        print(
          'Error parsing date in MealSlotModel: ${json['date']}, error: $e',
        );
      }
    }

    return MealSlotModel(
      day: day,
      timing: json['timing'] ?? 'unknown',
      meal:
          json['meal'] != null && json['meal'] is Map
              ? MealModel.fromJson(json['meal'])
              : null,
      mealId: json['meal'] is String ? json['meal'] : null,
      date: slotDate,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {'day': day, 'timing': timing};

    // Include meal data or mealId
    if (meal != null) {
      data['meal'] = meal!.toJson();
    } else if (mealId != null) {
      data['meal'] = mealId;
    }

    // Include date if available
    if (date != null) {
      data['date'] = date!.toIso8601String();
    }

    return data;
  }

  // For API request format used in subscribe endpoint
  Map<String, dynamic> toRequestJson() {
    final Map<String, dynamic> data = {'day': day, 'timing': timing};

    // Include mealId if available (for selecting meals)
    if (mealId != null) {
      data['meal'] = mealId;
    } else if (meal != null) {
      data['meal'] = meal!.id;
    }

    return data;
  }

  // Mapper to convert model to entity
  MealSlot toEntity() {
    return MealSlot(
      day: day,
      timing: timing,
      meal: meal?.toEntity(),
      mealId: mealId ?? meal?.id,
      date: date,
    );
  }

  // Mapper to convert entity to model
  factory MealSlotModel.fromEntity(MealSlot entity) {
    return MealSlotModel(
      day: entity.day,
      timing: entity.timing,
      meal: entity.meal != null ? MealModel.fromEntity(entity.meal!) : null,
      mealId: entity.mealId,
      date: entity.date,
    );
  }
}
