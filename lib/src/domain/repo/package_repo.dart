// lib/src/domain/repositories/package_repository.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/src/domain/entities/pacakge_entity.dart';

abstract class PackageRepository {
  Future<Either<Failure, List<Package>>> getAllPackages({
    String? dietaryPreference,
  });
  Future<Either<Failure, Package>> getPackageById(String packageId);
}
