// lib/src/presentation/screens/meal_planning/widgets/week_stepper_widget.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/layout/app_spacing.dart';

class WeekStepperWidget extends StatelessWidget {
  final int currentWeek;
  final int totalWeeks;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const WeekStepperWidget({
    super.key,
    required this.currentWeek,
    required this.totalWeeks,
    this.onPrevious,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Previous button
        _buildStepperButton(
          context: context,
          icon: Icons.chevron_left,
          onPressed: onPrevious,
          enabled: onPrevious != null,
        ),

        SizedBox(width: AppSpacing.xs),

        // Week indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Text(
            'Week $currentWeek',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        SizedBox(width: AppSpacing.xs),

        // Next button
        _buildStepperButton(
          context: context,
          icon: Icons.chevron_right,
          onPressed: onNext,
          enabled: onNext != null,
        ),
      ],
    );
  }

  Widget _buildStepperButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback? onPressed,
    required bool enabled,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color:
                enabled
                    ? AppColors.primary.withOpacity(0.1)
                    : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color:
                  enabled
                      ? AppColors.primary.withOpacity(0.3)
                      : Colors.grey.shade300,
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: enabled ? AppColors.primary : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }
}
