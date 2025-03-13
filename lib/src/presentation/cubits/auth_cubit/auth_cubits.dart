// lib/presentation/blocs/auth/auth_state.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/string_constants.dart';
import 'package:foodam/src/domain/entities/user_entity.dart';
import 'package:foodam/src/domain/repo/user_repo.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;

  AuthCubit({required this.authRepository}) : super(AuthInitial());

  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    
    final isLoggedInResult = await authRepository.isLoggedIn();
    
    isLoggedInResult.fold(
      (failure) => emit(AuthUnauthenticated()),
      (isLoggedIn) async {
        if (isLoggedIn) {
          final userResult = await authRepository.getCurrentUser();
          
          userResult.fold(
            (failure) => emit(AuthUnauthenticated()),
            (user) => emit(AuthAuthenticated(user)),
          );
        } else {
          emit(AuthUnauthenticated());
        }
      },
    );
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    
    final result = await authRepository.login(email, password);
    
    result.fold(
      (failure) => emit(AuthError(StringConstants.loginFailed)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> logout() async {
    emit(AuthLoading());
    
    final result = await authRepository.logout();
    
    result.fold(
      (failure) => emit(AuthError(StringConstants.unexpectedError)),
      (_) => emit(AuthUnauthenticated()),
    );
  }
}

