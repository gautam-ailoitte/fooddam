// lib/features/meal_selection/screens/meal_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/route/app_router.dart';
import 'package:foodam/core/widgets/primary_button.dart';
import 'package:foodam/core/widgets/secondary_button.dart';
import 'package:foodam/src/domain/entities/meal_slot_entity.dart';
import 'package:foodam/src/domain/entities/pacakge_entity.dart';
import 'package:foodam/src/presentation/cubits/subscription/create_subcription/create_subcription_cubit.dart';
import 'package:foodam/src/presentation/cubits/subscription/create_subcription/create_subcription_state.dart';
import 'package:foodam/src/presentation/widgets/meal_selection_widgets.dart';

class MealSelectionScreen extends StatefulWidget {
  final Package package;
  final int personCount;

  const MealSelectionScreen({
    super.key,
    required this.package,
    this.personCount = 1,
  });

  @override
  _MealSelectionScreenState createState() => _MealSelectionScreenState();
}

class _MealSelectionScreenState extends State<MealSelectionScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
  
  // State to track selected meals for each day and meal type
  Map<String, Map<String, bool>> _selectedSlots = {};
  
  // Selected meal slots
  List<MealSlot> _mealSlots = [];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _weekdays.length, vsync: this);
    
    // Initialize selected slots from package
    _initializeSelectedSlots();
    
    // Initialize meal slots from package
    _initializeMealSlots();
  }
  
  void _initializeSelectedSlots() {
    _selectedSlots = {};
    
    // Initialize for all weekdays and meal types
    for (var day in _weekdays) {
      _selectedSlots[day.toLowerCase()] = {
        'breakfast': true,
        'lunch': true,
        'dinner': true,
      };
    }
  }
  
  void _initializeMealSlots() {
    _mealSlots = [];
    
    // Add all slots from the package initially
    for (var slot in widget.package.slots) {
      if (_weekdays.contains(slot.day.toLowerCase().capitalize())) {
        _mealSlots.add(slot);
      }
    }
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose Your Meals'),
      ),
      body: Column(
        children: [
          // Tab bar for days
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              tabs: _weekdays.map((day) => DayTab(day: day)).toList(),
            ),
          ),
          
          // Tab views for each day
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _weekdays.map((day) => _buildDayTabContent(day)).toList(),
            ),
          ),
          
          // Bottom summary and action buttons
          _buildBottomActionArea(),
        ],
      ),
    );
  }

  Widget _buildBottomActionArea() {
    // Calculate total meals
    int totalMeals = 0;
    
    for (var day in _selectedSlots.keys) {
      for (var mealType in _selectedSlots[day]!.keys) {
        if (_selectedSlots[day]![mealType] == true) {
          totalMeals++;
        }
      }
    }
    
    // Multiply by person count
    totalMeals *= widget.personCount;
    
    return Container(
      padding: EdgeInsets.all(AppDimensions.marginLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Selected Meals:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                '$totalMeals',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.marginLarge),
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  text: 'Back',
                  onPressed: () => Navigator.pop(context),
                  icon: Icons.arrow_back,
                ),
              ),
              SizedBox(width: AppDimensions.marginMedium),
              Expanded(
                child: BlocBuilder<CreateSubscriptionCubit, CreateSubscriptionState>(
                  builder: (context, state) {
                    final isLoading = state is CreateSubscriptionLoading;
                    
                    return PrimaryButton(
                      text: 'Continue',
                      onPressed: isLoading ? null : () => _continueToCheckout(),
                      isLoading: isLoading,
                      icon: Icons.arrow_forward,
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _continueToCheckout() {
    // Update meal slots based on selected toggles
    _updateMealSlots();
    
    // Continue to checkout
    Navigator.of(context).pushNamed(
      AppRouter.checkoutRoute,
      arguments: {
        'packageId': widget.package.id,
        'mealSlots': _mealSlots,
        'personCount': widget.personCount,
      },
    );
  }

  void _updateMealSlots() {
    List<MealSlot> updatedSlots = [];
    
    // For each day and meal type, add slot if selected
    for (var day in _selectedSlots.keys) {
      for (var mealType in _selectedSlots[day]!.keys) {
        if (_selectedSlots[day]![mealType] == true) {
          // Find the slot in the package
          final slot = widget.package.slots.firstWhere(
            (slot) => 
                slot.day.toLowerCase() == day.toLowerCase() && 
                slot.timing.toLowerCase() == mealType.toLowerCase(),
            orElse: () => MealSlot(
              day: day,
              timing: mealType,
              mealId: null,
            ),
          );
          
          updatedSlots.add(slot);
        }
      }
    }
    
    _mealSlots = updatedSlots;
  }

  Widget _buildDayTabContent(String day) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppDimensions.marginMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breakfast section
          _buildMealTypeSection(day, 'Breakfast'),
          SizedBox(height: AppDimensions.marginLarge),
          
          // Lunch section
          _buildMealTypeSection(day, 'Lunch'),
          SizedBox(height: AppDimensions.marginLarge),
          
          // Dinner section
          _buildMealTypeSection(day, 'Dinner'),
        ],
      ),
    );
  }

  Widget _buildMealTypeSection(String day, String mealType) {
    final dayLower = day.toLowerCase();
    final mealTypeLower = mealType.toLowerCase();
    
    // Find the meal for this day and meal type from the package
    final slot = widget.package.slots.firstWhere(
      (slot) => 
          slot.day.toLowerCase() == dayLower && 
          slot.timing.toLowerCase() == mealTypeLower,
      orElse: () => MealSlot(
        day: dayLower,
        timing: mealTypeLower,
        mealId: null,
      ),
    );
    
    // Check if this slot is selected
    final isSelected = _selectedSlots[dayLower]?[mealTypeLower] ?? false;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with toggle switch
        MealTypeHeader(
          title: mealType,
          isSelected: isSelected,
          onToggle: (value) {
            setState(() {
              if (_selectedSlots.containsKey(dayLower)) {
                _selectedSlots[dayLower]![mealTypeLower] = value;
              } else {
                _selectedSlots[dayLower] = {mealTypeLower: value};
              }
            });
          },
        ),
        SizedBox(height: AppDimensions.marginMedium),
        
        // Meal card or empty state
        if (isSelected && slot.meal != null)
          MealSelectionCard(meal: slot.meal!)
        else if (isSelected)
          _buildEmptyMealState(mealType)
        else
          _buildDisabledMealState(mealType),
      ],
    );
  }

  Widget _buildEmptyMealState(String mealType) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.marginLarge),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
        border: Border.all(color: Color(0xFFE0E0E0)),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 48,
              color: AppColors.primary.withOpacity(0.5),
            ),
            SizedBox(height: AppDimensions.marginMedium),
            Text(
              'Meal Information Not Available',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppDimensions.marginSmall),
            Text(
              'The package includes a meal for this slot but detailed information is not available',
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisabledMealState(String mealType) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.marginLarge),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
        border: Border.all(color: Color(0xFFE0E0E0).withOpacity(0.5)),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.do_not_disturb,
              size: 48,
              color: Color(0xFFE0E0E0),
            ),
            SizedBox(height: AppDimensions.marginMedium),
            Text(
              '$mealType Disabled',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFE0E0E0),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppDimensions.marginSmall),
            Text(
              'Toggle the switch above to include this meal',
              style: TextStyle(
                color: Color(0xFFE0E0E0),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Extension to capitalize first letter of a string
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}