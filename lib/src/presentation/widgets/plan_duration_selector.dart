// lib/src/presentation/widgets/subscription/plan_duration_selector.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/constants/app_constants.dart';

class PlanDurationSelector extends StatelessWidget {
  final int selectedDuration;
  final ValueChanged<int> onDurationSelected;

  const PlanDurationSelector({
    Key? key,
    required this.selectedDuration,
    required this.onDurationSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Plan Duration',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildDurationOption(
              context,
              AppConstants.sevenDayPlan,
              '7 Days',
              'Weekly',
            ),
            const SizedBox(width: 16),
            _buildDurationOption(
              context,
              AppConstants.fourteenDayPlan,
              '14 Days',
              'Bi-Weekly',
            ),
            const SizedBox(width: 16),
            _buildDurationOption(
              context,
              AppConstants.twentyEightDayPlan,
              '28 Days',
              'Monthly',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDurationOption(
    BuildContext context,
    int days,
    String title,
    String subtitle,
  ) {
    final isSelected = selectedDuration == days;

    return Expanded(
      child: GestureDetector(
        onTap: () => onDurationSelected(days),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.divider,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}