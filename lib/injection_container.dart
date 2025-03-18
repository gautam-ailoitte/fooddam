// lib/injection_container.dart
import 'package:foodam/src/data/repo/dish_repo_impl.dart';
import 'package:foodam/src/data/repo/meal_repo_impl.dart';
import 'package:foodam/src/data/repo/order_repo_impl.dart';
import 'package:foodam/src/data/repo/payment_repo_impl.dart';
import 'package:foodam/src/data/repo/subscription_repo_impl.dart';
import 'package:foodam/src/data/repo/user_repo_impl.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Core
import 'package:foodam/core/network/network_info.dart';

// Data sources
import 'package:foodam/src/data/datasource/local_data_source.dart';
import 'package:foodam/src/data/datasource/remote_data_source.dart';

// Repositories

import 'package:foodam/src/domain/repo/user_repo.dart';
import 'package:foodam/src/domain/repo/dish_repository.dart';
import 'package:foodam/src/domain/repo/meal_repo.dart';
import 'package:foodam/src/domain/repo/susbcription_repo.dart';
import 'package:foodam/src/domain/repo/order_repo.dart';
import 'package:foodam/src/domain/repo/payment_repo.dart';

// UseCases
// User UseCases
import 'package:foodam/src/domain/usecase/user/register_user_usecase.dart';
import 'package:foodam/src/domain/usecase/user/login_user_usecase.dart';
import 'package:foodam/src/domain/usecase/user/get_current_user_usecase.dart';
import 'package:foodam/src/domain/usecase/user/check_logged_in_usecase.dart';
import 'package:foodam/src/domain/usecase/user/update_profile_usecase.dart';
import 'package:foodam/src/domain/usecase/user/update_password_usecase.dart';
import 'package:foodam/src/domain/usecase/user/logout_usecase.dart';
import 'package:foodam/src/domain/usecase/user/add_address_usecase.dart';
import 'package:foodam/src/domain/usecase/user/get_user_addresses_usecase.dart';

// Dish UseCases
import 'package:foodam/src/domain/usecase/dish/get_dishes_usecase.dart';
import 'package:foodam/src/domain/usecase/dish/get_dish_by_id_usecase.dart';
import 'package:foodam/src/domain/usecase/dish/search_dishes_usecase.dart';
import 'package:foodam/src/domain/usecase/dish/get_dishes_by_ids_usecase.dart';
import 'package:foodam/src/domain/usecase/dish/get_dishes_by_category_usecase.dart';
import 'package:foodam/src/domain/usecase/dish/get_dishes_by_dietary_preference_usecase.dart';

// Meal UseCases
import 'package:foodam/src/domain/usecase/meal/get_meals_usecase.dart';
import 'package:foodam/src/domain/usecase/meal/get_meal_by_id_usecase.dart';
import 'package:foodam/src/domain/usecase/meal/search_meals_usecase.dart';
import 'package:foodam/src/domain/usecase/meal/get_meals_by_dietary_preference_usecase.dart';
import 'package:foodam/src/domain/usecase/meal/get_meals_by_dish_id_usecase.dart';
import 'package:foodam/src/domain/usecase/meal/get_meals_by_ids_usecase.dart';

// Subscription UseCases
import 'package:foodam/src/domain/usecase/subscription/get_available_subscriptions_usecase.dart';
import 'package:foodam/src/domain/usecase/subscription/get_active_subscription_usecase.dart';
import 'package:foodam/src/domain/usecase/subscription/create_subscription_usecase.dart';
import 'package:foodam/src/domain/usecase/subscription/customize_subscription_usecase.dart';
import 'package:foodam/src/domain/usecase/subscription/save_draft_subscription_usecase.dart';
import 'package:foodam/src/domain/usecase/subscription/get_draft_subscription_usecase.dart';
import 'package:foodam/src/domain/usecase/subscription/clear_draft_subscription_usecase.dart';
import 'package:foodam/src/domain/usecase/subscription/save_subscription_and_get_payment_url_usecase.dart';
import 'package:foodam/src/domain/usecase/subscription/pause_subscription_usecase.dart';
import 'package:foodam/src/domain/usecase/subscription/resume_subscription_usecase.dart';
import 'package:foodam/src/domain/usecase/subscription/cancel_subscription_usecase.dart';
import 'package:foodam/src/domain/usecase/subscription/renew_subscription_usecase.dart';
import 'package:foodam/src/domain/usecase/subscription/get_subscription_by_id_usecase.dart';
import 'package:foodam/src/domain/usecase/subscription/get_subscription_history_usecase.dart';

// Order UseCases
import 'package:foodam/src/domain/usecase/order/create_order_usecase.dart';
import 'package:foodam/src/domain/usecase/order/get_user_orders_usecase.dart';
import 'package:foodam/src/domain/usecase/order/get_order_by_id_usecase.dart';
import 'package:foodam/src/domain/usecase/order/update_order_status_usecase.dart';
import 'package:foodam/src/domain/usecase/order/cancel_order_usecase.dart';
import 'package:foodam/src/domain/usecase/order/get_upcoming_orders_usecase.dart';
import 'package:foodam/src/domain/usecase/order/get_order_history_usecase.dart';

// Payment UseCases
import 'package:foodam/src/domain/usecase/payment/process_payment_usecase.dart';
import 'package:foodam/src/domain/usecase/payment/verify_coupon_usecase.dart';
import 'package:foodam/src/domain/usecase/payment/get_payment_history_usecase.dart';
import 'package:foodam/src/domain/usecase/payment/get_payment_by_id_usecase.dart';
import 'package:foodam/src/domain/usecase/payment/request_refund_usecase.dart';

// Cubits (to be created in the next step)

final sl = GetIt.instance;

Future<void> init() async {
  //! Features
  
  //! UseCases
  // User
  sl.registerLazySingleton(() => RegisterUserUseCase(sl()));
  sl.registerLazySingleton(() => LoginUserUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => CheckLoggedInUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdatePasswordUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => AddAddressUseCase(sl()));
  sl.registerLazySingleton(() => GetUserAddressesUseCase(sl()));
  
  // Dish
  sl.registerLazySingleton(() => GetDishesUseCase(sl()));
  sl.registerLazySingleton(() => GetDishByIdUseCase(sl()));
  sl.registerLazySingleton(() => SearchDishesUseCase(sl()));
  sl.registerLazySingleton(() => GetDishesByIdsUseCase(sl()));
  sl.registerLazySingleton(() => GetDishesByCategoryUseCase(sl()));
  sl.registerLazySingleton(() => GetDishesByDietaryPreferenceUseCase(sl()));
  
  // Meal
  sl.registerLazySingleton(() => GetMealsUseCase(sl()));
  sl.registerLazySingleton(() => GetMealByIdUseCase(sl()));
  sl.registerLazySingleton(() => SearchMealsUseCase(sl()));
  sl.registerLazySingleton(() => GetMealsByDietaryPreferenceUseCase(sl()));
  sl.registerLazySingleton(() => GetMealsByDishIdUseCase(sl()));
  sl.registerLazySingleton(() => GetMealsByIdsUseCase(sl()));
  
  // Subscription
  sl.registerLazySingleton(() => GetAvailableSubscriptionsUseCase(sl()));
  sl.registerLazySingleton(() => GetActiveSubscriptionUseCase(sl()));
  sl.registerLazySingleton(() => CreateSubscriptionUseCase(sl()));
  sl.registerLazySingleton(() => CustomizeSubscriptionUseCase(sl()));
  sl.registerLazySingleton(() => SaveDraftSubscriptionUseCase(sl()));
  sl.registerLazySingleton(() => GetDraftSubscriptionUseCase(sl()));
  sl.registerLazySingleton(() => ClearDraftSubscriptionUseCase(sl()));
  sl.registerLazySingleton(() => SaveSubscriptionAndGetPaymentUrlUseCase(sl()));
  sl.registerLazySingleton(() => PauseSubscriptionUseCase(sl()));
  sl.registerLazySingleton(() => ResumeSubscriptionUseCase(sl()));
  sl.registerLazySingleton(() => CancelSubscriptionUseCase(sl()));
  sl.registerLazySingleton(() => RenewSubscriptionUseCase(sl()));
  sl.registerLazySingleton(() => GetSubscriptionByIdUseCase(sl()));
  sl.registerLazySingleton(() => GetSubscriptionHistoryUseCase(sl()));
  
  // Order
  sl.registerLazySingleton(() => CreateOrderUseCase(sl()));
  sl.registerLazySingleton(() => GetUserOrdersUseCase(sl()));
  sl.registerLazySingleton(() => GetOrderByIdUseCase(sl()));
  sl.registerLazySingleton(() => UpdateOrderStatusUseCase(sl()));
  sl.registerLazySingleton(() => CancelOrderUseCase(sl()));
  sl.registerLazySingleton(() => GetUpcomingOrdersUseCase(sl()));
  sl.registerLazySingleton(() => GetOrderHistoryUseCase(sl()));
  
  // Payment
  sl.registerLazySingleton(() => ProcessPaymentUseCase(sl()));
  sl.registerLazySingleton(() => VerifyCouponUseCase(sl()));
  sl.registerLazySingleton(() => GetPaymentHistoryUseCase(sl()));
  sl.registerLazySingleton(() => GetPaymentByIdUseCase(sl()));
  sl.registerLazySingleton(() => RequestRefundUseCase(sl()));
  
  //! Repositories
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  
  sl.registerLazySingleton<DishRepository>(
    () => DishRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  
  sl.registerLazySingleton<MealRepository>(
    () => MealRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  
  sl.registerLazySingleton<SubscriptionRepository>(
    () => SubscriptionRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  
  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  
  sl.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  
  //! Data sources
  sl.registerLazySingleton<RemoteDataSource>(
    () => RemoteDataSourceImpl(),
  );
  
  sl.registerLazySingleton<LocalDataSource>(
    () => LocalDataSourceImpl(
      sharedPreferences: sl(),
    ),
  );
  
  //! Core
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl()),
  );
  
  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());
  // sl.registerLazySingleton(() => InternetConnectionChecker());
}