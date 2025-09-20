// lib/src/domain/repositories/package_repository.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';

import '../entities/package/package_entity.dart' as package;

abstract class PackageRepository {
  Future<Either<Failure, List<package.Package>>> getAllPackages({
    String? dietaryPreference,
  });
  Future<Either<Failure, package.Package>> getPackageById(String packageId);
}
