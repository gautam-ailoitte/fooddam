// lib/src/presentation/cubits/subscription/active_subscriptions_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/domain/entities/subscription_entity.dart';
import 'package:foodam/src/domain/usecase/subscription/getactivesubscription_usecase.dart';
import 'package:foodam/src/presentation/cubits/susbcription_management_cubit/susbcription_management_cubit_state.dart';

class ActiveSubscriptionsCubit extends Cubit<ActiveSubscriptionsState> {
  final GetActiveSubscriptionsUseCase _getActiveSubscriptionsUseCase;
  final LoggerService _logger = LoggerService();

  ActiveSubscriptionsCubit({
    required GetActiveSubscriptionsUseCase getActiveSubscriptionsUseCase,
  }) : 
    _getActiveSubscriptionsUseCase = getActiveSubscriptionsUseCase,
    super(ActiveSubscriptionsInitial());

  Future<void> getActiveSubscriptions() async {
    emit(ActiveSubscriptionsLoading());
    
    final result = await _getActiveSubscriptionsUseCase();
    
    result.fold(
      (failure) {
        _logger.e('Failed to get active subscriptions', error: failure);
        emit(ActiveSubscriptionsError('Failed to load your subscriptions'));
      },
      (subscriptions) {
        final active = subscriptions.where((sub) => 
          sub.status == SubscriptionStatus.active && !sub.isPaused).toList();
          
        final paused = subscriptions.where((sub) => 
          sub.status == SubscriptionStatus.paused || sub.isPaused).toList();
        
        _logger.i('Active subscriptions loaded: ${subscriptions.length} subscriptions');
        emit(ActiveSubscriptionsLoaded(
          subscriptions: subscriptions,
          activeSubscriptions: active,
          pausedSubscriptions: paused,
        ));
      },
    );
  }
}