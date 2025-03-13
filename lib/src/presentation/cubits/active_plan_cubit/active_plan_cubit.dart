import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/src/domain/entities/user_entity.dart';
import 'package:foodam/src/domain/repo/user_repo.dart';

part 'active_plan_state.dart';
class ActivePlanCubit extends Cubit<ActivePlanState> {
  final PlanRepository planRepository;
  
  ActivePlanCubit({required this.planRepository}) : super(ActivePlanInitial());
  
  Future<void> loadActivePlan() async {
    emit(ActivePlanLoading());
    final result = await planRepository.getActivePlan();
    result.fold(
      (failure) => emit(ActivePlanError('Failed to load active plan')),
      (plan) => emit(plan != null 
          ? ActivePlanNotFound()
          : ActivePlanNotFound()),

          //? ActivePlanLoaded(activePlan: plan) 
    );
  }
  
  void setActivePlan(Plan plan) {
    emit(ActivePlanLoaded(activePlan: plan));
  }
}