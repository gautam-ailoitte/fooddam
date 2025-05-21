// lib/src/presentation/cubits/package/package_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/domain/usecase/package_usecase.dart';

import 'pacakage_state.dart';

class PackageCubit extends Cubit<PackageState> {
  final PackageUseCase _packageUseCase;
  final LoggerService _logger = LoggerService();

  PackageCubit({required PackageUseCase packageUseCase})
    : _packageUseCase = packageUseCase,
      super(PackageInitial());

  /// Load all packages with optional dietary preference filter
  Future<void> loadPackages({String? dietaryPreference}) async {
    emit(PackageLoading());

    final result = await _packageUseCase.getAllPackages(
      dietaryPreference: dietaryPreference,
    );

    result.fold(
      (failure) {
        _logger.e('Failed to load packages', error: failure);
        emit(PackageError(failure.message ?? 'Failed to load packages'));
      },
      (packages) {
        _logger.i('Loaded ${packages.length} packages');
        emit(
          PackageLoaded(
            packages: packages,
            dietaryPreference: dietaryPreference,
          ),
        );
      },
    );
  }

  /// Load vegetarian packages
  Future<void> loadVegetarianPackages() async {
    await loadPackages(dietaryPreference: 'vegetarian');
  }

  /// Load non-vegetarian packages
  Future<void> loadNonVegetarianPackages() async {
    await loadPackages(dietaryPreference: 'non-vegetarian');
  }

  /// Load package details by ID
  Future<void> loadPackageDetails(String packageId) async {
    // If we're already viewing this package, don't reload
    if (state is PackageDetailLoaded &&
        (state as PackageDetailLoaded).package.id == packageId) {
      return;
    }

    emit(PackageLoading());

    final result = await _packageUseCase.getPackageById(packageId);

    result.fold(
      (failure) {
        _logger.e('Failed to load package details', error: failure);
        emit(PackageError(failure.message ?? 'Failed to load package details'));
      },
      (package) {
        _logger.i('Loaded details for package: ${package.id}');
        emit(PackageDetailLoaded(package: package));
      },
    );
  }

  /// Select meal count option and calculate price
  void selectMealCountOption(int mealCount) {
    if (state is! PackageDetailLoaded) {
      _logger.w('Cannot select meal count - no package loaded');
      return;
    }

    final currentState = state as PackageDetailLoaded;
    final package = currentState.package;

    // Find the price for this meal count
    final price = package.getPriceForMealCount(mealCount);

    emit(
      currentState.copyWith(selectedMealCount: mealCount, selectedPrice: price),
    );

    _logger.i('Selected meal count: $mealCount, price: $price');
  }

  /// Clear selected package details
  void clearSelectedPackage() {
    if (state is PackageDetailLoaded) {
      emit(PackageLoaded(packages: []));
    }
  }
}
