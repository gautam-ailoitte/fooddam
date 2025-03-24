import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/execption.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/network/network_info.dart';
import 'package:foodam/src/data/datasource/local_data_source.dart';
import 'package:foodam/src/data/datasource/remote_data_source.dart';
import 'package:foodam/src/domain/entities/pacakge_entity.dart';
import 'package:foodam/src/domain/repo/package_repo.dart';

class PackageRepositoryImpl implements PackageRepository {
  final RemoteDataSource remoteDataSource;
  final LocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  PackageRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Package>>> getAllPackages() async {
    if (await networkInfo.isConnected) {
      try {
        final packages = await remoteDataSource.getAllPackages();
        await localDataSource.cachePackages(packages);
        return Right(packages.map((package) => package.toEntity()).toList());
      } on ServerException {
        return Left(ServerFailure());
      } catch (e) {
        return Left(UnexpectedFailure());
      }
    } else {
      try {
        final cachedPackages = await localDataSource.getPackages();
        if (cachedPackages != null) {
          return Right(cachedPackages.map((package) => package.toEntity()).toList());
        } else {
          return Left(NetworkFailure());
        }
      } on CacheException {
        return Left(CacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, Package>> getPackageById(String packageId) async {
    if (await networkInfo.isConnected) {
      try {
        final packageModel = await remoteDataSource.getPackageById(packageId);
        await localDataSource.cachePackage(packageModel);
        return Right(packageModel.toEntity());
      } on ServerException {
        return Left(ServerFailure());
      } catch (e) {
        return Left(UnexpectedFailure());
      }
    } else {
      try {
        final cachedPackage = await localDataSource.getPackage(packageId);
        if (cachedPackage != null) {
          return Right(cachedPackage.toEntity());
        } else {
          return Left(NetworkFailure());
        }
      } on CacheException {
        return Left(CacheFailure());
      }
    }
  }
}