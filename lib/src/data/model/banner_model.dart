// lib/src/data/model/banner_model.dart
import 'package:foodam/src/domain/entities/banner_entity.dart' as banner_entity;

class BannerModel {
  final String id;
  final String title;
  final String category;
  final String url;
  final int index;
  final DateTime createdAt;
  final DateTime updatedAt;

  BannerModel({
    required this.id,
    required this.title,
    required this.category,
    required this.url,
    required this.index,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      url: json['url'] ?? '',
      index: json['index'] ?? 0,
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now(),
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'])
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'url': url,
      'index': index,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Mapper to convert model to entity
  banner_entity.Banner toEntity() {
    return banner_entity.Banner(
      id: id,
      title: title,
      category: category,
      url: url,
      index: index,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // Mapper to convert entity to model
  factory BannerModel.fromEntity(banner_entity.Banner entity) {
    return BannerModel(
      id: entity.id,
      title: entity.title,
      category: entity.category,
      url: entity.url,
      index: entity.index,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
