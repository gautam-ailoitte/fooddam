// ===================================================================

// lib/src/presentation/widgets/enhanced_meal_selection_card.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/src/domain/entities/meal_plan_item.dart';
import 'package:intl/intl.dart';

import '../../../cubits/subscription/week_selection/week_selection_state.dart';

class EnhancedMealSelectionCard extends StatefulWidget {
  final MealPlanItem item;
  final bool isSelected;
  final bool canSelect;
  final WeekSelectionActive state;
  final VoidCallback? onTap;
  final VoidCallback? onInfoTap;

  const EnhancedMealSelectionCard({
    super.key,
    required this.item,
    required this.isSelected,
    required this.canSelect,
    required this.state,
    this.onTap,
    this.onInfoTap,
  });

  @override
  State<EnhancedMealSelectionCard> createState() =>
      _EnhancedMealSelectionCardState();
}

class _EnhancedMealSelectionCardState extends State<EnhancedMealSelectionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  late Animation<Color?> _borderColorAnimation;

  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _elevationAnimation = Tween<double>(
      begin: widget.isSelected ? 4.0 : 1.0,
      end: widget.isSelected ? 8.0 : 3.0,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _borderColorAnimation = ColorTween(
      begin: widget.isSelected ? AppColors.primary : Colors.transparent,
      end:
          widget.isSelected
              ? AppColors.primary
              : AppColors.primary.withOpacity(0.3),
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    // Start animation if selected
    if (widget.isSelected) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(EnhancedMealSelectionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardKey = Key(
      '${widget.state.currentWeek}_${widget.item.day}_${widget.item.timing}_${widget.item.dishId}',
    );

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _isHovered ? _scaleAnimation.value : 1.0,
          child: Card(
            key: cardKey,
            margin: EdgeInsets.only(bottom: AppDimensions.marginMedium),
            elevation:
                _isHovered
                    ? _elevationAnimation.value
                    : (widget.isSelected ? 4 : 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: _borderColorAnimation.value ?? Colors.transparent,
                width: widget.isSelected ? 2 : (_isHovered ? 1 : 0),
              ),
            ),
            child: InkWell(
              onTap:
                  widget.canSelect ? widget.onTap : _showCannotSelectFeedback,
              onHover: (hovered) {
                setState(() {
                  _isHovered = hovered;
                });
                if (hovered) {
                  _animationController.forward();
                } else if (!widget.isSelected) {
                  _animationController.reverse();
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: EdgeInsets.all(AppDimensions.marginMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row with day/timing and selection checkbox
                    _buildHeaderRow(),
                    SizedBox(height: AppDimensions.marginSmall),

                    // Main content row
                    Row(
                      children: [
                        _buildMealIcon(),
                        SizedBox(width: AppDimensions.marginMedium),
                        Expanded(child: _buildMealInfo()),
                        _buildActionButtons(),
                      ],
                    ),

                    // Dietary preferences badges
                    if (widget.item.dietaryPreferences.isNotEmpty) ...[
                      SizedBox(height: AppDimensions.marginMedium),
                      _buildDietaryBadges(),
                    ],

                    // Selection feedback
                    if (widget.isSelected) ...[
                      SizedBox(height: AppDimensions.marginSmall),
                      _buildSelectionFeedback(),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderRow() {
    final isToday = widget.item.isToday(
      widget.state.planningData.startDate,
      widget.state.currentWeek,
    );
    final date = widget.item.calculateDate(
      widget.state.planningData.startDate,
      widget.state.currentWeek,
    );

    return Row(
      children: [
        // Day and timing info
        Expanded(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.item.formattedDay,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: AppDimensions.marginSmall),
              Text(
                DateFormat('MMM d').format(date),
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (isToday) ...[
                SizedBox(width: AppDimensions.marginSmall),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'TODAY',
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        // Selection checkbox
        _buildSelectionCheckbox(),
      ],
    );
  }

  Widget _buildMealIcon() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color:
            widget.isSelected
                ? AppColors.primary.withOpacity(0.15)
                : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.isSelected ? AppColors.primary : Colors.grey.shade300,
          width: widget.isSelected ? 2 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getMealIcon(widget.item.timing),
            color: widget.isSelected ? AppColors.primary : Colors.grey.shade600,
            size: 24,
          ),
          const SizedBox(height: 2),
          Text(
            widget.item.formattedTiming,
            style: TextStyle(
              fontSize: 10,
              color:
                  widget.isSelected ? AppColors.primary : Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.item.dishName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: widget.isSelected ? AppColors.primary : Colors.black,
            height: 1.2,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (widget.item.dishDescription.isNotEmpty) ...[
          SizedBox(height: AppDimensions.marginSmall),
          Text(
            widget.item.dishDescription,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Info button
        IconButton(
          onPressed: widget.onInfoTap ?? _showMealDetails,
          icon: Icon(Icons.info_outline, color: AppColors.primary, size: 20),
          tooltip: 'View meal details',
          padding: const EdgeInsets.all(8),
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        ),

        // Selection status indicator
        if (widget.isSelected)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check, color: Colors.white, size: 12),
          ),
      ],
    );
  }

  Widget _buildSelectionCheckbox() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Checkbox(
        value: widget.isSelected,
        onChanged: widget.canSelect ? (_) => widget.onTap?.call() : null,
        activeColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Widget _buildDietaryBadges() {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children:
          widget.item.dietaryPreferences.take(3).map((pref) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _getDietaryBadgeColor(pref).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getDietaryBadgeColor(pref).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getDietaryIcon(pref),
                    size: 12,
                    color: _getDietaryBadgeColor(pref),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _capitalize(pref),
                    style: TextStyle(
                      fontSize: 11,
                      color: _getDietaryBadgeColor(pref),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildSelectionFeedback() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.success.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline, color: AppColors.success, size: 16),
          const SizedBox(width: 6),
          Text(
            'Added to your meal plan',
            style: TextStyle(
              color: AppColors.success,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showCannotSelectFeedback() {
    final validation = widget.state.validateCurrentWeek();
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Maximum ${validation.requiredMeals} meals allowed for this week',
        ),
        backgroundColor: AppColors.warning,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showMealDetails() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildMealDetailsModal(),
    );
  }

  Widget _buildMealDetailsModal() {
    final date = widget.item.calculateDate(
      widget.state.planningData.startDate,
      widget.state.currentWeek,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return Padding(
            padding: EdgeInsets.all(AppDimensions.marginMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: AppDimensions.marginMedium),

                // Header
                Row(
                  children: [
                    _buildMealIcon(),
                    SizedBox(width: AppDimensions.marginMedium),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.item.formattedDay} ${widget.item.formattedTiming}',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.item.dishName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: AppColors.textSecondary),
                    ),
                  ],
                ),

                SizedBox(height: AppDimensions.marginLarge),

                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Description
                        if (widget.item.dishDescription.isNotEmpty) ...[
                          Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(height: AppDimensions.marginSmall),
                          Text(
                            widget.item.dishDescription,
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(height: AppDimensions.marginLarge),
                        ],

                        // Dietary Information
                        if (widget.item.dietaryPreferences.isNotEmpty) ...[
                          Text(
                            'Dietary Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(height: AppDimensions.marginSmall),
                          _buildDietaryBadges(),
                          SizedBox(height: AppDimensions.marginLarge),
                        ],

                        // Delivery Date
                        Text(
                          'Delivery Date',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(height: AppDimensions.marginSmall),
                        Container(
                          padding: EdgeInsets.all(AppDimensions.marginMedium),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              SizedBox(width: AppDimensions.marginSmall),
                              Text(
                                DateFormat('EEEE, MMMM d, yyyy').format(date),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Action Button
                SizedBox(height: AppDimensions.marginMedium),
                SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          widget.canSelect
                              ? () {
                                Navigator.pop(context);
                                widget.onTap?.call();
                              }
                              : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            widget.isSelected
                                ? AppColors.error
                                : AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            widget.isSelected
                                ? Icons.remove_circle
                                : Icons.add_circle,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.isSelected
                                ? 'Remove from Plan'
                                : 'Add to Plan',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  IconData _getMealIcon(String mealType) {
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

  IconData _getDietaryIcon(String preference) {
    switch (preference.toLowerCase()) {
      case 'vegetarian':
        return Icons.eco;
      case 'non-vegetarian':
        return Icons.restaurant;
      case 'vegan':
        return Icons.eco_outlined;
      case 'gluten-free':
        return Icons.no_food;
      default:
        return Icons.info;
    }
  }

  Color _getDietaryBadgeColor(String preference) {
    switch (preference.toLowerCase()) {
      case 'vegetarian':
        return AppColors.success;
      case 'non-vegetarian':
        return AppColors.error;
      case 'vegan':
        return AppColors.accent;
      case 'gluten-free':
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
