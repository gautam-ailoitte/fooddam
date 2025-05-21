import 'package:equatable/equatable.dart';

class PriceRange extends Equatable {
  final double min;
  final double max;

  const PriceRange({required this.min, required this.max});

  @override
  List<Object?> get props => [min, max];
}
