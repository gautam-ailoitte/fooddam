import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/diet_pref_entity.dart';
import 'package:foodam/src/domain/repo/user_repo.dart';

class UpdateDietaryPreferencesUseCase implements UseCaseWithParams<void, List<DietaryPreference>> {
  final UserRepository repository;

  UpdateDietaryPreferencesUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(List<DietaryPreference> params) {
    return repository.updateDietaryPreferences(params);
  }
}
