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
    // Implementation would depend on the actual API design
    return Left(UnexpectedFailure()); // Placeholder
  }

  @override
  Future<Either<Failure, List<Address>>> getUserAddresses() async {
    try {
      if (await networkInfo.isConnected) {
        try {
          final addresses = await remoteDataSource.getUserAddresses();
          await localDataSource.cacheAddresses(addresses);
          return Right(addresses.map((address) => address.toEntity()).toList());
        } on ServerException {
          return Left(ServerFailure());
        }
      } else {
        final cachedAddresses = await localDataSource.getAddresses();
        if (cachedAddresses != null) {
          return Right(cachedAddresses.map((address) => address.toEntity()).toList());
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
        final addressModel = AddressModel.fromEntity(address);
        final newAddress = await remoteDataSource.addAddress(addressModel);
        
        // Update local cache
        final cachedAddresses = await localDataSource.getAddresses();
        final updatedAddresses = [...?cachedAddresses, newAddress];
        await localDataSource.cacheAddresses(updatedAddresses);
        
        return Right(newAddress.toEntity());
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
        final addressModel = AddressModel.fromEntity(address);
        await remoteDataSource.updateAddress(addressModel);
        
        // Update local cache
        final cachedAddresses = await localDataSource.getAddresses();
        if (cachedAddresses != null) {
          final updatedAddresses = cachedAddresses.map((cachedAddress) => 
            cachedAddress.id == address.id ? addressModel : cachedAddress
          ).toList();
          await localDataSource.cacheAddresses(updatedAddresses);
        }
        
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
  Future<Either<Failure, void>> deleteAddress(String addressId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteAddress(addressId);
        
        // Update local cache
        final cachedAddresses = await localDataSource.getAddresses();
        if (cachedAddresses != null) {
          final updatedAddresses = cachedAddresses
              .where((address) => address.id != addressId)
              .toList();
          await localDataSource.cacheAddresses(updatedAddresses);
        }
        
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
}
