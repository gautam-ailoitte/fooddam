import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/execption.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/network/network_info.dart';
import 'package:foodam/src/data/datasource/local_data_source.dart';
import 'package:foodam/src/data/datasource/remote_data_source.dart';
import 'package:foodam/src/data/models/thali_model.dart';
import 'package:foodam/src/domain/entities/meal_entity.dart';
import 'package:foodam/src/domain/entities/thali_entity.dart';
import 'package:foodam/src/domain/repo/meal_repository.dart';

class MealRepositoryImpl implements MealRepository {
  final RemoteDataSource remoteDataSource;
  final LocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  MealRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Meal>>> getMealOptions(MealType type) async {
    if (await networkInfo.isConnected) {
      try {
        final meals = await remoteDataSource.getMealOptions(type);
        await localDataSource.cacheMealOptions(type, meals);
        return Right(meals);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      try {
        final meals = await localDataSource.getLastMealOptions(type);
        return Right(meals);
      } on CacheException {
        return Left(CacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, List<Thali>>> getThaliOptions(MealType type) async {
    if (await networkInfo.isConnected) {
      try {
        final thalis = await remoteDataSource.getThaliOptions(type);
        await localDataSource.cacheThaliOptions(type, thalis);
        return Right(thalis);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      try {
        final thalis = await localDataSource.getLastThaliOptions(type);
        return Right(thalis);
      } on CacheException {
        return Left(CacheFailure());
      }
    }
  }

  @override
 // In meal_repository_impl.dart
@override
Future<Either<Failure, Thali>> customizeThali(
  Thali thali,
  List<Meal> selectedMeals,
) async {
  try {
    // Print debug info
    print('Repository: Customizing thali ${thali.id} with ${selectedMeals.length} meals');
    
    // Make sure we're creating the right type
    final ThaliModel customizedThali = thali is ThaliModel 
        ? ThaliModel(
            id: thali.id,
            name: 'Customized ${thali.name}',
            type: thali.type,
            basePrice: thali.basePrice,
            defaultMeals: thali.defaultMeals,
            selectedMeals: selectedMeals,
            maxCustomizations: thali.maxCustomizations,
          )
        : ThaliModel(
            id: thali.id,
            name: 'Customized Thali',
            type: thali.type,
            basePrice: thali.basePrice,
            defaultMeals: thali is ThaliModel ? thali.defaultMeals : [],
            selectedMeals: selectedMeals,
            maxCustomizations: thali.maxCustomizations,
          );
    
    // Cache the customized thali if applicable
    await localDataSource.cacheCustomizedThali(customizedThali);
      
    print('Repository: Customization complete for thali ${customizedThali.id}');
    return Right(customizedThali);
  } catch (e) {
    print('Repository: Error customizing thali: ${e.toString()}');
    return Left(UnexpectedFailure());
  }
}
  
  // New methods
  
  @override
  Future<Either<Failure, Thali>> getDefaultThali(MealType type, ThaliType preferredType) async {
    try {
      // First try to get thali options from remote or cached data
      final thaliOptionsResult = await getThaliOptions(type);
      
      return thaliOptionsResult.fold(
        (failure) => Left(failure),
        (thalis) {
          // Find the thali matching the preferred type
          try {
            final defaultThali = thalis.firstWhere(
              (thali) => thali.type == preferredType,
              orElse: () => thalis.first, // Fallback to first thali if preferred not found
            );
            return Right(defaultThali);
          } catch (e) {
            return Left(UnexpectedFailure());
          }
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }
  
  @override
  Future<Either<Failure, Thali>> resetThaliToDefault(Thali thali) async {
    try {
      // Get thali options for this meal type
      final thaliOptionsResult = await getThaliOptions(thali.type as MealType);
      
      return thaliOptionsResult.fold(
        (failure) => Left(failure),
        (thalis) {
          // Find the matching default thali based on ID or type
          try {
            final defaultThali = thalis.firstWhere(
              (t) => t.id == thali.id || t.type == thali.type,
              orElse: () => thalis.first, // Fallback to first thali if not found
            );
            return Right(defaultThali);
          } catch (e) {
            return Left(UnexpectedFailure());
          }
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }
  
  @override
  Future<Either<Failure, bool>> compareThalis(Thali thali1, Thali thali2) async {
    try {
      // Use the helper method in Thali to compare the meals
      if (thali1 is ThaliModel && thali2 is ThaliModel) {
        final haveSameMeals = thali1.hasSameMeals(thali2);
        return Right(haveSameMeals);
      } else {
        // If different types, do manual comparison
        if (thali1.selectedMeals.length != thali2.selectedMeals.length) {
          return Right(false);
        }
        
        // Sort both lists by ID to ensure consistent comparison
        final sortedMeals1 = List<Meal>.from(thali1.selectedMeals)
          ..sort((a, b) => a.id.compareTo(b.id));
        final sortedMeals2 = List<Meal>.from(thali2.selectedMeals)
          ..sort((a, b) => a.id.compareTo(b.id));
        
        // Compare each meal by ID
        for (int i = 0; i < sortedMeals1.length; i++) {
          if (sortedMeals1[i].id != sortedMeals2[i].id) {
            return Right(false);
          }
        }
        
        return Right(true);
      }
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }
}
// lib/data/repositories/plan_repository_impl.dart

