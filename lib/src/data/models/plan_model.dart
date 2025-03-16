import 'package:foodam/src/data/models/daily_meal_model.dart';
import 'package:foodam/src/domain/entities/daily_meals_entity.dart';
import 'package:foodam/src/domain/entities/plan_entity.dart';

class PlanModel extends Plan {
  PlanModel({
    required super.id,
    required super.name,
    required super.isVeg,
    required super.duration,
    super.startDate,
    super.endDate,
    required super.mealsByDay,
    required super.basePrice,
    required super.isCustomized,
    required super.isDraft,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    final Map<DayOfWeek, DailyMeals> mealsByDay = {};
    (json['mealsByDay'] as Map<String, dynamic>).forEach((key, value) {
      final dayOfWeek = DayOfWeek.values.firstWhere(
        (e) => e.toString() == 'DayOfWeek.$key',
        orElse: () => DayOfWeek.monday,
      );
      mealsByDay[dayOfWeek] = DailyMealsModel.fromJson(value);
    });

    return PlanModel(
      id: json['id'],
      name: json['name'],
      isVeg: json['isVeg'],
      duration: PlanDuration.values.firstWhere(
        (e) => e.toString() == 'PlanDuration.${json['duration']}',
        orElse: () => PlanDuration.sevenDays,
      ),
      startDate:
          json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      mealsByDay: mealsByDay,
      basePrice: json['basePrice'].toDouble(),
      isCustomized: json['isCustomized'],
      isDraft: json['isDraft'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> mealsByDayJson = {};
    mealsByDay.forEach((key, value) {
      mealsByDayJson[key.toString().split('.').last] =
          (value as DailyMealsModel).toJson();
    });

    return {
      'id': id,
      'name': name,
      'isVeg': isVeg,
      'duration': duration.toString().split('.').last,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'mealsByDay': mealsByDayJson,
      'basePrice': basePrice,
      'isCustomized': isCustomized,
    };
  }

  @override
  PlanModel copyWith({
    String? id,
    String? name,
    bool? isVeg,
    PlanDuration? duration,
    DateTime? startDate,
    DateTime? endDate,
    Map<DayOfWeek, DailyMeals>? mealsByDay,
    double? basePrice,
    bool? isCustomized,
    bool? isDraft,
  }) {
    return PlanModel(
      id: id ?? this.id,
      name: name ?? this.name,
      isVeg: isVeg ?? this.isVeg,
      duration: duration ?? this.duration,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      mealsByDay: mealsByDay ?? this.mealsByDay,
      basePrice: basePrice ?? this.basePrice,
      isCustomized: isCustomized ?? this.isCustomized,
      isDraft: isDraft ?? this.isDraft,
    );
  }
}
