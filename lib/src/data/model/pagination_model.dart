// lib/src/data/model/pagination_model.dart
import 'package:foodam/src/domain/entities/pagination_entity.dart';

class PaginationModel {
  final int total;
  final int page;
  final int limit;
  final bool hasNextPage;
  final bool hasPreviousPage;

  PaginationModel({
    this.total = 0,
    this.page = 1,
    this.limit = 10,
    this.hasNextPage = false,
    this.hasPreviousPage = false,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      hasNextPage: json['hasNextPage'] ?? false,
      hasPreviousPage: json['hasPreviousPage'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'page': page,
      'limit': limit,
      'hasNextPage': hasNextPage,
      'hasPreviousPage': hasPreviousPage,
    };
  }

  Pagination toEntity() {
    return Pagination(
      total: total,
      page: page,
      limit: limit,
      hasNextPage: hasNextPage,
      hasPreviousPage: hasPreviousPage,
    );
  }

  factory PaginationModel.fromEntity(Pagination entity) {
    return PaginationModel(
      total: entity.total,
      page: entity.page,
      limit: entity.limit,
      hasNextPage: entity.hasNextPage,
      hasPreviousPage: entity.hasPreviousPage,
    );
  }
}
