// lib/src/data/repo/auth_repo_impl.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/execption.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/data/datasource/local_data_source.dart';
import 'package:foodam/src/data/datasource/remote_data_source.dart';
import 'package:foodam/src/data/model/user_model.dart';
import 'package:foodam/src/domain/entities/user_entity.dart';
import 'package:foodam/src/domain/repo/auth_repo.dart';

class AuthRepositoryImpl implements AuthRepository {
  final RemoteDataSource remoteDataSource;
  final LocalDataSource localDataSource;
  final LoggerService _logger = LoggerService();

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, String>> login(String email, String password) async {
    try {
      final response = await remoteDataSource.login(email, password);

      final token = response['token'] as String;
      //log token for debugging
      _logger.d('Received token after OTP verification: $token');
      await localDataSource.cacheToken(token);

      await localDataSource.cacheToken(token);

      // Cache refresh token if available
      if (response['refreshToken'] != null) {
        await localDataSource.cacheRefreshToken(response['refreshToken']);
      }

      // Cache user data if available
      if (response['user'] != null) {
        final userModel = UserModel.fromJson(response['user']);
        await localDataSource.cacheUser(userModel);
      }

      return Right(token);
    } on InvalidCredentialsException catch (e) {
      return Left(InvalidCredentialsFailure(e.message));
    } on EmailNotVerifiedException {
      return Left(EmailNotVerifiedFailure());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> register(
    String email,
    String password,
    String phone,
  ) async {
    try {
      await remoteDataSource.register(email, password, phone);

      // For email registration, we don't log the user in automatically
      // They need to verify their email first
      return const Right(
        'Registration successful! Please verify your email before logging in.',
      );
    } on UserAlreadyExistsException {
      return Left(UserAlreadyExistsFailure());
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> registerWithMobile(String mobile) async {
    try {
      final response = await remoteDataSource.registerWithMobile(mobile);

      // Return response message or default message
      return Right(
        response['message'] ?? 'OTP sent to your mobile for verification',
      );
    } on UserAlreadyExistsException {
      return Left(
        UserAlreadyExistsFailure('User already exists with this mobile number'),
      );
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> requestLoginOTP(String mobile) async {
    try {
      final response = await remoteDataSource.requestLoginOTP(mobile);
      return Right(response['message'] ?? 'OTP sent to your mobile number');
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> verifyLoginOTP(
    String mobile,
    String otp,
  ) async {
    try {
      final response = await remoteDataSource.verifyLoginOTP(mobile, otp);

      final token = response['token'] as String;
      //log token for debugging
      _logger.d('Received token after OTP verification: $token');
      await localDataSource.cacheToken(token);

      // Cache refresh token if available
      if (response['refreshToken'] != null) {
        await localDataSource.cacheRefreshToken(response['refreshToken']);
      }

      // Cache user data if available
      if (response['user'] != null) {
        final userModel = UserModel.fromJson(response['user']);
        await localDataSource.cacheUser(userModel);
      }

      return Right(token);
    } on InvalidOTPException {
      return Left(InvalidOTPFailure());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> verifyMobileOTP(
    String mobile,
    String otp,
  ) async {
    try {
      final response = await remoteDataSource.verifyMobileOTP(mobile, otp);

      final token = response['token'] as String;
      //log token for debugging
      _logger.d('Received token after OTP verification: $token');
      await localDataSource.cacheToken(token);

      // Cache refresh token if available
      if (response['refreshToken'] != null) {
        await localDataSource.cacheRefreshToken(response['refreshToken']);
      }

      // Cache user data if available
      if (response['user'] != null) {
        final userModel = UserModel.fromJson(response['user']);
        await localDataSource.cacheUser(userModel);
      }

      return Right(token);
    } on InvalidOTPException {
      return Left(InvalidOTPFailure());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      try {
        await remoteDataSource.logout();
      } catch (e) {
        // Continue with local logout even if server logout fails
        _logger.w('Server logout failed, continuing with local logout');
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
        _logger.d('Using cached user data');

        // Refresh user data in background
        _fetchAndCacheCurrentUser();

        return Right(cachedUser.toEntity());
      }

      // If not in cache, fetch from remote
      return _fetchAndReturnCurrentUser();
    } on CacheException {
      return _fetchAndReturnCurrentUser();
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  // Helper method to fetch and return current user
  Future<Either<Failure, User>> _fetchAndReturnCurrentUser() async {
    try {
      final userModel = await remoteDataSource.getCurrentUser();
      await localDataSource.cacheUser(userModel);
      return Right(userModel.toEntity());
    } on UnauthenticatedException {
      // Clear tokens as they might be invalid
      await localDataSource.clearToken();
      await localDataSource.clearRefreshToken();
      return Left(AuthFailure('You need to log in again'));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  // Background update of user data
  Future<void> _fetchAndCacheCurrentUser() async {
    try {
      final userModel = await remoteDataSource.getCurrentUser();
      await localDataSource.cacheUser(userModel);
      _logger.d('Updated user cache');
    } catch (e) {
      _logger.w('Background user cache update failed: $e');
    }
  }

  @override
  Future<Either<Failure, String>> refreshToken(String refreshToken) async {
    try {
      final response = await remoteDataSource.refreshToken(refreshToken);
      final newToken = response['token'] as String;

      // Cache the new token
      await localDataSource.cacheToken(newToken);

      // Cache new refresh token if provided
      if (response['refreshToken'] != null) {
        await localDataSource.cacheRefreshToken(response['refreshToken']);
      }

      return Right(newToken);
    } on InvalidTokenException {
      // Clear tokens as they are invalid
      await localDataSource.clearToken();
      await localDataSource.clearRefreshToken();
      return Left(InvalidTokenFailure());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> validateToken(String token) async {
    try {
      final response = await remoteDataSource.validateToken(token);
      return Right(response['valid'] as bool? ?? false);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> resendOTP(
    String mobile,
    bool isRegistration,
  ) async {
    try {
      final response = await remoteDataSource.resendOTP(mobile, isRegistration);
      return Right(response['message'] ?? 'OTP resent successfully');
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> forgotPassword(String email) async {
    try {
      final response = await remoteDataSource.forgotPassword(email);
      return Right('OTP sent to your email');
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword(
    String email,
    String otp,
    String newPassword,
  ) async {
    try {
      await remoteDataSource.resetPassword(email, otp, newPassword);
      return const Right(null);
    } on InvalidTokenException {
      return Left(InvalidTokenFailure());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
