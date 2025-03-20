import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/user_entity.dart';
import 'package:foodam/src/domain/repo/user_repo.dart';

class GetUserDetailsUseCase implements UseCase<User> {
  final UserRepository repository;

  GetUserDetailsUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call() {
    return repository.getUserDetails();
  }
}