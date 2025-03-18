import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/user_entity.dart';
import 'package:foodam/src/domain/repo/user_repo.dart';

class CheckAuthStatusUseCase implements UseCase<User?> {
  final AuthRepository authRepository;

  CheckAuthStatusUseCase({required this.authRepository});

  @override
  Future<Either<Failure, User?>> call() async {
    final isLoggedInResult = await authRepository.isLoggedIn();
    
    return isLoggedInResult.fold(
      (failure) => Left(failure),
      (isLoggedIn) async {
        if (isLoggedIn) {
          final userResult = await authRepository.getCurrentUser();
          return userResult;
        } else {
          return const Right(null);
        }
      },
    );
  }
}