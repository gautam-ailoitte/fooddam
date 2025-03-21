import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/user_entity.dart';
import 'package:foodam/src/domain/repo/user_repo.dart';

class UpdateUserDetailsUseCase implements UseCaseWithParams<void, User> {
  final UserRepository repository;

  UpdateUserDetailsUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(User params) {
    return repository.updateUserDetails(params);
  }
}