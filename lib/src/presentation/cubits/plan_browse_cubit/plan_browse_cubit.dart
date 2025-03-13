

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/src/domain/entities/user_entity.dart';
import 'package:foodam/src/domain/repo/user_repo.dart';

part 'plan_browse_state.dart';
class PlanBrowseCubit extends Cubit<PlanBrowseState> {
  final PlanRepository planRepository;
  
  PlanBrowseCubit({required this.planRepository}) : super(PlanBrowseInitial());
  
  Future<void> loadAvailablePlans() async {
    emit(PlanBrowseLoading());
    final result = await planRepository.getAvailablePlans();
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