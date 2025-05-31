// lib/src/data/repo/user_repos_impl.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/execption.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/data/datasource/remote_data_source.dart';
import 'package:foodam/src/domain/entities/address_entity.dart';
import 'package:foodam/src/domain/entities/user_entity.dart';
import 'package:foodam/src/domain/repo/user_repo.dart';

class UserRepositoryImpl implements UserRepository {
  final RemoteDataSource remoteDataSource;
  final LoggerService _logger = LoggerService();

  UserRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, User>> getUserDetails() async {
    try {
      _logger.d('Fetching fresh user data from API', tag: 'UserRepository');

      final userModel = await remoteDataSource.getCurrentUser();
      return Right(userModel.toEntity());
    } on NetworkException catch (e) {
      _logger.e('Network error getting user details', error: e, tag: 'UserRepository');
      return Left(NetworkFailure(e.message));
    } on UnauthenticatedException catch (e) {
      _logger.e('Authentication error getting user details', error: e, tag: 'UserRepository');
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      _logger.e('Server error getting user details', error: e, tag: 'UserRepository');
      return Left(ServerFailure(e.message));
    } catch (e) {
      _logger.e('Unexpected error getting user details', error: e, tag: 'UserRepository');
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserDetails(User user) async {
    try {
      _logger.d('Updating user details via API', tag: 'UserRepository');

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
        final addressList = user.addresses!.map((addr) {
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
            'country': addr.country ?? 'India', // Default to India if null
          };

          // Add id if present
          if (addr.id.isNotEmpty) addressMap['id'] = addr.id;

          return addressMap;
        }).toList();

        updateData['address'] = addressList;
      }

      _logger.d('Sending update data: $updateData', tag: 'UserRepository');

      // Send the update request
      await remoteDataSource.updateUserDetails(updateData);

      _logger.i('User details updated successfully', tag: 'UserRepository');
      return const Right(null);
    } on NetworkException catch (e) {
      _logger.e('Network error updating user details', error: e, tag: 'UserRepository');
      return Left(NetworkFailure(e.message));
    } on UnauthenticatedException catch (e) {
      _logger.e('Authentication error updating user details', error: e, tag: 'UserRepository');
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      _logger.e('Server error updating user details', error: e, tag: 'UserRepository');
      return Left(ServerFailure(e.message));
    } catch (e) {
      _logger.e('Unexpected error updating user details', error: e, tag: 'UserRepository');
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Address>>> getUserAddresses() async {
    try {
      _logger.d('Fetching fresh user addresses from API', tag: 'UserRepository');

      final userModel = await remoteDataSource.getCurrentUser();

      if (userModel.addresses != null && userModel.addresses!.isNotEmpty) {
        final addresses = userModel.addresses!.map((addr) => addr.toEntity()).toList();
        _logger.d('Found ${addresses.length} addresses', tag: 'UserRepository');
        return Right(addresses);
      } else {
        _logger.d('No addresses found for user', tag: 'UserRepository');
        return const Right([]);
      }
    } on NetworkException catch (e) {
      _logger.e('Network error getting user addresses', error: e, tag: 'UserRepository');
      return Left(NetworkFailure(e.message));
    } on UnauthenticatedException catch (e) {
      _logger.e('Authentication error getting user addresses', error: e, tag: 'UserRepository');
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      _logger.e('Server error getting user addresses', error: e, tag: 'UserRepository');
      return Left(ServerFailure(e.message));
    } catch (e) {
      _logger.e('Unexpected error getting user addresses', error: e, tag: 'UserRepository');
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Address>> addAddress(Address address) async {
    try {
      _logger.d('Adding new address via API', tag: 'UserRepository');

      // Get current user details first
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
              (_) {
            _logger.i('Address added successfully', tag: 'UserRepository');
            return Right(address);
          },
        );
      });
    } catch (e) {
      _logger.e('Unexpected error adding address', error: e, tag: 'UserRepository');
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateAddress(Address address) async {
    try {
      _logger.d('Updating address via API', tag: 'UserRepository');

      // Get current user details
      final userResult = await getUserDetails();

      return userResult.fold((failure) => Left(failure), (user) async {
        if (user.addresses == null) {
          return Left(UnexpectedFailure('User has no addresses to update'));
        }

        // Update the specific address in the list
        final updatedAddresses = user.addresses!.map((addr) {
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
              (_) {
            _logger.i('Address updated successfully', tag: 'UserRepository');
            return const Right(null);
          },
        );
      });
    } catch (e) {
      _logger.e('Unexpected error updating address', error: e, tag: 'UserRepository');
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAddress(String addressId) async {
    try {
      _logger.d('Deleting address via API', tag: 'UserRepository');

      // Get current user addresses
      final userResult = await getUserDetails();

      return userResult.fold((failure) => Left(failure), (user) async {
        if (user.addresses == null) {
          _logger.d('User has no addresses to delete', tag: 'UserRepository');
          return const Right(null); // No addresses to delete
        }

        // Filter out the address to delete
        final updatedAddresses = user.addresses!.where((addr) => addr.id != addressId).toList();

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
              (_) {
            _logger.i('Address deleted successfully', tag: 'UserRepository');
            return const Right(null);
          },
        );
      });
    } catch (e) {
      _logger.e('Unexpected error deleting address', error: e, tag: 'UserRepository');
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}