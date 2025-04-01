import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:guardian_bubble/core/util/app_constant.dart';

import '../../feature/data/data_source/local_data_source/local_data_source.dart';

extension RequestOptionsFunction on RequestOptions {
  Future<RequestOptions> addRequestOptions(
    final LocalDataSource localDataSource, {
    String? token,
  }) async {
    final accessToken = token ?? localDataSource.getAccessToken() ?? '';
    log(accessToken, name: "Bearer");
    if (accessToken.isNotEmpty) {
      headers[AppConstant.authorization] = "Bearer $accessToken";
    }
    return this;
  }
}
