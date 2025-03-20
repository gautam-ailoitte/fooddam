
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/address_entity.dart';
import 'package:foodam/src/domain/repo/user_repo.dart';

class UpdateAddressUseCase implements UseCaseWithParams<void, Address> {
  final UserRepository repository;

  UpdateAddressUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(Address params) {
    return repository.updateAddress(params);
  }
}