// lib/src/data/datasource/meal_planning_data_source.dart

import 'package:foodam/core/errors/execption.dart';
import 'package:foodam/src/data/client/dio_api_client.dart';
import 'package:foodam/src/data/model/meal_planning/calculated_plan_model.dart';
import 'package:foodam/src/data/model/meal_planning/subscription_request_model.dart';

abstract class MealPlanningDataSource {
  Future<CalculatedPlanModel> getCalculatedPlan({
    required String dietaryPreference,
    required int week,
    required DateTime startDate,
  });

  Future<SubscriptionResponseModel> createSubscription({
    required SubscriptionRequestModel request,
  });
}

class MealPlanningRemoteDataSource implements MealPlanningDataSource {
  final DioApiClient apiClient;

  MealPlanningRemoteDataSource({required this.apiClient});

  @override
  Future<CalculatedPlanModel> getCalculatedPlan({
    required String dietaryPreference,
    required int week,
    required DateTime startDate,
  }) async {
    try {
      final queryParams = {
        'dietaryPreference': dietaryPreference,
        'week': week.toString(),
        'startDate': startDate.toIso8601String().split('T').first,
      };

      final response = await apiClient.get(
        '/api/calendars/calculated-plan',
        queryParameters: queryParams,
      );

      if (response['status'] != 'success' || !response.containsKey('data')) {
        throw ServerException('Invalid calculated plan response format');
      }

      return CalculatedPlanModel.fromJson(response['data']);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to fetch calculated plan: ${e.toString()}');
    }
  }

  @override
  Future<SubscriptionResponseModel> createSubscription({
    required SubscriptionRequestModel request,
  }) async {
    try {
      final response = await apiClient.post(
        '/subscriptions',
        body: request.toJson(),
      );

      if (response['status'] != 'success' || !response.containsKey('data')) {
        throw ServerException('Invalid subscription creation response format');
      }

      final responseData = response['data'];
      return SubscriptionResponseModel(
        id: responseData['id']?.toString(),
        status: response['status']?.toString(),
        message: response['message']?.toString(),
        createdAt:
            responseData['createdAt'] != null
                ? DateTime.tryParse(responseData['createdAt'].toString())
                : DateTime.now(),
        totalAmount: responseData['totalAmount']?.toDouble(),
        additionalData:
            responseData is Map<String, dynamic> ? responseData : null,
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to create subscription: ${e.toString()}');
    }
  }
}
