// lib/src/data/model/cloud_kitchen_model.dart
import 'package:foodam/src/data/model/address_model.dart';
import 'package:foodam/src/domain/entities/cloud_kitchen_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cloud_kitchen_model.g.dart';

@JsonSerializable(explicitToJson: true)
class CloudKitchenModel {
  final String? id;
  final String? name;
  final AddressModel? address;

  CloudKitchenModel({this.id, this.name, this.address});

  factory CloudKitchenModel.fromJson(Map<String, dynamic> json) =>
      _$CloudKitchenModelFromJson(json);

  Map<String, dynamic> toJson() => _$CloudKitchenModelToJson(this);

  /// Mapper to convert model to entity
  CloudKitchen toEntity() {
    return CloudKitchen(id: id, name: name, address: address?.toEntity());
  }

  /// Mapper to convert entity to model
  factory CloudKitchenModel.fromEntity(CloudKitchen entity) {
    return CloudKitchenModel(
      id: entity.id,
      name: entity.name,
      address:
          entity.address != null
              ? AddressModel.fromEntity(entity.address!)
              : null,
    );
  }
}
