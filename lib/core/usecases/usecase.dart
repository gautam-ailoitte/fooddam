// lib/src/domain/usecases/base_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';

/// Base class for use cases that don't take parameters and return a value
abstract class UseCase<Type> {
  Future<Either<Failure, Type>> call();
}

/// Base class for use cases that take parameters and return a value
abstract class UseCaseWithParams<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Base class for use cases that don't return a value (fire and forget)
abstract class UseCaseNoReturn<Params> {
  Future<Either<Failure, void>> call(Params params);
}

/// Base class for use cases that don't take parameters and don't return a value
abstract class UseCaseNoParamsNoReturn {
  Future<Either<Failure, void>> call();
}