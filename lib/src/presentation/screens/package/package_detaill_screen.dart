// lib/src/presentation/screens/package/package_detaill_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/theme/enhanced_app_them.dart';
import 'package:foodam/src/domain/entities/pacakge_entity.dart';
import 'package:foodam/src/domain/usecase/package_usecase.dart';
import 'package:foodam/src/presentation/cubits/subscription/create_subcription/create_subcription_cubit.dart';
import 'package:foodam/src/presentation/widgets/pacakage_mealsbyday,dart';
import 'package:foodam/src/presentation/widgets/person_count_selection_widget.dart';
import 'package:intl/intl.dart';
import 'package:foodam/injection_container.dart' as di;

class PackageDetailScreen extends StatefulWidget {
  final Package package;

  const PackageDetailScreen({super.key, required this.package});

  @override
  State<PackageDetailScreen> createState() => _PackageDetailScreenState();
}

class _PackageDetailScreenState extends State<PackageDetailScreen> {
  int _personCount = 1;
  DateTime _startDate = DateTime.now().add(
    Duration(days: 1),
  ); // Start tomorrow by default
  int _durationDays = 7; // Default to 7 days

  Package? _fullPackage;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPackageDetails();
  }

  Future<void> _loadPackageDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Get the package use case
      final packageUseCase = di.di<PackageUseCase>();

      // Fetch the full package details
      final result = await packageUseCase.getPackageById(widget.package.id);

      result.fold(
        (failure) {
          setState(() {
            _isLoading = false;
            _error = 'Failed to load package details: ${failure.message}';
          });
        },
        (fullPackage) {
          setState(() {
            _fullPackage = fullPackage;
            _isLoading = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'An error occurred: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use the full package if loaded, otherwise use the passed package
    final packageToUse = _fullPackage ?? widget.package;

    final isVegetarian =
        packageToUse.name.toLowerCase().contains('veg') &&
        !packageToUse.name.toLowerCase().contains('non-veg');

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Animated app bar with package image
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                packageToUse.name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 2,
                      color: Colors.black.withOpacity(0.5),
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors:
                        isVegetarian
                            ? [
                              AppColors.vegetarian.withOpacity(0.8),
                              AppColors.vegetarian,
                            ]
                            : [
                              AppColors.primary.withOpacity(0.8),
                              AppColors.primary,
                            ],
                  ),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Center(
                      child: Icon(
                        isVegetarian ? Icons.eco : Icons.restaurant,
                        size: 80,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                    // Gradient overlay for better text readability
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.5),
                            ],
                            stops: [0.6, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              if (isVegetarian)
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Chip(
                    label: Text(
                      'Vegetarian',
                      style: TextStyle(
                        color: AppColors.vegetarian,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    backgroundColor: Colors.white,
                    avatar: Icon(
                      Icons.eco,
                      color: AppColors.vegetarian,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),

          // Main content
          SliverToBoxAdapter(
            child:
                _isLoading
                    ? _buildLoadingContent()
                    : _error != null
                    ? _buildErrorContent()
                    : _buildMainContent(packageToUse),
          ),
        ],
      ),
      bottomNavigationBar:
          _isLoading || _error != null
              ? null // Don't show bottom bar if still loading or if there's an error
              : _buildBottomBar(packageToUse),
    );
  }

  Widget _buildLoadingContent() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading package details...'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorContent() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red),
            SizedBox(height: 16),
            Text(_error ?? 'An error occurred'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPackageDetails,
              child: Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(Package packageToUse) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Package description
          Card(
            elevation: 0,
            margin: EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              decoration: EnhancedTheme.cardDecoration,
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About This Plan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    packageToUse.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildPackageStats(packageToUse),
                ],
              ),
            ),
          ),

          // Start date selection
          Card(
            elevation: 0,
            margin: EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              decoration: EnhancedTheme.cardDecoration,
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Plan Start Date',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'When would you like to start receiving meals?',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildDatePicker(),
                ],
              ),
            ),
          ),

          // Duration selection
          Card(
            elevation: 0,
            margin: EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              decoration: EnhancedTheme.cardDecoration,
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Plan Duration',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'How long would you like this subscription?',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildDurationSelector(),
                ],
              ),
            ),
          ),

          // Person count selection
          Card(
            elevation: 0,
            margin: EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              decoration: EnhancedTheme.cardDecoration,
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Number of People',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'How many people will be enjoying these meals?',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 16),
                  PersonCountSelector(
                    value: _personCount,
                    onChanged: (value) {
                      setState(() {
                        _personCount = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          // Meals included section - show only if fullPackage is loaded
          if (_fullPackage != null && _fullPackage!.slots.isNotEmpty)
            Card(
              elevation: 0,
              margin: EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                decoration: EnhancedTheme.cardDecoration,
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Meals Included',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    PackageDayMeals(slots: _fullPackage!.slots),
                  ],
                ),
              ),
            ),
          // Placeholder for meals if not loaded yet
          if (_fullPackage == null || _fullPackage!.slots.isEmpty)
            Card(
              elevation: 0,
              margin: EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                decoration: EnhancedTheme.cardDecoration,
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Meals Included',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Center(
                      child:
                          _isLoading
                              ? CircularProgressIndicator()
                              : Text('Meal information not available'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPackageStats(Package packageToUse) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatColumn(
          icon: Icons.restaurant_menu,
          // Use package slots count if available, otherwise fallback to a default
          value:
              packageToUse.slots.isNotEmpty
                  ? '${packageToUse.slots.length}'
                  : '21',
          label: 'Meals',
          color: AppColors.primary,
        ),
        _buildStatColumn(
          icon: Icons.calendar_today,
          value: '7',
          label: 'Days',
          color: Colors.blue,
        ),
        _buildStatColumn(
          icon: Icons.people,
          value: '$_personCount',
          label: 'People',
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildStatColumn({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: _showStartDatePicker,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary),
          color: AppColors.primary.withOpacity(0.05),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: AppColors.primary),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Starting From',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  DateFormat('EEEE, MMMM d, yyyy').format(_startDate),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Spacer(),
            Icon(Icons.arrow_drop_down, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Future<void> _showStartDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().add(Duration(days: 1)),
      lastDate: DateTime.now().add(Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Widget _buildDurationSelector() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDurationOption(7, 'Week'),
            SizedBox(width: 16),
            _buildDurationOption(14, '2 Weeks'),
            SizedBox(width: 16),
            _buildDurationOption(30, 'Month'),
          ],
        ),
        SizedBox(height: 16),
        // Row(
        //   children: [
        //     Expanded(
        //       child: Slider(
        //         value: _durationDays.toDouble(),
        //         min: 7,
        //         max: 30,
        //         divisions: 23,
        //         label: '$_durationDays days',
        //         activeColor: AppColors.primary,
        //         inactiveColor: AppColors.primary.withOpacity(0.2),
        //         onChanged: (double value) {
        //           setState(() {
        //             _durationDays = value.round();
        //           });
        //         },
        //       ),
        //     ),
        //   ],
        // ),
        Text(
          'Duration: $_durationDays days',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildDurationOption(int days, String label) {
    final isSelected = _durationDays == days;

    return InkWell(
      onTap: () {
        setState(() {
          _durationDays = days;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ]
                  : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(Package packageToUse) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Price',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '₹${(packageToUse.price * _personCount).toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                if (_personCount > 1)
                  Text(
                    '₹${packageToUse.price.toStringAsFixed(0)} × $_personCount',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // Set the package ID in the cubit before navigating
                context.read<CreateSubscriptionCubit>().selectPackage(
                  packageToUse.id,
                );

                // Set subscription details
                context.read<CreateSubscriptionCubit>().setSubscriptionDetails(
                  startDate: _startDate,
                  durationDays: _durationDays,
                );

                // Then navigate to meal selection
                Navigator.of(context).pushNamed(
                  '/meal-selection',
                  arguments: {
                    'package': _fullPackage ?? packageToUse,
                    'personCount': _personCount,
                    'startDate': _startDate,
                    'durationDays': _durationDays,
                  },
                );
              },
              style: EnhancedTheme.primaryButtonStyle,
              child: Text('Choose Meals'),
            ),
          ),
        ],
      ),
    );
  }
}
