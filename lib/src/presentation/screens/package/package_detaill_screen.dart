// lib/src/presentation/screens/package/enhanced_package_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/route/app_router.dart';
import 'package:foodam/core/theme/enhanced_app_them.dart';
import 'package:foodam/src/domain/entities/meal_entity.dart';
import 'package:foodam/src/domain/entities/pacakge_entity.dart';
import 'package:foodam/src/presentation/cubits/subscription/create_subcription/create_subcription_cubit.dart';
import 'package:foodam/src/presentation/widgets/person_count_selection_widget.dart';
import 'package:intl/intl.dart';

class PackageDetailScreen extends StatefulWidget {
  final Package package;

  const PackageDetailScreen({
    super.key,
    required this.package,
  });

  @override
  State<PackageDetailScreen> createState() => _EnhancedPackageDetailScreenState();
}

class _EnhancedPackageDetailScreenState extends State<PackageDetailScreen> {
  int _personCount = 1;
  DateTime _startDate = DateTime.now().add(Duration(days: 1)); // Start tomorrow by default
  int _durationDays = 7; // Default to 7 days

  @override
  Widget build(BuildContext context) {
    final isVegetarian = widget.package.name.toLowerCase().contains('veg') &&
        !widget.package.name.toLowerCase().contains('non-veg');

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Animated app bar with package image
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.package.name,
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
                    colors: isVegetarian
                        ? [AppColors.vegetarian.withOpacity(0.8), AppColors.vegetarian]
                        : [AppColors.primary.withOpacity(0.8), AppColors.primary],
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
            child: Padding(
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
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            widget.package.description,
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 16),
                          _buildPackageStats(),
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
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
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
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
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
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
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
                  
                  // Sample meals section
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
                            'Sample Meals',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          _buildSampleMeals(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildPackageStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatColumn(
          icon: Icons.restaurant_menu,
          value: '${widget.package.slots.length}',
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
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
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
            Icon(
              Icons.calendar_today,
              color: AppColors.primary,
            ),
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
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Spacer(),
            Icon(
              Icons.arrow_drop_down,
              color: AppColors.primary,
            ),
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
        Row(
          children: [
            Expanded(
              child: Slider(
                value: _durationDays.toDouble(),
                min: 7,
                max: 30,
                divisions: 23,
                label: '$_durationDays days',
                activeColor: AppColors.primary,
                inactiveColor: AppColors.primary.withOpacity(0.2),
                onChanged: (double value) {
                  setState(() {
                    _durationDays = value.round();
                  });
                },
              ),
            ),
          ],
        ),
        Text(
          'Duration: $_durationDays days',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
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
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.2),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ] : null,
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

  Widget _buildSampleMeals() {
    // Get unique meals from the package slots
    final mealIds = <String>{};
    final meals = widget.package.slots
        .where((slot) => slot.mealId != null && mealIds.add(slot.mealId!))
        .map((slot) => slot.meal)
        .where((meal) => meal != null)
        .take(3)
        .toList();

    return Column(
      children: meals.map((meal) => _buildMealItem(meal!)).toList(),
    );
  }

  Widget _buildMealItem(Meal meal) {
    final isVegetarian = meal.dietaryPreferences?.contains('vegetarian') ?? false;
    
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Meal image or placeholder
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: (isVegetarian ? AppColors.vegetarian : AppColors.nonVegetarian).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(
                isVegetarian ? Icons.eco : Icons.restaurant,
                color: isVegetarian ? AppColors.vegetarian : AppColors.nonVegetarian,
                size: 30,
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        meal.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    if (isVegetarian)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.vegetarian.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.eco, size: 12, color: AppColors.vegetarian),
                            SizedBox(width: 2),
                            Text(
                              'Veg',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.vegetarian,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  meal.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),
                // Text(
                //   'Includes ${meal.dishes.length} items',
                //   style: TextStyle(
                //     fontSize: 12,
                //     color: AppColors.primary,
                //     fontWeight: FontWeight.w500,
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
Widget _buildBottomBar() {
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
                '₹${(widget.package.price * _personCount).toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              if (_personCount > 1)
                Text(
                  '₹${widget.package.price.toStringAsFixed(0)} × $_personCount',
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
              context.read<CreateSubscriptionCubit>().selectPackage(widget.package.id);
              
              // Set subscription details
              context.read<CreateSubscriptionCubit>().setSubscriptionDetails(
                startDate: _startDate,
                durationDays: _durationDays,
              );
              
              // Then navigate to meal selection
              Navigator.of(context).pushNamed(
                AppRouter.mealSelectionRoute,
                arguments: {
                  'package': widget.package,
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
