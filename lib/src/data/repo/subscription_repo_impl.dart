// lib/src/data/repositories/subscription_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/execption.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/network/network_info.dart';
import 'package:foodam/src/data/datasource/local_data_source.dart';
import 'package:foodam/src/data/datasource/remote_data_source.dart';
import 'package:foodam/src/domain/entities/address_entity.dart';
import 'package:foodam/src/domain/entities/dish_entity.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';
import 'package:foodam/src/domain/repo/susbcription_repo.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final RemoteDataSource remoteDataSource;
  final LocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  SubscriptionRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Subscription>>> getAvailableSubscriptions() async {
    if (await networkInfo.isConnected) {
      try {
        final subscriptions = await remoteDataSource.getAvailableSubscriptions();
        return Right(subscriptions);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, Subscription?>> getActiveSubscription() async {
    if (await networkInfo.isConnected) {
      try {
        final subscription = await remoteDataSource.getActiveSubscription();
        return Right(subscription);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, Subscription>> createSubscription({
    required SubscriptionDuration duration,
    required DateTime startDate,
    required List<MealPreference> mealPreferences,
    required DeliverySchedule deliverySchedule,
    required Address deliveryAddress,
    String? paymentMethodId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final subscription = await remoteDataSource.createSubscription(
          duration: duration,
          startDate: startDate,
          mealPreferences: mealPreferences,
          deliverySchedule: deliverySchedule,
          deliveryAddress: deliveryAddress,
          paymentMethodId: paymentMethodId,
        );
        return Right(subscription);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, Subscription>> customizeSubscription(
    String subscriptionId, {
    List<MealPreference>? mealPreferences,
    DeliverySchedule? deliverySchedule,
    Address? deliveryAddress,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final subscription = await remoteDataSource.customizeSubscription(
          subscriptionId,
          mealPreferences: mealPreferences,
          deliverySchedule: deliverySchedule,
          deliveryAddress: deliveryAddress,
        );
        return Right(subscription);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, Subscription>> saveDraftSubscription(Subscription subscription) async {
    try {
      // Convert subscription to a serializable map
      // This is a simplified version - in a real app, you'd have a proper data model
      final subscriptionMap = {
        'id': subscription.id,
        'userId': subscription.userId,
        'duration': subscription.duration.toString(),
        'startDate': subscription.startDate.toIso8601String(),
        'endDate': subscription.endDate.toIso8601String(),
        'status': subscription.status.toString(),
        'basePrice': subscription.basePrice,
        'totalPrice': subscription.totalPrice,
        'isCustomized': subscription.isCustomized,
        'createdAt': subscription.createdAt.toIso8601String(),
        'updatedAt': subscription.updatedAt?.toIso8601String(),
        // Simplified meal preferences, delivery schedule, and address
        'mealPreferences': subscription.mealPreferences.map((pref) => {
          'mealType': pref.mealType,
          'preferences': pref.preferences.map((p) => p.toString()).toList(),
          'quantity': pref.quantity,
          'excludedIngredients': pref.excludedIngredients,
        }).toList(),
        'deliverySchedule': {
          'daysOfWeek': subscription.deliverySchedule.daysOfWeek,
          'preferredTimeSlot': subscription.deliverySchedule.preferredTimeSlot,
        },
        'deliveryAddress': {
          'street': subscription.deliveryAddress.street,
          'city': subscription.deliveryAddress.city,
          'state': subscription.deliveryAddress.state,
          'zipCode': subscription.deliveryAddress.zipCode,
          'country': subscription.deliveryAddress.country,
          'coordinates': subscription.deliveryAddress.coordinates != null
              ? {
                  'latitude': subscription.deliveryAddress.coordinates!.latitude,
                  'longitude': subscription.deliveryAddress.coordinates!.longitude,
                }
              : null,
        },
      };
      
      await localDataSource.cacheDraftSubscription(subscriptionMap);
      return Right(subscription);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, Subscription?>> getDraftSubscription() async {
    try {
      final draftMap = await localDataSource.getDraftSubscription();
      
      if (draftMap == null) {
        return const Right(null);
      }
      
      // Convert map back to Subscription entity
      // This is simplified - in a real app, you'd have proper mappers
      final duration = SubscriptionDuration.values.firstWhere(
        (d) => d.toString() == draftMap['duration'],
      );
      
      final status = SubscriptionStatus.values.firstWhere(
        (s) => s.toString() == draftMap['status'],
      );
      
      final deliveryAddressMap = draftMap['deliveryAddress'];
      final deliveryAddress = Address(
        street: deliveryAddressMap['street'],
        city: deliveryAddressMap['city'],
        state: deliveryAddressMap['state'],
        zipCode: deliveryAddressMap['zipCode'],
        country: deliveryAddressMap['country'],
        coordinates: deliveryAddressMap['coordinates'] != null
            ? Coordinates(
                latitude: deliveryAddressMap['coordinates']['latitude'],
                longitude: deliveryAddressMap['coordinates']['longitude'],
              )
            : null,
      );
      
      final deliveryScheduleMap = draftMap['deliverySchedule'];
      final deliverySchedule = DeliverySchedule(
        daysOfWeek: List<int>.from(deliveryScheduleMap['daysOfWeek']),
        preferredTimeSlot: deliveryScheduleMap['preferredTimeSlot'],
      );
      
      final mealPreferencesMapList = draftMap['mealPreferences'];
      final mealPreferences = mealPreferencesMapList.map<MealPreference>((prefMap) {
        final preferencesStrings = List<String>.from(prefMap['preferences']);
        final preferences = preferencesStrings.map((prefString) {
          return DietaryPreference.values.firstWhere(
            (pref) => pref.toString() == prefString,
          );
        }).toList();
        
        return MealPreference(
          mealType: prefMap['mealType'],
          preferences: preferences,
          quantity: prefMap['quantity'],
          excludedIngredients: prefMap['excludedIngredients'] != null
              ? List<String>.from(prefMap['excludedIngredients'])
              : null,
        );
      }).toList();
      
      final subscription = Subscription(
        id: draftMap['id'],
        userId: draftMap['userId'],
        duration: duration,
        startDate: DateTime.parse(draftMap['startDate']),
        endDate: DateTime.parse(draftMap['endDate']),
        status: status,
        basePrice: draftMap['basePrice'],
        totalPrice: draftMap['totalPrice'],
        isCustomized: draftMap['isCustomized'],
        mealPreferences: mealPreferences,
        deliverySchedule: deliverySchedule,
        deliveryAddress: deliveryAddress,
        paymentMethodId: draftMap['paymentMethodId'],
        createdAt: DateTime.parse(draftMap['createdAt']),
        updatedAt: draftMap['updatedAt'] != null
            ? DateTime.parse(draftMap['updatedAt'])
            : null,
      );
      
      return Right(subscription);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> clearDraftSubscription() async {
    try {
      await localDataSource.clearDraftSubscription();
      return const Right(null);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, String>> saveSubscriptionAndGetPaymentUrl(Subscription subscription) async {
    if (await networkInfo.isConnected) {
      try {
        final paymentUrl = await remoteDataSource.saveSubscriptionAndGetPaymentUrl(subscription);
        return Right(paymentUrl);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, Subscription>> pauseSubscription(
    String subscriptionId,
    DateTime resumeDate,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        // Since our mock data source doesn't have this method, we'll simulate it
        // Get current subscription
        final activeSubscription = await remoteDataSource.getActiveSubscription();
        
        if (activeSubscription == null || activeSubscription.id != subscriptionId) {
          return Left(ServerFailure());
        }
        
        // Create a paused version
        final pausedSubscription = Subscription(
          id: activeSubscription.id,
          userId: activeSubscription.userId,
          duration: activeSubscription.duration,
          startDate: activeSubscription.startDate,
          endDate: activeSubscription.endDate,
          status: SubscriptionStatus.paused,
          basePrice: activeSubscription.basePrice,
          totalPrice: activeSubscription.totalPrice,
          isCustomized: activeSubscription.isCustomized,
          mealPreferences: activeSubscription.mealPreferences,
          deliverySchedule: activeSubscription.deliverySchedule,
          deliveryAddress: activeSubscription.deliveryAddress,
          paymentMethodId: activeSubscription.paymentMethodId,
          createdAt: activeSubscription.createdAt,
          updatedAt: DateTime.now(),
        );
        
        return Right(pausedSubscription);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, Subscription>> resumeSubscription(String subscriptionId) async {
    if (await networkInfo.isConnected) {
      try {
        // Since our mock data source doesn't have this method, we'll simulate it
        // Get current subscription
        final activeSubscription = await remoteDataSource.getActiveSubscription();
        
        if (activeSubscription == null || activeSubscription.id != subscriptionId) {
          return Left(ServerFailure());
        }
        
        // Create a resumed version
        final resumedSubscription = Subscription(
          id: activeSubscription.id,
          userId: activeSubscription.userId,
          duration: activeSubscription.duration,
          startDate: activeSubscription.startDate,
          endDate: activeSubscription.endDate,
          status: SubscriptionStatus.active,
          basePrice: activeSubscription.basePrice,
          totalPrice: activeSubscription.totalPrice,
          isCustomized: activeSubscription.isCustomized,
          mealPreferences: activeSubscription.mealPreferences,
          deliverySchedule: activeSubscription.deliverySchedule,
          deliveryAddress: activeSubscription.deliveryAddress,
          paymentMethodId: activeSubscription.paymentMethodId,
          createdAt: activeSubscription.createdAt,
          updatedAt: DateTime.now(),
        );
        
        return Right(resumedSubscription);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, Subscription>> cancelSubscription(String subscriptionId, String reason) async {
    if (await networkInfo.isConnected) {
      try {
        // Since our mock data source doesn't have this method, we'll simulate it
        // Get current subscription
        final activeSubscription = await remoteDataSource.getActiveSubscription();
        
        if (activeSubscription == null || activeSubscription.id != subscriptionId) {
          return Left(ServerFailure());
        }
        
        // Create a cancelled version
        final cancelledSubscription = Subscription(
          id: activeSubscription.id,
          userId: activeSubscription.userId,
          duration: activeSubscription.duration,
          startDate: activeSubscription.startDate,
          endDate: activeSubscription.endDate,
          status: SubscriptionStatus.cancelled,
          basePrice: activeSubscription.basePrice,
          totalPrice: activeSubscription.totalPrice,
          isCustomized: activeSubscription.isCustomized,
          mealPreferences: activeSubscription.mealPreferences,
          deliverySchedule: activeSubscription.deliverySchedule,
          deliveryAddress: activeSubscription.deliveryAddress,
          paymentMethodId: activeSubscription.paymentMethodId,
          createdAt: activeSubscription.createdAt,
          updatedAt: DateTime.now(),
        );
        
        return Right(cancelledSubscription);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, Subscription>> renewSubscription(String subscriptionId) async {
    if (await networkInfo.isConnected) {
      try {
        // Since our mock data source doesn't have this method, we'll simulate it
        // Get current subscription
        final activeSubscription = await remoteDataSource.getActiveSubscription();
        
        if (activeSubscription == null || activeSubscription.id != subscriptionId) {
          return Left(ServerFailure());
        }
        
        // Create a renewed version with extended dates
        final renewedSubscription = Subscription(
          id: activeSubscription.id,
          userId: activeSubscription.userId,
          duration: activeSubscription.duration,
          startDate: activeSubscription.endDate,
          endDate: activeSubscription.endDate.add(Duration(days: activeSubscription.durationInDays)),
          status: SubscriptionStatus.active,
          basePrice: activeSubscription.basePrice,
          totalPrice: activeSubscription.totalPrice,
          isCustomized: activeSubscription.isCustomized,
          mealPreferences: activeSubscription.mealPreferences,
          deliverySchedule: activeSubscription.deliverySchedule,
          deliveryAddress: activeSubscription.deliveryAddress,
          paymentMethodId: activeSubscription.paymentMethodId,
          createdAt: activeSubscription.createdAt,
          updatedAt: DateTime.now(),
        );
        
        return Right(renewedSubscription);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, Subscription>> getSubscriptionById(String subscriptionId) async {
    if (await networkInfo.isConnected) {
      try {
        // Since our mock data source doesn't have this method, we'll use a workaround
        final subscriptions = await remoteDataSource.getAvailableSubscriptions();
        final subscription = subscriptions.where((sub) => sub.id == subscriptionId).firstOrNull;
        
        if (subscription == null) {
          return Left(ServerFailure());
        }
        
        return Right(subscription);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<Subscription>>> getSubscriptionHistory() async {
    if (await networkInfo.isConnected) {
      try {
        // Since our mock data source doesn't have this method specifically,
        // we'll use the available subscriptions as a substitute
        final subscriptions = await remoteDataSource.getAvailableSubscriptions();
        return Right(subscriptions);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, Subscription>> updatePaymentMethod(
    String subscriptionId,
    String paymentMethodId,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        // Since our mock data source doesn't have this method, we'll simulate it
        // Get current subscription
        final subscriptions = await remoteDataSource.getAvailableSubscriptions();
        final subscription = subscriptions.where((sub) => sub.id == subscriptionId).firstOrNull;
        
        if (subscription == null) {
          return Left(ServerFailure());
        }
        
        // Create updated subscription with new payment method
        final updatedSubscription = Subscription(
          id: subscription.id,
          userId: subscription.userId,
          duration: subscription.duration,
          startDate: subscription.startDate,
          endDate: subscription.endDate,
          status: subscription.status,
          basePrice: subscription.basePrice,
          totalPrice: subscription.totalPrice,
          isCustomized: subscription.isCustomized,
          mealPreferences: subscription.mealPreferences,
          deliverySchedule: subscription.deliverySchedule,
          deliveryAddress: subscription.deliveryAddress,
          paymentMethodId: paymentMethodId,
          createdAt: subscription.createdAt,
          updatedAt: DateTime.now(),
        );
        
        return Right(updatedSubscription);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }
}