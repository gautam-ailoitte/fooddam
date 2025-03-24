// lib/src/presentation/cubits/package/package_state.dart
import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/pacakge_entity.dart';

/// Base state for all package-related states
abstract class PackageState extends Equatable {
  const PackageState();
  
  @override
  List<Object?> get props => [];
}

/// Initial state when no package data has been loaded
class PackageInitial extends PackageState {
  const PackageInitial();
}

/// Loading state for package operations
class PackageLoading extends PackageState {
  const PackageLoading();
}

/// State for when packages are loaded (list view)
class PackageLoaded extends PackageState {
  final List<Package> packages;
  final List<Package> allPackages;
  final String? currentFilter;
  final String? sortOrder;
  
  const PackageLoaded({
    required this.packages, 
    this.allPackages = const [],
    this.currentFilter,
    this.sortOrder,
  });
  
  @override
  List<Object?> get props => [packages, allPackages, currentFilter, sortOrder];
  
  bool get isFiltered => currentFilter != null;
  bool get isSorted => sortOrder != null;
  bool get isEmpty => packages.isEmpty;
  bool get hasPackages => packages.isNotEmpty;
  
  int get packageCount => packages.length;
  
  double get lowestPrice => 
      packages.isEmpty ? 0 : packages.map((p) => p.price).reduce((a, b) => a < b ? a : b);
      
  double get highestPrice => 
      packages.isEmpty ? 0 : packages.map((p) => p.price).reduce((a, b) => a > b ? a : b);
      
  double get averagePrice => 
      packages.isEmpty ? 0 : packages.fold(0.0, (sum, p) => sum + p.price) / packages.length;
      
  /// Get packages that are vegetarian
  List<Package> get vegetarianPackages => 
      packages.where((p) => p.name.toLowerCase().contains('veg')).toList();
      
  /// Get packages that are non-vegetarian
  List<Package> get nonVegetarianPackages => 
      packages.where((p) => p.name.toLowerCase().contains('non-veg')).toList();
      
  /// Get packages that match a specific keyword
  List<Package> getPackagesByKeyword(String keyword) => 
      packages.where((p) => 
        p.name.toLowerCase().contains(keyword.toLowerCase()) || 
        p.description.toLowerCase().contains(keyword.toLowerCase())
      ).toList();
      
  /// Get a package by ID
  Package? getPackageById(String id) {
    try {
      return allPackages.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}

/// State for when a specific package is loaded (detail view)
class PackageDetailLoaded extends PackageState {
  final Package package;
  
  const PackageDetailLoaded({required this.package});
  
  @override
  List<Object?> get props => [package];
  
  bool get isVegetarian => 
      package.name.toLowerCase().contains('veg') && 
      !package.name.toLowerCase().contains('non-veg');
      
  bool get isNonVegetarian => 
      package.name.toLowerCase().contains('non-veg');
      
  int get totalMeals => package.slots.length;
  
  int get breakfastCount => 
      package.slots.where((slot) => slot.isBreakfast).length;
      
  int get lunchCount => 
      package.slots.where((slot) => slot.isLunch).length;
      
  int get dinnerCount => 
      package.slots.where((slot) => slot.isDinner).length;
      
  int get weekdayMealsCount => 
      package.slots.where((slot) => slot.isWeekday).length;
      
  int get weekendMealsCount => 
      package.slots.where((slot) => slot.isWeekend).length;
}

/// Error state for package operations
class PackageError extends PackageState {
  final String message;
  
  const PackageError({required this.message});
  
  @override
  List<Object?> get props => [message];
}