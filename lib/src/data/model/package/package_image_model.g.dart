// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'package_image_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PackageImageModel _$PackageImageModelFromJson(Map<String, dynamic> json) =>
    PackageImageModel(
      id: json['id'] as String?,
      url: json['url'] as String?,
      key: json['key'] as String?,
      fileName: json['fileName'] as String?,
    );

Map<String, dynamic> _$PackageImageModelToJson(PackageImageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'key': instance.key,
      'fileName': instance.fileName,
    };
