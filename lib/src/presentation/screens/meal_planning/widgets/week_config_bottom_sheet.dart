// lib/src/presentation/screens/meal_planning/widgets/week_config_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/widgets/primary_button.dart';

class WeekConfigResult {
  final String dietaryPreference;
  final int mealCount;
  final bool isSkipped;
  final bool keepSame;

  WeekConfigResult({
    required this.dietaryPreference,
    required this.mealCount,
    this.isSkipped = false,
    this.keepSame = false,
  });
}

class WeekConfigBottomSheet extends StatefulWidget {
  final int weekNumber;
  final String defaultDietaryPreference;
  final int defaultMealCount;
  final bool showKeepSameOption;
  final int? currentSelections;

  const WeekConfigBottomSheet({
    super.key,
    required this.weekNumber,
    required this.defaultDietaryPreference,
    required this.defaultMealCount,
    this.showKeepSameOption = true,
    this.currentSelections,
  });

  @override
  State<WeekConfigBottomSheet> createState() => _WeekConfigBottomSheetState();
}

class _WeekConfigBottomSheetState extends State<WeekConfigBottomSheet> {
  late String selectedDietaryPreference;
  late int selectedMealCount;
  bool isSkipped = false;

  @override
  void initState() {
    super.initState();
    selectedDietaryPreference = widget.defaultDietaryPreference;
    selectedMealCount = widget.defaultMealCount;
  }

  @override
  Widget build(BuildContext context) {
    // Simple prompt if showing keep same option
    if (widget.showKeepSameOption && widget.currentSelections == null) {
      return _buildSimplePrompt(context);
    }

    // Full config sheet
    return _buildFullConfig(context);
  }

  Widget _buildSimplePrompt(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppDimensions.borderRadiusLg),
          topRight: Radius.circular(AppDimensions.borderRadiusLg),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          SizedBox(height: AppSpacing.lg),

          // Title
          Text(
            'Configure Week ${widget.weekNumber}',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),

          SizedBox(height: AppSpacing.md),

          // Subtitle
          Text(
            'Use same settings as previous week?',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),

          SizedBox(height: AppSpacing.lg),

          // Current settings display
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildDietaryBadge(widget.defaultDietaryPreference),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      _getDietaryDisplayName(widget.defaultDietaryPreference),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Icon(
                      Icons.restaurant_menu,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      '${widget.defaultMealCount} meals per week',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: AppSpacing.lg),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showFullConfig(),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                  ),
                  child: const Text('Customize'),
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: PrimaryButton(
                  text: 'Yes, Keep Same',
                  onPressed: () {
                    Navigator.pop(
                      context,
                      WeekConfigResult(
                        dietaryPreference: widget.defaultDietaryPreference,
                        mealCount: widget.defaultMealCount,
                        keepSame: true,
                      ),
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

  Widget _buildFullConfig(BuildContext context) {
    final hasCurrentSelections =
        widget.currentSelections != null && widget.currentSelections! > 0;

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppDimensions.borderRadiusLg),
          topRight: Radius.circular(AppDimensions.borderRadiusLg),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
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

            SizedBox(height: AppSpacing.lg),

            // Title
            Text(
              'Configure Week ${widget.weekNumber}',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),

            SizedBox(height: AppSpacing.lg),

            // Dietary Preference
            Text(
              'Dietary Preference',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _buildDietaryOption(
                    'vegetarian',
                    'Vegetarian',
                    Icons.eco,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildDietaryOption(
                    'non-vegetarian',
                    'Non-Veg',
                    Icons.restaurant,
                  ),
                ),
              ],
            ),

            SizedBox(height: AppSpacing.lg),

            // Meal Count
            Text(
              'Meal Count',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(child: _buildMealCountOption(10)),
                SizedBox(width: AppSpacing.sm),
                Expanded(child: _buildMealCountOption(15)),
                SizedBox(width: AppSpacing.sm),
                Expanded(child: _buildMealCountOption(21)),
              ],
            ),

            SizedBox(height: AppSpacing.lg),

            // Skip week option
            CheckboxListTile(
              value: isSkipped,
              onChanged: (value) {
                setState(() {
                  isSkipped = value ?? false;
                });
              },
              title: const Text('Skip this week entirely'),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            ),

            // Warning if has selections
            if (hasCurrentSelections) ...[
              SizedBox(height: AppSpacing.md),
              Container(
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.borderRadiusMd,
                  ),
                  border: Border.all(color: Colors.orange.shade300),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange.shade700,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Note: You have ${widget.currentSelections}/${widget.defaultMealCount} meals selected. Changing settings will reset all selections for this week.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.orange.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: AppSpacing.lg),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: PrimaryButton(
                    text: hasCurrentSelections ? 'Reset & Apply' : 'Apply',
                    onPressed: () => _applyConfig(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDietaryOption(String value, String label, IconData icon) {
    final isSelected = selectedDietaryPreference == value;

    return InkWell(
      onTap: () {
        setState(() {
          selectedDietaryPreference = value;
        });
      },
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.primary.withOpacity(0.1)
                  : Colors.grey.shade50,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : Colors.grey,
              size: 28,
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealCountOption(int count) {
    final isSelected = selectedMealCount == count;

    return InkWell(
      onTap: () {
        setState(() {
          selectedMealCount = count;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.primary.withOpacity(0.1)
                  : Colors.grey.shade50,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
            Text(
              'meals',
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDietaryBadge(String preference) {
    final isVeg = preference.toLowerCase() == 'vegetarian';

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isVeg ? Colors.green : Colors.red,
        shape: BoxShape.circle,
      ),
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      ),
    );
  }

  String _getDietaryDisplayName(String preference) {
    return preference.toLowerCase() == 'vegetarian'
        ? 'Vegetarian'
        : 'Non-Vegetarian';
  }

  void _showFullConfig() {
    setState(() {
      // Just rebuild with full config
    });
  }

  void _applyConfig(BuildContext context) {
    Navigator.pop(
      context,
      WeekConfigResult(
        dietaryPreference: selectedDietaryPreference,
        mealCount: selectedMealCount,
        isSkipped: isSkipped,
        keepSame: false,
      ),
    );
  }
}
