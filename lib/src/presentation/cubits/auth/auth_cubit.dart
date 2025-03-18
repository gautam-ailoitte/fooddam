// lib/src/presentation/cubits/auth/auth_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/src/domain/entities/address_entity.dart';
import 'package:foodam/src/domain/usecase/user/login_user_usecase.dart';
import 'package:foodam/src/domain/usecase/user/logout_usecase.dart';
import 'package:foodam/src/domain/usecase/user/get_current_user_usecase.dart';
import 'package:foodam/src/domain/usecase/user/register_user_usecase.dart';
import 'package:foodam/src/domain/usecase/user/check_logged_in_usecase.dart';
import 'package:foodam/src/presentation/cubits/auth/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUserUseCase _loginUserUseCase;
  final RegisterUserUseCase _registerUserUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final CheckLoggedInUseCase _checkLoggedInUseCase;

  AuthCubit({
    required LoginUserUseCase loginUserUseCase,
    required RegisterUserUseCase registerUserUseCase,
    required LogoutUseCase logoutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required CheckLoggedInUseCase checkLoggedInUseCase,
  })  : _loginUserUseCase = loginUserUseCase,
        _registerUserUseCase = registerUserUseCase,
        _logoutUseCase = logoutUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _checkLoggedInUseCase = checkLoggedInUseCase,
        super(AuthInitial());

  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    
    final isLoggedInResult = await _checkLoggedInUseCase();
    
    isLoggedInResult.fold(
      (failure) => emit(AuthError(message: _mapFailureToMessage(failure))),
      (isLoggedIn) async {
        if (isLoggedIn) {
          final userResult = await _getCurrentUserUseCase();
          userResult.fold(
            (failure) => emit(AuthError(message: _mapFailureToMessage(failure))),
            (user) => emit(Authenticated(user: user)),
          );
        } else {
          emit(Unauthenticated());
        }
      },
    );
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    
    final params = LoginUserParams(
      email: email,
      password: password,
    );
    
    final result = await _loginUserUseCase(params);
    
    result.fold(
      (failure) => emit(AuthError(message: _mapFailureToMessage(failure))),
      (user) => emit(Authenticated(user: user)),
    );
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
    required String street,
    required String city,
    required String state,
    required String zipCode,
    required String country,
  }) async {
    emit(AuthLoading());
    
    final address = Address(
      street: street,
      city: city,
      state: state,
      zipCode: zipCode,
      country: country,
    );
    
    final params = RegisterUserParams(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
      phone: phone,
      address: address,
    );
    
    final result = await _registerUserUseCase(params);
    
    result.fold(
      (failure) => emit(AuthError(message: _mapFailureToMessage(failure))),
      (user) => emit(Authenticated(user: user)),
    );
  }

  Future<void> logout() async {
    emit(AuthLoading());
    
    final result = await _logoutUseCase();
    
    result.fold(
      (failure) => emit(AuthError(message: _mapFailureToMessage(failure))),
      (_) => emit(Unauthenticated()),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure _:
        return 'Server error occurred. Please try again.';
      case NetworkFailure _:
        return 'Network error occurred. Please check your connection.';
      case UnauthorizedFailure _:
        return 'Invalid credentials. Please try again.';
      case CacheFailure _:
        return 'Cache error occurred. Please restart the app.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}