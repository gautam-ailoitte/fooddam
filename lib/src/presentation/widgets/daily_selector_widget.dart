import 'package:flutter/material.dart';
import 'package:foodam/core/constants/string_constants.dart';
import 'package:foodam/src/domain/entities/daily_meals_entity.dart';

class DaySelector extends StatelessWidget {
  final DayOfWeek selectedDay;
  final Function(DayOfWeek) onDaySelected;
  final PlanDuration planDuration;

  const DaySelector({
    super.key,
    required this.selectedDay,
    required this.onDaySelected,
    required this.planDuration,
  });

  @override
  Widget build(BuildContext context) {
    final days = DayOfWeek.values;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Select Day',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 8),
            itemCount: days.length,
            itemBuilder: (context, index) {
              final day = days[index];
              final isSelected = day == selectedDay;
              
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: GestureDetector(
                  onTap: () => onDaySelected(day),
                  child: Container(
                    width: 64,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
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
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          _getDayName(day),
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected ? Colors.white : Colors.grey[600],
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

  String _getDayAbbreviation(DayOfWeek day) {
    switch (day) {
      case DayOfWeek.monday:
        return 'Mon';
      case DayOfWeek.tuesday:
        return 'Tue';
      case DayOfWeek.wednesday:
        return 'Wed';
      case DayOfWeek.thursday:
        return 'Thu';
      case DayOfWeek.friday:
        return 'Fri';
      case DayOfWeek.saturday:
        return 'Sat';
      case DayOfWeek.sunday:
        return 'Sun';
    }
  }

  String _getDayName(DayOfWeek day) {
    switch (day) {
      case DayOfWeek.monday:
        return StringConstants.monday;
      case DayOfWeek.tuesday:
        return StringConstants.tuesday;
      case DayOfWeek.wednesday:
        return StringConstants.wednesday;
      case DayOfWeek.thursday:
        return StringConstants.thursday;
      case DayOfWeek.friday:
        return StringConstants.friday;
      case DayOfWeek.saturday:
        return StringConstants.saturday;
      case DayOfWeek.sunday:
        return StringConstants.sunday;
    }
  }
}
