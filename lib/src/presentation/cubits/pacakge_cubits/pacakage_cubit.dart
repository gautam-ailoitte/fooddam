// lib/src/presentation/cubits/pacakge_cubits/pacakage_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/domain/entities/pacakge_entity.dart';
import 'package:foodam/src/domain/usecase/package_usecase.dart';

import 'pacakage_state.dart';

class PackageCubit extends Cubit<PackageState> {
  final PackageUseCase _packageUseCase;
  final LoggerService _logger = LoggerService();

  // Cache all packages to avoid re-fetching
  List<Package>? _cachedPackages;

  PackageCubit({required PackageUseCase packageUseCase})
    : _packageUseCase = packageUseCase,
      super(PackageInitial());

  /// Load all packages and cache them
  Future<void> loadPackages() async {
    // If we have cached packages and not in error state, return cached data
    if (_cachedPackages != null && state is! PackageError) {
      emit(PackageLoaded(packages: _cachedPackages!));
      return;
    }

    emit(PackageLoading());

    final result = await _packageUseCase.getAllPackages();

    result.fold(
      (failure) {
        _logger.e('Failed to load packages', error: failure);
        emit(PackageError(failure.message ?? 'Failed to load packages'));
      },
      (packages) {
        _logger.i('Loaded ${packages.length} packages');
        // Cache the packages
        _cachedPackages = packages;
        emit(PackageLoaded(packages: packages));
      },
    );
  }

  /// Force refresh packages (pull-to-refresh, retry)
  Future<void> refreshPackages() async {
    _cachedPackages = null; // Clear cache
    await loadPackages();
  }

  /// Load package details by ID (always fresh API call)
  Future<void> loadPackageDetail(String packageId) async {
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

  /// Return to cached package list from detail view
  void returnToPackageList() {
    if (_cachedPackages != null) {
      emit(PackageLoaded(packages: _cachedPackages!));
    } else {
      // If no cache, reload
      loadPackages();
    }
  }

  /// Clear all cache (for logout, etc.)
  void clearCache() {
    _cachedPackages = null;
    emit(PackageInitial());
  }
}
