import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/repo/user_repo.dart';

class UpdatePasswordParams {
  final String currentPassword;
  final String newPassword;

  UpdatePasswordParams({
    required this.currentPassword,
    required this.newPassword,
  });
}

class UpdatePasswordUseCase extends UseCaseWithParams<bool, UpdatePasswordParams> {
  final UserRepository repository;

  UpdatePasswordUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(UpdatePasswordParams params) {
    return repository.updatePassword(params.currentPassword, params.newPassword);
  }
}
