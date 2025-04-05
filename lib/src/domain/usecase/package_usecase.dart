// lib/src/domain/usecase/package_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/src/domain/entities/meal_slot_entity.dart';
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
  Future<Either<Failure, List<Package>>> filterPackagesByType(
    String type,
  ) async {
    final result = await getAllPackages();

    return result.fold((failure) => Left(failure), (packages) {
      if (type.isEmpty) {
        return Right(packages);
      }

      final filteredPackages =
          packages
              .where(
                (package) =>
                    package.name.toLowerCase().contains(type.toLowerCase()),
              )
              .toList();

      return Right(filteredPackages);
    });
  }

  /// Filter packages by vegetarian status
  Future<Either<Failure, List<Package>>> filterPackagesByVegStatus(
    bool isVeg,
  ) async {
    final result = await getAllPackages();

    return result.fold((failure) => Left(failure), (packages) {
      final filteredPackages =
          packages
              .where(
                (package) => package.name.toLowerCase().contains(
                  isVeg ? 'veg' : 'non-veg',
                ),
              )
              .toList();

      return Right(filteredPackages);
    });
  }

  /// Sort packages by price (ascending or descending)
  Future<Either<Failure, List<Package>>> sortPackagesByPrice(
    bool ascending,
  ) async {
    final result = await getAllPackages();

    return result.fold((failure) => Left(failure), (packages) {
      final sortedPackages = List<Package>.from(packages);

      if (ascending) {
        sortedPackages.sort((a, b) => a.price.compareTo(b.price));
      } else {
        sortedPackages.sort((a, b) => b.price.compareTo(a.price));
      }

      return Right(sortedPackages);
    });
  }

  /// Helper method to generate default slots for a package
  List<MealSlot> generateDefaultSlots() {
    final List<MealSlot> slots = [];
    final days = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];
    final timings = ['breakfast', 'lunch', 'dinner'];

    for (var day in days) {
      for (var timing in timings) {
        slots.add(MealSlot(day: day, timing: timing));
      }
    }

    return slots;
  }

  /// Get total meal count for a package
  int getMealCountForPackage(Package package) {
    // If package has slots, count them
    if (package.slots.isNotEmpty) {
      return package.slots.length;
    }

    // Default: 21 meals (7 days x 3 meals)
    return 21;
  }

  /// Get meal count breakdown for a package
  Map<String, int> getMealCountBreakdown(Package package) {
    final Map<String, int> breakdown = {
      'breakfast': 0,
      'lunch': 0,
      'dinner': 0,
    };

    // If package has slots, count by meal type
    if (package.slots.isNotEmpty) {
      for (var slot in package.slots) {
        final timing = slot.timing.toLowerCase();
        if (breakdown.containsKey(timing)) {
          breakdown[timing] = breakdown[timing]! + 1;
        }
      }
      return breakdown;
    }

    // Default: 7 of each meal type
    return {'breakfast': 7, 'lunch': 7, 'dinner': 7};
  }
}
