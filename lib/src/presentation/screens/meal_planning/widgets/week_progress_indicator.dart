// lib/src/presentation/widgets/meal_planning/week_progress_indicator.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/layout/app_spacing.dart';

class WeekProgressIndicator extends StatelessWidget {
  final int currentWeek;
  final int totalWeeks;
  final double overallProgress;

  const WeekProgressIndicator({
    super.key,
    required this.currentWeek,
    required this.totalWeeks,
    required this.overallProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        children: [
          _buildWeekSteps(context),
          SizedBox(height: AppSpacing.sm),
          _buildOverallProgress(context),
        ],
      ),
    );
  }

  Widget _buildWeekSteps(BuildContext context) {
    return Row(
      children: [
        for (int week = 1; week <= totalWeeks; week++) ...[
          _buildWeekStep(context, week),
          if (week < totalWeeks) _buildStepConnector(context, week),
        ],
      ],
    );
  }

  Widget _buildWeekStep(BuildContext context, int week) {
    final isActive = week == currentWeek;
    final isCompleted = week < currentWeek;
    final stepColor = _getStepColor(week);

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: stepColor,
              shape: BoxShape.circle,
              border:
                  isActive
                      ? Border.all(color: AppColors.primary, width: 2)
                      : null,
            ),
            child: Center(
              child:
                  isCompleted
                      ? Icon(Icons.check, color: Colors.white, size: 18)
                      : Text(
                        '$week',
                        style: Theme.of(
                          context,
                        ).textTheme.labelMedium?.copyWith(
                          color: _getStepTextColor(week),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            'Week $week',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: isActive ? AppColors.primary : AppColors.textSecondary,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector(BuildContext context, int week) {
    final isCompleted = week < currentWeek;

    return Expanded(
      child: Container(
        height: 2,
        margin: EdgeInsets.only(bottom: 24), // Align with step circles
        decoration: BoxDecoration(
          color: isCompleted ? AppColors.primary : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }

  Widget _buildOverallProgress(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Overall Progress',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
            Text(
              '${(overallProgress * 100).toInt()}% Complete',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.xs),
        LinearProgressIndicator(
          value: overallProgress.clamp(0.0, 1.0),
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          minHeight: 6,
        ),
      ],
    );
  }

  Color _getStepColor(int week) {
    if (week < currentWeek) {
      return AppColors.primary; // Completed
    } else if (week == currentWeek) {
      return AppColors.primary.withOpacity(0.2); // Active
    } else {
      return Colors.grey.shade300; // Upcoming
    }
  }

  Color _getStepTextColor(int week) {
    if (week < currentWeek) {
      return Colors.white; // Completed (white text on primary background)
    } else if (week == currentWeek) {
      return AppColors.primary; // Active (primary text on light background)
    } else {
      return AppColors.textSecondary; // Upcoming (secondary text)
    }
  }
}
