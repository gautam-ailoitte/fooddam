// lib/src/data/model/package_slot_model.dart
import 'package:json_annotation/json_annotation.dart';

import '../../../domain/entities/package/package_slot_entity.dart';
import '../meal/meal_model.dart';

part 'package_slot_model.g.dart';

@JsonSerializable(explicitToJson: true)
class PackageSlotModel {
  final String? day;
  final MealModel? meal;

  PackageSlotModel({this.day, this.meal});

  factory PackageSlotModel.fromJson(Map<String, dynamic> json) =>
      _$PackageSlotModelFromJson(json);

  Map<String, dynamic> toJson() => _$PackageSlotModelToJson(this);

  PackageSlot toEntity() {
    return PackageSlot(day: day ?? '', meal: meal?.toEntity());
  }

  factory PackageSlotModel.fromEntity(PackageSlot entity) {
    return PackageSlotModel(
      day: entity.day,
      meal: entity.meal != null ? MealModel.fromEntity(entity.meal!) : null,
    );
  }
}
