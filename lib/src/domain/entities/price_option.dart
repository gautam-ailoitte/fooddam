import 'package:equatable/equatable.dart';

class PriceOption extends Equatable {
  final int numberOfMeals;
  final double price;

  const PriceOption({required this.numberOfMeals, required this.price});

  @override
  List<Object?> get props => [numberOfMeals, price];
}
