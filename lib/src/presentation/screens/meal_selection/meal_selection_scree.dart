// lib/src/presentation/screens/meal_selection/meal_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/constants/string_constants.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/core/widgets/app_loading.dart';
import 'package:foodam/core/widgets/primary_button.dart';
import 'package:foodam/core/widgets/secondary_button.dart';
import 'package:foodam/src/domain/entities/meal_slot_entity.dart';
import 'package:foodam/src/domain/entities/pacakge_entity.dart';
import 'package:foodam/src/presentation/cubits/subscription/create_subcription/create_subcription_cubit.dart';
import 'package:foodam/src/presentation/cubits/subscription/create_subcription/create_subcription_state.dart';

class MealSelectionScreen extends StatefulWidget {
  final Package package;
  final int personCount;
   DateTime startDate= DateTime.now();
  final int durationDays;

   MealSelectionScreen({
    super.key,
    required this.package,
    this.personCount = 1,
     
     this.durationDays= 7,
  });

  @override
  _MealSelectionScreenState createState() => _MealSelectionScreenState();
}

class _MealSelectionScreenState extends State<MealSelectionScreen> {
  final LoggerService _logger = LoggerService();
  
  // Store selected meal slots
  Map<String, Map<String, bool>> _selectedMealsByDay = {};
  List<MealSlot> _mealSlots = [];
  int _selectedMealCount = 0;
  int _totalMealCount = 0;
  
  final List<String> _mealTypes = ['breakfast', 'lunch', 'dinner'];
  final List<String> _dayNames = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
  
  @override
  void initState() {
    super.initState();
    _initializeSelectedMeals();
    _initializeMealSlots();
  }
  
  void _initializeSelectedMeals() {
    // Initialize selected meals based on the package
    for (var day in _dayNames) {
      _selectedMealsByDay[day] = {};
      for (var mealType in _mealTypes) {
        // Default to selected for all meal types
        _selectedMealsByDay[day]![mealType] = true;
      }
    }
    
    // Calculate total count and selected count
    _totalMealCount = _dayNames.length * _mealTypes.length;
    _selectedMealCount = _totalMealCount;
    
    _logger.i('Initialized selected meals: $_selectedMealsByDay');
  }
  
  void _initializeMealSlots() {
    _mealSlots = [];
    
    // Add all slots from the package
    for (var slot in widget.package.slots) {
      if (_dayNames.contains(slot.day.toLowerCase())) {
        _mealSlots.add(slot);
      }
    }
    
    _logger.i('Initialized meal slots: ${_mealSlots.length} slots');
  }
  
  void _toggleMealSelection(String day, String mealType) {
    setState(() {
      final currentValue = _selectedMealsByDay[day]?[mealType] ?? false;
      _selectedMealsByDay[day]?[mealType] = !currentValue;
      
      if (currentValue) {
        _selectedMealCount--;
      } else {
        _selectedMealCount++;
      }
    });
    
    _logger.d('Toggled meal selection - Day: $day, Meal: $mealType, Selected: ${_selectedMealsByDay[day]?[mealType]}');
  }

  List<MealSlot> _getSelectedMealSlots() {
    final List<MealSlot> selectedSlots = [];
    
    _selectedMealsByDay.forEach((day, meals) {
      meals.forEach((mealType, isSelected) {
        if (isSelected) {
          // Find the matching slot from the package
          final matchingSlot = widget.package.slots.firstWhere(
            (slot) => slot.day.toLowerCase() == day.toLowerCase() && 
                      slot.timing.toLowerCase() == mealType.toLowerCase(),
            orElse: () => MealSlot(
              day: day,
              timing: mealType,
              mealId: null, // Will be filled by backend
            ),
          );
          
          selectedSlots.add(matchingSlot);
        }
      });
    });
    
    return selectedSlots;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Distribute Your Meals'),
        elevation: 0,
      ),
      body: BlocListener<CreateSubscriptionCubit, CreateSubscriptionState>(
        listener: (context, state) {
          if (state is CreateSubscriptionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Column(
          children: [
            // Plan summary section
            _buildPlanSummary(),
            
            // Main content area - scrollable
            Expanded(
              child: _buildMealGrid(),
            ),
            
            // Bottom action buttons
            _buildBottomActionArea(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPlanSummary() {
    return Container(
      padding: EdgeInsets.all(AppDimensions.marginMedium),
      color: AppColors.primaryLight.withOpacity(0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Plan name and duration
          Text(
            'Plan: ${widget.package.name}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 4),
          
          // Date range display
          Text(
            'Duration: ${_formatDate(widget.startDate)} to ${_formatDate(widget.startDate.add(Duration(days: widget.durationDays - 1)))}',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 8),
          
          // Progress bar showing selected meals vs total
          Row(
            children: [
              Text(
                'Total Meals: $_totalMealCount',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              Spacer(),
              Text(
                'Selected: $_selectedMealCount',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          LinearProgressIndicator(
            value: _selectedMealCount / _totalMealCount,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          SizedBox(height: 16),
          
          // Tab navigation for meal selection
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTabButton(
                label: 'Distribute Meals',
                isActive: true,
                onTap: () {},
              ),
              _buildTabButton(
                label: 'Review Selection',
                isActive: false,
                onTap: () {
                  // Navigate to review screen (future implementation)
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildTabButton({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: isActive ? AppColors.primary : AppColors.textSecondary,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 4),
          Container(
            height: 2,
            width: 80,
            color: isActive ? AppColors.primary : Colors.transparent,
          ),
        ],
      ),
    );
  }
  
  Widget _buildMealGrid() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppDimensions.marginMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Meal selection instructions
          Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
              'Select meals for your subscription plan. Tap to toggle selection.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          
          // Meal type icons for the header
          Row(
            children: [
              SizedBox(width: 100), // Space for day column
              ...List.generate(_mealTypes.length, (index) {
                final mealType = _mealTypes[index];
                return Expanded(
                  child: _buildMealTypeHeader(mealType),
                );
              }),
            ],
          ),
          SizedBox(height: 8),
          
          // Grid of meals by day and type
          ...List.generate(_dayNames.length, (dayIndex) {
            final day = _dayNames[dayIndex];
            return _buildDayRow(day, dayIndex);
          }),
        ],
      ),
    );
  }
  
  Widget _buildMealTypeHeader(String mealType) {
    IconData icon;
    String label;
    
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        icon = Icons.free_breakfast;
        label = 'Breakfast';
        break;
      case 'lunch':
        icon = Icons.lunch_dining;
        label = 'Lunch';
        break;
      case 'dinner':
        icon = Icons.dinner_dining;
        label = 'Dinner';
        break;
      default:
        icon = Icons.restaurant;
        label = 'Meal';
    }
    
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: 24,
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
  
  Widget _buildDayRow(String day, int dayIndex) {
    bool isWeekend = day.toLowerCase() == 'saturday' || day.toLowerCase() == 'sunday';
    
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isWeekend ? AppColors.primaryLighter.withOpacity(0.3) : Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Day name column
          Container(
            width: 100,
            padding: EdgeInsets.all(AppDimensions.marginSmall),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _capitalizeFirst(day),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                if (dayIndex < 7) ...[
                  Text(
                    _formatDayWithDate(widget.startDate, dayIndex),
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Meal selection cells for this day
          ...List.generate(_mealTypes.length, (mealIndex) {
            final mealType = _mealTypes[mealIndex];
            return Expanded(
              child: _buildMealSelectionCell(day, mealType),
            );
          }),
        ],
      ),
    );
  }
  
  Widget _buildMealSelectionCell(String day, String mealType) {
    // Find the matching meal from the package
    final meal = widget.package.slots.firstWhere(
      (slot) => slot.day.toLowerCase() == day.toLowerCase() && 
                slot.timing.toLowerCase() == mealType.toLowerCase() &&
                slot.meal != null,
      orElse: () => MealSlot(day: day, timing: mealType, mealId: null),
    ).meal;
    
    final isSelected = _selectedMealsByDay[day]?[mealType] ?? false;
    
    return InkWell(
      onTap: () => _toggleMealSelection(day, mealType),
      child: Container(
        padding: EdgeInsets.all(AppDimensions.marginSmall),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
        ),
        child: Column(
          children: [
            // Checkbox indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.grey,
                      width: 2,
                    ),
                  ),
                  child: isSelected 
                      ? Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
              ],
            ),
            SizedBox(height: 4),
            
            // Meal name if available
            meal != null
                ? Text(
                    meal.name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  )
                : Text(
                    'Standard Meal',
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBottomActionArea() {
    return Container(
      padding: EdgeInsets.all(AppDimensions.marginLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
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
                  onPressed: isLoading || _selectedMealCount == 0
                      ? null 
                      : _continueToCheckout,
                  isLoading: isLoading,
                  icon: Icons.arrow_forward,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  void _continueToCheckout() {
    final selectedSlots = _getSelectedMealSlots();
    
    // Set meal distributions in the cubit
    final subscriptionCubit = context.read<CreateSubscriptionCubit>();
    
    @Deprecated('Use MealSlot instead')
    final mealDistributions = selectedSlots.map((slot) {
      return MealDistribution(
        day: slot.day,
        mealTime: slot.timing,
        mealId: slot.mealId,
      );
    }).toList();
    
    subscriptionCubit.setMealDistributions(mealDistributions, widget.personCount);
    
    // Navigate to checkout
    Navigator.of(context).pushNamed(
      '/checkout',
      arguments: {
        'packageId': widget.package.id,
        'mealSlots': selectedSlots,
        'personCount': widget.personCount,
      },
    );
  }
  
  // Helper methods
  String _formatDate(DateTime date) {
    return '${date.day} ${_getMonthName(date.month)}, ${date.year}';
  }
  
  String _formatDayWithDate(DateTime startDate, int dayOffset) {
    final date = startDate.add(Duration(days: dayOffset));
    return '${date.day} ${_getMonthName(date.month)}';
  }
  
  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
  
  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}