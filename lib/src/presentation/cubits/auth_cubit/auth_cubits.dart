// lib/src/presentation/cubits/auth_cubit/auth_cubits.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/string_constants.dart';
import 'package:foodam/src/domain/entities/user_entity.dart';
import 'package:foodam/src/domain/usecase/auth/check_auth_status_usecase.dart';
import 'package:foodam/src/domain/usecase/auth/login_usecase.dart';
import 'package:foodam/src/domain/usecase/auth/logout_usecase.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final CheckAuthStatusUseCase checkAuthStatusUseCase;
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;

  AuthCubit({
    required this.checkAuthStatusUseCase,
    required this.loginUseCase,
    required this.logoutUseCase,
  }) : super(AuthInitial());

  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    
    final result = await checkAuthStatusUseCase();
    
    result.fold(
      (failure) => emit(AuthUnauthenticated()),
      (user) {
        if (user != null) {
          emit(AuthAuthenticated(user));
        } else {
          emit(AuthUnauthenticated());
        }
      },
    );
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    
    final result = await loginUseCase(LoginParams(
      email: email, 
      password: password,
    ));
    
    result.fold(
      (failure) => emit(AuthError(StringConstants.loginFailed)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> logout() async {
    emit(AuthLoading());
    
    final result = await logoutUseCase();
    
    result.fold(
      (failure) => emit(AuthError(StringConstants.unexpectedError)),
      (_) => emit(AuthUnauthenticated()),
    );
  }
}