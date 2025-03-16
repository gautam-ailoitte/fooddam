import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/plan_entity.dart';
import 'package:foodam/src/domain/repo/plan_repo.dart';

class CompletePaymentParams extends Equatable {
  final Plan plan;
  final String transactionId;

  const CompletePaymentParams({
    required this.plan,
    required this.transactionId,
  });

  @override
  List<Object?> get props => [plan, transactionId];
}

class CompletePaymentUseCase implements UseCaseWithParams<Plan, CompletePaymentParams> {
  final PlanRepository planRepository;

  CompletePaymentUseCase({required this.planRepository});

  @override
  Future<Either<Failure, Plan>> call(CompletePaymentParams params) {
    // In a real implementation, this would validate the payment and activate the plan
    // For now, we'll just mark the plan as non-draft and return it
    final completedPlan = params.plan.copyWith(isDraft: false);
    
    // The repository could have a method for finalizing a plan after payment
    // For now, let's just return the completed plan
    return Future.value(Right(completedPlan));
  }
}