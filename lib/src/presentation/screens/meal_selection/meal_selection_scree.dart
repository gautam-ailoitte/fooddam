// lib/src/presentation/screens/meal_selection/meal_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/widgets/primary_button.dart';
import 'package:foodam/core/widgets/secondary_button.dart';
import 'package:foodam/src/domain/entities/meal_slot_entity.dart';
import 'package:foodam/src/domain/entities/pacakge_entity.dart';
import 'package:foodam/src/presentation/cubits/subscription/create_subcription/create_subcription_cubit.dart';
import 'package:foodam/src/presentation/cubits/subscription/create_subcription/create_subcription_state.dart';

class MealSelectionScreen extends StatefulWidget {
  final Package package;
  final int personCount;
  final DateTime startDate;
  final int durationDays;

  MealSelectionScreen({
    super.key,
    required this.package,
    this.personCount = 1,
    DateTime? startDate,
    this.durationDays = 7,
  }) : this.startDate = startDate ?? DateTime.now();

  @override
  _MealSelectionScreenState createState() => _MealSelectionScreenState();
}

class _MealSelectionScreenState extends State<MealSelectionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  // Store selected meal slots
  final Map<String, Map<String, bool>> _selectedMealsByDay = {};
  List<MealSlot> _mealSlots = [];
  int _selectedMealCount = 0;
  int _totalMealCount = 0;

  final List<String> _mealTypes = ['breakfast', 'lunch', 'dinner'];
  final List<String> _dayNames = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];

  double _gridProgress = 0.0;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);

    _initializeSelectedMeals();
    _initializeMealSlots();

    // Animation for grid progress
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(milliseconds: 200), () {
        setState(() {
          _gridProgress = 1.0;
        });
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    setState(() {});
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
  }

  void _initializeMealSlots() {
    _mealSlots = [];

    // Add all slots from the package
    for (var slot in widget.package.slots) {
      if (_dayNames.contains(slot.day.toLowerCase())) {
        _mealSlots.add(slot);
      }
    }
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

      _hasChanges = true;
    });
  }

  // Toggle all meals for a specific meal type (e.g., all breakfasts)
  void _toggleMealTypeForAllDays(String mealType) {
    // Check if any meal of this type is currently selected
    bool anySelected = false;
    for (var day in _dayNames) {
      if (_selectedMealsByDay[day]?[mealType] == true) {
        anySelected = true;
        break;
      }
    }

    // Toggle based on current state
    setState(() {
      for (var day in _dayNames) {
        // If any are selected, deselect all. Otherwise, select all.
        final newValue = !anySelected;
        final oldValue = _selectedMealsByDay[day]?[mealType] ?? false;

        if (newValue != oldValue) {
          _selectedMealsByDay[day]?[mealType] = newValue;

          if (newValue) {
            _selectedMealCount++;
          } else {
            _selectedMealCount--;
          }
        }
      }

      _hasChanges = true;
    });
  }

  // Toggle all meal types for a specific day
  void _toggleAllMealTypesForDay(String day) {
    // Check if any meal type for this day is currently selected
    bool anySelected = false;
    for (var mealType in _mealTypes) {
      if (_selectedMealsByDay[day]?[mealType] == true) {
        anySelected = true;
        break;
      }
    }

    // Toggle based on current state
    setState(() {
      for (var mealType in _mealTypes) {
        // If any are selected, deselect all. Otherwise, select all.
        final newValue = !anySelected;
        final oldValue = _selectedMealsByDay[day]?[mealType] ?? false;

        if (newValue != oldValue) {
          _selectedMealsByDay[day]?[mealType] = newValue;

          if (newValue) {
            _selectedMealCount++;
          } else {
            _selectedMealCount--;
          }
        }
      }

      _hasChanges = true;
    });
  }

  List<MealSlot> _getSelectedMealSlots() {
    final List<MealSlot> selectedSlots = [];

    _selectedMealsByDay.forEach((day, meals) {
      meals.forEach((mealType, isSelected) {
        if (isSelected) {
          // Find the matching slot from the package
          final matchingSlot = widget.package.slots.firstWhere(
            (slot) =>
                slot.day.toLowerCase() == day.toLowerCase() &&
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
      body: BlocListener<CreateSubscriptionCubit, CreateSubscriptionState>(
        listener: (context, state) {
          if (state is CreateSubscriptionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 120,
                floating: true,
                pinned: true,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    if (_hasChanges) {
                      _showDiscardChangesDialog();
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    'Select Your Meals',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(48),
                  child: Container(
                    color: Colors.white,
                    child: TabBar(
                      controller: _tabController,
                      indicatorColor: AppColors.primary,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.textSecondary,
                      tabs: [
                        Tab(text: 'Grid View'),
                        Tab(text: 'Calendar View'),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(child: _buildPlanSummary()),
            ];
          },
          body: Column(
            children: [
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [_buildGridView(), _buildCalendarView()],
                ),
              ),
              _buildBottomActionArea(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanSummary() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Plan name and person count
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Plan: ${widget.package.name}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Persons: ${widget.personCount}',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_formatDate(widget.startDate)} - ${_formatDate(widget.startDate.add(Duration(days: widget.durationDays - 1)))}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Progress bar showing selected meals vs total
          Row(
            children: [
              Text('Selected meals:', style: TextStyle(fontSize: 14)),
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_selectedMealCount/$_totalMealCount',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Stack(
            children: [
              // Background
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              // Foreground
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                height: 8,
                width:
                    MediaQuery.of(context).size.width *
                        _selectedMealCount /
                        _totalMealCount -
                    32,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGridView() {
    return CustomScrollView(
      slivers: [
        // Header with meal types
        SliverPersistentHeader(
          pinned: true,
          delegate: _MealTypeHeaderDelegate(
            builder: (context, shrinkOffset) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Days label with center alignment
                        Container(
                          alignment: Alignment.center,
                          width: 70,
                          child: const Text(
                            'Days',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 8),
                        
                        // Meal type headers with equal spacing
                        Expanded(
                          child: Row(
                            children: _mealTypes.map((type) {
                              return Expanded(
                                child: _buildMealTypeHeader(
                                  mealType: type,
                                  onTap: () => _toggleMealTypeForAllDays(type),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        // Grid view with day rows
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final day = _dayNames[index];
            return AnimatedContainer(
              duration: Duration(milliseconds: 500),
              curve: Curves.easeOutQuart,
              transform: Matrix4.translationValues(
                0.0,
                (1.0 - _gridProgress) * 100 * index,
                0.0,
              ),
              child: _buildDayRow(day, index),
            );
          }, childCount: _dayNames.length),
        ),

        // Bottom padding
        SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildMealTypeHeader({
    required String mealType,
    required VoidCallback onTap,
  }) {
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

    // Count selected items for this meal type
    int selectedCount = 0;
    for (var day in _dayNames) {
      if (_selectedMealsByDay[day]?[mealType] == true) {
        selectedCount++;
      }
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Column(
          children: [
            Icon(
              icon,
              color: selectedCount > 0 ? AppColors.primary : Colors.grey,
              size: 24,
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight:
                    selectedCount > 0 ? FontWeight.bold : FontWeight.normal,
                color: selectedCount > 0 ? AppColors.textPrimary : Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Text(
              '$selectedCount/${_dayNames.length}',
              style: TextStyle(
                fontSize: 10,
                color: selectedCount > 0 ? AppColors.primary : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayRow(String day, int dayIndex) {
    final date = widget.startDate.add(Duration(days: dayIndex));
    final isToday = _isToday(date);
    final isWeekend =
        day.toLowerCase() == 'saturday' || day.toLowerCase() == 'sunday';

    // Count selected meal types for this day
    int selectedCount = 0;
    for (var mealType in _mealTypes) {
      if (_selectedMealsByDay[day]?[mealType] == true) {
        selectedCount++;
      }
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          color:
              isWeekend
                  ? AppColors.primaryLighter.withOpacity(0.3)
                  : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isToday
                    ? AppColors.primary
                    : isWeekend
                    ? AppColors.primaryLighter
                    : Colors.grey.shade200,
            width: isToday ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Day header
            InkWell(
              onTap: () => _toggleAllMealTypesForDay(day),
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      isToday
                          ? AppColors.primary.withOpacity(0.1)
                          : isWeekend
                          ? AppColors.primaryLighter.withOpacity(0.3)
                          : Colors.grey.shade50,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isToday ? AppColors.primary : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        _getDayAbbreviation(day),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isToday ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _capitalize(day),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color:
                                isToday
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${date.day} ${_getMonthName(date.month)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color:
                            selectedCount > 0
                                ? AppColors.primary.withOpacity(0.1)
                                : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$selectedCount/${_mealTypes.length}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color:
                              selectedCount > 0
                                  ? AppColors.primary
                                  : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Meal cells
            Padding(
              padding: EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children:
                    _mealTypes.map((mealType) {
                      return Expanded(child: _buildMealCell(day, mealType));
                    }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealCell(String day, String mealType) {
    final isSelected = _selectedMealsByDay[day]?[mealType] ?? false;

    // Find the meal for this slot
    final meal =
        widget.package.slots
            .firstWhere(
              (slot) =>
                  slot.day.toLowerCase() == day.toLowerCase() &&
                  slot.timing.toLowerCase() == mealType.toLowerCase() &&
                  slot.meal != null,
              orElse: () => MealSlot(day: day, timing: mealType, mealId: null),
            )
            .meal;

    return GestureDetector(
      onTap: () => _toggleMealSelection(day, mealType),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.primary.withOpacity(0.1)
                  : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: isSelected ? 2 : 0,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Checkbox indicator
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child:
                  isSelected
                      ? Icon(Icons.check, size: 12, color: Colors.white)
                      : null,
            ),
            SizedBox(height: 8),

            // Meal info
            Text(
              meal?.name ?? _capitalize(mealType),
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarView() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _dayNames.length,
      itemBuilder: (context, index) {
        final day = _dayNames[index];
        return _buildDayCard(day, index);
      },
    );
  }

  Widget _buildDayCard(String day, int dayIndex) {
    final date = widget.startDate.add(Duration(days: dayIndex));
    final isToday = _isToday(date);

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isToday ? AppColors.primary : Colors.transparent,
          width: isToday ? 2 : 0,
        ),
      ),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors:
                    isToday
                        ? [
                          AppColors.primary,
                          AppColors.primary.withOpacity(0.9),
                        ]
                        : [
                          AppColors.primaryLight.withOpacity(0.7),
                          AppColors.primaryLighter,
                        ],
              ),
            ),
            child: Row(
              children: [
                Text(
                  _capitalize(day),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: isToday ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  '${date.day} ${_getMonthName(date.month)}',
                  style: TextStyle(
                    fontSize: 14,
                    color:
                        isToday
                            ? Colors.white.withOpacity(0.9)
                            : AppColors.textSecondary,
                  ),
                ),
                if (isToday) ...[
                  SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Today',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Meal toggles
          InkWell(
            onTap: () => _toggleAllMealTypesForDay(day),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'All meals for this day',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Switch(
                    value: _mealTypes.every(
                      (type) => _selectedMealsByDay[day]?[type] == true,
                    ),
                    onChanged: (value) => _toggleAllMealTypesForDay(day),
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
          Divider(),

          // Individual meal types
          ..._mealTypes.map((mealType) {
            final isSelected = _selectedMealsByDay[day]?[mealType] ?? false;

            // Find the meal for this slot
            final meal =
                widget.package.slots
                    .firstWhere(
                      (slot) =>
                          slot.day.toLowerCase() == day.toLowerCase() &&
                          slot.timing.toLowerCase() == mealType.toLowerCase() &&
                          slot.meal != null,
                      orElse:
                          () => MealSlot(
                            day: day,
                            timing: mealType,
                            mealId: null,
                          ),
                    )
                    .meal;

            return InkWell(
              onTap: () => _toggleMealSelection(day, mealType),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(
                      _getMealTypeIcon(mealType),
                      color: isSelected ? AppColors.primary : Colors.grey,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _capitalize(mealType),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  isSelected
                                      ? AppColors.textPrimary
                                      : Colors.grey,
                            ),
                          ),
                          if (meal != null)
                            Text(
                              meal.name,
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    isSelected
                                        ? AppColors.textSecondary
                                        : Colors.grey.shade400,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Checkbox(
                      value: isSelected,
                      onChanged: (_) => _toggleMealSelection(day, mealType),
                      activeColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildBottomActionArea() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: SecondaryButton(
                text: 'Back',
                onPressed: () {
                  if (_hasChanges) {
                    _showDiscardChangesDialog();
                  } else {
                    Navigator.pop(context);
                  }
                },
                icon: Icons.arrow_back,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child:
                  BlocBuilder<CreateSubscriptionCubit, CreateSubscriptionState>(
                    builder: (context, state) {
                      final isLoading = state is CreateSubscriptionLoading;

                      return PrimaryButton(
                        text: 'Continue',
                        onPressed:
                            isLoading || _selectedMealCount == 0
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
      ),
    );
  }

  void _continueToCheckout() {
    final selectedSlots = _getSelectedMealSlots();

    // Set meal distributions in the cubit
    final subscriptionCubit = context.read<CreateSubscriptionCubit>();

    @Deprecated('Use MealSlot instead')
    final mealDistributions =
        selectedSlots.map((slot) {
          return MealDistribution(
            day: slot.day,
            mealTime: slot.timing,
            mealId: slot.mealId,
          );
        }).toList();

    subscriptionCubit.setMealDistributions(
      mealDistributions,
      widget.personCount,
    );

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

  void _showDiscardChangesDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Discard Changes?'),
            content: Text(
              'You have unsaved changes to your meal selection. Do you want to discard them?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back
                },
                child: Text('Discard', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  // Helper methods
  String _formatDate(DateTime date) {
    return '${date.day} ${_getMonthName(date.month)}';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  String _getDayAbbreviation(String day) {
    return day.substring(0, 2).toUpperCase();
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  IconData _getMealTypeIcon(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Icons.free_breakfast;
      case 'lunch':
        return Icons.lunch_dining;
      case 'dinner':
        return Icons.dinner_dining;
      default:
        return Icons.restaurant;
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}

class _MealTypeHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget Function(BuildContext, double) builder;

  _MealTypeHeaderDelegate({required this.builder});

  @override
  double get minExtent => 110.0; // Increased height to prevent overflow
  
  @override
  double get maxExtent => 110.0; // Same as min for consistent appearance

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      elevation: shrinkOffset > 0 ? 2 : 0,
      color: Colors.white,
      child: builder(context, shrinkOffset),
    );
  }

  @override
  bool shouldRebuild(_MealTypeHeaderDelegate oldDelegate) {
    return true; // Rebuild when header is scrolled
  }
}