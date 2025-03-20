// lib/src/presentation/cubits/subscription/subscription_plans_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/domain/usecase/subscription/getsubscription_usecase.dart';
import 'package:foodam/src/presentation/cubits/subscription_plan/subscription_plan_state.dart';


class SubscriptionPlansCubit extends Cubit<SubscriptionPlansState> {
  final GetSubscriptionPlansUseCase _getSubscriptionPlansUseCase;
  final LoggerService _logger = LoggerService();

  SubscriptionPlansCubit({
    required GetSubscriptionPlansUseCase getSubscriptionPlansUseCase,
  }) : 
    _getSubscriptionPlansUseCase = getSubscriptionPlansUseCase,
    super(SubscriptionPlansInitial());

  Future<void> getSubscriptionPlans() async {
    emit(SubscriptionPlansLoading());
    
    final result = await _getSubscriptionPlansUseCase();
    
    result.fold(
      (failure) {
        _logger.e('Failed to get subscription plans', error: failure);
        emit(SubscriptionPlansError('Failed to load subscription plans'));
      },
      (plans) {
        _logger.i('Subscription plans loaded: ${plans.length} plans');
        emit(SubscriptionPlansLoaded(
          plans: plans,
          filteredPlans: plans,
        ));
      },
    );
  }

  void filterPlansByType(String type) {
    if (state is SubscriptionPlansLoaded) {
      final currentState = state as SubscriptionPlansLoaded;
      
      if (type.isEmpty) {
        emit(SubscriptionPlansLoaded(
          plans: currentState.plans,
          filteredPlans: currentState.plans,
          currentFilter: null,
        ));
        return;
      }
      
      final filtered = currentState.plans.where((plan) {
        return plan.name.toLowerCase().contains(type.toLowerCase());
      }).toList();
      
      emit(SubscriptionPlansLoaded(
        plans: currentState.plans,
        filteredPlans: filtered,
        currentFilter: type,
      ));
    }
  }

  void filterPlansByDuration(String duration) {
    if (state is SubscriptionPlansLoaded) {
      final currentState = state as SubscriptionPlansLoaded;
      
      if (duration.isEmpty) {
        emit(SubscriptionPlansLoaded(
          plans: currentState.plans,
          filteredPlans: currentState.plans,
          currentFilter: null,
        ));
        return;
      }
      
      // This would be more sophisticated in a real app
      // Here we're just doing a simple name-based filter
      final filtered = currentState.plans.where((plan) {
        return plan.name.toLowerCase().contains(duration.toLowerCase());
      }).toList();
      
      emit(SubscriptionPlansLoaded(
        plans: currentState.plans,
        filteredPlans: filtered,
        currentFilter: duration,
      ));
    }
  }
}