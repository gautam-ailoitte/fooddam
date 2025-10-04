// lib/src/presentation/widgets/meal_planning/validation_chip_widget.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/src/domain/entities/meal_planning/week_validation_entity.dart';

class ValidationChipWidget extends StatelessWidget {
  final WeekValidation validation;
  final bool showProgress;

  const ValidationChipWidget({
    super.key,
    required this.validation,
    this.showProgress = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
        border: Border.all(color: _getBorderColor()),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_getStatusIcon(), color: _getIconColor(), size: 20),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      validation.message,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: _getTextColor(),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2),
                    _buildProgressText(context),
                  ],
                ),
              ),
            ],
          ),
          if (showProgress && !validation.isComplete) ...[
            SizedBox(height: AppSpacing.sm),
            _buildProgressBar(context),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressText(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: _getTextColor().withOpacity(0.8),
        ),
        children: [
          TextSpan(
            text: '${validation.selectedCount}',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: _getTextColor(),
            ),
          ),
          TextSpan(text: ' of '),
          TextSpan(
            text: '${validation.targetCount}',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: _getTextColor(),
            ),
          ),
          TextSpan(text: ' meals selected'),
        ],
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: validation.progressPercentage,
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor()),
                minHeight: 4,
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Text(
              '${(validation.progressPercentage * 100).toInt()}%',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: _getTextColor(),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getBackgroundColor() {
    switch (validation.status) {
      case ValidationStatus.complete:
        return Colors.green.shade50;
      case ValidationStatus.partial:
        return Colors.orange.shade50;
      case ValidationStatus.overSelected:
        return Colors.red.shade50;
      case ValidationStatus.empty:
        return Colors.grey.shade50;
    }
  }

  Color _getBorderColor() {
    switch (validation.status) {
      case ValidationStatus.complete:
        return Colors.green.shade300;
      case ValidationStatus.partial:
        return Colors.orange.shade300;
      case ValidationStatus.overSelected:
        return Colors.red.shade300;
      case ValidationStatus.empty:
        return Colors.grey.shade300;
    }
  }

  Color _getTextColor() {
    switch (validation.status) {
      case ValidationStatus.complete:
        return Colors.green.shade800;
      case ValidationStatus.partial:
        return Colors.orange.shade800;
      case ValidationStatus.overSelected:
        return Colors.red.shade800;
      case ValidationStatus.empty:
        return Colors.grey.shade700;
    }
  }

  Color _getIconColor() {
    switch (validation.status) {
      case ValidationStatus.complete:
        return Colors.green.shade600;
      case ValidationStatus.partial:
        return Colors.orange.shade600;
      case ValidationStatus.overSelected:
        return Colors.red.shade600;
      case ValidationStatus.empty:
        return Colors.grey.shade500;
    }
  }

  Color _getProgressColor() {
    switch (validation.status) {
      case ValidationStatus.complete:
        return Colors.green.shade600;
      case ValidationStatus.partial:
        return Colors.orange.shade600;
      case ValidationStatus.overSelected:
        return Colors.red.shade600;
      case ValidationStatus.empty:
        return Colors.grey.shade400;
    }
  }

  IconData _getStatusIcon() {
    switch (validation.status) {
      case ValidationStatus.complete:
        return Icons.check_circle;
      case ValidationStatus.partial:
        return Icons.access_time;
      case ValidationStatus.overSelected:
        return Icons.warning;
      case ValidationStatus.empty:
        return Icons.radio_button_unchecked;
    }
  }
}
