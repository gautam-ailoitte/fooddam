// lib/src/presentation/cubits/package/package_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/domain/entities/pacakge_entity.dart';
import 'package:foodam/src/domain/usecase/pacakages/get_all_packages.dart';
import 'package:foodam/src/domain/usecase/pacakages/get_pacakges_by_idusecase.dart';
import 'package:foodam/src/presentation/cubits/pacakge_cubits/pacakage_state.dart';

class PackageCubit extends Cubit<PackageState> {
  final GetAllPackagesUseCase _getAllPackagesUseCase;
  final GetPackageByIdUseCase _getPackageByIdUseCase;
  final LoggerService _logger = LoggerService();

  PackageCubit({
    required GetAllPackagesUseCase getAllPackagesUseCase,
    required GetPackageByIdUseCase getPackageByIdUseCase,
  }) : 
    _getAllPackagesUseCase = getAllPackagesUseCase,
    _getPackageByIdUseCase = getPackageByIdUseCase,
    super(PackageInitial());

  Future<void> getAllPackages() async {
    emit(PackageLoading());
    
    final result = await _getAllPackagesUseCase();
    
    result.fold(
      (failure) {
        _logger.e('Failed to get packages', error: failure);
        emit(PackageError('Failed to load available meal packages'));
      },
      (packages) {
        _logger.i('Packages loaded: ${packages.length} packages');
        
        // Sort packages by price (optional)
        final sortedPackages = List<Package>.from(packages);
        sortedPackages.sort((a, b) => a.price.compareTo(b.price));
        
        emit(PackageLoaded(
          packages: sortedPackages,
          allPackages: sortedPackages,
        ));
      },
    );
  }

  Future<void> getPackageDetails(String packageId) async {
    emit(PackageLoading());
    
    final result = await _getPackageByIdUseCase(packageId);
    
    result.fold(
      (failure) {
        _logger.e('Failed to get package details', error: failure);
        emit(PackageError('Failed to load package details'));
      },
      (package) {
        _logger.i('Package details loaded: ${package.id}');
        emit(PackageDetailLoaded(package: package));
      },
    );
  }
  
  void filterPackagesByType(String? type) {
    if (state is PackageLoaded) {
      final currentState = state as PackageLoaded;
      final allPackages = currentState.allPackages;
      
      if (type == null || type.isEmpty) {
        emit(PackageLoaded(
          packages: allPackages,
          allPackages: allPackages,
          currentFilter: null
        ));
        return;
      }
      
      final filtered = allPackages.where((package) => 
        package.name.toLowerCase().contains(type.toLowerCase())).toList();
        
      emit(PackageLoaded(
        packages: filtered,
        allPackages: allPackages,
        currentFilter: type
      ));
    }
  }
  
  void filterPackagesByVegType(bool isVeg) {
    if (state is PackageLoaded) {
      final currentState = state as PackageLoaded;
      final allPackages = currentState.allPackages;
      
      final filtered = allPackages.where((package) => 
        package.name.toLowerCase().contains(
          isVeg ? 'veg' : 'non-veg'
        )).toList();
        
      emit(PackageLoaded(
        packages: filtered,
        allPackages: allPackages,
        currentFilter: isVeg ? 'vegetarian' : 'non-vegetarian'
      ));
    }
  }
  
  void resetFilters() {
    if (state is PackageLoaded) {
      final currentState = state as PackageLoaded;
      emit(PackageLoaded(
        packages: currentState.allPackages,
        allPackages: currentState.allPackages,
      ));
    }
  }
}