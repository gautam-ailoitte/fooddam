// lib/src/presentation/cubits/pacakge_cubits/pacakage_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/domain/entities/pacakge_entity.dart';
import 'package:foodam/src/domain/usecase/package_usecase.dart';
import 'package:foodam/src/presentation/cubits/pacakge_cubits/pacakage_state.dart';

/// Consolidated Package Cubit
///
/// This class manages the state for package-related features
class PackageCubit extends Cubit<PackageState> {
  final PackageUseCase _packageUseCase;
  final LoggerService _logger = LoggerService();

  PackageCubit({required PackageUseCase packageUseCase})
    : _packageUseCase = packageUseCase,
      super(const PackageInitial());

  /// Load all available packages
  Future<void> loadAllPackages() async {
    // Start timing for the entire operation
    final totalStopwatch = Stopwatch()..start();
    _logger.i('📊 Starting package list loading...');

    // Measure time to emit loading state
    final setupStopwatch = Stopwatch()..start();
    emit(const PackageLoading());
    setupStopwatch.stop();
    _logger.i(
      '📊 Emitted loading state in ${setupStopwatch.elapsedMilliseconds}ms',
    );

    // Measure API call time
    final apiStopwatch = Stopwatch()..start();
    _logger.i('📊 Starting API call to get all packages');
    final result = await _packageUseCase.getAllPackages();
    apiStopwatch.stop();
    _logger.i('📊 API call completed in ${apiStopwatch.elapsedMilliseconds}ms');

    // Measure processing time
    final processingStopwatch = Stopwatch()..start();

    result.fold(
      (failure) {
        _logger.e('Failed to get packages', error: failure);
        emit(PackageError(message: 'Failed to load available meal packages'));
      },
      (packages) {
        _logger.i('Packages loaded: ${packages.length} packages');

        // Sort packages by price as default
        final sortedPackages = List<Package>.from(packages);
        sortedPackages.sort((a, b) => a.price.compareTo(b.price));

        emit(PackageLoaded(packages: sortedPackages, sortOrder: 'price_asc'));
      },
    );

    processingStopwatch.stop();
    totalStopwatch.stop();

    // Log timing summary
    _logger.i(
      '📊 Processing time: ${processingStopwatch.elapsedMilliseconds}ms',
    );
    _logger.i('📊 Total loading time: ${totalStopwatch.elapsedMilliseconds}ms');
    _logger.i(
      '📊 Breakdown - Setup: ${setupStopwatch.elapsedMilliseconds}ms (${(setupStopwatch.elapsedMilliseconds / totalStopwatch.elapsedMilliseconds * 100).toStringAsFixed(1)}%), ' +
          'API: ${apiStopwatch.elapsedMilliseconds}ms (${(apiStopwatch.elapsedMilliseconds / totalStopwatch.elapsedMilliseconds * 100).toStringAsFixed(1)}%), ' +
          'Processing: ${processingStopwatch.elapsedMilliseconds}ms (${(processingStopwatch.elapsedMilliseconds / totalStopwatch.elapsedMilliseconds * 100).toStringAsFixed(1)}%)',
    );
  }

  /// Load a specific package by ID
  Future<void> loadPackageDetails(String packageId) async {
    // Start timing for the entire operation
    final totalStopwatch = Stopwatch()..start();
    _logger.i('⏱️ Starting package detail request for $packageId');

    // Measure time to emit loading state
    final setupStopwatch = Stopwatch()..start();
    emit(const PackageLoading());
    setupStopwatch.stop();
    _logger.i(
      '⏱️ Emitted loading state in ${setupStopwatch.elapsedMilliseconds}ms',
    );

    // Measure API call time
    final apiStopwatch = Stopwatch()..start();
    final result = await _packageUseCase.getPackageById(packageId);
    apiStopwatch.stop();
    _logger.i('⏱️ API call completed in ${apiStopwatch.elapsedMilliseconds}ms');

    // Measure processing time
    final processingStopwatch = Stopwatch()..start();

    result.fold(
      (failure) {
        _logger.e('Failed to get package details', error: failure);
        emit(PackageError(message: 'Failed to load package details'));
      },
      (package) {
        _logger.i('Package details loaded: ${package.id}');
        emit(PackageDetailLoaded(package: package));
      },
    );

    processingStopwatch.stop();
    totalStopwatch.stop();

    // Log timing summary
    _logger.i(
      '⏱️ Processing time: ${processingStopwatch.elapsedMilliseconds}ms',
    );
    _logger.i('⏱️ Total time: ${totalStopwatch.elapsedMilliseconds}ms');
    _logger.i(
      '⏱️ Breakdown - API: ${apiStopwatch.elapsedMilliseconds}ms (${(apiStopwatch.elapsedMilliseconds / totalStopwatch.elapsedMilliseconds * 100).toStringAsFixed(1)}%), ' +
          'Processing: ${processingStopwatch.elapsedMilliseconds}ms (${(processingStopwatch.elapsedMilliseconds / totalStopwatch.elapsedMilliseconds * 100).toStringAsFixed(1)}%)',
    );
  }

  /// Sort packages by price
  void sortPackagesByPrice(bool ascending) {
    final sortStopwatch = Stopwatch()..start();
    _logger.i('📊 Starting package sorting');

    if (state is! PackageLoaded) {
      _logger.w('Cannot sort: Not in PackageLoaded state');
      return; // Can only sort in loaded state
    }

    final currentState = state as PackageLoaded;
    final sortedPackages = List<Package>.from(currentState.packages);

    if (ascending) {
      sortedPackages.sort((a, b) => a.price.compareTo(b.price));
    } else {
      sortedPackages.sort((a, b) => b.price.compareTo(a.price));
    }

    emit(
      PackageLoaded(
        packages: sortedPackages,
        sortOrder: ascending ? 'price_asc' : 'price_desc',
      ),
    );

    sortStopwatch.stop();
    _logger.i(
      'Packages sorted by price (ascending=$ascending): ${sortedPackages.length} packages ' +
          'in ${sortStopwatch.elapsedMilliseconds}ms',
    );
  }

  /// Reset all filters
  void resetFilters() {
    if (state is PackageLoaded) {
      loadAllPackages(); // Simply reload to get original order
    }
  }
}
