import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/execption.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/network/network_info.dart';
import 'package:foodam/src/data/datasource/local_data_source.dart';
import 'package:foodam/src/data/datasource/remote_data_source.dart';
import 'package:foodam/src/data/model/address_model.dart';
import 'package:foodam/src/data/model/user_model.dart';
import 'package:foodam/src/domain/entities/address_entity.dart';
import 'package:foodam/src/domain/entities/diet_pref_entity.dart';
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
        return Right(cachedUser);
      }
      
      // If not in cache and network available, fetch from remote
      if (await networkInfo.isConnected) {
        try {
          final userModel = await remoteDataSource.getUserDetails();
          await localDataSource.cacheUser(userModel);
          return Right(userModel);
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
        final userModel = user as UserModel;
        await remoteDataSource.updateUserDetails(userModel);
        await localDataSource.cacheUser(userModel);
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
  Future<Either<Failure, void>> updateDietaryPreferences(List<DietaryPreference> preferences) async {
    if (await networkInfo.isConnected) {
      try {
        // Convert enum values to strings for API
        final prefStrings = preferences.map((pref) {
          switch (pref) {
            case DietaryPreference.vegetarian:
              return 'vegetarian';
            case DietaryPreference.nonVegetarian:
              return 'non-vegetarian';
            case DietaryPreference.vegan:
              return 'vegan';
            case DietaryPreference.glutenFree:
              return 'gluten-free';
            case DietaryPreference.dairyFree:
              return 'dairy-free';
          }
        }).toList();
        
        await remoteDataSource.updateDietaryPreferences(prefStrings);
        
        // Update local user cache with new preferences
        final userEither = await getUserDetails();
        userEither.fold(
          (failure) => null,
          (user) async {
            final updatedUser = UserModel(
              id: user.id,
              firstName: user.firstName,
              lastName: user.lastName,
              email: user.email,
              phone: user.phone,
              role: user.role,
              address: user.address as AddressModel,
              dietaryPreferences: preferences,
              allergies: user.allergies,
            );
            await localDataSource.cacheUser(updatedUser);
          },
        );
        
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
  Future<Either<Failure, void>> updateAllergies(List<String> allergies) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.updateAllergies(allergies);
        
        // Update local user cache with new allergies
        final userEither = await getUserDetails();
        userEither.fold(
          (failure) => null,
          (user) async {
            final updatedUser = UserModel(
              id: user.id,
              firstName: user.firstName,
              lastName: user.lastName,
              email: user.email,
              phone: user.phone,
              role: user.role,
              address: user.address as AddressModel,
              dietaryPreferences: user.dietaryPreferences,
              allergies: allergies,
            );
            await localDataSource.cacheUser(updatedUser);
          },
        );
        
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
  Future<Either<Failure, void>> addAddress(Address address) async {
    // Implementation would depend on the actual API design
    return Left(UnexpectedFailure()); // Placeholder
  }

  @override
  Future<Either<Failure, void>> updateAddress(Address address) async {
    // Implementation would depend on the actual API design
    return Left(UnexpectedFailure()); // Placeholder
  }

  @override
  Future<Either<Failure, List<Address>>> getUserAddresses() async {
    // Implementation would depend on the actual API design
    return Left(UnexpectedFailure()); // Placeholder
  }
}
