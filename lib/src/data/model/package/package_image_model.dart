// lib/src/data/model/package_image_model.dart
import 'package:json_annotation/json_annotation.dart';

import '../../../domain/entities/package/package_image_entity.dart';

part 'package_image_model.g.dart';

@JsonSerializable()
class PackageImageModel {
  final String? id;
  final String? url;
  final String? key;
  final String? fileName;

  PackageImageModel({this.id, this.url, this.key, this.fileName});

  factory PackageImageModel.fromJson(Map<String, dynamic> json) =>
      _$PackageImageModelFromJson(json);

  Map<String, dynamic> toJson() => _$PackageImageModelToJson(this);

  PackageImage toEntity() {
    return PackageImage(
      id: id ?? '',
      url: url ?? '',
      key: key ?? '',
      fileName: fileName ?? '',
    );
  }

  factory PackageImageModel.fromEntity(PackageImage entity) {
    return PackageImageModel(
      id: entity.id,
      url: entity.url,
      key: entity.key,
      fileName: entity.fileName,
    );
  }
}
