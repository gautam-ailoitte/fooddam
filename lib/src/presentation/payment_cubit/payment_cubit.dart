// lib/src/presentation/payment_cubit/payment_cubit.dart
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
    
    try {
      // Create final non-draft version
      final finalPlan = plan.copyWith(isDraft: false);
      
      // Recalculate plan price to ensure it's up to date
      double totalPrice = 0.0;
      finalPlan.mealsByDay.forEach((day, meals) {
        totalPrice += meals.dailyTotal;
      });
      
      // Apply any duration-based discounts
      switch (finalPlan.duration) {
        case PlanDuration.sevenDays:
          // No discount for 7 days
          break;
        case PlanDuration.fourteenDays:
          // 5% discount for 14 days
          totalPrice = totalPrice * 0.95;
          break;
        case PlanDuration.twentyEightDays:
          // 10% discount for 28 days
          totalPrice = totalPrice * 0.90;
          break;
      }
      
      // Get payment URL
      final result = await planRepository.savePlanAndGetPaymentUrl(finalPlan);
      
      result.fold(
        (failure) => emit(PaymentError(StringConstants.unexpectedError)),
        (paymentUrl) => emit(PaymentReady(plan: finalPlan, paymentUrl: paymentUrl)),
      );
    } catch (e) {
      emit(PaymentError('Error initiating payment: ${e.toString()}'));
    }
  }
  
  void completePayment() {
    if (state is PaymentReady) {
      final currentState = state as PaymentReady;
      
      // Set start and end dates
      final startDate = DateTime.now();
      DateTime endDate;
      
      switch (currentState.plan.duration) {
        case PlanDuration.sevenDays:
          endDate = startDate.add(Duration(days: 7));
          break;
        case PlanDuration.fourteenDays:
          endDate = startDate.add(Duration(days: 14));
          break;
        case PlanDuration.twentyEightDays:
          endDate = startDate.add(Duration(days: 28));
          break;
      }
      
      // Create completed plan with dates
      final completedPlan = currentState.plan.copyWith(
        startDate: startDate,
        endDate: endDate,
        isDraft: false,
      );
      
      emit(PaymentCompleted(plan: completedPlan));
    }
  }
  
  void reset() {
    emit(PaymentInitial());
  }
}