// lib/src/domain/usecase/package/package_use_case.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/src/domain/entities/pacakge_entity.dart';
import 'package:foodam/src/domain/repo/package_repo.dart';

/// Consolidated Package Use Case
///
/// This class combines multiple previously separate use cases related to packages:
/// - GetAllPackagesUseCase
/// - GetPackageByIdUseCase
class PackageUseCase {
  final PackageRepository repository;

  PackageUseCase(this.repository);

  /// Get all available packages
  Future<Either<Failure, List<Package>>> getAllPackages() {
    return repository.getAllPackages();
  }

  /// Get a specific package by ID
  Future<Either<Failure, Package>> getPackageById(String packageId) {
    return repository.getPackageById(packageId);
  }
  
  /// Filter packages by type (vegetarian, non-vegetarian, etc.)
  Future<Either<Failure, List<Package>>> filterPackagesByType(String type) async {
    final result = await getAllPackages();
    
    return result.fold(
      (failure) => Left(failure),
      (packages) {
        if (type.isEmpty) {
          return Right(packages);
        }
        
        final filteredPackages = packages.where((package) => 
          package.name.toLowerCase().contains(type.toLowerCase())
        ).toList();
        
        return Right(filteredPackages);
      },
    );
  }
  
  /// Filter packages by vegetarian status
  Future<Either<Failure, List<Package>>> filterPackagesByVegStatus(bool isVeg) async {
    final result = await getAllPackages();
    
    return result.fold(
      (failure) => Left(failure),
      (packages) {
        final filteredPackages = packages.where((package) => 
          package.name.toLowerCase().contains(
            isVeg ? 'veg' : 'non-veg'
          )
        ).toList();
        
        return Right(filteredPackages);
      },
    );
  }
  
  /// Sort packages by price (ascending or descending)
  Future<Either<Failure, List<Package>>> sortPackagesByPrice(bool ascending) async {
    final result = await getAllPackages();
    
    return result.fold(
      (failure) => Left(failure),
      (packages) {
        final sortedPackages = List<Package>.from(packages);
        
        if (ascending) {
          sortedPackages.sort((a, b) => a.price.compareTo(b.price));
        } else {
          sortedPackages.sort((a, b) => b.price.compareTo(a.price));
        }
        
        return Right(sortedPackages);
      },
    );
  }
}