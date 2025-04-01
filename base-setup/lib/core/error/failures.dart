import 'package:equatable/equatable.dart';

import '../util/app_constant.dart';

/// Parent class for all failures in Domain Layer\
/// Parent class for all failures in Domain Layer
abstract class Failure extends Equatable {
  final String message;

  const Failure({
    this.message = AppConstant.errorUnknown,
  });

  @override
  List<Object> get props => [];
}

/// Remote failure in Domain Layer
class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
  });
}

/// Cache failure in Domain Layer
class CacheFailure extends Failure {
  // final String message;

  const CacheFailure({required super.message});
}
