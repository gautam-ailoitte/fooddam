// lib/src/presentation/widgets/day_selector.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/constants/string_constants.dart';

class DaySelector extends StatelessWidget {
  final int selectedDayIndex;
  final Function(int) onDaySelected;

  const DaySelector({
    Key? key,
    required this.selectedDayIndex,
    required this.onDaySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7, // 7 days in a week
        itemBuilder: (context, index) {
          final isSelected = index == selectedDayIndex;
          return _buildDayOption(context, index, isSelected);
        },
      ),
    );
  }

  Widget _buildDayOption(BuildContext context, int index, bool isSelected) {
    final dayName = _getDayName(index);
    final dayNumber = index + 1;

    return GestureDetector(
      onTap: () => onDaySelected(index),
      child: Container(
        width: 60,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Day',
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
            Text(
              '$dayNumber',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
            Text(
              dayName,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDayName(int index) {
    switch (index % 7) {
      case 0:
        return StringConstants.monday.substring(0, 3);
      case 1:
        return StringConstants.tuesday.substring(0, 3);
      case 2:
        return StringConstants.wednesday.substring(0, 3);
      case 3:
        return StringConstants.thursday.substring(0, 3);
      case 4:
        return StringConstants.friday.substring(0, 3);
      case 5:
        return StringConstants.saturday.substring(0, 3);
      case 6:
        return StringConstants.sunday.substring(0, 3);
      default:
        return '';
    }
  }
}

