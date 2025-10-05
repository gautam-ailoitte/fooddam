// lib/src/presentation/cubits/meal_planning/week_selection_extensions.dart
import 'package:foodam/src/domain/entities/meal_planning/week_selection_data_entity.dart';

extension WeekSelectionDataExtensions on WeekSelectionData {
  // Convert selections to API format (day::timing)
  List<String> getAllSlots() {
    // selectedSlots is already in "day::meal" format
    // Just filter for selected (true) ones
    return selectedSlots.entries
        .where((entry) => entry.value == true)
        .map((entry) => entry.key)
        .toList();
  }
}
