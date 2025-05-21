// lib/src/presentation/cubits/package/package_state.dart
import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/pacakge_entity.dart';

abstract class PackageState extends Equatable {
  const PackageState();

  @override
  List<Object?> get props => [];
}

class PackageInitial extends PackageState {}

class PackageLoading extends PackageState {}

class PackageError extends PackageState {
  final String message;

  const PackageError(this.message);

  @override
  List<Object?> get props => [message];
}

class PackageLoaded extends PackageState {
  final List<Package> packages;
  final String? dietaryPreference;
  final String? sortOrder;

  const PackageLoaded({
    required this.packages,
    this.dietaryPreference,
    this.sortOrder,
  });

  @override
  List<Object?> get props => [packages, dietaryPreference, sortOrder];

  bool get isEmpty => packages.isEmpty;
  bool get hasPackages => packages.isNotEmpty;
}

class PackageDetailLoaded extends PackageState {
  final Package package;
  final int? selectedMealCount;
  final double? selectedPrice;

  const PackageDetailLoaded({
    required this.package,
    this.selectedMealCount,
    this.selectedPrice,
  });

  @override
  List<Object?> get props => [package, selectedMealCount, selectedPrice];

  // New method to create a copy with selected meal count and price
  PackageDetailLoaded copyWith({
    Package? package,
    int? selectedMealCount,
    double? selectedPrice,
  }) {
    return PackageDetailLoaded(
      package: package ?? this.package,
      selectedMealCount: selectedMealCount ?? this.selectedMealCount,
      selectedPrice: selectedPrice ?? this.selectedPrice,
    );
  }
}
