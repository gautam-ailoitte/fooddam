import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/repo/auth_repo.dart';

class IsLoggedInUseCase implements UseCase<bool> {
  final AuthRepository repository;

  IsLoggedInUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call() {
    return repository.isLoggedIn();
  }
}