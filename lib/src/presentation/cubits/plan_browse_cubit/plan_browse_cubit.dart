// lib/src/presentation/cubits/plan_browse_cubit/plan_browse_cubit.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/src/domain/entities/plan_entity.dart';
import 'package:foodam/src/domain/usecase/plan/get_available_plan_usecase.dart';

part 'plan_browse_state.dart';

class PlanBrowseCubit extends Cubit<PlanBrowseState> {
  final GetAvailablePlansUseCase getAvailablePlansUseCase;
  
  PlanBrowseCubit({required this.getAvailablePlansUseCase}) 
      : super(PlanBrowseInitial());
  
  Future<void> loadAvailablePlans() async {
    emit(PlanBrowseLoading());
    
    final result = await getAvailablePlansUseCase();
    
    result.fold(
      (failure) => emit(PlanBrowseError('Failed to load plans')),
      (plans) => emit(PlanBrowseLoaded(plans: plans)),
    );
  }
  
  void selectPlan(Plan plan) {
    if (state is PlanBrowseLoaded) {
      final currentState = state as PlanBrowseLoaded;
      emit(PlanBrowseLoaded(
        plans: currentState.plans,
        selectedPlan: plan,
      ));
    }
  }
}