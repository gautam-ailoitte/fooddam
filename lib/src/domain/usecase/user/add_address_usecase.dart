import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/address_entity.dart';
import 'package:foodam/src/domain/repo/user_repo.dart';

class AddAddressUseCase extends UseCaseWithParams<Address, Address> {
  final UserRepository repository;

  AddAddressUseCase(this.repository);

  @override
  Future<Either<Failure, Address>> call(Address params) {
    return repository.addAddress(params);
  }
}