// lib/src/data/repo/user_repos_impl.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/execption.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/network/network_info.dart';
import 'package:foodam/src/data/datasource/local_data_source.dart';
import 'package:foodam/src/data/datasource/remote_data_source.dart';
import 'package:foodam/src/data/model/address_model.dart';
import 'package:foodam/src/domain/entities/address_entity.dart';
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
  Future<Either<Failure, User>> getUserDetails() async {
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
        } on ServerException {
          return Left(ServerFailure());
        }
      } else {
        return Left(NetworkFailure());
      }
    } on CacheException {
      return Left(CacheFailure());
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateUserDetails(User user) async {
    if (await networkInfo.isConnected) {
      try {
        // Convert user entity to a format for API
        final userData = {
          'firstName': user.firstName,
          'lastName': user.lastName,
          'phone': user.phone,
          'dietaryPreferences': user.dietaryPreferences,
          'allergies': user.allergies,
        };

        final updatedUser = await remoteDataSource.updateUserDetails(userData);
        await localDataSource.cacheUser(updatedUser);
        return const Right(null);
      } on ServerException {
        return Left(ServerFailure());
      } catch (e) {
        return Left(UnexpectedFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<Address>>> getUserAddresses() async {
    try {
      if (await networkInfo.isConnected) {
        try {
          // Get user details which includes addresses
          final userModel = await remoteDataSource.getCurrentUser();
          await localDataSource.cacheUser(userModel);
          
          if (userModel.addresses != null && userModel.addresses!.isNotEmpty) {
            return Right(userModel.addresses!.map((addr) => addr.toEntity()).toList());
          } else {
            return const Right([]);
          }
        } on ServerException {
          return Left(ServerFailure());
        }
      } else {
        final cachedUser = await localDataSource.getUser();
        if (cachedUser != null && cachedUser.addresses != null) {
          return Right(cachedUser.addresses!.map((addr) => addr.toEntity()).toList());
        } else {
          return Left(NetworkFailure());
        }
      }
    } on CacheException {
      return Left(CacheFailure());
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, Address>> addAddress(Address address) async {
    if (await networkInfo.isConnected) {
      try {
        // Convert address to format for API
        final addressData = AddressModel.fromEntity(address).toJson();
        
        // Update user with the new address
        final userData = {'address': [addressData]};
        final updatedUser = await remoteDataSource.updateUserDetails(userData);
        await localDataSource.cacheUser(updatedUser);
        
        // Return the added address (last in the list)
        if (updatedUser.addresses != null && updatedUser.addresses!.isNotEmpty) {
          return Right(updatedUser.addresses!.last.toEntity());
        } else {
          return Left(UnexpectedFailure());
        }
      } on ServerException {
        return Left(ServerFailure());
      } catch (e) {
        return Left(UnexpectedFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateAddress(Address address) async {
    if (await networkInfo.isConnected) {
      try {
        // Get current user addresses
        final userResult = await getUserDetails();
        
        return userResult.fold(
          (failure) => Left(failure),
          (user) async {
            if (user.addresses == null) {
              return Left(UnexpectedFailure());
            }
            
            // Update the specific address in the list
            final updatedAddresses = user.addresses!.map((addr) {
              if (addr.id == address.id) {
                return address;
              }
              return addr;
            }).toList();
            
            // Convert addresses to format for API
            final addressesData = updatedAddresses.map(
              (addr) => AddressModel.fromEntity(addr).toJson()
            ).toList();
            
            // Update user with all addresses
            final userData = {'address': addressesData};
            final updatedUser = await remoteDataSource.updateUserDetails(userData);
            await localDataSource.cacheUser(updatedUser);
            
            return const Right(null);
          }
        );
      } on ServerException {
        return Left(ServerFailure());
      } catch (e) {
        return Left(UnexpectedFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteAddress(String addressId) async {
    if (await networkInfo.isConnected) {
      try {
        // Get current user addresses
        final userResult = await getUserDetails();
        
        return userResult.fold(
          (failure) => Left(failure),
          (user) async {
            if (user.addresses == null) {
              return const Right(null); // No addresses to delete
            }
            
            // Filter out the address to delete
            final updatedAddresses = user.addresses!
                .where((addr) => addr.id != addressId)
                .toList();
            
            // Convert addresses to format for API
            final addressesData = updatedAddresses.map(
              (addr) => AddressModel.fromEntity(addr).toJson()
            ).toList();
            
            // Update user with filtered addresses
            final userData = {'address': addressesData};
            final updatedUser = await remoteDataSource.updateUserDetails(userData);
            await localDataSource.cacheUser(updatedUser);
            
            return const Right(null);
          }
        );
      } on ServerException {
        return Left(ServerFailure());
      } catch (e) {
        return Left(UnexpectedFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }
}
