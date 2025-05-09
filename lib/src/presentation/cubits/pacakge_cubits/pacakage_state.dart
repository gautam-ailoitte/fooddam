// lib/src/presentation/cubits/pacakge_cubits/pacakage_state.dart

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
  final String? sortOrder;

  const PackageLoaded({required this.packages, this.sortOrder});

  @override
  List<Object?> get props => [packages, sortOrder];

  bool get isEmpty => packages.isEmpty;
  bool get hasPackages => packages.isNotEmpty;
}

/// State for when a specific package is loaded (detail view)
class PackageDetailLoaded extends PackageState {
  final Package package;

  const PackageDetailLoaded({required this.package});

  @override
  List<Object?> get props => [package];
}

/// Error state for package operations
class PackageError extends PackageState {
  final String message;

  const PackageError({required this.message});

  @override
  List<Object?> get props => [message];
}
