// lib/injection_container.dart
import 'package:flutter/foundation.dart';
import 'package:foodam/core/constants/app_constants.dart';
import 'package:foodam/core/network/network_info.dart';
import 'package:foodam/core/service/loggin_manager.dart';
import 'package:foodam/core/service/onboarding_service.dart';
import 'package:foodam/core/service/storage_service.dart';
import 'package:foodam/core/theme/theme_provider.dart';
import 'package:foodam/src/data/client/dio_api_client.dart';
import 'package:foodam/src/data/datasource/api_remote_data_source.dart';
import 'package:foodam/src/data/datasource/local_data_source.dart';
import 'package:foodam/src/data/datasource/meal_planning_data_source.dart';
import 'package:foodam/src/data/datasource/remote_data_source.dart';
import 'package:foodam/src/data/repo/auth_repo_impl.dart';
import 'package:foodam/src/data/repo/banner_repo_impl.dart';
import 'package:foodam/src/data/repo/calendar_repo_impl.dart';
import 'package:foodam/src/data/repo/meal_planning_repository_impl.dart';
import 'package:foodam/src/data/repo/meal_repo_impl.dart';
import 'package:foodam/src/data/repo/order_repo_impl.dart';
import 'package:foodam/src/data/repo/pacakge_repo_impl.dart';
import 'package:foodam/src/data/repo/paymetn_repo_impl.dart';
import 'package:foodam/src/data/repo/subscripton_repo_imp.dart';
import 'package:foodam/src/data/repo/user_repos_impl.dart';
import 'package:foodam/src/domain/repo/auth_repo.dart';
import 'package:foodam/src/domain/repo/banner_repo.dart';
import 'package:foodam/src/domain/repo/calendar_repo.dart';
import 'package:foodam/src/domain/repo/meal_planning_repository.dart';
import 'package:foodam/src/domain/repo/meal_rep.dart';
import 'package:foodam/src/domain/repo/order_repo.dart';
import 'package:foodam/src/domain/repo/package_repo.dart';
import 'package:foodam/src/domain/repo/payment_repo.dart';
import 'package:foodam/src/domain/repo/subscription_repo.dart';
import 'package:foodam/src/domain/repo/user_repo.dart';
import 'package:foodam/src/domain/usecase/auth_usecase.dart';
import 'package:foodam/src/domain/usecase/banner_usecase.dart';
import 'package:foodam/src/domain/usecase/calendar_usecase.dart';
import 'package:foodam/src/domain/usecase/meal_planning/create_subscription_use_case.dart';
import 'package:foodam/src/domain/usecase/meal_planning/get_calculated_plan_use_case.dart';
import 'package:foodam/src/domain/usecase/order_usecase.dart';
import 'package:foodam/src/domain/usecase/package_usecase.dart';
import 'package:foodam/src/domain/usecase/payment_usecase.dart';
import 'package:foodam/src/domain/usecase/susbcription_usecase.dart';
import 'package:foodam/src/domain/usecase/user_usecase.dart';
import 'package:foodam/src/presentation/cubits/auth_cubit/auth_cubit_cubit.dart';
import 'package:foodam/src/presentation/cubits/banner/banner_cubits.dart';
import 'package:foodam/src/presentation/cubits/checkout/checkout_cubit.dart';
import 'package:foodam/src/presentation/cubits/cloud_kitchen/cloud_kitchen_cubit.dart';
import 'package:foodam/src/presentation/cubits/meal_planning/meal_planning_cubit.dart';
import 'package:foodam/src/presentation/cubits/pacakge_cubits/pacakage_cubit.dart';
import 'package:foodam/src/presentation/cubits/payment/razor_pay_cubit/razor_pay_cubit/razor_pay_cubit_cubit.dart';
import 'package:foodam/src/presentation/cubits/payment_history/payment_cubit.dart';
import 'package:foodam/src/presentation/cubits/user_profile/user_profile_cubit.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

final di = GetIt.instance;

Future<void> init() async {
  try {
    // External Dependencies
    final sharedPreferences = await SharedPreferences.getInstance();
    di.registerLazySingleton(() => sharedPreferences);
    di.registerLazySingleton(() => InternetConnectionChecker.instance);

    // Core Services
    di.registerLazySingleton<NetworkInfo>(
      () => NetworkInfoImpl(di<InternetConnectionChecker>()),
    );
    di.registerLazySingleton<StorageService>(
      () => StorageService(di<SharedPreferences>()),
    );
    di.registerLazySingleton<ThemeProvider>(
      () => ThemeProvider(di<StorageService>()),
    );
    di.registerLazySingleton<OnboardingService>(
      () => OnboardingService(di<StorageService>()),
    );
    di.registerLazySingleton<LoggingManager>(() => LoggingManager());

    // API Client
    di.registerLazySingleton<DioApiClient>(
      () => DioApiClient(
        baseUrl: AppConstants.apiBaseUrl,
        localDataSource: di<LocalDataSource>(),
      ),
    );

    // Data Sources - Local
    di.registerLazySingleton<LocalDataSource>(
      () => LocalDataSourceImpl(storageService: di<StorageService>()),
    );

    // Data Sources - Remote
    di.registerLazySingleton<RemoteDataSource>(
      () => ApiRemoteDataSource(apiClient: di<DioApiClient>()),
    );
    di.registerLazySingleton<MealPlanningDataSource>(
      () => MealPlanningRemoteDataSource(apiClient: di<DioApiClient>()),
    );

    // Repositories
    di.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        remoteDataSource: di<RemoteDataSource>(),
        localDataSource: di<LocalDataSource>(),
      ),
    );
    di.registerLazySingleton<BannerRepository>(
      () => BannerRepositoryImpl(remoteDataSource: di<RemoteDataSource>()),
    );
    di.registerLazySingleton<UserRepository>(
      () => UserRepositoryImpl(remoteDataSource: di<RemoteDataSource>()),
    );
    di.registerLazySingleton<PackageRepository>(
      () => PackageRepositoryImpl(remoteDataSource: di<RemoteDataSource>()),
    );
    di.registerLazySingleton<MealRepository>(
      () => MealRepositoryImpl(
        remoteDataSource: di<RemoteDataSource>(),
        networkInfo: di<NetworkInfo>(),
      ),
    );
    di.registerLazySingleton<SubscriptionRepository>(
      () =>
          SubscriptionRepositoryImpl(remoteDataSource: di<RemoteDataSource>()),
    );
    di.registerLazySingleton<OrderRepository>(
      () => OrderRepositoryImpl(remoteDataSource: di<RemoteDataSource>()),
    );
    di.registerLazySingleton<PaymentRepository>(
      () => PaymentRepositoryImpl(remoteDataSource: di<RemoteDataSource>()),
    );
    di.registerLazySingleton<CalendarRepository>(
      () => CalendarRepositoryImpl(remoteDataSource: di<RemoteDataSource>()),
    );
    di.registerLazySingleton<MealPlanningRepository>(
      () => MealPlanningRepositoryImpl(
        remoteDataSource: di<MealPlanningDataSource>(),
      ),
    );

    // Use Cases - Auth
    di.registerFactory(() => AuthUseCase(di<AuthRepository>()));

    // Use Cases - User
    di.registerFactory(() => UserUseCase(di<UserRepository>()));

    // Use Cases - Package
    di.registerFactory(() => PackageUseCase(di<PackageRepository>()));

    // Use Cases - Subscription
    di.registerFactory(() => SubscriptionUseCase(di<SubscriptionRepository>()));

    // Use Cases - Order
    di.registerFactory(() => OrderUseCase(di<OrderRepository>()));

    // Use Cases - Payment
    di.registerFactory(() => PaymentUseCase(di<PaymentRepository>()));

    // Use Cases - Calendar
    di.registerFactory(() => CalendarUseCase(di<CalendarRepository>()));

    // Use Cases - Banner
    di.registerFactory(() => BannerUseCase(di<BannerRepository>()));

    // Use Cases - Meal Planning
    di.registerFactory(
      () => GetCalculatedPlanUseCase(di<MealPlanningRepository>()),
    );
    di.registerFactory(
      () => CreateSubscriptionUseCase(di<MealPlanningRepository>()),
    );

    // Cubits
    di.registerFactory(() => AuthCubit(authUseCase: di<AuthUseCase>()));
    di.registerFactory(() => UserProfileCubit(userUseCase: di<UserUseCase>()));
    di.registerFactory(
      () => PackageCubit(packageUseCase: di<PackageUseCase>()),
    );
    di.registerFactory(() => CloudKitchenCubit(apiClient: di<DioApiClient>()));
    di.registerLazySingleton(
      () => BannerCubit(bannerUseCase: di<BannerUseCase>()),
    );
    di.registerFactory(
      () => RazorpayPaymentCubit(apiClient: di<DioApiClient>()),
    );
    di.registerFactory(
      () => PaymentCubit(paymentUseCase: di<PaymentUseCase>()),
    );
    di.registerFactory(
      () => MealPlanningCubit(
        getCalculatedPlanUseCase: di<GetCalculatedPlanUseCase>(),
        createSubscriptionUseCase: di<CreateSubscriptionUseCase>(),
        logger: di<LoggingManager>(),
      ),
    );
    di.registerFactory(
      () => CheckoutCubit(userUseCase: di(), createSubscriptionUseCase: di()),
    );
  } catch (e, stackTrace) {
    debugPrint('Error during DI initialization: $e');
    debugPrint('Stack trace: $stackTrace');
    rethrow;
  }
}
