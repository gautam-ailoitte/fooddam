import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  Failure(String s);

  @override
  List<Object> get props => [];
}

class ServerFailure extends Failure {}

class CacheFailure extends Failure {}

class NetworkFailure extends Failure {}

class UnauthorizedFailure extends Failure {}

class UnexpectedFailure extends Failure {}