import 'package:foodam/src/data/model/meal/meal_slot_model.dart';
import 'package:foodam/src/data/model/package/package_model.dart';
import 'package:foodam/src/domain/entities/week_plan.dart';
import 'package:json_annotation/json_annotation.dart';

part 'week_plan_model.g.dart';

@JsonSerializable(explicitToJson: true)
class WeekPlanModel {
  final PackageModel? package;
  final int? week;
  final List<MealSlotModel>? slots;

  WeekPlanModel({this.package, this.week, this.slots});

  factory WeekPlanModel.fromJson(Map<String, dynamic> json) =>
      _$WeekPlanModelFromJson(json);

  Map<String, dynamic> toJson() => _$WeekPlanModelToJson(this);

  WeekPlan toEntity() {
    return WeekPlan(
      package: package?.toEntity(),
      week: week ?? 0,
      slots: slots?.map((slot) => slot.toEntity()).toList() ?? [],
    );
  }

  factory WeekPlanModel.fromEntity(WeekPlan entity) {
    return WeekPlanModel(
      package:
          entity.package != null
              ? PackageModel.fromEntity(entity.package!)
              : null,
      week: entity.week,
      slots:
          entity.slots.map((slot) => MealSlotModel.fromEntity(slot)).toList(),
    );
  }
}
