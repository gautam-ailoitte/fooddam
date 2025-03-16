import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/execption.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/network/network_info.dart';
import 'package:foodam/src/data/datasource/local_data_source.dart';
import 'package:foodam/src/data/datasource/remote_data_source.dart';
import 'package:foodam/src/domain/entities/user_entity.dart';
import 'package:foodam/src/domain/repo/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final RemoteDataSource remoteDataSource;
  final LocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    if (await networkInfo.isConnected) {
      try {
        final userModel = await remoteDataSource.login(email, password);
        await localDataSource.cacheUser(userModel);
        return Right(userModel);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    try {
      final hasToken = await localDataSource.hasToken();
      return Right(hasToken);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final userModel = await localDataSource.getLastUser();
      return Right(userModel);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.clearUser();
      return const Right(null);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> hasActiveSubscription() async {
    if (await networkInfo.isConnected) {
      try {
        final hasSubscription =
            await remoteDataSource.checkSubscriptionStatus();
        return Right(hasSubscription);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      try {
        final user = await localDataSource.getLastUser();
        return Right(user.hasActivePlan);
      } on CacheException {
        return Left(CacheFailure());
      }
    }
  }
}
