// lib/injection_container.dart
import 'package:foodam/src/data/datasource/local_data_source.dart';
import 'package:foodam/src/data/datasource/remote_data_source.dart';
import 'package:foodam/src/data/repo/auth_repo_impl.dart';
import 'package:foodam/src/data/repo/meal_repo_impl.dart';
import 'package:foodam/src/data/repo/plan_repo_impl.dart';
import 'package:foodam/src/domain/repo/auth_repository.dart';
import 'package:foodam/src/domain/repo/meal_repository.dart';
import 'package:foodam/src/domain/repo/plan_repo.dart';
import 'package:foodam/src/domain/usecase/auth/check_auth_status_usecase.dart';
import 'package:foodam/src/domain/usecase/auth/login_usecase.dart';
import 'package:foodam/src/domain/usecase/auth/logout_usecase.dart';
import 'package:foodam/src/domain/usecase/meal/customize_thali_usecase.dart';
import 'package:foodam/src/domain/usecase/meal/get_meal_option_usecase.dart';
import 'package:foodam/src/domain/usecase/payment/complete_payment_usecase.dart';
import 'package:foodam/src/domain/usecase/payment/initate_payment_usecase.dart';
import 'package:foodam/src/domain/usecase/plan/clear_draft_plan_usecase.dart';
import 'package:foodam/src/domain/usecase/plan/create_plan_usecase.dart';
import 'package:foodam/src/domain/usecase/plan/customize_plan_usecase.dart';
import 'package:foodam/src/domain/usecase/plan/get_active_plan_usecase.dart';
import 'package:foodam/src/domain/usecase/plan/get_available_plan_usecase.dart';
import 'package:foodam/src/domain/usecase/plan/get_draft_plan_usecase.dart';
import 'package:foodam/src/domain/usecase/plan/save_draft_plan_usecase.dart';
import 'package:foodam/src/domain/usecase/thali/get_thali_option_usecase.dart';
import 'package:foodam/src/domain/usecase/thali/select_thali_usecase.dart';
import 'package:foodam/src/presentation/cubits/active_plan_cubit/active_plan_cubit.dart';
import 'package:foodam/src/presentation/cubits/auth_cubit/auth_cubits.dart';
import 'package:foodam/src/presentation/cubits/draft_plan_cubit/draft_plan_cubit.dart';
import 'package:foodam/src/presentation/cubits/meal_customization_cubit/meal_customization_cubit.dart';
import 'package:foodam/src/presentation/cubits/plan_browse_cubit/plan_browse_cubit.dart';
import 'package:foodam/src/presentation/cubits/plan_customization_cubit/plan_customization_cubit.dart';
import 'package:foodam/src/presentation/cubits/thali_customization_cubit/thali_cutomization_cubit.dart';
import 'package:foodam/src/presentation/cubits/thali_selection_subit/thali_selection_cubit.dart';
import 'package:foodam/src/presentation/payment_cubit/payment_cubit.dart';
import 'package:foodam/src/presentation/utlis/thali_customization_manager.dart';
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
  // Cubits
  sl.registerFactory(
    () => AuthCubit(
      checkAuthStatusUseCase: sl(),
      loginUseCase: sl(),
      logoutUseCase: sl(),
    ),
  );

  // Plan management cubits
  sl.registerFactory(() => ActivePlanCubit(getActivePlanUseCase: sl()));

  sl.registerFactory(
    () => DraftPlanCubit(
      getDraftPlanUseCase: sl(),
      saveDraftPlanUseCase: sl(),
      clearDraftPlanUseCase: sl(),
    ),
  );

  sl.registerFactory(() => PlanBrowseCubit(getAvailablePlansUseCase: sl()));

  sl.registerLazySingleton(
    () => PlanCustomizationCubit(
      createPlanUseCase: sl(),
      customizePlanUseCase: sl(),
      draftCubit: sl(),
    ),
  );

  sl.registerFactory(
    () => PaymentCubit(
      initiatePaymentUseCase: sl(),
      completePaymentUseCase: sl(),
    ),
  );

  // Register ThaliCustomizationCubit
  sl.registerFactory(
    () => ThaliCustomizationCubit(
      getMealOptionsUseCase: sl(),
      customizeThaliUseCase: sl(),
    ),
  );
  sl.registerFactory(() => ThaliSelectionCubit(getThaliOptionsUseCase: sl()));

  sl.registerFactory(
    () => MealCustomizationCubit(
      getMealOptionsUseCase: sl(),
      customizeThaliUseCase: sl(),
    ),
  );

  //! Utility Managers
  sl.registerLazySingleton<ThaliCustomizationManager>(
    () => ThaliCustomizationManager(),
  );

  //! Use Cases
  // Auth use cases
  sl.registerLazySingleton(() => CheckAuthStatusUseCase(authRepository: sl()));

  sl.registerLazySingleton(() => LoginUseCase(authRepository: sl()));

  sl.registerLazySingleton(() => LogoutUseCase(authRepository: sl()));

  // Plan use cases
  sl.registerLazySingleton(() => GetActivePlanUseCase(planRepository: sl()));

  sl.registerLazySingleton(
    () => GetAvailablePlansUseCase(planRepository: sl()),
  );

  sl.registerLazySingleton(() => GetDraftPlanUseCase(planRepository: sl()));

  sl.registerLazySingleton(() => SaveDraftPlanUseCase(planRepository: sl()));

  sl.registerLazySingleton(() => ClearDraftPlanUseCase(planRepository: sl()));

  sl.registerLazySingleton(() => CreatePlanUseCase(planRepository: sl()));

  sl.registerLazySingleton(() => CustomizePlanUseCase(planRepository: sl()));

  // Meal and Thali use cases
  sl.registerLazySingleton(() => GetMealOptionsUseCase(mealRepository: sl()));

  sl.registerLazySingleton(() => CustomizeThaliUseCase(mealRepository: sl()));

  sl.registerLazySingleton(() => GetThaliOptionsUseCase(mealRepository: sl()));
  // Register SelectThaliUseCase
  sl.registerLazySingleton(() => SelectThaliUseCase(mealRepository: sl()));
  // Payment use cases
  sl.registerLazySingleton(() => InitiatePaymentUseCase(planRepository: sl()));

  sl.registerLazySingleton(() => CompletePaymentUseCase(planRepository: sl()));

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
