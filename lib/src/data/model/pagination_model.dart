// lib/src/data/model/paginated_response.dart
import 'package:foodam/src/domain/entities/pagination_entity.dart';

class PaginatedResponse<T> {
  final List<T> items;
  final PaginationModel pagination;

  PaginatedResponse({required this.items, required this.pagination});

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json) fromJsonT,
    String itemsKey,
  ) {
    return PaginatedResponse<T>(
      items: (json[itemsKey] as List).map((item) => fromJsonT(item)).toList(),
      pagination: PaginationModel.fromJson(json['pagination']),
    );
  }
}

class PaginationModel {
  final int total;
  final int page;
  final int limit;
  final bool hasNextPage;
  final bool hasPreviousPage;

  PaginationModel({
    required this.total,
    required this.page,
    required this.limit,
    required this.hasNextPage,
    required this.hasPreviousPage,
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

  Pagination toEntity() {
    return Pagination(
      total: total,
      page: page,
      limit: limit,
      hasNextPage: hasNextPage,
      hasPreviousPage: hasPreviousPage,
    );
  }
}
