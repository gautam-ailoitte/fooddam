// lib/src/presentation/screens/meal_selection/meal_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/route/app_router.dart';
import 'package:foodam/core/widgets/primary_button.dart';
import 'package:foodam/core/widgets/secondary_button.dart';
import 'package:foodam/src/domain/entities/meal_slot_entity.dart';
import 'package:foodam/src/domain/entities/pacakge_entity.dart';
import 'package:foodam/src/presentation/cubits/subscription/create_subcription/create_subcription_cubit.dart';
import 'package:foodam/src/presentation/cubits/subscription/create_subcription/create_subcription_state.dart';
import 'package:intl/intl.dart';

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
  }) : startDate = startDate ?? DateTime.now().add(const Duration(days: 1));

  @override
  State<MealSelectionScreen> createState() => _MealSelectionScreenState();
}

class _MealSelectionScreenState extends State<MealSelectionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _gridScrollController = ScrollController();
  final ScrollController _calendarScrollController = ScrollController();

  // Store selected meal slots
  final Map<String, Map<String, bool>> _selectedMealsByDay = {};
  List<MealSlot> _mealSlots = [];
  int _selectedMealCount = 0;
  int _totalAvailableMealCount = 0;

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
  
  // Map to track available meals in package
  final Map<String, Map<String, bool>> _availableMealsByDay = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);

    _initializeAvailableMeals();
    _initializeSelectedMeals();
    _initializeMealSlots();

    // Animation for grid progress
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 200), () {
        setState(() {
          _gridProgress = 1.0;
        });
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _gridScrollController.dispose();
    _calendarScrollController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {});
    }
  }

  // Initialize which meals are available in the package
  void _initializeAvailableMeals() {
    // Initialize all to false first
    for (var day in _dayNames) {
      _availableMealsByDay[day] = {};
      for (var mealType in _mealTypes) {
        _availableMealsByDay[day]![mealType] = false;
      }
    }
    
    // Mark meals that exist in the package
    for (var slot in widget.package.slots) {
      final day = slot.day.toLowerCase();
      final mealType = slot.timing.toLowerCase();
      
      if (_dayNames.contains(day) && _mealTypes.contains(mealType)) {
        _availableMealsByDay[day]![mealType] = true;
        _totalAvailableMealCount++;
      }
    }
  }

  void _initializeSelectedMeals() {
    // Initialize all combinations to false first
    for (var day in _dayNames) {
      _selectedMealsByDay[day] = {};
      for (var mealType in _mealTypes) {
        _selectedMealsByDay[day]![mealType] = false;
      }
    }

    // Then, select only the available meals from the package
    for (var day in _dayNames) {
      for (var mealType in _mealTypes) {
        if (_availableMealsByDay[day]?[mealType] == true) {
          _selectedMealsByDay[day]![mealType] = true;
          _selectedMealCount++;
        }
      }
    }
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
    // Only allow toggling if the meal is available
    if (_availableMealsByDay[day]?[mealType] != true) return;
    
    setState(() {
      final currentValue = _selectedMealsByDay[day]?[mealType] ?? false;
      
      // If this is the last selected meal and user is trying to unselect it, show warning
      if (currentValue && _selectedMealCount == 1) {
        _showAtLeastOneMealRequiredDialog();
        return;
      }
      
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

    // Count how many we'll unselect
    int unselectionCount = 0;
    if (anySelected) {
      for (var day in _dayNames) {
        if (_availableMealsByDay[day]?[mealType] == true && 
            _selectedMealsByDay[day]?[mealType] == true) {
          unselectionCount++;
        }
      }
    }

    // If unselecting all would leave no meals, show warning
    if (anySelected && unselectionCount == _selectedMealCount) {
      _showAtLeastOneMealRequiredDialog();
      return;
    }

    // Toggle based on current state
    setState(() {
      for (var day in _dayNames) {
        // Only toggle if the meal is available
        if (_availableMealsByDay[day]?[mealType] == true) {
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

    // Count how many we'll unselect
    int unselectionCount = 0;
    if (anySelected) {
      for (var mealType in _mealTypes) {
        if (_availableMealsByDay[day]?[mealType] == true && 
            _selectedMealsByDay[day]?[mealType] == true) {
          unselectionCount++;
        }
      }
    }

    // If unselecting all would leave no meals, show warning
    if (anySelected && unselectionCount == _selectedMealCount) {
      _showAtLeastOneMealRequiredDialog();
      return;
    }

    // Toggle based on current state
    setState(() {
      for (var mealType in _mealTypes) {
        // Only toggle if the meal is available
        if (_availableMealsByDay[day]?[mealType] == true) {
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
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              // Enhanced App Bar with plan details
              SliverAppBar(
                expandedHeight: 100, // Reduced height for better spacing
                floating: false,
                pinned: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    if (_hasChanges) {
                      _showDiscardChangesDialog();
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.package.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Start: ${DateFormat('E, MMM d').format(widget.startDate)} • ${widget.durationDays} days',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${widget.personCount} ${widget.personCount > 1 ? 'persons' : 'person'}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                flexibleSpace: Container(
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
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(48),
                  child: Container(
                    color: Colors.white,
                    child: TabBar(
                      controller: _tabController,
                      indicatorColor: AppColors.primary,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.textSecondary,
                      tabs: const [
                        Tab(text: 'Grid View'),
                        Tab(text: 'Calendar View'),
                      ],
                    ),
                  ),
                ),
              ),

              // Persistent Progress Bar
              SliverPersistentHeader(
                pinned: true,
                delegate: _ProgressBarHeaderDelegate(
                  progressValue: _selectedMealCount / (_totalAvailableMealCount > 0 ? _totalAvailableMealCount : 1),
                  selectedCount: _selectedMealCount,
                  totalCount: _totalAvailableMealCount,
                ),
              ),
            ];
          },
          body: Column(
            children: [
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildGridView(), 
                    _buildCalendarView(),
                  ],
                ),
              ),
              _buildBottomActionArea(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridView() {
    return CustomScrollView(
      controller: _gridScrollController,
      slivers: [
        // Header with meal types
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Days label with center alignment
                    SizedBox(
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
          ),
        ),
        // Grid view with day rows
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final day = _dayNames[index];
            return AnimatedContainer(
              duration: const Duration(milliseconds: 500),
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
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
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

    // Count selected and available items for this meal type
    int selectedCount = 0;
    int availableCount = 0;
    for (var day in _dayNames) {
      if (_availableMealsByDay[day]?[mealType] == true) {
        availableCount++;
        if (_selectedMealsByDay[day]?[mealType] == true) {
          selectedCount++;
        }
      }
    }

    return InkWell(
      onTap: availableCount > 0 ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Column(
          children: [
            Icon(
              icon,
              color: selectedCount > 0 
                  ? AppColors.primary 
                  : availableCount > 0 
                      ? Colors.grey
                      : Colors.grey.shade300,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selectedCount > 0 ? FontWeight.bold : FontWeight.normal,
                color: selectedCount > 0 
                    ? AppColors.textPrimary 
                    : availableCount > 0 
                        ? Colors.grey
                        : Colors.grey.shade300,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              '$selectedCount/$availableCount',
              style: TextStyle(
                fontSize: 10,
                color: selectedCount > 0 
                    ? AppColors.primary 
                    : availableCount > 0 
                        ? Colors.grey
                        : Colors.grey.shade300,
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

    // Count available and selected meal types for this day
    int availableCount = 0;
    int selectedCount = 0;
    for (var mealType in _mealTypes) {
      if (_availableMealsByDay[day]?[mealType] == true) {
        availableCount++;
        if (_selectedMealsByDay[day]?[mealType] == true) {
          selectedCount++;
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          color: isWeekend
              ? AppColors.primaryLighter.withOpacity(0.3)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isToday
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
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Day header
            InkWell(
              onTap: availableCount > 0 ? () => _toggleAllMealTypesForDay(day) : null,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isToday
                      ? AppColors.primary.withOpacity(0.1)
                      : isWeekend
                          ? AppColors.primaryLighter.withOpacity(0.3)
                          : Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
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
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _capitalize(day),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isToday
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
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: selectedCount > 0
                            ? AppColors.primary.withOpacity(0.1)
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$selectedCount/$availableCount',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: selectedCount > 0
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
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _mealTypes.map((mealType) {
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
    final isAvailable = _availableMealsByDay[day]?[mealType] ?? false;

    // Find the meal for this slot
    final meal = widget.package.slots
        .firstWhere(
          (slot) =>
              slot.day.toLowerCase() == day.toLowerCase() &&
              slot.timing.toLowerCase() == mealType.toLowerCase() &&
              slot.meal != null,
          orElse: () => MealSlot(day: day, timing: mealType, mealId: null),
        )
        .meal;

    return GestureDetector(
      onTap: isAvailable ? () => _toggleMealSelection(day, mealType) : null,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isAvailable
              ? (isSelected
                  ? AppColors.primary.withOpacity(0.1)
                  : Colors.grey.shade100)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isAvailable
                ? (isSelected ? AppColors.primary : Colors.transparent)
                : Colors.grey.shade200,
            width: isSelected ? 2 : 0,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Checkbox or not available indicator
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: isAvailable
                    ? (isSelected ? AppColors.primary : Colors.white)
                    : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isAvailable
                      ? (isSelected ? AppColors.primary : Colors.grey.shade400)
                      : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: isAvailable
                  ? (isSelected
                      ? const Icon(Icons.check, size: 12, color: Colors.white)
                      : null)
                  : const Icon(Icons.not_interested, size: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),

            // Meal info
            Text(
              isAvailable
                  ? (meal?.name ?? _capitalize(mealType))
                  : "Not Available",
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontStyle: isAvailable ? FontStyle.normal : FontStyle.italic,
                color: isAvailable
                    ? (isSelected ? AppColors.primary : AppColors.textSecondary)
                    : Colors.grey.shade400,
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
      controller: _calendarScrollController,
      padding: const EdgeInsets.all(16),
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

    // Count available meals for this day
    int availableCount = 0;
    int selectedCount = 0;
    for (var mealType in _mealTypes) {
      if (_availableMealsByDay[day]?[mealType] == true) {
        availableCount++;
        if (_selectedMealsByDay[day]?[mealType] == true) {
          selectedCount++;
        }
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isToday
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
                const SizedBox(width: 8),
                Text(
                  '${date.day} ${_getMonthName(date.month)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: isToday
                        ? Colors.white.withOpacity(0.9)
                        : AppColors.textSecondary,
                  ),
                ),
                if (isToday) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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

          // All meals toggle (only if there are available meals)
          if (availableCount > 0)
            InkWell(
              onTap: () => _toggleAllMealTypesForDay(day),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'All meals for this day',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Switch(
                      value: selectedCount > 0 && selectedCount == availableCount,
                      onChanged: (_) => _toggleAllMealTypesForDay(day),
                      activeColor: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
          
          if (availableCount > 0) const Divider(),

          // Individual meal types
          ...(_mealTypes.map((mealType) {
            final isSelected = _selectedMealsByDay[day]?[mealType] ?? false;
            final isAvailable = _availableMealsByDay[day]?[mealType] ?? false;

            // Find the meal for this slot
            final matchingSlot = widget.package.slots.firstWhere(
              (slot) =>
                  slot.day.toLowerCase() == day.toLowerCase() &&
                  slot.timing.toLowerCase() == mealType.toLowerCase(),
              orElse: () => MealSlot(
                day: day,
                timing: mealType,
              ),
            );
            
            final meal = matchingSlot.meal;

            return InkWell(
              onTap: isAvailable ? () => _toggleMealSelection(day, mealType) : null,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(
                      _getMealTypeIcon(mealType),
                      color: isAvailable
                          ? (isSelected ? AppColors.primary : Colors.grey)
                          : Colors.grey.shade300,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _capitalize(mealType),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isAvailable
                                  ? (isSelected ? AppColors.textPrimary : Colors.grey)
                                  : Colors.grey.shade400,
                            ),
                          ),
                          if (meal != null)
                            Text(
                              meal.name,
                              style: TextStyle(
                                fontSize: 12,
                                color: isAvailable
                                    ? (isSelected ? AppColors.textSecondary : Colors.grey.shade400)
                                    : Colors.grey.shade300,
                              ),
                            )
                          else
                            Text(
                              isAvailable ? "Standard meal" : "Not available",
                              style: TextStyle(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                color: isAvailable
                                    ? (isSelected ? AppColors.textSecondary : Colors.grey.shade400)
                                    : Colors.grey.shade300,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (isAvailable)
                      Checkbox(
                        value: isSelected,
                        onChanged: (_) => _toggleMealSelection(day, mealType),
                        activeColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Icon(
                          Icons.not_interested,
                          size: 18,
                          color: Colors.grey.shade300,
                        ),
                      ),
                  ],
                ),
              ),
            );
          }).toList()),
        ],
      ),
    );
  }

  Widget _buildBottomActionArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
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
            const SizedBox(width: 16),
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
      ),
    );
  }

  void _continueToCheckout() {
    final selectedSlots = _getSelectedMealSlots();

    // Set meal distributions in the cubit
    final subscriptionCubit = context.read<CreateSubscriptionCubit>();
    
    // Update subscription details first
    subscriptionCubit.setSubscriptionDetails(
      startDate: widget.startDate,
      durationDays: widget.durationDays,
    );
    
    // Pass MealSlot objects directly
    subscriptionCubit.setMealDistributions(
      selectedSlots,
      widget.personCount,
    );

    // Navigate to checkout
    Navigator.of(context).pushNamed(
      AppRouter.checkoutRoute,
      arguments: {
        'packageId': widget.package.id,
        'mealSlots': selectedSlots,
        'personCount': widget.personCount,
        'startDate': widget.startDate,
        'durationDays': widget.durationDays,
      },
    );
  }

  void _showDiscardChangesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Changes?'),
        content: const Text(
          'You have unsaved changes to your meal selection. Do you want to discard them?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back
            },
            child: const Text('Discard', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAtLeastOneMealRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('At Least One Meal Required'),
        content: const Text(
          'You must select at least one meal to continue. Please select at least one meal before proceeding.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Helper methods

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

// class _MealTypeHeaderDelegate extends SliverPersistentHeaderDelegate {
//   final Widget Function(BuildContext, double) builder;

//   _MealTypeHeaderDelegate({required this.builder});

//   @override
//   double get minExtent => 110.0;
  
//   @override
//   double get maxExtent => 110.0;

//   @override
//   Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
//     return Material(
//       elevation: shrinkOffset > 0 ? 2 : 0,
//       color: Colors.white,
//       child: builder(context, shrinkOffset),
//     );
//   }

//   @override
//   bool shouldRebuild(_MealTypeHeaderDelegate oldDelegate) {
//     return true;
//   }
// }

class _ProgressBarHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double progressValue;
  final int selectedCount;
  final int totalCount;

  _ProgressBarHeaderDelegate({
    required this.progressValue,
    required this.selectedCount,
    required this.totalCount,
  });

  @override
  double get minExtent => 60.0;
  
  @override
  double get maxExtent => 60.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selected vs total meals
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Selected meals:', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '$selectedCount/$totalCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: [
                // Background
                Container(
                  height: 6,
                  width: double.infinity,
                  color: Colors.grey.shade200,
                ),
                // Foreground
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 6,
                  width: (MediaQuery.of(context).size.width - 32) * progressValue,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_ProgressBarHeaderDelegate oldDelegate) {
    return oldDelegate.progressValue != progressValue ||
           oldDelegate.selectedCount != selectedCount ||
           oldDelegate.totalCount != totalCount;
  }
}