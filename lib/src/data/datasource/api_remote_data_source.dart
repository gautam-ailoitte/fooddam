// lib/src/data/datasource/api_remote_data_source.dart
import 'package:dio/dio.dart';
import 'package:foodam/core/constants/app_constants.dart';
import 'package:foodam/core/errors/execption.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/data/client/dio_api_client.dart';
import 'package:foodam/src/data/datasource/remote_data_source.dart';
import 'package:foodam/src/data/model/dish_model.dart';
import 'package:foodam/src/data/model/meal_model.dart';
import 'package:foodam/src/data/model/meal_slot_model.dart';
import 'package:foodam/src/data/model/package_model.dart';
import 'package:foodam/src/data/model/subscription_model.dart';
import 'package:foodam/src/data/model/user_model.dart';

class ApiRemoteDataSource implements RemoteDataSource {
  final DioApiClient _apiClient;
  final LoggerService _logger = LoggerService();

  ApiRemoteDataSource({required DioApiClient apiClient})
    : _apiClient = apiClient;

  // AUTH METHODS
  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        AppConstants.loginEndpoint,
        body: {'email': email, 'password': password},
      );

      if (response['status'] != 'success' ||
          !response.containsKey('data') ||
          !response['data'].containsKey('token')) {
        throw ServerException('Invalid login response format');
      }

      return response['data'];
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        // Check if this is due to unverified email
        if (e.response?.data is Map &&
            (e.response?.data as Map).containsKey('message') &&
            (e.response?.data as Map)['message'].toString().contains(
              'not verified',
            )) {
          throw EmailNotVerifiedException();
        }

        throw InvalidCredentialsException('Invalid email or password');
      }
      _logger.e('Login error', error: e, tag: 'ApiRemoteDataSource');
      throw ServerException('Failed to login: ${e.message}');
    } catch (e) {
      if (e is AppException) rethrow;
      _logger.e('Unexpected login error', error: e, tag: 'ApiRemoteDataSource');
      throw ServerException('An unexpected error occurred during login');
    }
  }

  @override
  Future<Map<String, dynamic>> register(
    String email,
    String password,
    String phone,
  ) async {
    try {
      final response = await _apiClient.post(
        AppConstants.registerEndpoint,
        body: {'email': email, 'password': password, 'phone': phone},
      );

      if (response['status'] != 'success') {
        throw ServerException('Invalid registration response format');
      }

      return response['data'] ??
          {'message': 'Registration successful! Please verify your email.'};
    } on DioException catch (e) {
      if (e.response?.statusCode == 400 &&
          e.response?.data is Map &&
          (e.response?.data as Map).containsKey('message') &&
          (e.response?.data as Map)['message'].toString().contains(
            'already exists',
          )) {
        throw UserAlreadyExistsException();
      }
      _logger.e('Registration error', error: e, tag: 'ApiRemoteDataSource');
      throw ServerException('Failed to register: ${e.message}');
    } catch (e) {
      if (e is AppException) rethrow;
      _logger.e(
        'Unexpected registration error',
        error: e,
        tag: 'ApiRemoteDataSource',
      );
      throw ServerException('An unexpected error occurred during registration');
    }
  }

  @override
  Future<Map<String, dynamic>> registerWithMobile(
    String mobile,
    String password,
  ) async {
    try {
      final response = await _apiClient.post(
        '/api/auth/register-mobile',
        body: {'mobile': mobile, 'password': password},
      );

      if (response['status'] != 'success') {
        throw ServerException('Invalid mobile registration response format');
      }

      return response['data'] ??
          {'message': 'OTP sent to your mobile for verification'};
    } on DioException catch (e) {
      if (e.response?.statusCode == 400 &&
          e.response?.data is Map &&
          (e.response?.data as Map).containsKey('message') &&
          (e.response?.data as Map)['message'].toString().contains(
            'already exists',
          )) {
        throw UserAlreadyExistsException();
      }
      _logger.e(
        'Mobile registration error',
        error: e,
        tag: 'ApiRemoteDataSource',
      );
      throw ServerException('Failed to register with mobile: ${e.message}');
    } catch (e) {
      if (e is AppException) rethrow;
      _logger.e(
        'Unexpected mobile registration error',
        error: e,
        tag: 'ApiRemoteDataSource',
      );
      throw ServerException(
        'An unexpected error occurred during mobile registration',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> requestLoginOTP(String mobile) async {
    try {
      final response = await _apiClient.post(
        '/api/auth/request-otp',
        body: {'mobile': mobile},
      );

      if (response['status'] != 'success') {
        throw ServerException('Invalid OTP request response format');
      }

      return response['data'] ?? {'message': 'OTP sent to your mobile number'};
    } on DioException catch (e) {
      _logger.e('OTP request error', error: e, tag: 'ApiRemoteDataSource');
      throw ServerException('Failed to request OTP: ${e.message}');
    } catch (e) {
      if (e is AppException) rethrow;
      _logger.e(
        'Unexpected OTP request error',
        error: e,
        tag: 'ApiRemoteDataSource',
      );
      throw ServerException('An unexpected error occurred during OTP request');
    }
  }

  @override
  Future<Map<String, dynamic>> verifyLoginOTP(String mobile, String otp) async {
    try {
      final response = await _apiClient.post(
        '/api/auth/verify-otp',
        body: {'mobile': mobile, 'otp': otp},
      );

      if (response['status'] != 'success' ||
          !response.containsKey('data') ||
          !response['data'].containsKey('token')) {
        throw ServerException('Invalid OTP verification response format');
      }

      return response['data'];
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw InvalidOTPException('Invalid OTP');
      }
      _logger.e('OTP verification error', error: e, tag: 'ApiRemoteDataSource');
      throw ServerException('Failed to verify OTP: ${e.message}');
    } catch (e) {
      if (e is AppException) rethrow;
      _logger.e(
        'Unexpected OTP verification error',
        error: e,
        tag: 'ApiRemoteDataSource',
      );
      throw ServerException(
        'An unexpected error occurred during OTP verification',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> verifyMobileOTP(
    String mobile,
    String otp,
  ) async {
    try {
      final response = await _apiClient.post(
        '/api/auth/verify-mobile',
        body: {'mobile': mobile, 'otp': otp},
      );

      if (response['status'] != 'success' ||
          !response.containsKey('data') ||
          !response['data'].containsKey('token')) {
        throw ServerException('Invalid mobile verification response format');
      }

      return response['data'];
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw InvalidOTPException('Invalid OTP');
      }
      _logger.e(
        'Mobile verification error',
        error: e,
        tag: 'ApiRemoteDataSource',
      );
      throw ServerException('Failed to verify mobile: ${e.message}');
    } catch (e) {
      if (e is AppException) rethrow;
      _logger.e(
        'Unexpected mobile verification error',
        error: e,
        tag: 'ApiRemoteDataSource',
      );
      throw ServerException(
        'An unexpected error occurred during mobile verification',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    try {
      final response = await _apiClient.post(
        '/api/auth/refresh-token',
        body: {'refreshToken': refreshToken},
      );

      if (response['status'] != 'success' ||
          !response.containsKey('data') ||
          !response['data'].containsKey('token')) {
        throw ServerException('Invalid refresh token response format');
      }

      return response['data'];
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw InvalidTokenException('Invalid or expired refresh token');
      }
      _logger.e('Refresh token error', error: e, tag: 'ApiRemoteDataSource');
      throw ServerException('Failed to refresh token: ${e.message}');
    } catch (e) {
      if (e is AppException) rethrow;
      _logger.e(
        'Unexpected refresh token error',
        error: e,
        tag: 'ApiRemoteDataSource',
      );
      throw ServerException(
        'An unexpected error occurred during token refresh',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> validateToken(String token) async {
    try {
      final response = await _apiClient.post(
        '/api/auth/validate-token',
        body: {'token': token},
      );

      return response['data'] ?? {'valid': false};
    } on DioException catch (e) {
      _logger.e('Validate token error', error: e, tag: 'ApiRemoteDataSource');
      throw ServerException('Failed to validate token: ${e.message}');
    } catch (e) {
      if (e is AppException) rethrow;
      _logger.e(
        'Unexpected validate token error',
        error: e,
        tag: 'ApiRemoteDataSource',
      );
      throw ServerException(
        'An unexpected error occurred during token validation',
      );
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _apiClient.post('/api/auth/logout');
    } catch (e) {
      // We'll still clear the local token even if server logout fails
      _logger.w(
        'Logout from server failed, but continuing with local logout',
        tag: 'ApiRemoteDataSource',
      );
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await _apiClient.post(
        '/api/auth/forgot-password',
        body: {'email': email},
      );
    } on DioException catch (e) {
      _logger.e('Forgot password error', error: e, tag: 'ApiRemoteDataSource');
      throw ServerException(
        'Failed to process forgot password request: ${e.message}',
      );
    } catch (e) {
      if (e is AppException) rethrow;
      _logger.e(
        'Unexpected forgot password error',
        error: e,
        tag: 'ApiRemoteDataSource',
      );
      throw ServerException(
        'An unexpected error occurred during forgot password request',
      );
    }
  }

  @override
  Future<void> resetPassword(String token, String newPassword) async {
    try {
      await _apiClient.post(
        '/api/auth/reset-password',
        body: {'token': token, 'password': newPassword},
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw InvalidTokenException('Invalid or expired reset token');
      }
      _logger.e('Reset password error', error: e, tag: 'ApiRemoteDataSource');
      throw ServerException('Failed to reset password: ${e.message}');
    } catch (e) {
      if (e is AppException) rethrow;
      _logger.e(
        'Unexpected reset password error',
        error: e,
        tag: 'ApiRemoteDataSource',
      );
      throw ServerException(
        'An unexpected error occurred during password reset',
      );
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _apiClient.get(AppConstants.currentUserEndpoint);

      if (response['status'] != 'success' || !response.containsKey('data')) {
        throw ServerException('Invalid user data response format');
      }

      return UserModel.fromJson(response['data']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthenticatedException('User not authenticated');
      }
      _logger.e('Get user error', error: e, tag: 'ApiRemoteDataSource');
      throw ServerException('Failed to get user data: ${e.message}');
    } catch (e) {
      if (e is AppException) rethrow;
      _logger.e(
        'Unexpected error getting user',
        error: e,
        tag: 'ApiRemoteDataSource',
      );
      throw ServerException(
        'An unexpected error occurred while fetching user data',
      );
    }
  }

  @override
  Future<UserModel> updateUserDetails(Map<String, dynamic> data) async {
    try {
      _logger.d('Updating user with data: $data', tag: 'ApiRemoteDataSource');

      // The endpoint should match what's in your API
      final response = await _apiClient.patch('/api/auth/me', body: data);

      if (response['status'] != 'success' || !response.containsKey('data')) {
        throw ServerException('Invalid update user response format');
      }

      _logger.i('User updated successfully', tag: 'ApiRemoteDataSource');

      // Return the updated user model
      return UserModel.fromJson(response['data']);
    } on DioException catch (e) {
      _logger.e(
        'Update user error: ${e.response?.data}',
        error: e,
        tag: 'ApiRemoteDataSource',
      );

      if (e.response?.statusCode == 401) {
        throw UnauthenticatedException('User not authenticated');
      }

      // Include more detailed error information
      final errorMessage =
          e.response?.data is Map
              ? e.response?.data['message'] ?? e.message
              : e.message;

      throw ServerException('Failed to update user: $errorMessage');
    } catch (e) {
      if (e is AppException) rethrow;
      _logger.e(
        'Unexpected error updating user: $e',
        error: e,
        tag: 'ApiRemoteDataSource',
      );
      throw ServerException(
        'An unexpected error occurred while updating user data: $e',
      );
    }
  }

  // MEAL METHODS

  @override
  Future<MealModel> getMealById(String mealId) async {
    try {
      final response = await _apiClient.get('/api/meals/$mealId');

      bool success =
          response['status'] == 'success' || response['success'] == true;
      if (!success || !response.containsKey('data')) {
        throw ServerException('Invalid meal data response format');
      }

      return MealModel.fromJson(response['data']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw ResourceNotFoundException('Meal not found');
      }
      _logger.e('Get meal error', error: e, tag: 'ApiRemoteDataSource');
      throw ServerException('Failed to get meal: ${e.message}');
    } catch (e) {
      if (e is AppException) rethrow;
      _logger.e(
        'Unexpected error getting meal',
        error: e,
        tag: 'ApiRemoteDataSource',
      );
      throw ServerException(
        'An unexpected error occurred while fetching meal data',
      );
    }
  }

  @override
  Future<DishModel> getDishById(String dishId) async {
    try {
      final response = await _apiClient.get('/api/dishes/$dishId');

      bool success =
          response['status'] == 'success' || response['success'] == true;
      if (!success || !response.containsKey('data')) {
        throw ServerException('Invalid dish data response format');
      }

      return DishModel.fromJson(response['data']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw ResourceNotFoundException('Dish not found');
      }
      _logger.e('Get dish error', error: e, tag: 'ApiRemoteDataSource');
      throw ServerException('Failed to get dish: ${e.message}');
    } catch (e) {
      if (e is AppException) rethrow;
      _logger.e(
        'Unexpected error getting dish',
        error: e,
        tag: 'ApiRemoteDataSource',
      );
      throw ServerException(
        'An unexpected error occurred while fetching dish data',
      );
    }
  }

  // PACKAGE METHODS

  @override
  Future<List<PackageModel>> getAllPackages() async {
    try {
      final response = await _apiClient.get(AppConstants.packagesEndpoint);

      if (response['status'] != "success" || !response.containsKey('data')) {
        throw ServerException('Invalid packages response format');
      }

      final packagesList = response['data'] as List;

      // Convert the packages and create default slots if not provided
      return packagesList.map((json) {
        final package = PackageModel.fromJson(json);

        // If the package has no slots (since API doesn't return slots in list view),
        // we'll return it as is and let the repository or UI handle it
        return package;
      }).toList();
    } on DioException catch (e) {
      _logger.e('Get packages error', error: e, tag: 'ApiRemoteDataSource');
      throw ServerException('Failed to get packages: ${e.message}');
    } catch (e) {
      if (e is AppException) rethrow;
      _logger.e(
        'Unexpected error getting packages',
        error: e,
        tag: 'ApiRemoteDataSource',
      );
      throw ServerException(
        'An unexpected error occurred while fetching packages',
      );
    }
  }

  @override
  Future<PackageModel> getPackageById(String packageId) async {
    try {
      final response = await _apiClient.get(
        '${AppConstants.packagesEndpoint}/$packageId',
      );

      if (response['status'] != "success" || !response.containsKey('data')) {
        throw ServerException('Invalid package response format');
      }

      // Extract the package data from the response
      final packageData = response['data'];

      // Create a package model from the response data
      final package = PackageModel.fromJson(packageData);

      // If slots are available, great. Otherwise, slots will be an empty list
      // which is handled when displayed

      return package;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw ResourceNotFoundException('Package not found');
      }
      _logger.e('Get package error', error: e, tag: 'ApiRemoteDataSource');
      throw ServerException('Failed to get package: ${e.message}');
    } catch (e) {
      if (e is AppException) rethrow;
      _logger.e(
        'Unexpected error getting package',
        error: e,
        tag: 'ApiRemoteDataSource',
      );
      throw ServerException(
        'An unexpected error occurred while fetching package data',
      );
    }
  }

  // SUBSCRIPTION METHODS

  @override
  Future<List<SubscriptionModel>> getActiveSubscriptions() async {
    try {
      final response = await _apiClient.get(AppConstants.subscriptionsEndpoint);

      if (response['status'] != "success" || !response.containsKey('data')) {
        throw ServerException('Invalid subscriptions response format');
      }

      final subscriptionsList = response['data'] as List;
      return subscriptionsList
          .map((json) => SubscriptionModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthenticatedException('User not authenticated');
      }
      _logger.e(
        'Get subscriptions error',
        error: e,
        tag: 'ApiRemoteDataSource',
      );
      throw ServerException('Failed to get subscriptions: ${e.message}');
    } catch (e) {
      if (e is AppException) rethrow;
      _logger.e(
        'Unexpected error getting subscriptions',
        error: e,
        tag: 'ApiRemoteDataSource',
      );
      throw ServerException(
        'An unexpected error occurred while fetching subscriptions',
      );
    }
  }

  @override
  Future<SubscriptionModel> getSubscriptionById(String subscriptionId) async {
    try {
      final response = await _apiClient.get(
        '${AppConstants.subscriptionsEndpoint}/$subscriptionId',
      );

      if (response['status'] != "success" || !response.containsKey('data')) {
        throw ServerException('Invalid subscription response format');
      }

      return SubscriptionModel.fromJson(response['data']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw ResourceNotFoundException('Subscription not found');
      }
      if (e.response?.statusCode == 401) {
        throw UnauthenticatedException('User not authenticated');
      }
      _logger.e('Get subscription error', error: e, tag: 'ApiRemoteDataSource');
      throw ServerException('Failed to get subscription: ${e.message}');
    } catch (e) {
      if (e is AppException) rethrow;
      _logger.e(
        'Unexpected error getting subscription',
        error: e,
        tag: 'ApiRemoteDataSource',
      );
      throw ServerException(
        'An unexpected error occurred while fetching subscription data',
      );
    }
  }

  @override
  Future<String> createSubscription({
    required String packageId,
    required DateTime startDate,
    required int durationDays,
    required String addressId,
    String? instructions,
    required List<MealSlotModel> slots,
  }) async {
    try {
      // Convert slots to the format required by the API
      final slotsList = slots.map((slot) => slot.toRequestJson()).toList();

      final response = await _apiClient.post(
        AppConstants.subscribeEndpoint,
        body: {
          'startDate':
              startDate.toIso8601String().split('T')[0], // Format as YYYY-MM-DD
          'durationDays': durationDays.toString(),
          'address': addressId,
          'instructions': instructions ?? '',
          'package': packageId,
          'slots': slotsList,
        },
      );

      if (response['status'] != "success") {
        throw ServerException('Invalid subscription creation response format');
      }

      // Extract message from response or create a default message
      final message =
          response['message'] as String? ?? 'Subscription created successfully';
      return message;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthenticatedException('User not authenticated');
      }
      if (e.response?.statusCode == 400) {
        throw ValidationException('Invalid subscription data');
      }
      _logger.e(
        'Create subscription error',
        error: e,
        tag: 'ApiRemoteDataSource',
      );
      throw ServerException('Failed to create subscription: ${e.message}');
    } catch (e) {
      if (e is AppException) rethrow;
      _logger.e(
        'Unexpected error creating subscription',
        error: e,
        tag: 'ApiRemoteDataSource',
      );
      throw ServerException(
        'An unexpected error occurred while creating subscription',
      );
    }
  }

  @override
  Future<void> updateSubscription(
    String subscriptionId,
    List<MealSlotModel> slots,
  ) async {
    try {
      // Convert slots to the format required by the API
      final slotsList = slots.map((slot) => slot.toRequestJson()).toList();

      final response = await _apiClient.put(
        '${AppConstants.subscriptionsEndpoint}/$subscriptionId',
        body: {'slots': slotsList},
      );

      if (response['status'] != "success") {
        throw ServerException('Failed to update subscription');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw ResourceNotFoundException('Subscription not found');
      }
      if (e.response?.statusCode == 401) {
        throw UnauthenticatedException('User not authenticated');
      }
      _logger.e(
        'Update subscription error',
        error: e,
        tag: 'ApiRemoteDataSource',
      );
      throw ServerException('Failed to update subscription: ${e.message}');
    } catch (e) {
      if (e is AppException) rethrow;
      _logger.e(
        'Unexpected error updating subscription',
        error: e,
        tag: 'ApiRemoteDataSource',
      );
      throw ServerException(
        'An unexpected error occurred while updating subscription',
      );
    }
  }

  @override
  Future<void> cancelSubscription(String subscriptionId) async {
    try {
      final response = await _apiClient.delete(
        '${AppConstants.subscriptionsEndpoint}/$subscriptionId',
      );

      if (response['status'] != "success") {
        throw ServerException('Failed to cancel subscription');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw ResourceNotFoundException('Subscription not found');
      }
      if (e.response?.statusCode == 401) {
        throw UnauthenticatedException('User not authenticated');
      }
      _logger.e(
        'Cancel subscription error',
        error: e,
        tag: 'ApiRemoteDataSource',
      );
      throw ServerException('Failed to cancel subscription: ${e.message}');
    } catch (e) {
      if (e is AppException) rethrow;
      _logger.e(
        'Unexpected error cancelling subscription',
        error: e,
        tag: 'ApiRemoteDataSource',
      );
      throw ServerException(
        'An unexpected error occurred while cancelling subscription',
      );
    }
  }

  @override
  Future<void> pauseSubscription(String subscriptionId) async {
    try {
      final response = await _apiClient.post(
        '${AppConstants.subscriptionsEndpoint}/$subscriptionId/pause',
        body: {}, // Format as YYYY-MM-DD
      );

      if (response['status'] != "success") {
        throw ServerException('Failed to pause subscription');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw ResourceNotFoundException('Subscription not found');
      }
      if (e.response?.statusCode == 401) {
        throw UnauthenticatedException('User not authenticated');
      }
      _logger.e(
        'Pause subscription error',
        error: e,
        tag: 'ApiRemoteDataSource',
      );
      throw ServerException('Failed to pause subscription: ${e.message}');
    } catch (e) {
      if (e is AppException) rethrow;
      _logger.e(
        'Unexpected error pausing subscription',
        error: e,
        tag: 'ApiRemoteDataSource',
      );
      throw ServerException(
        'An unexpected error occurred while pausing subscription',
      );
    }
  }

  @override
  Future<void> resumeSubscription(String subscriptionId) async {
    try {
      final response = await _apiClient.post(
        '${AppConstants.subscriptionsEndpoint}/$subscriptionId/resume',
        body: {},
      );

      if (response['status'] != "success") {
        throw ServerException('Failed to resume subscription');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw ResourceNotFoundException('Subscription not found');
      }
      if (e.response?.statusCode == 401) {
        throw UnauthenticatedException('User not authenticated');
      }
      _logger.e(
        'Resume subscription error',
        error: e,
        tag: 'ApiRemoteDataSource',
      );
      throw ServerException('Failed to resume subscription: ${e.message}');
    } catch (e) {
      if (e is AppException) rethrow;
      _logger.e(
        'Unexpected error resuming subscription',
        error: e,
        tag: 'ApiRemoteDataSource',
      );
      throw ServerException(
        'An unexpected error occurred while resuming subscription',
      );
    }
  }
}
