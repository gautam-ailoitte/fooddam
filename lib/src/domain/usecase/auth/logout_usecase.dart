import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/repo/auth_repository.dart';

class LogoutUseCase implements UseCaseNoParamsNoReturn {
  final AuthRepository authRepository;

  LogoutUseCase({required this.authRepository});

  @override
  Future<Either<Failure, void>> call() {
    return authRepository.logout();
  }
}