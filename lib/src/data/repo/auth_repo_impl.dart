// lib/src/data/repo/auth_repo_impl.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/execption.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/network/network_info.dart';
import 'package:foodam/src/data/datasource/local_data_source.dart';
import 'package:foodam/src/data/datasource/remote_data_source.dart';
import 'package:foodam/src/data/model/user_model.dart';
import 'package:foodam/src/domain/entities/user_entity.dart';
import 'package:foodam/src/domain/repo/auth_repo.dart';

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
  Future<Either<Failure, String>> login(String email, String password) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.login(email, password);
        final token = response['data']['token'] as String;
        await localDataSource.cacheToken(token);

        // Cache refresh token if available
        if (response['data']['refreshToken'] != null) {
          await localDataSource.cacheRefreshToken(
            response['data']['refreshToken'],
          );
        }

        // Cache user data
        if (response['data']['user'] != null) {
          final userModel = UserModel.fromJson(response['data']['user']);
          await localDataSource.cacheUser(userModel);
        }

        return Right(token);
      } on InvalidCredentialsException {
        return Left(InvalidCredentialsFailure());
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, String>> register(
    String email,
    String password,
    String phone,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.register(
          email,
          password,
          phone,
        );
        final token = response['token'] as String;
        await localDataSource.cacheToken(token);

        // Cache refresh token if available
        if (response['refreshToken'] != null) {
          await localDataSource.cacheRefreshToken(response['refreshToken']);
        }

        // Cache user data
        if (response['user'] != null) {
          final userModel = UserModel.fromJson(response['user']);
          await localDataSource.cacheUser(userModel);
        }

        return Right(token);
      } on UserAlreadyExistsException {
        return Left(UserAlreadyExistsFailure());
      } on ValidationException {
        return Left(ValidationFailure());
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.logout();
        } catch (e) {
          // Continue with local logout even if server logout fails
        }
      }

      // Clear tokens and cached user data from local storage
      await localDataSource.clearToken();
      await localDataSource.clearRefreshToken();
      return const Right(null);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    try {
      final token = await localDataSource.getToken();
      return Right(token != null && token.isNotEmpty);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      // Try to get from local cache first
      final cachedUser = await localDataSource.getUser();

      if (cachedUser != null) {
        return Right(cachedUser.toEntity());
      }

      // If not in cache and network available, fetch from remote
      if (await networkInfo.isConnected) {
        try {
          final userModel = await remoteDataSource.getCurrentUser();
          await localDataSource.cacheUser(userModel);
          return Right(userModel.toEntity());
        } on UnauthenticatedException {
          // Clear tokens as they might be invalid
          await localDataSource.clearToken();
          await localDataSource.clearRefreshToken();
          return Left(AuthFailure('You need to log in again'));
        } on ServerException {
          return Left(ServerFailure());
        }
      } else {
        return Left(NetworkFailure());
      }
    } on CacheException {
      return Left(CacheFailure());
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> refreshToken(String refreshToken) {
    // TODO: implement refreshToken
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, bool>> validateToken(String token) {
    // TODO: implement validateToken
    throw UnimplementedError();
  }

  @override
Future<Either<Failure, void>> forgotPassword(String email) async {
  if (await networkInfo.isConnected) {
    try {
      await remoteDataSource.forgotPassword(email);
      return const Right(null);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  } else {
    return Left(NetworkFailure());
  }
}
}
