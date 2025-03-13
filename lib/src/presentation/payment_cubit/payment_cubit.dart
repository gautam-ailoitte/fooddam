
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/string_constants.dart';
import 'package:foodam/src/domain/entities/user_entity.dart';
import 'package:foodam/src/domain/repo/user_repo.dart';

part 'payment_state.dart';


class PaymentCubit extends Cubit<PaymentState> {
  final PlanRepository planRepository;
  
  PaymentCubit({required this.planRepository}) : super(PaymentInitial());
  
  Future<void> initiatePayment(Plan plan) async {
    emit(PaymentProcessing());
    
    // Create final non-draft version
    final finalPlan = plan.copyWith(isDraft: false);
    
    // Try to get payment URL
    final result = await planRepository.savePlanAndGetPaymentUrl(finalPlan);
    
    result.fold(
      (failure) => emit(PaymentError(StringConstants.unexpectedError)),
      (paymentUrl) => emit(PaymentReady(plan: finalPlan, paymentUrl: paymentUrl)),
    );
  }
  
  void completePayment() {
    if (state is PaymentReady) {
      final currentState = state as PaymentReady;
      emit(PaymentCompleted(plan: currentState.plan));
    }
  }
  
  void reset() {
    emit(PaymentInitial());
  }
}