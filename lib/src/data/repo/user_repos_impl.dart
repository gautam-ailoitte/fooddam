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
        // Create update data object with only the fields we want to update
        final Map<String, dynamic> updateData = {};

        // Add basic user fields if they exist
        if (user.firstName != null) updateData['firstName'] = user.firstName;
        if (user.lastName != null) updateData['lastName'] = user.lastName;
        if (user.phone != null) updateData['phone'] = user.phone;

        // Add dietary preferences if they exist
        if (user.dietaryPreferences != null) {
          updateData['dietaryPreferences'] = user.dietaryPreferences;
        }

        // Add allergies if they exist
        if (user.allergies != null) {
          updateData['allergies'] = user.allergies;
        }

        // Add addresses if they exist - using the correct format
        if (user.addresses != null && user.addresses!.isNotEmpty) {
          // Convert addresses to the expected format
          final addressList =
              user.addresses!.map((addr) {
                final addressMap = {
                  'street': addr.street,
                  'city': addr.city,
                  'state': addr.state,
                  'zipCode': addr.zipCode,
                  'coordinates': {
                    'latitude': addr.latitude ?? 0,
                    'longitude': addr.longitude ?? 0,
                  },
                  // IMPORTANT: Always include country field
                  'country':
                      addr.country ?? 'India', // Default to India if null
                };

                // Add id if present
                if (addr.id.isNotEmpty) addressMap['id'] = addr.id;

                return addressMap;
              }).toList();

          updateData['address'] = addressList;
        }

        // Log the update data for debugging
        // print('Updating user with data: $updateData');

        // Send the update request
        final updatedUser = await remoteDataSource.updateUserDetails(
          updateData,
        );

        // Cache the updated user
        await localDataSource.cacheUser(updatedUser);

        return const Right(null);
      } on ServerException catch (e) {
        // print('Server exception: ${e.message}');
        return Left(ServerFailure(e.message));
      } catch (e) {
        // print('Unexpected failure: $e');
        return Left(UnexpectedFailure(e.toString()));
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
            return Right(
              userModel.addresses!.map((addr) => addr.toEntity()).toList(),
            );
          } else {
            return const Right([]);
          }
        } on ServerException {
          return Left(ServerFailure());
        }
      } else {
        final cachedUser = await localDataSource.getUser();
        if (cachedUser != null && cachedUser.addresses != null) {
          return Right(
            cachedUser.addresses!.map((addr) => addr.toEntity()).toList(),
          );
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
        // Get current addresses
        final userResult = await getUserDetails();

        return userResult.fold((failure) => Left(failure), (user) async {
          // Create list of existing addresses plus the new one
          final List<Address> updatedAddresses = [
            ...(user.addresses ?? []),
            address,
          ];

          // Update user with the new address list
          final updatedUser = User(
            id: user.id,
            email: user.email,
            firstName: user.firstName,
            lastName: user.lastName,
            phone: user.phone,
            role: user.role,
            addresses: updatedAddresses,
            dietaryPreferences: user.dietaryPreferences,
            allergies: user.allergies,
            isEmailVerified: user.isEmailVerified,
            isPhoneVerified: user.isPhoneVerified,
          );

          // Call update user details
          final updateResult = await updateUserDetails(updatedUser);

          return updateResult.fold(
            (failure) => Left(failure),
            (_) => Right(address),
          );
        });
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
        // Get current user details
        final userResult = await getUserDetails();

        return userResult.fold((failure) => Left(failure), (user) async {
          if (user.addresses == null) {
            return Left(UnexpectedFailure());
          }

          // Update the specific address in the list
          final updatedAddresses =
              user.addresses!.map((addr) {
                if (addr.id == address.id) {
                  return address;
                }
                return addr;
              }).toList();

          // Update user with the updated address list
          final updatedUser = User(
            id: user.id,
            email: user.email,
            firstName: user.firstName,
            lastName: user.lastName,
            phone: user.phone,
            role: user.role,
            addresses: updatedAddresses,
            dietaryPreferences: user.dietaryPreferences,
            allergies: user.allergies,
            isEmailVerified: user.isEmailVerified,
            isPhoneVerified: user.isPhoneVerified,
          );

          // Call update user details
          final updateResult = await updateUserDetails(updatedUser);

          return updateResult.fold(
            (failure) => Left(failure),
            (_) => const Right(null),
          );
        });
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

        return userResult.fold((failure) => Left(failure), (user) async {
          if (user.addresses == null) {
            return const Right(null); // No addresses to delete
          }

          // Filter out the address to delete
          final updatedAddresses =
              user.addresses!.where((addr) => addr.id != addressId).toList();

          // Update user with the filtered addresses
          final updatedUser = User(
            id: user.id,
            email: user.email,
            firstName: user.firstName,
            lastName: user.lastName,
            phone: user.phone,
            role: user.role,
            addresses: updatedAddresses,
            dietaryPreferences: user.dietaryPreferences,
            allergies: user.allergies,
            isEmailVerified: user.isEmailVerified,
            isPhoneVerified: user.isPhoneVerified,
          );

          // Call update user details
          final updateResult = await updateUserDetails(updatedUser);

          return updateResult.fold(
            (failure) => Left(failure),
            (_) => const Right(null),
          );
        });
      } catch (e) {
        return Left(UnexpectedFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }
}
