// lib/src/presentation/cubits/pacakge_cubits/pacakage_cubit.dart
// ignore_for_file: unused_element, unused_local_variable

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/domain/entities/meal_slot_entity.dart';
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
    emit(const PackageLoading());

    final result = await _packageUseCase.getAllPackages();

    result.fold(
      (failure) {
        _logger.e('Failed to get packages', error: failure);
        emit(PackageError(message: 'Failed to load available meal packages'));
      },
      (packages) {
        _logger.i('Packages loaded: ${packages.length} packages');

        // Process packages to ensure they have default slots for display
        final processedPackages =
            packages.map((package) {
              // If the package doesn't have slots, we'll create default ones for UI
              if (package.slots.isEmpty) {
                final defaultSlots = _packageUseCase.generateDefaultSlots();
                // We don't modify the entity here, but we'll handle this in the UI
                // or provide helper methods to get the default meal counts
              }
              return package;
            }).toList();

        // Sort packages by price (optional)
        final sortedPackages = List<Package>.from(processedPackages);
        sortedPackages.sort((a, b) => a.price.compareTo(b.price));

        emit(
          PackageLoaded(packages: sortedPackages, allPackages: sortedPackages),
        );
      },
    );
  }

  /// Load a specific package by ID
  Future<void> loadPackageDetails(String packageId) async {
    emit(const PackageLoading());

    final result = await _packageUseCase.getPackageById(packageId);

    result.fold(
      (failure) {
        _logger.e('Failed to get package details', error: failure);
        emit(PackageError(message: 'Failed to load package details'));
      },
      (package) {
        _logger.i('Package details loaded: ${package.id}');

        // If the package doesn't have slots, we'll use default ones for display
        final mealsBreakdown = _packageUseCase.getMealCountBreakdown(package);

        emit(PackageDetailLoaded(package: package));
      },
    );
  }

  /// Get meal count breakdown for a package
  Map<String, int> getMealCountBreakdown(Package package) {
    return _packageUseCase.getMealCountBreakdown(package);
  }

  /// Filter packages by type (vegetarian, non-vegetarian, etc.)
  Future<void> filterPackagesByType(String? type) async {
    if (state is! PackageLoaded) {
      await loadAllPackages();
      if (state is! PackageLoaded) return; // Guard against failure
    }

    if (type == null || type.isEmpty) {
      // If no type is specified, show all packages
      final currentState = state as PackageLoaded;
      emit(
        PackageLoaded(
          packages: currentState.allPackages,
          allPackages: currentState.allPackages,
        ),
      );
      return;
    }

    // Get all packages from current state
    final currentState = state as PackageLoaded;
    final allPackages = currentState.allPackages;

    // Filter packages by type
    final result = await _packageUseCase.filterPackagesByType(type);

    result.fold(
      (failure) {
        _logger.e('Failed to filter packages', error: failure);
        emit(PackageError(message: 'Failed to filter packages'));

        // Restore previous state
        emit(currentState);
      },
      (filteredPackages) {
        _logger.i(
          'Packages filtered by type "$type": ${filteredPackages.length} packages',
        );
        emit(
          PackageLoaded(
            packages: filteredPackages,
            allPackages: allPackages,
            currentFilter: type,
          ),
        );
      },
    );
  }

  /// Filter packages by vegetarian status
  Future<void> filterPackagesByVegStatus(bool isVeg) async {
    if (state is! PackageLoaded) {
      await loadAllPackages();
      if (state is! PackageLoaded) return; // Guard against failure
    }

    // Get all packages from current state
    final currentState = state as PackageLoaded;
    final allPackages = currentState.allPackages;

    // Filter packages by vegetarian status
    final result = await _packageUseCase.filterPackagesByVegStatus(isVeg);

    result.fold(
      (failure) {
        _logger.e('Failed to filter packages by veg status', error: failure);
        emit(PackageError(message: 'Failed to filter packages'));

        // Restore previous state
        emit(currentState);
      },
      (filteredPackages) {
        _logger.i(
          'Packages filtered by veg status (isVeg=$isVeg): ${filteredPackages.length} packages',
        );
        emit(
          PackageLoaded(
            packages: filteredPackages,
            allPackages: allPackages,
            currentFilter: isVeg ? 'vegetarian' : 'non-vegetarian',
          ),
        );
      },
    );
  }

  /// Sort packages by price
  Future<void> sortPackagesByPrice(bool ascending) async {
    if (state is! PackageLoaded) {
      await loadAllPackages();
      if (state is! PackageLoaded) return; // Guard against failure
    }

    // Get current state
    final currentState = state as PackageLoaded;

    // Sort packages by price
    final result = await _packageUseCase.sortPackagesByPrice(ascending);

    result.fold(
      (failure) {
        _logger.e('Failed to sort packages by price', error: failure);
        emit(PackageError(message: 'Failed to sort packages'));

        // Restore previous state
        emit(currentState);
      },
      (sortedPackages) {
        _logger.i(
          'Packages sorted by price (ascending=$ascending): ${sortedPackages.length} packages',
        );
        emit(
          PackageLoaded(
            packages: sortedPackages,
            allPackages: currentState.allPackages,
            currentFilter: currentState.currentFilter,
            sortOrder: ascending ? 'price_asc' : 'price_desc',
          ),
        );
      },
    );
  }

  /// Reset all filters
  void resetFilters() {
    if (state is PackageLoaded) {
      final currentState = state as PackageLoaded;
      emit(
        PackageLoaded(
          packages: currentState.allPackages,
          allPackages: currentState.allPackages,
        ),
      );
    }
  }

  // Helper method for creating default slots - for UI purposes
  List<MealSlot> _createDefaultSlots() {
    final List<MealSlot> slots = [];
    final days = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];
    final timings = ['breakfast', 'lunch', 'dinner'];

    for (var day in days) {
      for (var timing in timings) {
        slots.add(MealSlot(day: day, timing: timing));
      }
    }

    return slots;
  }
}
