// lib/src/domain/usecases/package/get_package_by_id_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/pacakge_entity.dart';
import 'package:foodam/src/domain/repo/package_repo.dart';
class GetPackageByIdUseCase implements UseCaseWithParams<Package, String> {
  final PackageRepository repository;

  GetPackageByIdUseCase(this.repository);

  @override
  Future<Either<Failure, Package>> call(String packageId) {
    return repository.getPackageById(packageId);
  }
}