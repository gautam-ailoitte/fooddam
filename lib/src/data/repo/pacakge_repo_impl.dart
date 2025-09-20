// lib/src/data/repo/package_repo_impl.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/execption.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/src/data/datasource/remote_data_source.dart';
import 'package:foodam/src/domain/repo/package_repo.dart';

import '../../domain/entities/package/package_entity.dart' as package;

// lib/src/data/repo/pacakge_repo_impl.dart (UPDATE)
class PackageRepositoryImpl implements PackageRepository {
  final RemoteDataSource remoteDataSource;

  PackageRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<package.Package>>> getAllPackages({
    String? dietaryPreference,
  }) async {
    try {
      final packages = await remoteDataSource.getAllPackages(
        dietaryPreference: dietaryPreference,
      );
      return Right(packages.map((package) => package.toEntity()).toList());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, package.Package>> getPackageById(
    String packageId,
  ) async {
    try {
      final packageModel = await remoteDataSource.getPackageById(packageId);
      return Right(packageModel.toEntity());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ResourceNotFoundException catch (e) {
      return Left(ResourceNotFoundFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
