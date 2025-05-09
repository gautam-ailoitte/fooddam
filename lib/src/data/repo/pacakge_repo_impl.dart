// lib/src/data/repo/package_repo_impl.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/execption.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/data/datasource/local_data_source.dart';
import 'package:foodam/src/data/datasource/remote_data_source.dart';
import 'package:foodam/src/domain/entities/pacakge_entity.dart';
import 'package:foodam/src/domain/repo/package_repo.dart';

class PackageRepositoryImpl implements PackageRepository {
  final RemoteDataSource remoteDataSource;
  final LocalDataSource localDataSource;
  final LoggerService _logger = LoggerService();

  PackageRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<Package>>> getAllPackages() async {
    // Try fetching from cache first
    try {
      final cachedPackages = await localDataSource.getPackages();
      if (cachedPackages != null && cachedPackages.isNotEmpty) {
        // Use cached data immediately if available
        final cachedEntities =
            cachedPackages.map((package) => package.toEntity()).toList();
        _logger.d('Using ${cachedPackages.length} cached packages');

        // Fetch fresh data in the background
        _fetchAndCachePackages();

        return Right(cachedEntities);
      }
    } on CacheException {
      _logger.d('No valid cached packages found');
    }

    // If no cache, fetch directly
    return _fetchAndReturnPackages();
  }

  // Helper method to fetch and return packages
  Future<Either<Failure, List<Package>>> _fetchAndReturnPackages() async {
    try {
      final packages = await remoteDataSource.getAllPackages();

      // Cache the fresh data
      await localDataSource.cachePackages(packages);

      return Right(packages.map((package) => package.toEntity()).toList());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  // Background update of package cache
  Future<void> _fetchAndCachePackages() async {
    try {
      final packages = await remoteDataSource.getAllPackages();
      await localDataSource.cachePackages(packages);
      _logger.d('Updated package cache with ${packages.length} packages');
    } catch (e) {
      _logger.w('Background cache update failed: $e');
    }
  }

  @override
  Future<Either<Failure, Package>> getPackageById(String packageId) async {
    // Try fetching from cache first
    try {
      final cachedPackage = await localDataSource.getPackage(packageId);
      if (cachedPackage != null) {
        // Use cached data if available
        _logger.d('Using cached package for ID: $packageId');

        // Fetch fresh data in the background
        _fetchAndCachePackageById(packageId);

        return Right(cachedPackage.toEntity());
      }
    } on CacheException {
      _logger.d('No cached package found for ID: $packageId');
    }

    // If no cache, fetch directly
    return _fetchAndReturnPackageById(packageId);
  }

  // Helper method to fetch and return a specific package
  Future<Either<Failure, Package>> _fetchAndReturnPackageById(
    String packageId,
  ) async {
    try {
      final packageModel = await remoteDataSource.getPackageById(packageId);

      // Cache the fresh data
      await localDataSource.cachePackage(packageModel);

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

  // Background update of specific package cache
  Future<void> _fetchAndCachePackageById(String packageId) async {
    try {
      final packageModel = await remoteDataSource.getPackageById(packageId);
      await localDataSource.cachePackage(packageModel);
      _logger.d('Updated cache for package ID: $packageId');
    } catch (e) {
      _logger.w('Background package cache update failed: $e');
    }
  }
}
