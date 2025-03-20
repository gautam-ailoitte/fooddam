

import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/address_entity.dart';
import 'package:foodam/src/domain/repo/user_repo.dart';

class GetUserAddressesUseCase implements UseCase<List<Address>> {
  final UserRepository repository;

  GetUserAddressesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Address>>> call() {
    return repository.getUserAddresses();
  }
}