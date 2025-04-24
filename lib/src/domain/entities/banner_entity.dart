// lib/src/domain/entities/banner_entity.dart
import 'package:equatable/equatable.dart';

class Banner extends Equatable {
  final String id;
  final String title;
  final String category;
  final String url;
  final int index;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Banner({
    required this.id,
    required this.title,
    required this.category,
    required this.url,
    required this.index,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    category,
    url,
    index,
    createdAt,
    updatedAt,
  ];
}
