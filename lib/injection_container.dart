// lib/injection_container.dart
import 'package:foodam/core/constants/app_constants.dart';
import 'package:foodam/core/network/api_client.dart';
import 'package:foodam/core/network/network_info.dart';
import 'package:foodam/core/service/storage_service.dart';
import 'package:foodam/src/data/datasource/local_data_source.dart';
import 'package:foodam/src/data/datasource/remote_data_source.dart';
import 'package:foodam/src/data/repo/auth_repo_impl.dart';
import 'package:foodam/src/data/repo/meal_repo_impl.dart';
import 'package:foodam/src/data/repo/payment_repo_impl.dart';
import 'package:foodam/src/data/repo/subscripton_repo_imp.dart';
import 'package:foodam/src/data/repo/user_repos_impl.dart';
import 'package:foodam/src/domain/repo/auth_repo.dart';
import 'package:foodam/src/domain/repo/meal_rep.dart';
import 'package:foodam/src/domain/repo/payment_repo.dart';
import 'package:foodam/src/domain/repo/subscription_repo.dart';
import 'package:foodam/src/domain/repo/user_repo.dart';
import 'package:foodam/src/domain/usecase/auth/isLoggedIn_usecase.dart';
import 'package:foodam/src/domain/usecase/auth/login_usecase.dart';
import 'package:foodam/src/domain/usecase/auth/logout_usecase.dart';
import 'package:foodam/src/domain/usecase/dish/get_dish_details_usecase.dart';
import 'package:foodam/src/domain/usecase/dish/get_dishes_usecase.dart';
import 'package:foodam/src/domain/usecase/meal/get_available_meal_usecase.dart';
import 'package:foodam/src/domain/usecase/meal/get_meal_bydietpref_usecase.dart';
import 'package:foodam/src/domain/usecase/meal/get_meal_details_usecase.dart';
import 'package:foodam/src/domain/usecase/meal/get_meals_bytype_usecase.dart';
import 'package:foodam/src/domain/usecase/order/get_meal_order_bysubscription_usecase.dart';
import 'package:foodam/src/domain/usecase/order/get_order_bydate_usecase.dart';
import 'package:foodam/src/domain/usecase/order/get_today_mealorder_usecase.dart';
import 'package:foodam/src/domain/usecase/payment/get_payment_details_usecase.dart';
import 'package:foodam/src/domain/usecase/payment/get_payment_history_usecase.dart';
import 'package:foodam/src/domain/usecase/payment/processpayement_usecase.dart';
import 'package:foodam/src/domain/usecase/subscription/cancel_susbcritpion_usecase.dart';
import 'package:foodam/src/domain/usecase/subscription/create_subscription_usecase.dart';
import 'package:foodam/src/domain/usecase/subscription/get_subscription_detail_usecase.dart';
import 'package:foodam/src/domain/usecase/subscription/getactivesubscription_usecase.dart';
import 'package:foodam/src/domain/usecase/subscription/getsubscription_usecase.dart';
import 'package:foodam/src/domain/usecase/subscription/pause_subscription_usecase.dart';
import 'package:foodam/src/domain/usecase/subscription/resume_susbcription_usecase.dart';
import 'package:foodam/src/domain/usecase/user/addaddress_usecase.dart';
import 'package:foodam/src/domain/usecase/user/getcurrentuser_usecase.dart';
import 'package:foodam/src/domain/usecase/user/getuseraddres_usecase.dart';
import 'package:foodam/src/domain/usecase/user/getuserdetail_usecase.dart';
import 'package:foodam/src/domain/usecase/user/updateaddress_usecase.dart';
import 'package:foodam/src/domain/usecase/user/updatedietpref_usecase.dart';
import 'package:foodam/src/domain/usecase/user/updateuser_usecase.dart';
import 'package:foodam/src/presentation/cubits/active_subscription_cubit/active_subscription_cubit.dart';
import 'package:foodam/src/presentation/cubits/auth_cubit/auth_cubit_cubit.dart';
import 'package:foodam/src/presentation/cubits/meal_distributaion/meal_distributaion_cubit.dart';
import 'package:foodam/src/presentation/cubits/meal_plan/meal_plan_cubit.dart';
import 'package:foodam/src/presentation/cubits/payment/payament_cubit.dart';
import 'package:foodam/src/presentation/cubits/payment_history/payment_history_cubit.dart';
import 'package:foodam/src/presentation/cubits/subscription_plan/subscription_plan_cubit.dart';
import 'package:foodam/src/presentation/cubits/susbcription_detail_cubit/subscription_detail_cubit.dart';
import 'package:foodam/src/presentation/cubits/thali_selection/thali_selection_cubit.dart';
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
      initWithMockData: true,
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
  // Auth use cases
  di.registerLazySingleton(() => LoginUseCase(di<AuthRepository>()));
  di.registerLazySingleton(() => RegisterUseCase(di<AuthRepository>()));
  di.registerLazySingleton(() => LogoutUseCase(di<AuthRepository>()));
  di.registerLazySingleton(() => IsLoggedInUseCase(di<AuthRepository>()));
  di.registerLazySingleton(() => GetCurrentUserUseCase(di<AuthRepository>()));
  
  // User use cases
  di.registerLazySingleton(() => GetUserDetailsUseCase(di<UserRepository>()));
  di.registerLazySingleton(() => GetUserAddressesUseCase(di<UserRepository>()));
  di.registerLazySingleton(() => AddAddressUseCase(di<UserRepository>()));
  
  // Package use cases
  di.registerLazySingleton(() => GetAllPackagesUseCase(di<PackageRepository>()));
  di.registerLazySingleton(() => GetPackageByIdUseCase(di<PackageRepository>()));
  
  // Meal use cases
  di.registerLazySingleton(() => GetMealByIdUseCase(di<MealRepository>()));
  
  // Subscription use cases
  di.registerLazySingleton(() => GetActiveSubscriptionsUseCase(di<SubscriptionRepository>()));
  di.registerLazySingleton(() => CreateSubscriptionUseCase(di<SubscriptionRepository>()));
  
  //! Cubits
  // Auth Cubits
  di.registerFactory(() => AuthCubit(
    loginUseCase: di<LoginUseCase>(),
    logoutUseCase: di<LogoutUseCase>(),
    isLoggedInUseCase: di<IsLoggedInUseCase>(),
    getCurrentUserUseCase: di<GetCurrentUserUseCase>(),
  ));
  
  // User Cubits
  di.registerFactory(() => UserProfileCubit(
    getUserDetailsUseCase: di<GetUserDetailsUseCase>(),
    getUserAddressesUseCase: di<GetUserAddressesUseCase>(),
    updateUserDetailsUseCase: di<UpdateUserDetailsUseCase>(),
    updateDietaryPreferencesUseCase: di<UpdateDietaryPreferencesUseCase>(),
  ));
  
  // Subscription Cubits
  di.registerFactory(() => ActiveSubscriptionsCubit(
    getActiveSubscriptionsUseCase: di<GetActiveSubscriptionsUseCase>(),
  ));
  
  di.registerFactory(() => SubscriptionPlansCubit(
    getSubscriptionPlansUseCase: di<GetSubscriptionPlansUseCase>(),
  ));
  
  di.registerFactory(() => SubscriptionDetailsCubit(
    getSubscriptionDetailsUseCase: di<GetSubscriptionDetailsUseCase>(),
    getMealOrdersBySubscriptionUseCase: di<GetMealOrdersBySubscriptionUseCase>(),
    pauseSubscriptionUseCase: di<PauseSubscriptionUseCase>(),
    resumeSubscriptionUseCase: di<ResumeSubscriptionUseCase>(),
    cancelSubscriptionUseCase: di<CancelSubscriptionUseCase>(),
  ));
  
  // Meal Cubits
  di.registerFactory(() => TodayMealsCubit(
    getTodayMealOrdersUseCase: di<GetTodayMealOrdersUseCase>(),
  ));
  
  di.registerFactory(() => MealPlanSelectionCubit());
  
  di.registerFactory(() => MealDistributionCubit());
  
  di.registerFactory(() => ThaliSelectionCubit(
    getAvailableMealsUseCase: di<GetAvailableMealsUseCase>(),
    getMealsByTypeUseCase: di<GetMealsByTypeUseCase>(),
  ));
  
  // Payment Cubits
  di.registerFactory(() => PaymentCubit(
    processPaymentUseCase: di<ProcessPaymentUseCase>(),
    getSubscriptionDetailsUseCase: di<GetSubscriptionDetailsUseCase>(),
  ));
  
  di.registerFactory(() => PaymentHistoryCubit(
    getPaymentHistoryUseCase: di<GetPaymentHistoryUseCase>(),
  ));
}