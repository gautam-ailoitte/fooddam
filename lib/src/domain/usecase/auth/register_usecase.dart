import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/repo/auth_repo.dart';



class RegisterUseCase implements UseCaseWithParams<String, RegisterParams> {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(RegisterParams params) {
    return repository.register(params.email, params.password, params.phone);
  }
}

class RegisterParams {
  final String email;
  final String password;
  final String phone;

  RegisterParams({
    required this.email, 
    required this.password,
    required this.phone,
  });
}
