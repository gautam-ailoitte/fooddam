import 'package:dio/dio.dart';
import 'package:guardian_bubble/core/extension/custom_ext.dart';
import 'package:guardian_bubble/core/extension/dio_error.dart';
import 'package:guardian_bubble/core/util/app_constant.dart';
import 'package:retrofit/retrofit.dart';

import '../data_source/local_data_source/local_data_source.dart';

part 'auth_client.g.dart';

/// Use below command to generate
/// dart run build_runner build --delete-conflicting-outputs

@RestApi()
abstract class AuthClient {
  factory AuthClient(
    final Dio dio,
    final LocalDataSource localDataSource,
  ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          options.addRequestOptions(localDataSource);
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          e.printErrorPath();
          return handler.next(e);
        },
      ),
    );
    return _AuthClient(
      dio,
      baseUrl: AppConstant.baseApiUrl,
    );
  }

  // @POST(EndpointConstants.endpointUserLogin)
  // Future<LoginModel> login(
  //   @Body() final Map<String, dynamic> body,
  // );
}
