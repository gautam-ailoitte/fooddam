// lib/src/presentation/cubits/payment/payment_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/domain/entities/payment_entity.dart';
import 'package:foodam/src/domain/entities/subscription_entity.dart';
import 'package:foodam/src/domain/entities/address_entity.dart';
import 'package:foodam/src/domain/entities/subscription_plan_entity.dart';
import 'package:foodam/src/domain/usecase/payment/processpayement_usecase.dart';
import 'package:foodam/src/domain/usecase/subscription/get_subscription_detail_usecase.dart';
import 'package:foodam/src/presentation/cubits/payment/payament_state.dart';
class PaymentCubit extends Cubit<PaymentState> {
  final ProcessPaymentUseCase _processPaymentUseCase;
  final GetSubscriptionDetailsUseCase _getSubscriptionDetailsUseCase;
  final LoggerService _logger = LoggerService();

  PaymentCubit({
    required ProcessPaymentUseCase processPaymentUseCase,
    required GetSubscriptionDetailsUseCase getSubscriptionDetailsUseCase,
  }) : 
    _processPaymentUseCase = processPaymentUseCase,
    _getSubscriptionDetailsUseCase = getSubscriptionDetailsUseCase,
    super(PaymentInitial());

  Future<void> processPayment({
    required String subscriptionId,
    required double amount,
    required PaymentMethod method,
    required Address deliveryAddress,
    required SubscriptionPlan plan, // Add plan parameter for fallback
  }) async {
    emit(PaymentProcessing(
      amount: amount,
      subscriptionId: subscriptionId,
      method: method,
    ));
    
    final params = PaymentParams(
      subscriptionId: subscriptionId,
      amount: amount,
      method: method,
    );
    
    final result = await _processPaymentUseCase(params);
    
    result.fold(
      (failure) {
        _logger.e('Payment processing failed', error: failure);
        emit(PaymentFailed(
          message: 'Payment processing failed. Please try again.',
          method: method,
        ));
      },
      (payment) async {
        _logger.i('Payment processed successfully: ${payment.id}');
        
        // Get updated subscription details
        final subscriptionResult = await _getSubscriptionDetailsUseCase(subscriptionId);
        
        subscriptionResult.fold(
          (failure) {
            _logger.e('Failed to get subscription after payment', error: failure);
            
            // Create a temporary subscription with limited info since we couldn't fetch it
            final tempSubscription = Subscription(
              id: subscriptionId,
              startDate: DateTime.now(),
              endDate: DateTime.now().add(Duration(days: 30)),
              planId: plan.id,
              deliveryAddress: deliveryAddress,
              deliveryInstructions: '',
              paymentStatus: PaymentStatus.paid,
              isPaused: false,
              subscriptionPlan: plan, // Use the provided plan instead of null
              status: SubscriptionStatus.active,
            );
            
            emit(PaymentSuccess(
              payment: payment,
              subscription: tempSubscription,
            ));
          },
          (subscription) {
            emit(PaymentSuccess(
              payment: payment,
              subscription: subscription,
            ));
          },
        );
      },
    );
  }

  void resetPayment() {
    emit(PaymentInitial());
  }
}