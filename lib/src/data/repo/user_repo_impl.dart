// lib/src/data/repositories/user_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/execption.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/network/network_info.dart';
import 'package:foodam/src/data/datasource/local_data_source.dart';
import 'package:foodam/src/data/datasource/remote_data_source.dart';
import 'package:foodam/src/domain/entities/address_entity.dart';
import 'package:foodam/src/domain/entities/dish_entity.dart';
import 'package:foodam/src/domain/entities/user_entity.dart';
import 'package:foodam/src/domain/repo/user_repo.dart';

class UserRepositoryImpl implements UserRepository {
  final RemoteDataSource remoteDataSource;
  final LocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  UserRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, User>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
    required Address address,
    List<DietaryPreference>? dietaryPreferences,
    List<String>? allergies,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final user = await remoteDataSource.registerUser(
          firstName: firstName,
          lastName: lastName,
          email: email,
          password: password,
          phone: phone,
          address: address,
          dietaryPreferences: dietaryPreferences,
          allergies: allergies,
        );
        
        // Cache the user
        await localDataSource.cacheUser(user);
        
        return Right(user);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    if (await networkInfo.isConnected) {
      try {
        final user = await remoteDataSource.loginUser(email, password);
        
        // Cache the user
        await localDataSource.cacheUser(user);
        
        return Right(user);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final user = await localDataSource.getLastLoggedInUser();
      return Right(user);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    try {
      final isLoggedIn = await localDataSource.isUserLoggedIn();
      return Right(isLoggedIn);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, User>> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    Address? address,
    List<DietaryPreference>? dietaryPreferences,
    List<String>? allergies,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final user = await remoteDataSource.updateUserProfile(
          firstName: firstName,
          lastName: lastName,
          phone: phone,
          address: address,
          dietaryPreferences: dietaryPreferences,
          allergies: allergies,
        );
        
        // Update cached user
        await localDataSource.cacheUser(user);
        
        return Right(user);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> updatePassword(String currentPassword, String newPassword) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.updatePassword(currentPassword, newPassword);
        return Right(result);
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
      await localDataSource.clearUserCache();
      return const Right(null);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, Address>> addAddress(Address address) async {
    if (await networkInfo.isConnected) {
      try {
        final newAddress = await remoteDataSource.addUserAddress(address);
        
        // Update cached addresses
        final cachedAddresses = await localDataSource.getCachedAddresses();
        cachedAddresses.add(newAddress);
        await localDataSource.cacheAddresses(cachedAddresses);
        
        return Right(newAddress);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, Address>> updateAddress(String addressId, Address address) async {
    // This would typically have a remote endpoint to update an address
    // For our mock app, we'll treat it as successful
    return Right(address);
  }

  @override
  Future<Either<Failure, bool>> deleteAddress(String addressId) async {
    // This would typically have a remote endpoint to delete an address
    // For our mock app, we'll treat it as successful
    return const Right(true);
  }

  @override
  Future<Either<Failure, List<Address>>> getUserAddresses() async {
    if (await networkInfo.isConnected) {
      try {
        final addresses = await remoteDataSource.getUserAddresses();
        
        // Cache addresses
        await localDataSource.cacheAddresses(addresses);
        
        return Right(addresses);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      // Try to get cached addresses
      try {
        final cachedAddresses = await localDataSource.getCachedAddresses();
        return Right(cachedAddresses);
      } on CacheException {
        return Left(CacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, bool>> requestPasswordReset(String email) async {
    // This would typically have a remote endpoint to request password reset
    // For our mock app, we'll treat it as successful
    return const Right(true);
  }

  @override
  Future<Either<Failure, bool>> verifyEmail(String token) async {
    // This would typically have a remote endpoint to verify email
    // For our mock app, we'll treat it as successful
    return const Right(true);
  }
}