// lib/src/presentation/cubits/subscription/active_subscription_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';
import 'package:foodam/src/domain/usecase/subscription/getactivesubscription_usecase.dart';
import 'package:foodam/src/presentation/cubits/active_subscription_cubit/active_subscription_state.dart';

class ActiveSubscriptionCubit extends Cubit<ActiveSubscriptionState> {
  final GetActiveSubscriptionsUseCase _getActiveSubscriptionsUseCase;
  final LoggerService _logger = LoggerService();

  ActiveSubscriptionCubit({
    required GetActiveSubscriptionsUseCase getActiveSubscriptionsUseCase,
  }) : 
    _getActiveSubscriptionsUseCase = getActiveSubscriptionsUseCase,
    super(ActiveSubscriptionInitial());

  Future<void> getActiveSubscriptions() async {
    emit(ActiveSubscriptionLoading());
    
    final result = await _getActiveSubscriptionsUseCase();
    
    result.fold(
      (failure) {
        _logger.e('Failed to get active subscriptions', error: failure);
        emit(ActiveSubscriptionError('Failed to load your subscriptions'));
      },
      (subscriptions) {
        // Separate active and paused subscriptions
        final active = subscriptions.where((sub) => 
          sub.status == SubscriptionStatus.active && !sub.isPaused).toList();
          
        final paused = subscriptions.where((sub) => 
          sub.status == SubscriptionStatus.paused || sub.isPaused).toList();
        
        _logger.i('Active subscriptions loaded: ${subscriptions.length} subscriptions');
        emit(ActiveSubscriptionLoaded(
          subscriptions: subscriptions,
          activeSubscriptions: active,
          pausedSubscriptions: paused,
        ));
      },
    );
  }
  
  // Filter subscriptions by status
  void filterByStatus(SubscriptionStatus status) {
    if (state is ActiveSubscriptionLoaded) {
      final currentState = state as ActiveSubscriptionLoaded;
      final filtered = currentState.subscriptions
          .where((sub) => sub.status == status)
          .toList();
      
      emit(ActiveSubscriptionFiltered(
        subscriptions: currentState.subscriptions,
        activeSubscriptions: currentState.activeSubscriptions,
        pausedSubscriptions: currentState.pausedSubscriptions,
        filteredSubscriptions: filtered,
        filterType: 'status',
        filterValue: status.toString(),
      ));
    }
  }
  
  // Clear any applied filters
  void clearFilters() {
    if (state is ActiveSubscriptionFiltered) {
      final currentState = state as ActiveSubscriptionFiltered;
      
      emit(ActiveSubscriptionLoaded(
        subscriptions: currentState.subscriptions,
        activeSubscriptions: currentState.activeSubscriptions,
        pausedSubscriptions: currentState.pausedSubscriptions,
      ));
    }
  }
}