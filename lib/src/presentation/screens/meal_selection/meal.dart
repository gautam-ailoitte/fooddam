// // lib/src/presentation/screens/meal_distribution/meal_distribution_screen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:foodam/core/constants/app_colors.dart';
// import 'package:foodam/core/constants/string_constants.dart';
// import 'package:foodam/core/layout/app_spacing.dart';
// import 'package:foodam/core/widgets/app_loading.dart';
// import 'package:foodam/core/widgets/error_display_wideget.dart';
// import 'package:foodam/core/widgets/primary_button.dart';
// import 'package:foodam/core/widgets/secondary_button.dart';
// import 'package:foodam/src/domain/entities/meal_slot_entity.dart';
// import 'package:foodam/src/domain/entities/pacakge_entity.dart';
// import 'package:foodam/src/presentation/cubits/subscription/create_subcription/create_subcription_cubit.dart';
// import 'package:foodam/src/presentation/cubits/subscription/create_subcription/create_subcription_state.dart';
// import 'package:intl/intl.dart';

// class MealDistributionScreen extends StatefulWidget {
//   final Package package;
//   final int personCount;
//   final DateTime startDate;
//   final int durationDays;

//   const MealDistributionScreen({
//     Key? key,
//     required this.package,
//     this.personCount = 1,
//     required this.startDate,
//     required this.durationDays,
//   }) : super(key: key);

//   @override
//   State<MealDistributionScreen> createState() => _MealDistributionScreenState();
// }

// class _MealDistributionScreenState extends State<MealDistributionScreen> with SingleTickerProviderStateMixin {
//   final List<String> _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
//   final List<String> _mealTypes = ['Breakfast', 'Lunch', 'Dinner'];
//   late TabController _tabController;
  
//   // Map to track selected meals
//   Map<String, Map<String, bool>> _selectedMeals = {};
//   int _totalSelectedMeals = 0;
//   int _maxMeals = 0;
  
//   // Editing state tracker
//   bool _hasChanges = false;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     _initializeSelectedMeals();
//     _calculateMaxMeals();
//   }
  
//   void _initializeSelectedMeals() {
//     // Initialize all days and meal types as selected by default
//     for (String day in _days) {
//       _selectedMeals[day] = {};
//       for (String mealType in _mealTypes) {
//         _selectedMeals[day]![mealType] = true;
//       }
//     }
    
//     // Count total initially selected meals
//     _countSelectedMeals();
//   }
  
//   void _calculateMaxMeals() {
//     // Calculate max meals based on duration
//     _maxMeals = widget.durationDays * 3; // 3 meals per day
//   }
  
//   void _countSelectedMeals() {
//     int count = 0;
//     for (var day in _selectedMeals.keys) {
//       for (var mealType in _selectedMeals[day]!.keys) {
//         if (_selectedMeals[day]![mealType] == true) {
//           count++;
//         }
//       }
//     }
//     setState(() {
//       _totalSelectedMeals = count;
//     });
//   }

//   void _toggleMeal(String day, String mealType) {
//     setState(() {
//       // Toggle the selection status
//       _selectedMeals[day]![mealType] = !(_selectedMeals[day]![mealType] ?? false);
//       _countSelectedMeals();
//       _hasChanges = true;
//     });
//   }
  
//   // Build the meal slots based on selections
//   List<MealSlot> _buildMealSlots() {
//     List<MealSlot> slots = [];
    
//     for (String day in _selectedMeals.keys) {
//       for (String mealType in _selectedMeals[day]!.keys) {
//         if (_selectedMeals[day]![mealType] == true) {
//           // Find the corresponding meal from the package
//           final packageSlot = widget.package.slots.firstWhere(
//             (slot) => 
//                 slot.day.toLowerCase() == day.toLowerCase() && 
//                 slot.timing.toLowerCase() == mealType.toLowerCase(),
//             orElse: () => MealSlot(
//               day: day.toLowerCase(),
//               timing: mealType.toLowerCase(),
//               mealId: null,
//             ),
//           );
          
//           slots.add(MealSlot(
//             day: day.toLowerCase(),
//             timing: mealType.toLowerCase(),
//             mealId: packageSlot.mealId,
//             meal: packageSlot.meal,
//           ));
//         }
//       }
//     }
    
//     return slots;
//   }
  
//   void _saveAndContinue() {
//     final mealSlots = _buildMealSlots();
    
//     @Deprecated('Use MealSlot instead')
//     final mealDistributions = mealSlots.map((slot) {
//       return MealDistribution(
//         day: slot.day,
//         mealTime: slot.timing,
//         mealId: slot.mealId,
//       );
//     }).toList();
    
//     // Save to cubit
//     final cubit = context.read<CreateSubscriptionCubit>();
//     cubit.setMealDistributions(mealDistributions, widget.personCount);
    
//     // Navigate to checkout
//     Navigator.of(context).pushNamed(
//       '/checkout',
//       arguments: {
//         'packageId': widget.package.id,
//         'mealSlots': mealSlots,
//         'personCount': widget.personCount,
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Distribute Your Meals'),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           onPressed: () {
//             if (_hasChanges) {
//               _showDiscardChangesDialog();
//             } else {
//               Navigator.pop(context);
//             }
//           },
//         ),
//         elevation: 0,
//       ),
//       body: Column(
//         children: [
//           // Plan info header
//           _buildPlanInfoHeader(),
          
//           // Tab bar for switching views
//           _buildTabBar(),
          
//           // Tab views
//           Expanded(
//             child: TabBarView(
//               controller: _tabController,
//               children: [
//                 // Grid view
//                 _buildGridView(),
                
//                 // Calendar view
//                 _buildCalendarView(),
//               ],
//             ),
//           ),
          
//           // Bottom action area
//           _buildBottomActionArea(),
//         ],
//       ),
//     );
//   }
  
//   Widget _buildPlanInfoHeader() {
//     final endDate = widget.startDate.add(Duration(days: widget.durationDays));
    
//     return Container(
//       color: AppColors.primaryLighter,
//       padding: EdgeInsets.all(AppDimensions.marginMedium),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Plan: ${widget.package.name}',
//             style: Theme.of(context).textTheme.titleMedium?.copyWith(
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           SizedBox(height: 4),
//           Text(
//             'Duration: ${DateFormat('dd MMM, yyyy').format(widget.startDate)} to ${DateFormat('dd MMM, yyyy').format(endDate)}',
//             style: Theme.of(context).textTheme.bodyMedium,
//           ),
//           SizedBox(height: 8),
          
//           // Progress indicator for meal selection
//           LinearProgressIndicator(
//             value: _maxMeals > 0 ? _totalSelectedMeals / _maxMeals : 0,
//             backgroundColor: Colors.white,
//             valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
//           ),
//           SizedBox(height: 4),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Total Meals: $_maxMeals',
//                 style: Theme.of(context).textTheme.bodyMedium,
//               ),
//               Text(
//                 'Selected: $_totalSelectedMeals',
//                 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                   color: _totalSelectedMeals == _maxMeals 
//                     ? AppColors.success 
//                     : AppColors.primary,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
  
//   Widget _buildTabBar() {
//     return Container(
//       color: Colors.white,
//       child: TabBar(
//         controller: _tabController,
//         indicatorColor: AppColors.primary,
//         labelColor: AppColors.primary,
//         unselectedLabelColor: AppColors.textSecondary,
//         tabs: [
//           Tab(
//             icon: Icon(Icons.grid_on),
//             text: 'Grid View',
//           ),
//           Tab(
//             icon: Icon(Icons.calendar_today),
//             text: 'Calendar View',
//           ),
//         ],
//       ),
//     );
//   }
  
//   Widget _buildGridView() {
//     return SingleChildScrollView(
//       padding: EdgeInsets.all(AppDimensions.marginMedium),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header row with meal types
//           _buildGridHeader(),
          
//           // Grid rows for each day
//           ...List.generate(
//             _days.length, 
//             (index) => _buildDayRow(_days[index]),
//           ),
//         ],
//       ),
//     );
//   }
  
//   Widget _buildGridHeader() {
//     return Padding(
//       padding: const EdgeInsets.only(left: 100.0),
//       child: Row(
//         children: _mealTypes.map((mealType) {
//           return Expanded(
//             child: Container(
//               padding: EdgeInsets.all(AppDimensions.marginSmall),
//               decoration: BoxDecoration(
//                 color: AppColors.primaryLighter,
//                 borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
//               ),
//               child: Column(
//                 children: [
//                   Icon(
//                     _getMealTypeIcon(mealType),
//                     color: AppColors.primary,
//                   ),
//                   SizedBox(height: 4),
//                   Text(
//                     mealType,
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: AppColors.primary,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }
  
//   Widget _buildDayRow(String day) {
//     return Container(
//       margin: EdgeInsets.only(top: 12),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           // Day label
//           Container(
//             width: 100,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   day,
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 Text(
//                   _getDayDate(day),
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: AppColors.textSecondary,
//                   ),
//                 ),
//               ],
//             ),
//           ),
          
//           // Meal type cells
//           ..._mealTypes.map((mealType) {
//             final isSelected = _selectedMeals[day]?[mealType] ?? false;
            
//             return Expanded(
//               child: GestureDetector(
//                 onTap: () => _toggleMeal(day, mealType),
//                 child: Container(
//                   margin: EdgeInsets.symmetric(horizontal: 4),
//                   height: 80,
//                   decoration: BoxDecoration(
//                     color: isSelected ? AppColors.primaryLighter : Colors.white,
//                     borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
//                     border: Border.all(
//                       color: isSelected ? AppColors.primary : Colors.grey.shade300,
//                       width: isSelected ? 2 : 1,
//                     ),
//                   ),
//                   child: Stack(
//                     children: [
//                       Center(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text(
//                               'Standard',
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: isSelected ? AppColors.primary : AppColors.textSecondary,
//                               ),
//                             ),
//                             Text(
//                               'Meal',
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: isSelected ? AppColors.primary : AppColors.textSecondary,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       if (isSelected)
//                         Positioned(
//                           top: 4,
//                           right: 4,
//                           child: Container(
//                             padding: EdgeInsets.all(2),
//                             decoration: BoxDecoration(
//                               color: AppColors.success,
//                               shape: BoxShape.circle,
//                             ),
//                             child: Icon(
//                               Icons.check,
//                               size: 14,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           }).toList(),
//         ],
//       ),
//     );
//   }
  
//   Widget _buildCalendarView() {
//     return ListView.builder(
//       padding: EdgeInsets.all(AppDimensions.marginMedium),
//       itemCount: _days.length,
//       itemBuilder: (context, index) {
//         final day = _days[index];
//         return _buildCalendarDay(day);
//       },
//     );
//   }
  
//   Widget _buildCalendarDay(String day) {
//     return Card(
//       margin: EdgeInsets.only(bottom: 12),
//       child: Padding(
//         padding: EdgeInsets.all(AppDimensions.marginMedium),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: 12,
//                     vertical: 4,
//                   ),
//                   decoration: BoxDecoration(
//                     color: AppColors.primary,
//                     borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
//                   ),
//                   child: Text(
//                     day,
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 8),
//                 Text(
//                   _getDayDate(day),
//                   style: TextStyle(
//                     color: AppColors.textSecondary,
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 12),
//             ..._mealTypes.map((mealType) {
//               final isSelected = _selectedMeals[day]?[mealType] ?? false;
              
//               return InkWell(
//                 onTap: () => _toggleMeal(day, mealType),
//                 child: Container(
//                   padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
//                   child: Row(
//                     children: [
//                       Icon(
//                         _getMealTypeIcon(mealType),
//                         color: isSelected ? AppColors.primary : AppColors.textSecondary,
//                       ),
//                       SizedBox(width: 8),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               mealType,
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
//                               ),
//                             ),
//                             Text(
//                               'Standard Meal',
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: AppColors.textSecondary,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Switch(
//                         value: isSelected,
//                         onChanged: (value) => _toggleMeal(day, mealType),
//                         activeColor: AppColors.primary,
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             }).toList(),
//           ],
//         ),
//       ),
//     );
//   }
  
//   Widget _buildBottomActionArea() {
//     return Container(
//       padding: EdgeInsets.all(AppDimensions.marginLarge),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 4,
//             offset: Offset(0, -2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: SecondaryButton(
//               text: 'Back',
//               onPressed: () {
//                 if (_hasChanges) {
//                   _showDiscardChangesDialog();
//                 } else {
//                   Navigator.pop(context);
//                 }
//               },
//               icon: Icons.arrow_back,
//             ),
//           ),
//           SizedBox(width: AppDimensions.marginMedium),
//           Expanded(
//             child: PrimaryButton(
//               text: 'Continue',
//               onPressed: _totalSelectedMeals > 0 ? _saveAndContinue : null,
//               icon: Icons.arrow_forward,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
  
//   // Helper methods
  
//   IconData _getMealTypeIcon(String mealType) {
//     switch (mealType.toLowerCase()) {
//       case 'breakfast':
//         return Icons.free_breakfast;
//       case 'lunch':
//         return Icons.lunch_dining;
//       case 'dinner':
//         return Icons.dinner_dining;
//       default:
//         return Icons.restaurant;
//     }
//   }
  
//   String _getDayDate(String day) {
//     // Calculate date based on start date and day of the week
//     final dayIndex = _days.indexOf(day);
//     final startDayIndex = widget.startDate.weekday - 1; // 0-based index
    
//     int daysToAdd = (dayIndex - startDayIndex) % 7;
//     final date = widget.startDate.add(Duration(days: daysToAdd));
    
//     return DateFormat('dd MMM').format(date);
//   }
  
//   void _showDiscardChangesDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Discard Changes?'),
//         content: Text('You have unsaved changes. Do you want to discard them?'),
//         actions: [
//           TextButton(
//             child: Text('Cancel'),
//             onPressed: () => Navigator.pop(context),
//           ),
//           TextButton(
//             child: Text('Discard'),
//             onPressed: () {
//               Navigator.pop(context); // Close dialog
//               Navigator.pop(context); // Go back
//             },
//             style: TextButton.styleFrom(foregroundColor: Colors.red),
//           ),
//         ],
//       ),
//     );
//   }
  
//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }
// }