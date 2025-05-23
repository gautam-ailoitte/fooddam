// lib/src/data/model/package_slot_model.dart
import 'package:foodam/src/data/model/day_meal_model.dart';
import 'package:foodam/src/domain/entities/package_slot_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'package_slot_model.g.dart';

@JsonSerializable(explicitToJson: true)
class PackageSlotModel {
  final String? day;
  final DayMealModel? meal;

  PackageSlotModel({this.day, this.meal});

  factory PackageSlotModel.fromJson(Map<String, dynamic> json) =>
      _$PackageSlotModelFromJson(json);

  Map<String, dynamic> toJson() => _$PackageSlotModelToJson(this);

  // Mapper to convert model to entity
  PackageSlot toEntity() {
    return PackageSlot(day: day ?? '', meal: meal?.toEntity());
  }

  // Mapper to convert entity to model
  factory PackageSlotModel.fromEntity(PackageSlot entity) {
    return PackageSlotModel(
      day: entity.day,
      meal: entity.meal != null ? DayMealModel.fromEntity(entity.meal!) : null,
    );
  }
}
