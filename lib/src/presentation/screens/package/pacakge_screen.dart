// lib/src/presentation/screens/package/pacakge_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/route/app_router.dart';
import 'package:foodam/core/widgets/app_loading.dart';
import 'package:foodam/core/widgets/error_display_wideget.dart';
import 'package:foodam/src/domain/entities/pacakge_entity.dart';
import 'package:foodam/src/presentation/cubits/pacakge_cubits/pacakage_cubit.dart';
import 'package:foodam/src/presentation/cubits/pacakge_cubits/pacakage_state.dart';
import 'package:foodam/src/presentation/widgets/pacakge_card.dart';

class PackagesScreen extends StatefulWidget {
  const PackagesScreen({super.key});

  @override
  State<PackagesScreen> createState() => _PackagesScreenState();
}

class _PackagesScreenState extends State<PackagesScreen> {
  bool _sortByPriceAsc = true;
  List<Package>? _cachedPackages; // Cache packages here

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  void _loadPackages() {
    // Only load if we don't have cached data
    if (_cachedPackages == null || _cachedPackages!.isEmpty) {
      context.read<PackageCubit>().loadPackages();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meal Packages'),
        actions: [
          // Sort button
          // IconButton(
          //   icon: Icon(
          //     _sortByPriceAsc ? Icons.arrow_upward : Icons.arrow_downward,
          //   ),
          //   tooltip:
          //   _sortByPriceAsc
          //       ? 'Sort by price (low to high)'
          //       : 'Sort by price (high to low)',
          //   onPressed: _toggleSortByPrice,
          // ),
          // Refresh button
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              // Force reload on refresh
              _cachedPackages = null;
              _loadPackages();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Force reload on pull-to-refresh
            _cachedPackages = null;
            _loadPackages();
            await Future.delayed(Duration(milliseconds: 300));
          },
          child: BlocConsumer<PackageCubit, PackageState>(
            listener: (context, state) {
              // Update cached packages when state changes to PackageLoaded
              if (state is PackageLoaded && state.hasPackages) {
                _cachedPackages = state.packages;
              }
            },
            builder: (context, state) {
              // If we're loading and don't have cached data yet
              if (state is PackageLoading && _cachedPackages == null) {
                return AppLoading(message: 'Loading packages...');
              }
              // If there's an error and no cached data
              else if (state is PackageError && _cachedPackages == null) {
                return ErrorDisplayWidget(
                  message: state.message,
                  onRetry: _loadPackages,
                );
              }
              // If we have cached data, or we're in a loaded/detail state
              else if (_cachedPackages != null && _cachedPackages!.isNotEmpty) {
                return _buildPackagesList(_cachedPackages!);
              }
              // If we have a loaded state but empty packages
              else if (state is PackageLoaded && state.isEmpty) {
                return _buildEmptyState();
              }
              // If we have a detail loaded state but no cached list
              else if (state is PackageDetailLoaded) {
                // We have at least one package from the detail state
                return _buildPackagesList([state.package]);
              }

              // Initial state or fallback
              return Center(child: Text('Start exploring meal packages'));
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
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
            ElevatedButton(
              onPressed: () {
                // Clear cache and force reload
                _cachedPackages = null;
                _loadPackages();
              },
              child: Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackagesList(List<Package> packages) {
    return ListView.builder(
      padding: EdgeInsets.all(AppDimensions.marginMedium),
      itemCount: packages.length,
      itemBuilder: (context, index) {
        final package = packages[index];
        return PackageCard(
          package: package,
          onTap: () {
            Navigator.of(
              context,
            ).pushNamed(AppRouter.packageDetailRoute, arguments: package).then((
              _,
            ) {
              // When returning from details, check if we need to refresh
              final currentState = context.read<PackageCubit>().state;
              if (currentState is PackageDetailLoaded) {
                // We were looking at a package detail, ensure it's in our cached list
                if (_cachedPackages != null) {
                  // Update the package in our cached list if it exists
                  final index = _cachedPackages!.indexWhere(
                    (p) => p.id == currentState.package.id,
                  );
                  if (index >= 0) {
                    setState(() {
                      _cachedPackages![index] = currentState.package;
                    });
                  } else {
                    // Add it to our cached list if not found
                    setState(() {
                      _cachedPackages!.add(currentState.package);
                    });
                  }
                }
              }
            });
          },
        );
      },
    );
  }
}
