// lib/injection_container.dart (UPDATED - REMOVED MealSelectionService)
import 'package:flutter/foundation.dart';
import 'package:foodam/core/constants/app_constants.dart';
import 'package:foodam/core/network/network_info.dart';
import 'package:foodam/core/service/onboarding_service.dart';
import 'package:foodam/core/service/storage_service.dart';
import 'package:foodam/core/theme/theme_provider.dart';
import 'package:foodam/src/data/client/dio_api_client.dart';
import 'package:foodam/src/data/datasource/api_remote_data_source.dart';
import 'package:foodam/src/data/datasource/local_data_source.dart';
import 'package:foodam/src/data/datasource/remote_data_source.dart';
import 'package:foodam/src/data/repo/auth_repo_impl.dart';
import 'package:foodam/src/data/repo/banner_repo_impl.dart';
import 'package:foodam/src/data/repo/calendar_repo_impl.dart';
import 'package:foodam/src/data/repo/meal_repo_impl.dart';
import 'package:foodam/src/data/repo/pacakge_repo_impl.dart';
import 'package:foodam/src/data/repo/paymetn_repo_impl.dart';
import 'package:foodam/src/data/repo/subscripton_repo_imp.dart';
import 'package:foodam/src/data/repo/user_repos_impl.dart';
import 'package:foodam/src/domain/repo/auth_repo.dart';
import 'package:foodam/src/domain/repo/banner_repo.dart';
import 'package:foodam/src/domain/repo/calendar_repo.dart';
import 'package:foodam/src/domain/repo/meal_rep.dart';
import 'package:foodam/src/domain/repo/package_repo.dart';
import 'package:foodam/src/domain/repo/payment_repo.dart';
import 'package:foodam/src/domain/repo/subscription_repo.dart';
import 'package:foodam/src/domain/repo/user_repo.dart';
import 'package:foodam/src/domain/services/subscription_service.dart';
import 'package:foodam/src/domain/services/week_data_service.dart';
import 'package:foodam/src/domain/usecase/auth_usecase.dart';
import 'package:foodam/src/domain/usecase/banner_usecase.dart';
import 'package:foodam/src/domain/usecase/calendar_usecase.dart';
import 'package:foodam/src/domain/usecase/package_usecase.dart';
import 'package:foodam/src/domain/usecase/payment_usecase.dart';
import 'package:foodam/src/domain/usecase/susbcription_usecase.dart';
import 'package:foodam/src/domain/usecase/user_usecase.dart';
import 'package:foodam/src/presentation/cubits/auth_cubit/auth_cubit_cubit.dart';
import 'package:foodam/src/presentation/cubits/banner/banner_cubits.dart';
import 'package:foodam/src/presentation/cubits/cloud_kitchen/cloud_kitchen_cubit.dart';
import 'package:foodam/src/presentation/cubits/pacakge_cubits/pacakage_cubit.dart';
import 'package:foodam/src/presentation/cubits/payment/razor_pay_cubit/razor_pay_cubit/razor_pay_cubit_cubit.dart';
import 'package:foodam/src/presentation/cubits/payment_history/payment_cubit.dart';
import 'package:foodam/src/presentation/cubits/subscription/create_subcription/create_subcription_cubit.dart';
import 'package:foodam/src/presentation/cubits/subscription/planning/subscription_planning_cubit.dart';
import 'package:foodam/src/presentation/cubits/subscription/subscription/subscription_details_cubit.dart';
import 'package:foodam/src/presentation/cubits/user_profile/user_profile_cubit.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

final di = GetIt.instance;

// Development flags - kept but not actively used for mock data
const bool USE_MOCK_DATA = false;
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
    if (!_registeredTypes.contains(ThemeProvider)) {
      di.registerLazySingleton<ThemeProvider>(
        () => ThemeProvider(di<StorageService>()),
      );
      _registeredTypes.add(ThemeProvider);
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
    di.registerLazySingleton<OnboardingService>(
      () => OnboardingService(di<StorageService>()),
    );

    if (!_registeredTypes.contains(StorageService)) {
      di.registerLazySingleton<StorageService>(
        () => StorageService(di<SharedPreferences>()),
      );
      _registeredTypes.add(StorageService);
    }

    // Update ApiClient to use Dio
    if (!_registeredTypes.contains(DioApiClient)) {
      di.registerLazySingleton<DioApiClient>(
        () => DioApiClient(
          baseUrl: AppConstants.apiBaseUrl,
          localDataSource: di<LocalDataSource>(),
        ),
      );
      _registeredTypes.add(DioApiClient);
    }

    //! Data sources
    if (!_registeredTypes.contains(RemoteDataSource)) {
      di.registerLazySingleton<RemoteDataSource>(
        () => ApiRemoteDataSource(apiClient: di<DioApiClient>()),
      );
      _registeredTypes.add(RemoteDataSource);
    }

    if (!_registeredTypes.contains(LocalDataSource)) {
      di.registerLazySingleton<LocalDataSource>(
        () => LocalDataSourceImpl(storageService: di<StorageService>()),
      );
      _registeredTypes.add(LocalDataSource);
    }

    //! Repositories
    if (!_registeredTypes.contains(AuthRepository)) {
      di.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(
          remoteDataSource: di<RemoteDataSource>(),
          localDataSource: di<LocalDataSource>(),
        ),
      );
      _registeredTypes.add(AuthRepository);
    }
    if (!_registeredTypes.contains(BannerRepository)) {
      di.registerLazySingleton<BannerRepository>(
        () => BannerRepositoryImpl(remoteDataSource: di<RemoteDataSource>()),
      );
      _registeredTypes.add(BannerRepository);
    }

    if (!_registeredTypes.contains(UserRepository)) {
      di.registerLazySingleton<UserRepository>(
        () => UserRepositoryImpl(
          remoteDataSource: di<RemoteDataSource>(),
          localDataSource: di<LocalDataSource>(),
        ),
      );
      _registeredTypes.add(UserRepository);
    }

    if (!_registeredTypes.contains(PackageRepository)) {
      di.registerLazySingleton<PackageRepository>(
        () => PackageRepositoryImpl(remoteDataSource: di<RemoteDataSource>()),
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
        ),
      );
      _registeredTypes.add(SubscriptionRepository);
    }

    if (!_registeredTypes.contains(PaymentRepository)) {
      di.registerLazySingleton<PaymentRepository>(
        () => PaymentRepositoryImpl(remoteDataSource: di<RemoteDataSource>()),
      );
      _registeredTypes.add(PaymentRepository);
    }

    //! Use cases
    if (!_registeredTypes.contains(CalendarRepository)) {
      di.registerLazySingleton<CalendarRepository>(
        () => CalendarRepositoryImpl(remoteDataSource: di<RemoteDataSource>()),
      );
      _registeredTypes.add(CalendarRepository);
    }

    if (!_registeredTypes.contains(CalendarUseCase)) {
      di.registerLazySingleton(() => CalendarUseCase(di<CalendarRepository>()));
      _registeredTypes.add(CalendarUseCase);
    }

    if (!_registeredTypes.contains(AuthUseCase)) {
      di.registerLazySingleton(() => AuthUseCase(di<AuthRepository>()));
      _registeredTypes.add(AuthUseCase);
    }
    if (!_registeredTypes.contains(BannerUseCase)) {
      di.registerLazySingleton(() => BannerUseCase(di<BannerRepository>()));
      _registeredTypes.add(BannerUseCase);
    }

    if (!_registeredTypes.contains(UserUseCase)) {
      di.registerLazySingleton(() => UserUseCase(di<UserRepository>()));
      _registeredTypes.add(UserUseCase);
    }

    if (!_registeredTypes.contains(PackageUseCase)) {
      di.registerLazySingleton(() => PackageUseCase(di<PackageRepository>()));
      _registeredTypes.add(PackageUseCase);
    }

    // UPDATED: Subscription use case
    if (!_registeredTypes.contains(SubscriptionUseCase)) {
      di.registerLazySingleton(
        () => SubscriptionUseCase(di<SubscriptionRepository>()),
      );
      _registeredTypes.add(SubscriptionUseCase);
    }

    if (!_registeredTypes.contains(PaymentUseCase)) {
      di.registerLazySingleton(() => PaymentUseCase(di<PaymentRepository>()));
      _registeredTypes.add(PaymentUseCase);
    }

    //! Services
    if (!_registeredTypes.contains(WeekDataService)) {
      di.registerLazySingleton<WeekDataService>(
        () => WeekDataService(calendarUseCase: di<CalendarUseCase>()),
      );
      _registeredTypes.add(WeekDataService);
    }

    if (!_registeredTypes.contains(SubscriptionService)) {
      di.registerLazySingleton<SubscriptionService>(
        () => SubscriptionService(remoteDataSource: di<RemoteDataSource>()),
      );
      _registeredTypes.add(SubscriptionService);
    }

    // 🔥 REMOVED: MealSelectionService registration
    // Selection management is now handled directly in SubscriptionPlanningCubit

    //! Cubits
    if (!_registeredTypes.contains(AuthCubit)) {
      di.registerFactory(() => AuthCubit(authUseCase: di<AuthUseCase>()));
      _registeredTypes.add(AuthCubit);
    }

    if (!_registeredTypes.contains(UserProfileCubit)) {
      di.registerFactory(
        () => UserProfileCubit(userUseCase: di<UserUseCase>()),
      );
      _registeredTypes.add(UserProfileCubit);
    }

    if (!_registeredTypes.contains(PackageCubit)) {
      di.registerFactory(
        () => PackageCubit(packageUseCase: di<PackageUseCase>()),
      );
      _registeredTypes.add(PackageCubit);
    }

    if (!_registeredTypes.contains(CloudKitchenCubit)) {
      di.registerFactory(
        () => CloudKitchenCubit(apiClient: di<DioApiClient>()),
      );
      _registeredTypes.add(CloudKitchenCubit);
    }

    // UPDATED: Subscription Cubit
    if (!_registeredTypes.contains(SubscriptionCubit)) {
      di.registerFactory(
        () => SubscriptionCubit(subscriptionUseCase: di<SubscriptionUseCase>()),
      );
      _registeredTypes.add(SubscriptionCubit);
    }

    if (!_registeredTypes.contains(SubscriptionCreationCubit)) {
      di.registerFactory(
        () => SubscriptionCreationCubit(
          subscriptionUseCase: di<SubscriptionUseCase>(),
          calendarUseCase: di<CalendarUseCase>(),
        ),
      );
      _registeredTypes.add(SubscriptionCreationCubit);
    }
    if (!_registeredTypes.contains(BannerCubit)) {
      di.registerLazySingleton(
        () => BannerCubit(bannerUseCase: di<BannerUseCase>()),
      );
      _registeredTypes.add(BannerCubit);
    }
    if (!_registeredTypes.contains(RazorpayPaymentCubit)) {
      di.registerFactory(
        () => RazorpayPaymentCubit(apiClient: di<DioApiClient>()),
      );
      _registeredTypes.add(RazorpayPaymentCubit);
    }

    // 🔥 UPDATED: Enhanced SubscriptionPlanningCubit with selection management
    if (!_registeredTypes.contains(SubscriptionPlanningCubit)) {
      di.registerFactory(
        () => SubscriptionPlanningCubit(
          weekDataService: di<WeekDataService>(),
          subscriptionService: di<SubscriptionService>(),
        ),
      );
      _registeredTypes.add(SubscriptionPlanningCubit);
    }

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
