// lib/src/presentation/screens/package/package_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/theme/enhanced_app_them.dart';
import 'package:foodam/src/domain/entities/pacakge_entity.dart';
import 'package:foodam/src/presentation/cubits/pacakge_cubits/pacakage_cubit.dart';
import 'package:foodam/src/presentation/cubits/pacakge_cubits/pacakage_state.dart';
import 'package:foodam/src/presentation/cubits/subscription/create_subcription/create_subcription_cubit.dart';
import 'package:foodam/src/presentation/widgets/person_count_selection_widget.dart';
import 'package:intl/intl.dart';

class PackageDetailScreen extends StatefulWidget {
  final Package package;

  const PackageDetailScreen({super.key, required this.package});

  @override
  State<PackageDetailScreen> createState() => _PackageDetailScreenState();
}

class _PackageDetailScreenState extends State<PackageDetailScreen> {
  int _personCount = 1;
  DateTime _startDate = DateTime.now().add(const Duration(days: 1));
  int _durationDays = 7;
  int? _selectedMealCount; // 10, 15, 18, or 21
  double _selectedPrice = 0;

  @override
  void initState() {
    super.initState();
    _loadPackageDetails();
  }

  void _loadPackageDetails() {
    context.read<PackageCubit>().loadPackageDetails(widget.package.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<PackageCubit, PackageState>(
        builder: (context, state) {
          if (state is PackageLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PackageError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadPackageDetails,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final packageToDisplay =
              state is PackageDetailLoaded ? state.package : widget.package;

          return _buildPackageDetailContent(packageToDisplay);
        },
      ),
      bottomNavigationBar: SafeArea(child: _buildBottomBar()),
    );
  }

  Widget _buildPackageDetailContent(Package package) {
    final isVegetarian = package.isVegetarian;

    return CustomScrollView(
      slivers: [
        // App bar with package image
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              package.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 2,
                    color: Colors.black45,
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
                      color: Colors.white.withOpacity(0.3),
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
                  label: const Text(
                    'Vegetarian',
                    style: TextStyle(
                      color: AppColors.vegetarian,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  backgroundColor: Colors.white,
                  avatar: const Icon(
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
          child: Padding(
            padding: EdgeInsets.all(AppDimensions.marginMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Package description
                _buildDescriptionCard(package),
                SizedBox(height: AppDimensions.marginMedium),

                // Meal count selection - NEW
                _buildMealCountSelectionCard(package),
                SizedBox(height: AppDimensions.marginMedium),

                // Start date selection
                _buildStartDateCard(),
                SizedBox(height: AppDimensions.marginMedium),

                // Duration selection
                _buildDurationCard(),
                SizedBox(height: AppDimensions.marginMedium),

                // Person count selection
                _buildPersonCountCard(),
                SizedBox(height: AppDimensions.marginMedium),

                // Package info
                _buildPackageInfoCard(package),
                SizedBox(height: AppDimensions.marginLarge),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionCard(Package package) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: EnhancedTheme.cardDecoration,
        padding: EdgeInsets.all(AppDimensions.marginMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'About This Plan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppDimensions.marginSmall),
            Text(
              package.description,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealCountSelectionCard(Package package) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: EnhancedTheme.cardDecoration,
        padding: EdgeInsets.all(AppDimensions.marginMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Meals Per Week',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppDimensions.marginSmall),
            const Text(
              'Choose how many meals you want per week',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            SizedBox(height: AppDimensions.marginMedium),

            // Meal count options
            if (package.priceOptions != null &&
                package.priceOptions!.isNotEmpty)
              ...package.priceOptions!.map((option) {
                final isSelected = _selectedMealCount == option.numberOfMeals;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMealCount = option.numberOfMeals;
                      _selectedPrice = option.price;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: AppDimensions.marginSmall),
                    padding: EdgeInsets.all(AppDimensions.marginMedium),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? AppColors.primary.withOpacity(0.1)
                              : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            isSelected
                                ? AppColors.primary
                                : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? AppColors.primary
                                    : Colors.grey.shade200,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${option.numberOfMeals}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color:
                                    isSelected
                                        ? Colors.white
                                        : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: AppDimensions.marginMedium),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${option.numberOfMeals} meals per week',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _getMealBreakdown(option.numberOfMeals),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '₹${option.price.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color:
                                    isSelected
                                        ? AppColors.primary
                                        : AppColors.textPrimary,
                              ),
                            ),
                            const Text(
                              'per week',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList()
            else
              const Center(child: Text('No meal options available')),
          ],
        ),
      ),
    );
  }

  Widget _buildStartDateCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: EnhancedTheme.cardDecoration,
        padding: EdgeInsets.all(AppDimensions.marginMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Start Date',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppDimensions.marginSmall),
            const Text(
              'When would you like to start?',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            SizedBox(height: AppDimensions.marginMedium),
            InkWell(
              onTap: _showStartDatePicker,
              child: Container(
                padding: EdgeInsets.all(AppDimensions.marginMedium),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary),
                  color: AppColors.primary.withOpacity(0.05),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: AppColors.primary),
                    SizedBox(width: AppDimensions.marginMedium),
                    Expanded(
                      child: Text(
                        DateFormat('EEEE, MMMM d, yyyy').format(_startDate),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: EnhancedTheme.cardDecoration,
        padding: EdgeInsets.all(AppDimensions.marginMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Duration',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppDimensions.marginSmall),
            const Text(
              'How long would you like this subscription?',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            SizedBox(height: AppDimensions.marginMedium),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildDurationOption(7, '1 Week'),
                  const SizedBox(width: 4),
                  _buildDurationOption(14, '2 Weeks'),
                  const SizedBox(width: 4),
                  _buildDurationOption(21, '3 Weeks'),
                  const SizedBox(width: 4),
                  _buildDurationOption(28, '4 Weeks'),
                ],
              ),
            ),
          ],
        ),
      ),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
          ),
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

  Widget _buildPersonCountCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: EnhancedTheme.cardDecoration,
        padding: EdgeInsets.all(AppDimensions.marginMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Number of People',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppDimensions.marginSmall),
            const Text(
              'How many people will be enjoying these meals?',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            SizedBox(height: AppDimensions.marginMedium),
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
    );
  }

  Widget _buildPackageInfoCard(Package package) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: EnhancedTheme.cardDecoration,
        padding: EdgeInsets.all(AppDimensions.marginMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Package Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppDimensions.marginMedium),
            _buildInfoRow('Week Number', 'Week ${package.week}'),
            _buildInfoRow('Total Slots', '${package.noOfSlots}'),
            _buildInfoRow(
              'Dietary Preference',
              package.isVegetarian ? 'Vegetarian' : 'Non-Vegetarian',
            ),
            _buildInfoRow('Status', package.isActive ? 'Active' : 'Inactive'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppDimensions.marginSmall),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final canProceed = _selectedMealCount != null;
    final numberOfWeeks = (_durationDays / 7).ceil();
    final totalPrice = _selectedPrice * _personCount * numberOfWeeks;

    return Container(
      padding: EdgeInsets.all(AppDimensions.marginMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -4),
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
                const Text(
                  'Total Price',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (canProceed) ...[
                  Text(
                    '₹${totalPrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    '₹${_selectedPrice} × $_personCount × $numberOfWeeks weeks',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ] else
                  const Text(
                    'Select meal count',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: AppDimensions.marginMedium),
          Expanded(
            child: ElevatedButton(
              onPressed: canProceed ? _proceedToMealSelection : null,
              style: EnhancedTheme.primaryButtonStyle,
              child: const Text('Select Meals'),
            ),
          ),
        ],
      ),
    );
  }

  void _proceedToMealSelection() {
    if (_selectedMealCount == null) return;

    final package =
        context.read<PackageCubit>().state is PackageDetailLoaded
            ? (context.read<PackageCubit>().state as PackageDetailLoaded)
                .package
            : widget.package;

    // Update subscription creation cubit with selection
    context.read<SubscriptionCreationCubit>().selectPackageAndMealCount(
      package: package,
      mealCount: _selectedMealCount!,
      startDate: _startDate,
      durationDays: _durationDays,
    );

    // Navigate to meal selection WITH ARGUMENTS
    Navigator.pushNamed(
      context,
      '/meal-selection',
      arguments: {
        'package': package,
        'selectedMealCount': _selectedMealCount,
        'selectedPrice': _selectedPrice,
        'startDate': _startDate,
        'durationDays': _durationDays,
        'personCount': _personCount,
      },
    );
  }

  Future<void> _showStartDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
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

  String _getMealBreakdown(int mealCount) {
    // Simple breakdown logic - you can adjust this
    switch (mealCount) {
      case 10:
        return 'Perfect for trying out our service';
      case 15:
        return 'Ideal for regular meal planning';
      case 18:
        return 'Great for families';
      case 21:
        return 'Complete meal coverage - 3 meals daily';
      default:
        return '$mealCount meals throughout the week';
    }
  }
}
