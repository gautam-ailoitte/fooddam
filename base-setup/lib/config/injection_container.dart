import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:guardian_bubble/core/util/app_constant.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/component/custom_widget/custom_widget.dart';
import '../core/component/theme/app_theme.dart';
import '../core/network/network_info.dart';
import 'cache/db_provider.dart';
import 'my_shared_pref.dart';

final sl = GetIt.instance;

Future<void> init() async {
  /// Cubit

  /// Usecase

  /// Repository

  /// Data Source

  sl.registerLazySingleton<AppTheme>(() => AppTheme());
  sl.registerLazySingleton<CustomWidget>(() => CustomWidget());

  /// Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton<MySharedPref>(() => MySharedPref(sl()));

  /// initializing dio
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstant.baseApiUrl,
      connectTimeout: const Duration(milliseconds: 500000),
      receiveTimeout: const Duration(milliseconds: 500000),
      sendTimeout: const Duration(milliseconds: 500000),
    ),
  );
  dio.interceptors.add(
    LogInterceptor(
      request: true,
      responseHeader: true,
      logPrint: (value) => log(value.toString()),
      responseBody: true,
      requestBody: true,
      requestHeader: true,
      error: true,
    ),
  );

  ///Others

  final dbProvider = DBProvider();

  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  sl.registerLazySingleton<DBProvider>(() => dbProvider);

  sl.registerLazySingleton(() => InternetConnection());

  /// Client
}
