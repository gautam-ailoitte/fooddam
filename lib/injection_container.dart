// Updated lib/injection_container.dart
import 'package:foodam/src/data/datasource/remote_data_source.dart';
import 'package:foodam/src/data/repo/user_repo_impl.dart';
import 'package:foodam/src/presentation/cubits/active_plan_cubit/active_plan_cubit.dart';
import 'package:foodam/src/presentation/cubits/auth_cubit/auth_cubits.dart';
import 'package:foodam/src/presentation/cubits/draft_plan_cubit/draft_plan_cubit.dart';
import 'package:foodam/src/presentation/cubits/meal_customization_cubit/meal_customization_cubit.dart';
import 'package:foodam/src/presentation/cubits/plan_browse_cubit/plan_browse_cubit.dart';
import 'package:foodam/src/presentation/cubits/plan_customization_cubit/plan_customization_cubit.dart';
import 'package:foodam/src/presentation/payment_cubit/payment_cubit.dart';
import 'package:foodam/src/presentation/utlis/thali_customization_manager.dart';
import 'package:foodam/src/domain/repo/user_repo.dart';
import 'package:foodam/src/presentation/cubits/thali_selection_subit/thali_selection_cubit.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_constants.dart';
import 'core/network/api_client.dart';
import 'core/network/network_info.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Auth
  // Bloc
  sl.registerFactory(() => AuthCubit(authRepository: sl()));

  // Plan management cubits (split by responsibility)
  sl.registerFactory(() => ActivePlanCubit(planRepository: sl()));
  sl.registerFactory(() => DraftPlanCubit(planRepository: sl()));
  sl.registerFactory(() => PlanBrowseCubit(planRepository: sl()));
  sl.registerLazySingleton(
    () => PlanCustomizationCubit(
      planRepository: sl(),
      draftCubit: sl(),
      mealRepository: sl(),
    ),
  );
  sl.registerFactory(() => PaymentCubit(planRepository: sl()));

  // Existing cubits for meal and thali
  sl.registerFactory(() => ThaliSelectionCubit(mealRepository: sl()));
  sl.registerFactory(() => MealCustomizationCubit(mealRepository: sl()));

  //! Utility Managers
  sl.registerLazySingleton<ThaliCustomizationManager>(
    () => ThaliCustomizationManager(),
  );

  //! Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<MealRepository>(
    () => MealRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<PlanRepository>(
    () => PlanRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  //! Data sources
  sl.registerLazySingleton<RemoteDataSource>(
    () => RemoteDataSourceImpl(client: sl()),
  );

  sl.registerLazySingleton<LocalDataSource>(
    () => LocalDataSourceImpl(sharedPreferences: sl()),
  );

  //! Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  sl.registerLazySingleton(
    () => ApiClient(
      httpClient: sl(),
      sharedPreferences: sl(),
      baseUrl: AppConstants.apiBaseUrl,
    ),
  );

  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => InternetConnectionChecker.createInstance());
}
