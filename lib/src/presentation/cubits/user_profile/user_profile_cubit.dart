// lib/src/presentation/cubits/user_profile/user_profile_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/domain/entities/address_entity.dart';
import 'package:foodam/src/domain/entities/user_entity.dart';
import 'package:foodam/src/domain/usecase/user_usecase.dart';
import 'package:foodam/src/presentation/cubits/user_profile/user_profile_state.dart';

class UserProfileCubit extends Cubit<UserProfileState> {
  final UserUseCase _userUseCase;
  final LoggerService _logger = LoggerService();

  UserProfileCubit({
    required UserUseCase userUseCase,
  }) : 
    _userUseCase = userUseCase,
    super(UserProfileInitial());

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
            _logger.i('User profile loaded: ${user.id} with ${addresses.length} addresses');
            emit(UserProfileLoaded(
              user: user,
              addresses: addresses,
            ));
          },
        );
      },
    );
  }

  /// Update user profile details
  Future<void> updateUserDetails(User updatedUser) async {
    if (state is UserProfileLoaded) {
      final currentState = state as UserProfileLoaded;
      
      emit(UserProfileUpdating(
        user: currentState.user,
        field: 'profile',
      ));
      
      final result = await _userUseCase.updateUserDetails(updatedUser);
      
      result.fold(
        (failure) {
          _logger.e('Failed to update user details', error: failure);
          emit(UserProfileError('Failed to update profile'));
          // Reload profile
          getUserProfile();
        },
        (_) {
          _logger.i('User profile updated: ${updatedUser.id}');
          emit(UserProfileUpdateSuccess(
            user: updatedUser,
            message: 'Profile updated successfully',
          ));
          // Reload profile
          getUserProfile();
        },
      );
    } else {
      emit(UserProfileError('Cannot update profile before loading'));
    }
  }

  /// Add a new address
  Future<void> addAddress(Address address) async {
    if (state is UserProfileLoaded) {
      final currentState = state as UserProfileLoaded;
      
      emit(UserProfileUpdating(
        user: currentState.user,
        field: 'address',
      ));
      
      final result = await _userUseCase.addAddress(address);
      
      result.fold(
        (failure) {
          _logger.e('Failed to add address', error: failure);
          emit(UserProfileError('Failed to add address'));
          // Reload profile
          getUserProfile();
        },
        (newAddress) {
          _logger.i('Address added successfully');
          emit(UserProfileUpdateSuccess(
            user: currentState.user,
            message: 'Address added successfully',
          ));
          // Reload profile
          getUserProfile();
        },
      );
    } else {
      emit(UserProfileError('Cannot add address before loading profile'));
    }
  }

  /// Update an existing address
  Future<void> updateAddress(Address address) async {
    if (state is UserProfileLoaded) {
      final currentState = state as UserProfileLoaded;
      
      emit(UserProfileUpdating(
        user: currentState.user,
        field: 'address',
      ));
      
      final result = await _userUseCase.updateAddress(address);
      
      result.fold(
        (failure) {
          _logger.e('Failed to update address', error: failure);
          emit(UserProfileError('Failed to update address'));
          // Reload profile
          getUserProfile();
        },
        (_) {
          _logger.i('Address updated successfully');
          emit(UserProfileUpdateSuccess(
            user: currentState.user,
            message: 'Address updated successfully',
          ));
          // Reload profile
          getUserProfile();
        },
      );
    } else {
      emit(UserProfileError('Cannot update address before loading profile'));
    }
  }

  /// Delete an address
  Future<void> deleteAddress(String addressId) async {
    if (state is UserProfileLoaded) {
      final currentState = state as UserProfileLoaded;
      
      emit(UserProfileUpdating(
        user: currentState.user,
        field: 'address',
      ));
      
      final result = await _userUseCase.deleteAddress(addressId);
      
      result.fold(
        (failure) {
          _logger.e('Failed to delete address', error: failure);
          emit(UserProfileError('Failed to delete address'));
          // Reload profile
          getUserProfile();
        },
        (_) {
          _logger.i('Address deleted successfully');
          emit(UserProfileUpdateSuccess(
            user: currentState.user,
            message: 'Address deleted successfully',
          ));
          // Reload profile
          getUserProfile();
        },
      );
    } else {
      emit(UserProfileError('Cannot delete address before loading profile'));
    }
  }
}