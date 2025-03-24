// lib/src/presentation/cubits/user_profile/user_profile_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/domain/entities/user_entity.dart';
import 'package:foodam/src/domain/usecase/user/getuseraddres_usecase.dart';
import 'package:foodam/src/domain/usecase/user/getuserdetail_usecase.dart';
import 'package:foodam/src/domain/usecase/user/updateuser_usecase.dart';
import 'package:foodam/src/presentation/cubits/user_profile/user_profile_state.dart';

class UserProfileCubit extends Cubit<UserProfileState> {
  final GetUserDetailsUseCase _getUserDetailsUseCase;
  final GetUserAddressesUseCase _getUserAddressesUseCase;
  final UpdateUserDetailsUseCase _updateUserDetailsUseCase;
  final LoggerService _logger = LoggerService();

  UserProfileCubit({
    required GetUserDetailsUseCase getUserDetailsUseCase,
    required GetUserAddressesUseCase getUserAddressesUseCase,
    required UpdateUserDetailsUseCase updateUserDetailsUseCase,
  }) : 
    _getUserDetailsUseCase = getUserDetailsUseCase,
    _getUserAddressesUseCase = getUserAddressesUseCase,
    _updateUserDetailsUseCase = updateUserDetailsUseCase,
    super(UserProfileInitial());

  Future<void> getUserProfile() async {
    emit(UserProfileLoading());
    
    final userResult = await _getUserDetailsUseCase();
    
    await userResult.fold(
      (failure) {
        _logger.e('Failed to get user details', error: failure);
        emit(UserProfileError('Failed to load user profile'));
      },
      (user) async {
        final addressesResult = await _getUserAddressesUseCase();
        
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

  Future<void> updateUserDetails(User updatedUser) async {
    if (state is UserProfileLoaded) {
      final currentState = state as UserProfileLoaded;
      
      emit(UserProfileUpdating(
        user: currentState.user,
        field: 'profile',
      ));
      
      final result = await _updateUserDetailsUseCase(updatedUser);
      
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

 
}