// lib/src/data/datasource/api_remote_data_source.dart
import 'package:dio/dio.dart';
import 'package:foodam/core/constants/app_constants.dart';
import 'package:foodam/core/errors/execption.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/data/client/dio_api_client.dart';
import 'package:foodam/src/data/datasource/remote_data_source.dart';
import 'package:foodam/src/data/model/banner_model.dart';
import 'package:foodam/src/data/model/dish_model.dart';
import 'package:foodam/src/data/model/meal_model.dart';
import 'package:foodam/src/data/model/meal_slot_model.dart';
import 'package:foodam/src/data/model/order_model.dart';
import 'package:foodam/src/data/model/package_model.dart';
import 'package:foodam/src/data/model/subscription_model.dart';
import 'package:foodam/src/data/model/user_model.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../model/pagination_model.dart';

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
        body: {
          'email': email,
          'password': password,
          if (phone.trim().isNotEmpty) 'phone': phone,
        },
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

  Future<String?> _getAppSignature() async {
    try {
      return await SmsAutoFill().getAppSignature;
    } catch (e) {
      _logger.e('Failed to get app signature', error: e);
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>> registerWithMobile(String mobile) async {
    try {
      // print(mobile);
      // final appSignature = await _getAppSignature();
      await SmsAutoFill().listenForCode();
      final response = await _apiClient.post(
        '/api/auth/register',
        body: {'phone': mobile},
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
      // final appSignature = await _getAppSignature();
      await SmsAutoFill().listenForCode();

      final response = await _apiClient.post(
        '/api/auth/login',
        body: {'phone': mobile},
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
        '/api/auth/verify-mobile',
        body: {'phone': mobile, 'otp': otp},
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
        body: {'phone': mobile, 'otp': otp},
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
  Future<Map<String, dynamic>> resendOTP(
    String mobile,
    bool isRegistration,
  ) async {
    try {
      final endpoint =
          isRegistration ? '/api/auth/register' : '/api/auth/login';
      final response = await _apiClient.post(endpoint, body: {'phone': mobile});

      if (response['status'] != 'success') {
        throw ServerException('Invalid OTP resend response format');
      }

      return response['data'] ??
          {'message': 'OTP resent to your mobile number'};
    } on DioException catch (e) {
      _logger.e('OTP resend error', error: e, tag: 'ApiRemoteDataSource');
      throw ServerException('Failed to resend OTP: ${e.message}');
    } catch (e) {
      if (e is AppException) rethrow;
      _logger.e(
        'Unexpected OTP resend error',
        error: e,
        tag: 'ApiRemoteDataSource',
      );
      throw ServerException('An unexpected error occurred during OTP resend');
    }
  }

  @override
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await _apiClient.post(
        '/api/auth/forgot-password',
        body: {'email': email},
      );

      if (response['status'] != 'success') {
        throw ServerException('Invalid forgot password response format');
      }

      return response['data'] ??
          {
            'message':
                'If a user with that email exists, a password reset link has been sent',
          };
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
  Future<void> resetPassword(
    String email,
    String otp,
    String newPassword,
  ) async {
    try {
      await _apiClient.post(
        '/api/auth/reset-password',
        body: {
          'email': email,
          'token': otp, // Based on your API screenshot, it uses 'token' field
          'newPassword': newPassword,
        },
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

  // Update the getActiveSubscriptions method to handle the new response format
  // Update in lib/src/data/datasource/api_remote_data_source.dart

  @override
  Future<List<SubscriptionModel>> getActiveSubscriptions() async {
    try {
      final response = await _apiClient.get(AppConstants.subscriptionsEndpoint);

      if (response['status'] != 'success' || !response.containsKey('data')) {
        throw ServerException('Invalid subscriptions response format');
      }

      final data = response['data'];

      // Handle new nested format
      if (data is Map && data.containsKey('subscriptions')) {
        // New pagination format
        final List<dynamic> subscriptionsData = data['subscriptions'] as List;
        return subscriptionsData
            .map((json) => SubscriptionModel.fromJson(json))
            .toList();
      } else if (data is List) {
        // Old format for backward compatibility
        return data.map((json) => SubscriptionModel.fromJson(json)).toList();
      } else {
        throw ServerException('Unexpected subscriptions data format');
      }
    } on Exception catch (e) {
      _logger.e(
        'Error fetching active subscriptions',
        error: e,
        tag: 'ApiRemoteDataSource',
      );
      throw ServerException(
        'Failed to get active subscriptions: ${e.toString()}',
      );
    }
  }

  // Update the getSubscriptionById method to handle the new response format
  @override
  Future<SubscriptionModel> getSubscriptionById(String subscriptionId) async {
    try {
      final response = await _apiClient.get(
        '${AppConstants.subscriptionsEndpoint}/$subscriptionId',
      );

      if (response['status'] != 'success' || !response.containsKey('data')) {
        throw ServerException('Invalid subscription response format');
      }

      return SubscriptionModel.fromJson(response['data']);
    } on Exception catch (e) {
      _logger.e(
        'Error fetching subscription details',
        error: e,
        tag: 'ApiRemoteDataSource',
      );
      throw ServerException(
        'Failed to get subscription details: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<String>> createSubscription({
    required String packageId,
    required DateTime startDate,
    required int durationDays,
    required String addressId,
    required int personCount,
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
          'noOfPersons': personCount,
        },
      );

      if (response['status'] != "success") {
        throw ServerException('Invalid subscription creation response format');
      }

      // Extract message from response or create a default message
      final message =
          response['message'] as String? ?? 'Subscription created successfully';
      final id = response['data']['id'] as String;
      return [message, id];
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

  @override
  Future<PaginatedResponse<OrderModel>> getUpcomingOrders({
    int? page,
    int? limit,
    String? dayContext,
  }) async {
    try {
      _logger.d(
        '====== DEBUGGING: Making API request for upcoming orders ======',
        tag: 'ApiRemoteDataSource',
      );

      // Build query parameters
      final queryParams = <String, dynamic>{};
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;
      if (dayContext != null) queryParams['dayContext'] = dayContext;

      final response = await _apiClient.get(
        '/api/orders/my-orders',
        queryParameters: queryParams,
      );

      _logger.d(
        '====== DEBUGGING: API response received ======',
        tag: 'ApiRemoteDataSource',
      );
      _logger.d(
        'Response type: ${response.runtimeType}',
        tag: 'ApiRemoteDataSource',
      );
      _logger.d(
        'Response keys: ${response.keys.join(', ')}',
        tag: 'ApiRemoteDataSource',
      );
      _logger.d(
        'Response status: ${response['status']}',
        tag: 'ApiRemoteDataSource',
      );
      _logger.d(
        'Has data field: ${response.containsKey('data')}',
        tag: 'ApiRemoteDataSource',
      );

      if (response['status'] != 'success' || !response.containsKey('data')) {
        _logger.e(
          'Invalid upcoming orders response format: $response',
          tag: 'ApiRemoteDataSource',
        );
        throw ServerException('Invalid upcoming orders response format');
      }

      final data = response['data'];
      _logger.d('Data type: ${data.runtimeType}', tag: 'ApiRemoteDataSource');

      // Handle new nested format with pagination
      if (data is Map && data.containsKey('orders')) {
        final ordersData = data['orders'] as List;
        final orders = <OrderModel>[];

        for (var i = 0; i < ordersData.length; i++) {
          try {
            _logger.d(
              'Creating OrderModel for item $i',
              tag: 'ApiRemoteDataSource',
            );
            final orderData = ordersData[i];

            // Check meal data specifically
            if (orderData['meal'] == null) {
              _logger.e(
                'Meal data missing in order $i',
                tag: 'ApiRemoteDataSource',
              );
              continue;
            }

            final orderModel = OrderModel.fromJson(orderData);
            orders.add(orderModel);
            _logger.d(
              'Successfully created OrderModel for item $i',
              tag: 'ApiRemoteDataSource',
            );
          } catch (e) {
            _logger.e(
              'Error parsing order at index $i: ${e.toString()}',
              error: e,
              tag: 'ApiRemoteDataSource',
            );
            // Continue with next order instead of failing completely
          }
        }

        _logger.i(
          'Successfully processed ${orders.length} out of ${ordersData.length} upcoming orders',
          tag: 'ApiRemoteDataSource',
        );

        return PaginatedResponse<OrderModel>(
          items: orders,
          pagination: PaginationModel.fromJson(data['pagination']),
        );
      } else {
        _logger.e('Unexpected data format: $data', tag: 'ApiRemoteDataSource');
        throw ServerException(
          'Expected Map with orders key but got ${data.runtimeType}',
        );
      }
    } on Exception catch (e) {
      _logger.e(
        'Error fetching upcoming orders: ${e.toString()}',
        error: e,
        tag: 'ApiRemoteDataSource',
      );
      throw ServerException('Failed to get upcoming orders: ${e.toString()}');
    }
  }

  @override
  Future<PaginatedResponse<OrderModel>> getPastOrders({
    int? page,
    int? limit,
    String? dayContext,
  }) async {
    try {
      _logger.d(
        '====== DEBUGGING: Making API request for past orders ======',
        tag: 'ApiRemoteDataSource',
      );

      // Build query parameters
      final queryParams = <String, dynamic>{};
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;
      if (dayContext != null) queryParams['dayContext'] = dayContext;

      final response = await _apiClient.get(
        '/api/orders/my-orders',
        queryParameters: queryParams,
      );
      _logger.d(
        '====== DEBUGGING: API response received ======',
        tag: 'ApiRemoteDataSource',
      );
      _logger.d(
        'Response type: ${response.runtimeType}',
        tag: 'ApiRemoteDataSource',
      );
      _logger.d(
        'Response keys: ${response.keys.join(', ')}',
        tag: 'ApiRemoteDataSource',
      );
      _logger.d(
        'Response status: ${response['status']}',
        tag: 'ApiRemoteDataSource',
      );
      _logger.d(
        'Has data field: ${response.containsKey('data')}',
        tag: 'ApiRemoteDataSource',
      );

      if (response['status'] != 'success' || !response.containsKey('data')) {
        _logger.e(
          'Invalid past orders response format: $response',
          tag: 'ApiRemoteDataSource',
        );
        throw ServerException('Invalid past orders response format');
      }

      final data = response['data'];
      _logger.d('Data type: ${data.runtimeType}', tag: 'ApiRemoteDataSource');

      List<dynamic> ordersData;

      // Handle new nested format with pagination
      if (data is Map && data.containsKey('orders')) {
        ordersData = data['orders'] as List;
        _logger.d(
          'Extracted ${ordersData.length} orders from paginated response',
          tag: 'ApiRemoteDataSource',
        );
      } else if (data is List) {
        // Old format for backward compatibility
        ordersData = data;
        _logger.d(
          'Using old format with ${ordersData.length} orders',
          tag: 'ApiRemoteDataSource',
        );
      } else {
        _logger.e('Unexpected data format: $data', tag: 'ApiRemoteDataSource');
        throw ServerException(
          'Expected List or Map with orders key but got ${data.runtimeType}',
        );
      }

      _logger.d(
        'Processing ${ordersData.length} past orders',
        tag: 'ApiRemoteDataSource',
      );

      // Debug first item if available
      if (ordersData.isNotEmpty) {
        _logger.d(
          'Sample first item: ${ordersData[0]}',
          tag: 'ApiRemoteDataSource',
        );
      }

      final orders = <OrderModel>[];

      for (var i = 0; i < ordersData.length; i++) {
        try {
          _logger.d(
            'Creating OrderModel for item $i',
            tag: 'ApiRemoteDataSource',
          );
          final orderData = ordersData[i];

          // Check meal data specifically
          if (orderData['meal'] == null) {
            _logger.e(
              'Meal data missing in order $i',
              tag: 'ApiRemoteDataSource',
            );
            continue;
          }

          final orderModel = OrderModel.fromJson(orderData);
          orders.add(orderModel);
          _logger.d(
            'Successfully created OrderModel for item $i',
            tag: 'ApiRemoteDataSource',
          );
        } catch (e) {
          _logger.e(
            'Error parsing past order at index $i: ${e.toString()}',
            error: e,
            tag: 'ApiRemoteDataSource',
          );
          // Continue with next order instead of failing completely
        }
      }

      _logger.i(
        'Successfully processed ${orders.length} out of ${ordersData.length} past orders',
        tag: 'ApiRemoteDataSource',
      );

      return PaginatedResponse<OrderModel>(
        items: orders,
        pagination: PaginationModel.fromJson(data['pagination']),
      );
    } on Exception catch (e) {
      _logger.e(
        'Error fetching past orders: ${e.toString()}',
        error: e,
        tag: 'ApiRemoteDataSource',
      );
      throw ServerException('Failed to get past orders: ${e.toString()}');
    }
  }

  @override
  Future<List<BannerModel>> getBanners({String? category}) async {
    try {
      final response = await _apiClient.get('/api/banners');

      if (response['status'] != 'success' || !response.containsKey('data')) {
        throw ServerException('Invalid banner response format');
      }

      final List<dynamic> bannersData = response['data'];
      final banners =
          bannersData.map((json) => BannerModel.fromJson(json)).toList();

      // Sort by index
      banners.sort((a, b) => a.index.compareTo(b.index));

      // Filter by category if provided
      if (category != null && category.isNotEmpty) {
        return banners
            .where(
              (banner) =>
                  banner.category.toLowerCase() == category.toLowerCase(),
            )
            .toList();
      }

      return banners;
    } catch (e) {
      _logger.e('Error fetching banners', error: e, tag: 'ApiRemoteDataSource');
      throw ServerException('Failed to get banners: ${e.toString()}');
    }
  }
}
