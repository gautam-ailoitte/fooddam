// lib/src/presentation/screens/package/pacakge_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
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

class _PackagesScreenState extends State<PackagesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _sortByPriceAsc = true;

  // UI-level filter state - no cubit state emissions
  String? _currentFilter;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _currentFilter = null; // Start with "All"
    _loadPackages();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadPackages() {
    context.read<PackageCubit>().loadPackages();
  }

  void _refreshPackages() {
    context.read<PackageCubit>().refreshPackages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            _refreshPackages();
            await Future.delayed(const Duration(milliseconds: 300));
          },
          child: Column(
            children: [
              // Filter tabs
              _buildFilterTabs(),

              // Sort options
              _buildSortOptions(),

              // Package list
              Expanded(
                child: BlocBuilder<PackageCubit, PackageState>(
                  builder: (context, state) {
                    if (state is PackageLoading) {
                      return const AppLoading(
                        message: 'Loading meal packages...',
                      );
                    }

                    if (state is PackageError) {
                      return ErrorDisplayWidget(
                        message: state.message,
                        onRetry: _loadPackages,
                      );
                    }

                    if (state is PackageLoaded) {
                      // UI-level filtering and sorting
                      final allPackages = state.packages;
                      final filteredPackages = state.getFilteredPackages(
                        _currentFilter,
                      );
                      final displayPackages = state.getSortedPackages(
                        filteredPackages,
                        ascending: _sortByPriceAsc,
                      );

                      if (displayPackages.isEmpty) {
                        return _buildEmptyState(allPackages.isNotEmpty);
                      }

                      return _buildPackagesList(displayPackages);
                    }

                    return _buildInitialState();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Meal Packages'),
      centerTitle: true,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _refreshPackages,
          tooltip: 'Refresh packages',
        ),
      ],
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      margin: EdgeInsets.all(AppDimensions.marginMedium),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
      ),
      child: TabBar(
        controller: _tabController,
        onTap: (index) {
          setState(() {
            switch (index) {
              case 0:
                _currentFilter = null; // All packages
                break;
              case 1:
                _currentFilter = 'vegetarian';
                break;
              case 2:
                _currentFilter = 'non-vegetarian';
                break;
            }
          });
        },
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'Vegetarian'),
          Tab(text: 'Non-Veg'),
        ],
      ),
    );
  }

  Widget _buildSortOptions() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppDimensions.marginMedium),
      child: Row(
        children: [
          Icon(Icons.sort, color: AppColors.textSecondary, size: 20),
          SizedBox(width: AppDimensions.marginSmall),
          const Text(
            'Sort by:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(width: AppDimensions.marginSmall),
          InkWell(
            onTap: () {
              setState(() {
                _sortByPriceAsc = !_sortByPriceAsc;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Price',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _sortByPriceAsc ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 14,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          BlocBuilder<PackageCubit, PackageState>(
            builder: (context, state) {
              if (state is PackageLoaded) {
                final filteredCount =
                    state.getFilteredPackages(_currentFilter).length;
                return Text(
                  '$filteredCount packages',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool hasAllPackages) {
    String emptyMessage = 'No packages found';
    String emptySubMessage = 'Try adjusting your filters or refresh the list';

    if (hasAllPackages) {
      // We have packages but current filter shows none
      if (_currentFilter == 'vegetarian') {
        emptyMessage = 'No vegetarian packages found';
        emptySubMessage = 'Try browsing all packages or non-vegetarian options';
      } else if (_currentFilter == 'non-vegetarian') {
        emptyMessage = 'No non-vegetarian packages found';
        emptySubMessage = 'Try browsing all packages or vegetarian options';
      }
    }

    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.marginLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasAllPackages ? Icons.filter_list_off : Icons.search_off,
              size: 80,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: AppDimensions.marginMedium),
            Text(
              emptyMessage,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppDimensions.marginSmall),
            Text(
              emptySubMessage,
              style: TextStyle(color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppDimensions.marginLarge),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (hasAllPackages) ...[
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _currentFilter = null;
                        _tabController.animateTo(0);
                      });
                    },
                    child: const Text('Show All'),
                  ),
                  SizedBox(width: AppDimensions.marginMedium),
                ],
                ElevatedButton(
                  onPressed: _refreshPackages,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Refresh'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_menu, size: 64, color: Colors.grey.shade400),
          SizedBox(height: AppDimensions.marginMedium),
          Text(
            'Explore Our Meal Packages',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: Colors.grey.shade600),
          ),
          SizedBox(height: AppDimensions.marginSmall),
          ElevatedButton(
            onPressed: _loadPackages,
            child: const Text('Browse Packages'),
          ),
        ],
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
            Navigator.pushNamed(
              context,
              AppRouter.packageDetailRoute,
              arguments: package,
            ).then((_) {
              // When returning from detail, restore the package list
              context.read<PackageCubit>().returnToPackageList();
            });
          },
        );
      },
    );
  }
}
