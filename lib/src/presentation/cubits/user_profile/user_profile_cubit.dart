// lib/src/presentation/cubits/user_profile/user_profile_cubit.dart
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/injection_container.dart';
import 'package:foodam/src/data/client/dio_api_client.dart';
import 'package:foodam/src/domain/entities/address_entity.dart';
import 'package:foodam/src/domain/entities/uploaded_file_entity.dart';
import 'package:foodam/src/domain/entities/user_entity.dart';
import 'package:foodam/src/domain/usecase/user_usecase.dart';
import 'package:foodam/src/presentation/cubits/user_profile/user_profile_state.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../data/datasource/local_data_source.dart';

class UserProfileCubit extends Cubit<UserProfileState> {
  final UserUseCase _userUseCase;
  final LoggerService _logger = LoggerService();

  UserProfileCubit({required UserUseCase userUseCase})
    : _userUseCase = userUseCase,
      super(UserProfileInitial());

  /// Upload file to USER folder - Direct API call without state emission
  Future<Either<String, UploadedFile>> uploadFile(File file) async {
    try {
      _logger.i('Starting file upload: ${file.path}');

      // Create a separate Dio instance for multipart uploads
      final dio = Dio();
      dio.options.baseUrl =
          AppConstants.apiBaseUrl; // Replace with actual base URL

      // Get token from local storage
      final token = await di<LocalDataSource>().getToken();
      if (token != null && token.isNotEmpty) {
        dio.options.headers['Authorization'] = 'Bearer $token';
      }

      // Create multipart form data
      final formData = FormData.fromMap({
        'files': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
      });

      final response = await dio.post('/api/static/media/USER', data: formData);

      _logger.d('Upload response: ${response.data}');

      // Parse response
      final uploadResponse = _parseUploadResponse(
        response.data is Map ? Map<String, dynamic>.from(response.data) : {},
      );

      if (uploadResponse.isSuccess && uploadResponse.firstFile != null) {
        final uploadedFile = uploadResponse.firstFile!;
        _logger.i('File uploaded successfully: ${uploadedFile.fileUrl}');
        return Right(uploadedFile);
      } else {
        final errorMessage = uploadResponse.message ?? 'Upload failed';
        _logger.e('Upload failed: $errorMessage');
        return Left(errorMessage);
      }
    } on DioException catch (e) {
      final errorMessage = 'Failed to upload file: ${e.message}';
      _logger.e('Upload error', error: e);
      return Left(errorMessage);
    } catch (e) {
      final errorMessage = 'Failed to upload file: ${e.toString()}';
      _logger.e('Upload error', error: e);
      return Left(errorMessage);
    }
  }

  /// Helper method to parse upload response
  FileUploadResponse _parseUploadResponse(Map<String, dynamic> response) {
    try {
      final List<UploadedFile> files = [];

      if (response['data'] != null && response['data'] is List) {
        final dataList = response['data'] as List;
        for (final item in dataList) {
          if (item is Map<String, dynamic>) {
            final file = UploadedFile(
              fileName: item['fileName'] as String?,
              fileUrl: item['fileUrl'] as String?,
              folder: item['folder'] as String?,
              size: item['size'] as int?,
              key: item['key'] as String?,
              categories:
                  item['categories'] != null
                      ? List<String>.from(item['categories'])
                      : null,
              uploadedAt:
                  item['uploadedAt'] != null
                      ? DateTime.tryParse(item['uploadedAt'])
                      : null,
              id: item['_id'] as String?,
            );
            files.add(file);
          }
        }
      }

      return FileUploadResponse(
        status: response['status'] as String?,
        message: response['message'] as String?,
        data: files,
      );
    } catch (e) {
      _logger.e('Error parsing upload response', error: e);
      return FileUploadResponse(
        status: 'error',
        message: 'Failed to parse response',
        data: null,
      );
    }
  }

  /// Load user profile with details and addresses
  Future<void> getUserProfile() async {
    emit(UserProfileLoading());

    // Get user details
    final userResult = await _userUseCase.getUserDetails();

    await userResult.fold(
      (failure) {
        _logger.e('Failed to get user details', error: failure);
        emit(UserProfileError('Failed to load user profile'));
      },
      (user) async {
        // Get user addresses
        final addressesResult = await _userUseCase.getUserAddresses();

        addressesResult.fold(
          (failure) {
            _logger.e('Failed to get user addresses', error: failure);
            // Still emit success with user but without addresses
            emit(UserProfileLoaded(user: user));
          },
          (addresses) {
            _logger.i(
              'User profile loaded: ${user.id} with ${addresses.length} addresses',
            );
            emit(UserProfileLoaded(user: user, addresses: addresses));
          },
        );
      },
    );
  }

  /// Update user profile details
  Future<void> updateUserDetails(User updatedUser) async {
    if (state is! UserProfileLoaded) {
      emit(UserProfileError('Cannot update profile before loading'));
      return;
    }

    final currentState = state as UserProfileLoaded;
    emit(
      UserProfileUpdating(
        user: currentState.user,
        field: 'profile',
        addresses: currentState.addresses,
      ),
    );

    // Make sure to preserve the addresses from current state if not included in update
    final userToUpdate = _preserveAddresses(updatedUser, currentState);

    final result = await _userUseCase.updateUserDetails(userToUpdate);

    result.fold(
      (failure) {
        _logger.e('Failed to update user details', error: failure);
        emit(UserProfileError('Failed to update profile: ${failure.message}'));
        // Reload profile only on error
        getUserProfile();
      },
      (_) {
        _logger.i('User profile updated successfully');

        // Emit success state
        emit(
          UserProfileUpdateSuccess(
            user: userToUpdate,
            message: 'Profile updated successfully',
            addresses: currentState.addresses,
          ),
        );

        // Return to loaded state after brief delay
        Future.delayed(const Duration(milliseconds: 100), () {
          emit(
            UserProfileLoaded(
              user: userToUpdate,
              addresses: currentState.addresses,
            ),
          );
        });
      },
    );
  }

  /// Add a new address
  Future<void> addAddress(Address address) async {
    if (state is! UserProfileLoaded) {
      emit(UserProfileError('Cannot add address before loading profile'));
      return;
    }

    final currentState = state as UserProfileLoaded;
    emit(
      UserProfileUpdating(
        user: currentState.user,
        field: 'address',
        addresses: currentState.addresses,
      ),
    );

    final result = await _userUseCase.addAddress(address);

    result.fold(
      (failure) {
        _logger.e('Failed to add address', error: failure);
        emit(UserProfileError('Failed to add address: ${failure.message}'));
        getUserProfile();
      },
      (newAddress) {
        _logger.i('Address added successfully');

        // Fix: Create a properly typed list by explicitly mapping elements
        final List<Address> updatedAddresses = [
          ...(currentState.addresses ?? []),
          newAddress,
        ];

        emit(
          UserProfileUpdateSuccess(
            user: currentState.user,
            message: 'Address added successfully',
            addresses: updatedAddresses,
          ),
        );

        // Return to loaded state with updated addresses
        Future.delayed(const Duration(milliseconds: 100), () {
          emit(
            UserProfileLoaded(
              user: currentState.user,
              addresses: updatedAddresses,
            ),
          );
        });
      },
    );
  }

  /// Update an existing address
  Future<void> updateAddress(Address address) async {
    if (state is! UserProfileLoaded) {
      emit(UserProfileError('Cannot update address before loading profile'));
      return;
    }

    final currentState = state as UserProfileLoaded;
    emit(
      UserProfileUpdating(
        user: currentState.user,
        field: 'address',
        addresses: currentState.addresses,
      ),
    );

    final result = await _userUseCase.updateAddress(address);

    result.fold(
      (failure) {
        _logger.e('Failed to update address', error: failure);
        emit(UserProfileError('Failed to update address: ${failure.message}'));
        getUserProfile();
      },
      (_) {
        _logger.i('Address updated successfully');

        // Update the specific address in the list
        final updatedAddresses =
            currentState.addresses?.map((addr) {
              return addr.id == address.id ? address : addr;
            }).toList();

        emit(
          UserProfileUpdateSuccess(
            user: currentState.user,
            message: 'Address updated successfully',
            addresses: updatedAddresses,
          ),
        );

        // Return to loaded state with updated addresses
        Future.delayed(const Duration(milliseconds: 100), () {
          emit(
            UserProfileLoaded(
              user: currentState.user,
              addresses: updatedAddresses,
            ),
          );
        });
      },
    );
  }

  /// Delete an address
  Future<void> deleteAddress(String addressId) async {
    if (state is! UserProfileLoaded) {
      emit(UserProfileError('Cannot delete address before loading profile'));
      return;
    }

    final currentState = state as UserProfileLoaded;
    emit(
      UserProfileUpdating(
        user: currentState.user,
        field: 'address',
        addresses: currentState.addresses,
      ),
    );

    final result = await _userUseCase.deleteAddress(addressId);

    result.fold(
      (failure) {
        _logger.e('Failed to delete address', error: failure);
        emit(UserProfileError('Failed to delete address: ${failure.message}'));
        getUserProfile();
      },
      (_) {
        _logger.i('Address deleted successfully');

        // Remove the address from the list
        final updatedAddresses =
            currentState.addresses
                ?.where((addr) => addr.id != addressId)
                .toList();

        emit(
          UserProfileUpdateSuccess(
            user: currentState.user,
            message: 'Address deleted successfully',
            addresses: updatedAddresses,
          ),
        );

        // Return to loaded state with updated addresses
        Future.delayed(const Duration(milliseconds: 100), () {
          emit(
            UserProfileLoaded(
              user: currentState.user,
              addresses: updatedAddresses,
            ),
          );
        });
      },
    );
  }

  /// Update user email with separate API endpoint
  Future<void> updateUserEmail(String newEmail) async {
    if (state is! UserProfileLoaded) {
      emit(UserProfileError('Cannot update email before loading profile'));
      return;
    }

    final currentState = state as UserProfileLoaded;
    emit(
      UserProfileUpdating(
        user: currentState.user,
        field: 'email',
        addresses: currentState.addresses,
      ),
    );

    try {
      // Using API client directly for PATCH request
      final apiClient = di<DioApiClient>();
      final response = await apiClient.patch(
        '/api/auth/email',
        body: {'email': newEmail},
      );

      if (response['status'] == 'success') {
        final message = response['message'] ?? 'Email updated successfully';

        _logger.i('Email updated successfully');

        // Create updated user with new email
        final updatedUser = User(
          id: currentState.user.id,
          email: newEmail,
          firstName: currentState.user.firstName,
          lastName: currentState.user.lastName,
          phone: currentState.user.phone,
          role: currentState.user.role,
          addresses: currentState.addresses,
          dietaryPreferences: currentState.user.dietaryPreferences,
          allergies: currentState.user.allergies,
          isEmailVerified: false, // Email needs verification after change
          isPhoneVerified: currentState.user.isPhoneVerified,
        );

        emit(
          UserProfileUpdateSuccess(
            user: updatedUser,
            message: message,
            addresses: currentState.addresses,
          ),
        );

        // Return to loaded state with updated user
        Future.delayed(const Duration(milliseconds: 100), () {
          emit(
            UserProfileLoaded(
              user: updatedUser,
              addresses: currentState.addresses,
            ),
          );
        });
      } else {
        throw Exception(response['message'] ?? 'Failed to update email');
      }
    } catch (e) {
      _logger.e('Failed to update email', error: e);
      emit(UserProfileError('Failed to update email: ${e.toString()}'));
      // Reload profile to ensure consistent state
      getUserProfile();
    }
  }

  // Helper method to preserve addresses
  User _preserveAddresses(User updatedUser, UserProfileLoaded currentState) {
    if (updatedUser.addresses == null || updatedUser.addresses!.isEmpty) {
      return User(
        id: updatedUser.id,
        email: updatedUser.email,
        firstName: updatedUser.firstName,
        lastName: updatedUser.lastName,
        phone: updatedUser.phone,
        role: updatedUser.role,
        addresses: currentState.addresses,
        dietaryPreferences: updatedUser.dietaryPreferences,
        allergies: updatedUser.allergies,
        isEmailVerified: updatedUser.isEmailVerified,
        isPhoneVerified: updatedUser.isPhoneVerified,
      );
    }
    return updatedUser;
  }
}
