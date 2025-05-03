// lib/src/domain/entities/pagination_entity.dart
import 'package:equatable/equatable.dart';

class Pagination extends Equatable {
  final int total;
  final int page;
  final int limit;
  final bool hasNextPage;
  final bool hasPreviousPage;

  const Pagination({
    this.total = 0,
    this.page = 1,
    this.limit = 10,
    this.hasNextPage = false,
    this.hasPreviousPage = false,
  });

  @override
  List<Object?> get props => [total, page, limit, hasNextPage, hasPreviousPage];
}
