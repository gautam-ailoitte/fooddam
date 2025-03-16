// lib/src/presentation/widgets/daily_selector_widget.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/constants/app_text_style.dart';
import 'package:foodam/core/constants/string_constants.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/domain/entities/daily_meals_entity.dart';
import 'package:foodam/src/presentation/utlis/date_formatter_utility.dart';

class DaySelector extends StatelessWidget {
  final DayOfWeek selectedDay;
  final Function(DayOfWeek) onDaySelected;
  final PlanDuration planDuration;
  static final LoggerService _logger = LoggerService();

  const DaySelector({
    super.key,
    required this.selectedDay,
    required this.onDaySelected,
    required this.planDuration,
  });

  @override
  Widget build(BuildContext context) {
    final days = DayOfWeek.values;
    _logger.d('Building DaySelector with selected day: $selectedDay', tag: 'WIDGET');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: Text(
            StringConstants.selectDay,
            style: AppTextStyles.heading6,
          ),
        ),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            itemCount: days.length,
            itemBuilder: (context, index) {
              final day = days[index];
              final isSelected = day == selectedDay;
              
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
                child: GestureDetector(
                  onTap: () => _handleDayTap(day),
                  child: Container(
                    width: 64,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _getDayAbbreviation(day),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? AppColors.textLight : AppColors.textPrimary,
                          ),
                        ),
                        AppSpacing.vXs,
                        Text(
                          _getDayName(day),
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected ? AppColors.textLight : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  void _handleDayTap(DayOfWeek day) {
    _logger.d('Day selected: $day', tag: 'WIDGET');
    onDaySelected(day);
  }

  String _getDayAbbreviation(DayOfWeek day) {
    return DateFormatter.getDayAbbreviation(day);
  }

  String _getDayName(DayOfWeek day) {
    return DateFormatter.getDayName(day);
  }
}