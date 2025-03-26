// lib/injection_container.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:foodam/core/constants/app_constants.dart';
import 'package:foodam/core/network/api_client.dart';
import 'package:foodam/core/network/network_info.dart';
import 'package:foodam/core/service/storage_service.dart';
import 'package:foodam/firebase_config.dart';
import 'package:foodam/src/data/datasource/firebase_remote_datasource.dart';
import 'package:foodam/src/data/datasource/local_data_source.dart';
import 'package:foodam/src/data/datasource/mock_remote_data_soruce.dart';
import 'package:foodam/src/data/datasource/remote_data_source.dart';
import 'package:foodam/src/data/repo/auth_repo_impl.dart';
import 'package:foodam/src/data/repo/meal_repo_impl.dart';
import 'package:foodam/src/data/repo/pacakge_repo_impl.dart';
import 'package:foodam/src/data/repo/paymetn_repo_impl.dart';
import 'package:foodam/src/data/repo/subscripton_repo_imp.dart';
import 'package:foodam/src/data/repo/user_repos_impl.dart';
import 'package:foodam/src/domain/repo/auth_repo.dart';
import 'package:foodam/src/domain/repo/meal_rep.dart';
import 'package:foodam/src/domain/repo/package_repo.dart';
import 'package:foodam/src/domain/repo/payment_repo.dart';
import 'package:foodam/src/domain/repo/subscription_repo.dart';
import 'package:foodam/src/domain/repo/user_repo.dart';
import 'package:foodam/src/domain/usecase/auth_usecase.dart';
import 'package:foodam/src/domain/usecase/meal_usecase.dart';
import 'package:foodam/src/domain/usecase/package_usecase.dart';
import 'package:foodam/src/domain/usecase/payment_usecase.dart';
import 'package:foodam/src/domain/usecase/subscription/create_subscription_usecase.dart';
import 'package:foodam/src/domain/usecase/susbcription_usecase.dart';
import 'package:foodam/src/domain/usecase/user_usecase.dart';
import 'package:foodam/src/presentation/cubits/auth_cubit/auth_cubit_cubit.dart';
import 'package:foodam/src/presentation/cubits/meal/meal_cubit.dart';
import 'package:foodam/src/presentation/cubits/pacakge_cubits/pacakage_cubit.dart';
import 'package:foodam/src/presentation/cubits/payment_history/payment_cubit.dart';
import 'package:foodam/src/presentation/cubits/subscription/create_subcription/create_subcription_cubit.dart';
import 'package:foodam/src/presentation/cubits/subscription/subscription/subscription_details_cubit.dart';
import 'package:foodam/src/presentation/cubits/today_meal_cubit/today_meal_cubit_cubit.dart';
import 'package:foodam/src/presentation/cubits/user_profile/user_profile_cubit.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

final di = GetIt.instance;

// Development flags
const bool USE_MOCK_DATA = false; // Set to false to use real Firebase data
const bool initLocalStorageWithMockData = true;

// Track registered types to prevent duplicates
final Set<Type> _registeredTypes = {};

Future<void> init() async {
  try {
    //! External
    if (!_registeredTypes.contains(SharedPreferences)) {
      final sharedPreferences = await SharedPreferences.getInstance();
      di.registerLazySingleton(() => sharedPreferences);
      _registeredTypes.add(SharedPreferences);
    }

    if (!_registeredTypes.contains(http.Client)) {
      di.registerLazySingleton(() => http.Client());
      _registeredTypes.add(http.Client);
    }

    if (!_registeredTypes.contains(InternetConnectionChecker)) {
      di.registerLazySingleton(() => InternetConnectionChecker.instance);
      _registeredTypes.add(InternetConnectionChecker);
    }

    //! Core
    if (!_registeredTypes.contains(NetworkInfo)) {
      di.registerLazySingleton<NetworkInfo>(
        () => NetworkInfoImpl(di<InternetConnectionChecker>()),
      );
      _registeredTypes.add(NetworkInfo);
    }

    if (!_registeredTypes.contains(StorageService)) {
      di.registerLazySingleton<StorageService>(
        () => StorageService(di<SharedPreferences>()),
      );
      _registeredTypes.add(StorageService);
    }

    if (!_registeredTypes.contains(ApiClient)) {
      di.registerLazySingleton<ApiClient>(
        () => ApiClient(
          httpClient: di<http.Client>(),
          sharedPreferences: di<SharedPreferences>(),
          baseUrl: AppConstants.apiBaseUrl,
        ),
      );
      _registeredTypes.add(ApiClient);
    }

    // Initialize Firebase if we're not using mock data
    if (!USE_MOCK_DATA) {
      await FirebaseConfig.initialize();
    }

    //! Data sources
    if (!_registeredTypes.contains(RemoteDataSource)) {
      // Register the appropriate RemoteDataSource implementation based on the flag
      if (USE_MOCK_DATA) {
        di.registerLazySingleton<RemoteDataSource>(
          () => MockRemoteDataSource(),
        );
        debugPrint('Using MockRemoteDataSource');
      } else {
        // Use real Firebase implementation
        di.registerLazySingleton<RemoteDataSource>(
          () => FirebaseRemoteDataSource(
            firestore: FirebaseFirestore.instance,
            auth: FirebaseAuth.instance,
          ),
        );
        debugPrint('Using FirebaseRemoteDataSource');
      }
      _registeredTypes.add(RemoteDataSource);
    }

    if (!_registeredTypes.contains(LocalDataSource)) {
      di.registerLazySingleton<LocalDataSource>(
        () => LocalDataSourceImpl(
          storageService: di<StorageService>(),
          initWithMockData: initLocalStorageWithMockData,
        ),
      );
      _registeredTypes.add(LocalDataSource);
    }

    //! Repositories
    if (!_registeredTypes.contains(AuthRepository)) {
      di.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(
          remoteDataSource: di<RemoteDataSource>(),
          localDataSource: di<LocalDataSource>(),
          networkInfo: di<NetworkInfo>(),
        ),
      );
      _registeredTypes.add(AuthRepository);
    }

    if (!_registeredTypes.contains(UserRepository)) {
      di.registerLazySingleton<UserRepository>(
        () => UserRepositoryImpl(
          remoteDataSource: di<RemoteDataSource>(),
          localDataSource: di<LocalDataSource>(),
          networkInfo: di<NetworkInfo>(),
        ),
      );
      _registeredTypes.add(UserRepository);
    }

    if (!_registeredTypes.contains(PackageRepository)) {
      di.registerLazySingleton<PackageRepository>(
        () => PackageRepositoryImpl(
          remoteDataSource: di<RemoteDataSource>(),
          localDataSource: di<LocalDataSource>(),
          networkInfo: di<NetworkInfo>(),
        ),
      );
      _registeredTypes.add(PackageRepository);
    }

    if (!_registeredTypes.contains(MealRepository)) {
      di.registerLazySingleton<MealRepository>(
        () => MealRepositoryImpl(
          remoteDataSource: di<RemoteDataSource>(),
          networkInfo: di<NetworkInfo>(),
        ),
      );
      _registeredTypes.add(MealRepository);
    }

    if (!_registeredTypes.contains(SubscriptionRepository)) {
      di.registerLazySingleton<SubscriptionRepository>(
        () => SubscriptionRepositoryImpl(
          remoteDataSource: di<RemoteDataSource>(),
          localDataSource: di<LocalDataSource>(),
          networkInfo: di<NetworkInfo>(),
        ),
      );
      _registeredTypes.add(SubscriptionRepository);
    }

    if (!_registeredTypes.contains(PaymentRepository)) {
      di.registerLazySingleton<PaymentRepository>(
        () => PaymentRepositoryImpl(
          remoteDataSource: di<RemoteDataSource>(),
          networkInfo: di<NetworkInfo>(),
        ),
      );
      _registeredTypes.add(PaymentRepository);
    }

    //! Use cases
    // Auth use case
    if (!_registeredTypes.contains(AuthUseCase)) {
      di.registerLazySingleton(() => AuthUseCase(di<AuthRepository>()));
      _registeredTypes.add(AuthUseCase);
    }

    // User use case
    if (!_registeredTypes.contains(UserUseCase)) {
      di.registerLazySingleton(() => UserUseCase(di<UserRepository>()));
      _registeredTypes.add(UserUseCase);
    }

    // Package use case
    if (!_registeredTypes.contains(PackageUseCase)) {
      di.registerLazySingleton(() => PackageUseCase(di<PackageRepository>()));
      _registeredTypes.add(PackageUseCase);
    }

    // Meal use case
    if (!_registeredTypes.contains(MealUseCase)) {
      di.registerLazySingleton(
        () => MealUseCase(di<MealRepository>(), di<SubscriptionRepository>()),
      );
      _registeredTypes.add(MealUseCase);
    }

    // Subscription use case
    if (!_registeredTypes.contains(SubscriptionUseCase)) {
      di.registerLazySingleton(
        () => SubscriptionUseCase(di<SubscriptionRepository>()),
      );
      _registeredTypes.add(SubscriptionUseCase);
    }

    // Payment use case
    if (!_registeredTypes.contains(PaymentUseCase)) {
      di.registerLazySingleton(() => PaymentUseCase(di<PaymentRepository>()));
      _registeredTypes.add(PaymentUseCase);
    }

    // Create Subscription use case
    if (!_registeredTypes.contains(CreateSubscriptionUseCase)) {
      di.registerLazySingleton(
        () => CreateSubscriptionUseCase(di<SubscriptionRepository>()),
      );
      _registeredTypes.add(CreateSubscriptionUseCase);
    }

    //! Cubits
    // Auth Cubit
    if (!_registeredTypes.contains(AuthCubit)) {
      di.registerFactory(() => AuthCubit(authUseCase: di<AuthUseCase>()));
      _registeredTypes.add(AuthCubit);
    }

    // User Profile Cubit
    if (!_registeredTypes.contains(UserProfileCubit)) {
      di.registerFactory(
        () => UserProfileCubit(userUseCase: di<UserUseCase>()),
      );
      _registeredTypes.add(UserProfileCubit);
    }

    // Package Cubit
    if (!_registeredTypes.contains(PackageCubit)) {
      di.registerFactory(
        () => PackageCubit(packageUseCase: di<PackageUseCase>()),
      );
      _registeredTypes.add(PackageCubit);
    }

    // Meal Cubit
    if (!_registeredTypes.contains(MealCubit)) {
      di.registerFactory(
        () => MealCubit(
          mealUseCase: di<MealUseCase>(),
          subscriptionUseCase: di<SubscriptionUseCase>(),
        ),
      );
      _registeredTypes.add(MealCubit);
    }

    // Today Meal Cubit
    if (!_registeredTypes.contains(TodayMealCubit)) {
      di.registerFactory(() => TodayMealCubit(mealUseCase: di<MealUseCase>()));
      _registeredTypes.add(TodayMealCubit);
    }

    // Subscription Cubit
    if (!_registeredTypes.contains(SubscriptionCubit)) {
      di.registerFactory(
        () => SubscriptionCubit(subscriptionUseCase: di<SubscriptionUseCase>()),
      );
      _registeredTypes.add(SubscriptionCubit);
    }

    // Create Subscription Cubit
    if (!_registeredTypes.contains(CreateSubscriptionCubit)) {
      di.registerFactory(
        () => CreateSubscriptionCubit(
          createSubscriptionUseCase: di<CreateSubscriptionUseCase>(),
        ),
      );
      _registeredTypes.add(CreateSubscriptionCubit);
    }

    // Payment Cubit
    if (!_registeredTypes.contains(PaymentCubit)) {
      di.registerFactory(
        () => PaymentCubit(paymentUseCase: di<PaymentUseCase>()),
      );
      _registeredTypes.add(PaymentCubit);
    }
  } catch (e, stackTrace) {
    debugPrint('Error during DI initialization: $e');
    debugPrint('Stack trace: $stackTrace');
    rethrow;
  }
}