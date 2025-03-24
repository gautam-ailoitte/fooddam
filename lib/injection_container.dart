// lib/injection_container.dart
import 'package:foodam/core/constants/app_constants.dart';
import 'package:foodam/core/network/api_client.dart';
import 'package:foodam/core/network/network_info.dart';
import 'package:foodam/core/service/storage_service.dart';
import 'package:foodam/src/data/datasource/local_data_source.dart';
import 'package:foodam/src/data/datasource/mock_remote_data_soruce.dart';
import 'package:foodam/src/data/datasource/remote_data_source.dart';
import 'package:foodam/src/data/repo/auth_repo_impl.dart';
import 'package:foodam/src/data/repo/meal_repo_impl.dart';
import 'package:foodam/src/data/repo/pacakge_repo_impl.dart';
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

final di = GetIt.instance;

// Development flags
const bool useMockRemoteData = true;
const bool initLocalStorageWithMockData = true;
const bool USE_MOCK_API = true; // Define the USE_MOCK_API constant

Future<void> init() async {
  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  di.registerLazySingleton(() => sharedPreferences);
  di.registerLazySingleton(() => http.Client());
  di.registerLazySingleton(() => InternetConnectionChecker.instance);

  //! Core
  di.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(di<InternetConnectionChecker>()),
  );
  
  di.registerLazySingleton<StorageService>(
    () => StorageService(di<SharedPreferences>()),
  );
  
  di.registerLazySingleton<ApiClient>(
    () => ApiClient(
      httpClient: di<http.Client>(),
      sharedPreferences: di<SharedPreferences>(),
      baseUrl: AppConstants.apiBaseUrl,
    ),
  );

  //! Data sources
   //! Data sources
  // Register the appropriate RemoteDataSource implementation based on the flag
  if (USE_MOCK_API) {
    di.registerLazySingleton<RemoteDataSource>(
      () => MockRemoteDataSource(),
    );
  } else {
    di.registerLazySingleton<RemoteDataSource>(
      () => RemoteDataSourceImpl(client: di<ApiClient>()),
    );
  }
  
  di.registerLazySingleton<LocalDataSource>(
    () => LocalDataSourceImpl(
      storageService: di<StorageService>(),
      initWithMockData: initLocalStorageWithMockData,
    ),
  );

  //! Repositories
  di.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: di<RemoteDataSource>(),
      localDataSource: di<LocalDataSource>(),
      networkInfo: di<NetworkInfo>(),
    ),
  );
  
  di.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(
      remoteDataSource: di<RemoteDataSource>(),
      localDataSource: di<LocalDataSource>(),
      networkInfo: di<NetworkInfo>(),
    ),
  );
  
  di.registerLazySingleton<PackageRepository>(
    () => PackageRepositoryImpl(
      remoteDataSource: di<RemoteDataSource>(),
      localDataSource: di<LocalDataSource>(),
      networkInfo: di<NetworkInfo>(),
    ),
  );
  
  di.registerLazySingleton<MealRepository>(
    () => MealRepositoryImpl(
      remoteDataSource: di<RemoteDataSource>(),
      networkInfo: di<NetworkInfo>(),
    ),
  );
  
  di.registerLazySingleton<SubscriptionRepository>(
    () => SubscriptionRepositoryImpl(
      remoteDataSource: di<RemoteDataSource>(),
      localDataSource: di<LocalDataSource>(),
      networkInfo: di<NetworkInfo>(),
    ),
  );
  
 
  //! Use cases
  // Auth use case
  di.registerLazySingleton(() => AuthUseCase(di<AuthRepository>()));
  
  // User use case
  di.registerLazySingleton(() => UserUseCase(di<UserRepository>()));
  
  // Package use case
  di.registerLazySingleton(() => PackageUseCase(di<PackageRepository>()));
  
  // Meal use case
  di.registerLazySingleton(() => MealUseCase(
    di<MealRepository>(), 
    di<SubscriptionRepository>()
  ));
  
  // Subscription use case
  di.registerLazySingleton(() => SubscriptionUseCase(di<SubscriptionRepository>()));
  
  // Payment use case
  di.registerLazySingleton(() => PaymentUseCase(di<PaymentRepository>()));

  //! Cubits
  // Auth Cubit
  di.registerFactory(() => AuthCubit(
    authUseCase: di<AuthUseCase>(),
  ));
  
  // User Profile Cubit
  di.registerFactory(() => UserProfileCubit(
     userUseCase: di<UserUseCase>(),
  ));
  
  // Package Cubit
  di.registerFactory(() => PackageCubit(
    packageUseCase: di<PackageUseCase>(),
  ));
  
  // Meal Cubit
  di.registerFactory(() => MealCubit(
    mealUseCase: di<MealUseCase>(),
    subscriptionUseCase: di<SubscriptionUseCase>(),
  ));
  
  // Today Meal Cubit
  di.registerFactory(() => TodayMealCubit(
    mealUseCase: di<MealUseCase>(),
  ));
  
  // Subscription Cubit
  di.registerFactory(() => SubscriptionCubit(
    subscriptionUseCase: di<SubscriptionUseCase>(),
  ));
  
  // Create Subscription Cubit
  di.registerFactory(() => CreateSubscriptionCubit(
    createSubscriptionUseCase: di<CreateSubscriptionUseCase>(),
  ));
  
  // Payment Cubit
  di.registerFactory(() => PaymentCubit(
    paymentUseCase: di<PaymentUseCase>(),
  ));
}