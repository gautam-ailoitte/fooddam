// lib/src/domain/usecase/package_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/src/domain/repo/package_repo.dart';

import '../entities/package/package_entity.dart';

/// Consolidated Package Use Case
///
/// This class combines multiple previously separate use cases related to packages:
/// - GetAllPackagesUseCase
/// - GetPackageByIdUseCase
// lib/src/domain/usecase/package_usecase.dart (UPDATE)
class PackageUseCase {
  final PackageRepository repository;

  PackageUseCase(this.repository);

  /// Get all available packages with optional dietary preference filter
  Future<Either<Failure, List<Package>>> getAllPackages({
    String? dietaryPreference,
  }) {
    return repository.getAllPackages(dietaryPreference: dietaryPreference);
  }

  /// Get a specific package by ID
  Future<Either<Failure, Package>> getPackageById(String packageId) {
    return repository.getPackageById(packageId);
  }

  /// Filter packages by vegetarian status
  Future<Either<Failure, List<Package>>> getVegetarianPackages() {
    return repository.getAllPackages(dietaryPreference: 'vegetarian');
  }

  /// Filter packages by non-vegetarian status
  Future<Either<Failure, List<Package>>> getNonVegetarianPackages() {
    return repository.getAllPackages(dietaryPreference: 'non-vegetarian');
  }

  /// Filter packages by week number
  Future<Either<Failure, List<Package>>> filterPackagesByWeek(int week) async {
    final result = await repository.getAllPackages();

    return result.fold((failure) => Left(failure), (packages) {
      final filtered = packages.where((pkg) => pkg.week == week).toList();
      return Right(filtered);
    });
  }

  /// Sort packages by price range
  Future<Either<Failure, List<Package>>> sortPackagesByPriceRange(
    bool ascending,
  ) async {
    final result = await repository.getAllPackages();

    return result.fold((failure) => Left(failure), (packages) {
      final sortedPackages = List<Package>.from(packages);

      return Right(sortedPackages);
    });
  }
}
