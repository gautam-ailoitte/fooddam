// lib/src/presentation/cubits/subscription/subscription_details_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/domain/entities/meal_order_entity.dart';
import 'package:foodam/src/domain/usecase/order/get_meal_order_bysubscription_usecase.dart';
import 'package:foodam/src/domain/usecase/subscription/get_subscription_detail_usecase.dart';
import 'package:foodam/src/domain/usecase/subscription/pause_subscription_usecase.dart';
import 'package:foodam/src/domain/usecase/subscription/resume_susbcription_usecase.dart';
import 'package:foodam/src/domain/usecase/subscription/cancel_susbcritpion_usecase.dart';
import 'package:foodam/src/presentation/cubits/susbcription_detail_cubit/subscription_detail_state.dart';
import 'package:foodam/src/presentation/utlis/date_formatter.dart';

class SubscriptionDetailsCubit extends Cubit<SubscriptionDetailsState> {
  final GetSubscriptionDetailsUseCase _getSubscriptionDetailsUseCase;
  final GetMealOrdersBySubscriptionUseCase _getMealOrdersBySubscriptionUseCase;
  final PauseSubscriptionUseCase _pauseSubscriptionUseCase;
  final ResumeSubscriptionUseCase _resumeSubscriptionUseCase;
  final CancelSubscriptionUseCase _cancelSubscriptionUseCase;
  final LoggerService _logger = LoggerService();
  final DateFormatter _dateFormatter = DateFormatter();

  SubscriptionDetailsCubit({
    required GetSubscriptionDetailsUseCase getSubscriptionDetailsUseCase,
    required GetMealOrdersBySubscriptionUseCase getMealOrdersBySubscriptionUseCase,
    required PauseSubscriptionUseCase pauseSubscriptionUseCase,
    required ResumeSubscriptionUseCase resumeSubscriptionUseCase,
    required CancelSubscriptionUseCase cancelSubscriptionUseCase,
  }) : 
    _getSubscriptionDetailsUseCase = getSubscriptionDetailsUseCase,
    _getMealOrdersBySubscriptionUseCase = getMealOrdersBySubscriptionUseCase,
    _pauseSubscriptionUseCase = pauseSubscriptionUseCase,
    _resumeSubscriptionUseCase = resumeSubscriptionUseCase,
    _cancelSubscriptionUseCase = cancelSubscriptionUseCase,
    super(SubscriptionDetailsInitial());

  Future<void> getSubscriptionDetails(String subscriptionId) async {
    emit(SubscriptionDetailsLoading());
    
    final subscriptionResult = await _getSubscriptionDetailsUseCase(subscriptionId);
    
    await subscriptionResult.fold(
      (failure) {
        _logger.e('Failed to get subscription details', error: failure);
        emit(SubscriptionDetailsError('Failed to load subscription details'));
      },
      (subscription) async {
        final ordersResult = await _getMealOrdersBySubscriptionUseCase(subscriptionId);
        
        ordersResult.fold(
          (failure) {
            _logger.e('Failed to get subscription orders', error: failure);
            // We still show the subscription, just without orders
            final daysRemaining = _calculateDaysRemaining(subscription.endDate);
            final totalMeals = _calculateTotalMeals(subscription);
            
            emit(SubscriptionDetailsLoaded(
              subscription: subscription,
              daysRemaining: daysRemaining,
              totalMeals: totalMeals,
              consumedMeals: 0, // Unknown since we couldn't load orders
            ));
          },
          (orders) {
            final daysRemaining = _calculateDaysRemaining(subscription.endDate);
            final totalMeals = _calculateTotalMeals(subscription);
            final consumedMeals = orders.where((order) => 
                order.status == OrderStatus.delivered).length;
            
            _logger.i('Subscription details loaded: ${subscription.id}');
            emit(SubscriptionDetailsLoaded(
              subscription: subscription,
              upcomingOrders: orders,
              daysRemaining: daysRemaining,
              totalMeals: totalMeals,
              consumedMeals: consumedMeals,
            ));
          },
        );
      },
    );
  }

  Future<void> pauseSubscription(String subscriptionId, DateTime untilDate) async {
    emit(SubscriptionDetailsActionInProgress('pause'));
    
    final params = PauseSubscriptionParams(
      subscriptionId: subscriptionId, 
      until: untilDate
    );
    
    final result = await _pauseSubscriptionUseCase(params);
    
    result.fold(
      (failure) {
        _logger.e('Failed to pause subscription', error: failure);
        emit(SubscriptionDetailsError('Failed to pause subscription'));
      },
      (_) {
        _logger.i('Subscription paused successfully: $subscriptionId');
        emit(SubscriptionDetailsActionSuccess(
          action: 'pause',
          message: 'Your subscription has been paused until ${_dateFormatter.formatDate(untilDate)}'
        ));
        // Refresh details after action
        getSubscriptionDetails(subscriptionId);
      },
    );
  }

  Future<void> resumeSubscription(String subscriptionId) async {
    emit(SubscriptionDetailsActionInProgress('resume'));
    
    final result = await _resumeSubscriptionUseCase(subscriptionId);
    
    result.fold(
      (failure) {
        _logger.e('Failed to resume subscription', error: failure);
        emit(SubscriptionDetailsError('Failed to resume subscription'));
      },
      (_) {
        _logger.i('Subscription resumed successfully: $subscriptionId');
        emit(SubscriptionDetailsActionSuccess(
          action: 'resume',
          message: 'Your subscription has been resumed successfully'
        ));
        // Refresh details after action
        getSubscriptionDetails(subscriptionId);
      },
    );
  }

  Future<void> cancelSubscription(String subscriptionId) async {
    emit(SubscriptionDetailsActionInProgress('cancel'));
    
    final result = await _cancelSubscriptionUseCase(subscriptionId);
    
    result.fold(
      (failure) {
        _logger.e('Failed to cancel subscription', error: failure);
        emit(SubscriptionDetailsError('Failed to cancel subscription'));
      },
      (_) {
        _logger.i('Subscription cancelled successfully: $subscriptionId');
        emit(SubscriptionDetailsActionSuccess(
          action: 'cancel',
          message: 'Your subscription has been cancelled'
        ));
      },
    );
  }

  int _calculateDaysRemaining(DateTime endDate) {
    final now = DateTime.now();
    final difference = endDate.difference(now).inDays;
    return difference > 0 ? difference : 0;
  }

  int _calculateTotalMeals(dynamic subscription) {
    // This is a placeholder - in a real app, you would calculate based on meal template
    return 21; // Example: 3 meals per day for 7 days
  }
}