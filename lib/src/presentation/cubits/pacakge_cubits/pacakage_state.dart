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

class PackageLoaded extends PackageState {
  final List<Package> packages;
  final List<Package> allPackages;
  final String? currentFilter;
  
  const PackageLoaded({
    required this.packages, 
    this.allPackages = const [],
    this.currentFilter,
  });
  
  @override
  List<Object?> get props => [packages, allPackages, currentFilter];
}

class PackageDetailLoaded extends PackageState {
  final Package package;
  
  const PackageDetailLoaded({required this.package});
  
  @override
  List<Object?> get props => [package];
}

class PackageError extends PackageState {
  final String message;
  
  const PackageError(this.message);
  
  @override
  List<Object?> get props => [message];
}