// lib/src/domain/usecase/user/check_logged_in_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/repo/user_repo.dart';

class CheckLoggedInUseCase extends UseCase<bool> {
  final UserRepository repository;

  CheckLoggedInUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call() {
    return repository.isLoggedIn();
  }
}