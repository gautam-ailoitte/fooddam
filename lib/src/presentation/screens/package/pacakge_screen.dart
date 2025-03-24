// lib/features/packages/screens/packages_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/route/app_router.dart';
import 'package:foodam/core/widgets/app_loading.dart';
import 'package:foodam/core/widgets/error_display_wideget.dart';
import 'package:foodam/src/presentation/cubits/pacakge_cubits/pacakage_cubit.dart';
import 'package:foodam/src/presentation/cubits/pacakge_cubits/pacakage_state.dart';
import 'package:foodam/src/presentation/widgets/pacakge_card.dart';
import 'package:foodam/src/presentation/widgets/pacakge_filter.dart';

class PackagesScreen extends StatefulWidget {
  const PackagesScreen({super.key});

  @override
  _PackagesScreenState createState() => _PackagesScreenState();
}

class _PackagesScreenState extends State<PackagesScreen> {
  String? _currentFilter;
  bool _sortByPriceAsc = true;
  
  @override
  void initState() {
    super.initState();
    _loadPackages();
  }
  
  void _loadPackages() {
    context.read<PackageCubit>().loadAllPackages();
  }
  
  void _filterByType(String? type) {
    setState(() {
      _currentFilter = type;
    });
    
    if (type == null) {
      context.read<PackageCubit>().resetFilters();
    } else if (type == 'vegetarian') {
      context.read<PackageCubit>().filterPackagesByVegStatus(true);
    } else if (type == 'non-vegetarian') {
      context.read<PackageCubit>().filterPackagesByVegStatus(false);
    } else {
      context.read<PackageCubit>().filterPackagesByType(type);
    }
  }
  
  void _toggleSortByPrice() {
    setState(() {
      _sortByPriceAsc = !_sortByPriceAsc;
    });
    
    context.read<PackageCubit>().sortPackagesByPrice(_sortByPriceAsc);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meal Packages'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadPackages,
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            _loadPackages();
            await Future.delayed(Duration(milliseconds: 300));
          },
          child: Column(
            children: [
              // Filters section
              PackageFilter(
                currentFilter: _currentFilter,
                sortByPriceAsc: _sortByPriceAsc,
                onFilterSelected: _filterByType,
                onSortToggled: _toggleSortByPrice,
              ),
              
              // Packages list
              Expanded(
                child: BlocBuilder<PackageCubit, PackageState>(
                  builder: (context, state) {
                    if (state is PackageLoading) {
                      return AppLoading(message: 'Loading packages...');
                    } else if (state is PackageError) {
                      return ErrorDisplayWidget(
                        message: state.message,
                        onRetry: _loadPackages,
                      );
                    } else if (state is PackageLoaded) {
                      if (state.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(AppDimensions.marginLarge),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: Theme.of(context).disabledColor,
                                ),
                                SizedBox(height: AppDimensions.marginMedium),
                                Text(
                                  'No packages found',
                                  style: Theme.of(context).textTheme.titleLarge,
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: AppDimensions.marginSmall),
                                Text(
                                  'Try changing your filters or check back later for new packages',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      
                      return ListView.builder(
                        padding: EdgeInsets.all(AppDimensions.marginMedium),
                        itemCount: state.packages.length,
                        itemBuilder: (context, index) {
                          final package = state.packages[index];
                          return PackageCard(
                            package: package,
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                AppRouter.packageDetailRoute,
                                arguments: package,
                              );
                            },
                          );
                        },
                      );
                    }
                    
                    return Center(
                      child: Text('Start exploring meal packages'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}