import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/pacakge_entity.dart';
import 'package:foodam/src/domain/repo/package_repo.dart';

class GetAllPackagesUseCase implements UseCase<List<Package>> {
  final PackageRepository repository;

  GetAllPackagesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Package>>> call() {
    return repository.getAllPackages();
  }
}