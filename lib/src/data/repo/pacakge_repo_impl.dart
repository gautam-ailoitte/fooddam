// lib/src/data/repo/pacakge_repo_impl.dart
// ignore_for_file: unused_element

import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/execption.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/network/network_info.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/data/datasource/local_data_source.dart';
import 'package:foodam/src/data/datasource/remote_data_source.dart';
import 'package:foodam/src/data/model/meal_slot_model.dart';
import 'package:foodam/src/domain/entities/pacakge_entity.dart';
import 'package:foodam/src/domain/repo/package_repo.dart';

class PackageRepositoryImpl implements PackageRepository {
  final RemoteDataSource remoteDataSource;
  final LocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  final LoggerService _logger = LoggerService();

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

        // Process packages to ensure they have valid slots
        final processedPackages =
            packages.map((package) {
              // If the package doesn't have slots, add dummy slots for UI preview
              if (package.slots.isEmpty) {
                return package;
              }
              return package;
            }).toList();

        await localDataSource.cachePackages(processedPackages);
        return Right(
          processedPackages.map((package) => package.toEntity()).toList(),
        );
      } on ServerException {
        return Left(ServerFailure());
      } catch (e) {
        _logger.e('Unexpected error in getAllPackages', error: e);
        return Left(UnexpectedFailure());
      }
    } else {
      try {
        final cachedPackages = await localDataSource.getPackages();
        if (cachedPackages != null) {
          return Right(
            cachedPackages.map((package) => package.toEntity()).toList(),
          );
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

        // Process package to ensure it has valid slots
        final processedPackage =
            packageModel.slots.isEmpty ? packageModel : packageModel;

        await localDataSource.cachePackage(processedPackage);
        return Right(processedPackage.toEntity());
      } on ResourceNotFoundException {
        return Left(ResourceNotFoundFailure('Package not found'));
      } on ServerException {
        return Left(ServerFailure());
      } catch (e) {
        _logger.e('Unexpected error in getPackageById', error: e);
        return Left(UnexpectedFailure());
      }
    } else {
      try {
        final cachedPackage = await localDataSource.getPackage(packageId);
        if (cachedPackage != null) {
          return Right(cachedPackage.toEntity());
        } else {
          return Left(
            NetworkFailure(
              'No internet connection and no cached data available',
            ),
          );
        }
      } on CacheException {
        return Left(CacheFailure());
      }
    }
  }

  // Helper method to create default meal slots
  List<MealSlotModel> _createDefaultSlots() {
    final List<MealSlotModel> slots = [];
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
        slots.add(MealSlotModel(day: day, timing: timing));
      }
    }

    return slots;
  }
}
