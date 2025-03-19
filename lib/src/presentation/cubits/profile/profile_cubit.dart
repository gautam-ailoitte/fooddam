// lib/src/presentation/cubits/profile/profile_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/src/domain/entities/address_entity.dart';
import 'package:foodam/src/domain/entities/dish_entity.dart';
import 'package:foodam/src/domain/usecase/user/add_address_usecase.dart';
import 'package:foodam/src/domain/usecase/user/get_current_user_usecase.dart';
import 'package:foodam/src/domain/usecase/user/get_user_addresses_usecase.dart';
import 'package:foodam/src/domain/usecase/user/update_profile_usecase.dart';
import 'package:foodam/src/presentation/cubits/profile/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final GetUserAddressesUseCase _getUserAddressesUseCase;
  final AddAddressUseCase _addAddressUseCase;

  ProfileCubit({
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required UpdateProfileUseCase updateProfileUseCase,
    required GetUserAddressesUseCase getUserAddressesUseCase,
    required AddAddressUseCase addAddressUseCase,
  })  : _getCurrentUserUseCase = getCurrentUserUseCase,
        _updateProfileUseCase = updateProfileUseCase,
        _getUserAddressesUseCase = getUserAddressesUseCase,
        _addAddressUseCase = addAddressUseCase,
        super(const ProfileState());

  // Load user profile data
  Future<void> loadProfile() async {
    emit(state.copyWith(status: ProfileStatus.loading));

    // Get current user
    final userResult = await _getCurrentUserUseCase();
    
    userResult.fold(
      (failure) => emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: _mapFailureToMessage(failure),
      )),
      (user) async {
        // After getting user, load addresses
        final addressesResult = await _getUserAddressesUseCase();
        
        addressesResult.fold(
          (failure) => emit(state.copyWith(
            status: ProfileStatus.loaded,
            user: user,
            errorMessage: 'Failed to load addresses: ${_mapFailureToMessage(failure)}',
          )),
          (addresses) => emit(state.copyWith(
            status: ProfileStatus.loaded,
            user: user,
            addresses: addresses,
          )),
        );
      },
    );
  }

  // Update user profile
  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    Address? address,
    List<DietaryPreference>? dietaryPreferences,
    List<String>? allergies,
  }) async {
    emit(state.copyWith(isUpdating: true));

    final params = UpdateProfileParams(
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      address: address,
      dietaryPreferences: dietaryPreferences,
      allergies: allergies,
    );

    final result = await _updateProfileUseCase(params);

    result.fold(
      (failure) => emit(state.copyWith(
        isUpdating: false,
        errorMessage: _mapFailureToMessage(failure),
      )),
      (updatedUser) => emit(state.copyWith(
        isUpdating: false,
        user: updatedUser,
      )),
    );
  }

  // Add a new address
  Future<void> addAddress(Address address) async {
    emit(state.copyWith(isUpdating: true));

    final result = await _addAddressUseCase(address);

    result.fold(
      (failure) => emit(state.copyWith(
        isUpdating: false,
        errorMessage: _mapFailureToMessage(failure),
      )),
      (newAddress) {
        final updatedAddresses = List<Address>.from(state.addresses)..add(newAddress);
        emit(state.copyWith(
          isUpdating: false,
          addresses: updatedAddresses,
        ));
      },
    );
  }

  // Helper method to map failures to user-friendly messages
  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Server error. Please try again later.';
      case NetworkFailure:
        return 'Network error. Please check your connection.';
      case UnauthorizedFailure:
        return 'Unauthorized. Please login again.';
      default:
        return 'An unexpected error occurred.';
    }
  }
}