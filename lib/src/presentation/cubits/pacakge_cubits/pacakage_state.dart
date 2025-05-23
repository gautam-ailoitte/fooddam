// lib/src/presentation/cubits/package_cubits/pacakage_state.dart
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

/// Always contains ALL packages - filtering happens at UI level
class PackageLoaded extends PackageState {
  final List<Package> packages;

  const PackageLoaded({required this.packages});

  @override
  List<Object?> get props => [packages];

  bool get isEmpty => packages.isEmpty;
  bool get hasPackages => packages.isNotEmpty;

  /// Helper methods for UI-level filtering
  List<Package> get vegetarianPackages =>
      packages.where((p) => p.isVegetarian).toList();

  List<Package> get nonVegetarianPackages =>
      packages.where((p) => p.isNonVegetarian).toList();

  /// Get filtered packages based on dietary preference
  List<Package> getFilteredPackages(String? filter) {
    switch (filter) {
      case 'vegetarian':
        return vegetarianPackages;
      case 'non-vegetarian':
        return nonVegetarianPackages;
      default:
        return packages; // Return all packages
    }
  }

  /// Sort packages by price
  List<Package> getSortedPackages(
    List<Package> packagesToSort, {
    bool ascending = true,
  }) {
    final sortedList = List<Package>.from(packagesToSort);
    sortedList.sort((a, b) {
      final aPrice = a.minPrice ?? 0;
      final bPrice = b.minPrice ?? 0;
      return ascending ? aPrice.compareTo(bPrice) : bPrice.compareTo(aPrice);
    });
    return sortedList;
  }
}

class PackageDetailLoaded extends PackageState {
  final Package package;

  const PackageDetailLoaded({required this.package});

  @override
  List<Object?> get props => [package];

  /// Helper getters for package details
  bool get hasSlots => package.hasSlots;
  List<String> get availableDays => package.availableDays;
  int get totalMeals => package.totalMealsInWeek;
  String get priceDisplay => package.priceDisplayText;
}
