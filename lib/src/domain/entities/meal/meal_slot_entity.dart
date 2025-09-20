import 'package:equatable/equatable.dart';

class MealSlot extends Equatable {
  final String? day;
  final DateTime? date;
  final String? timing;
  final String? dishId;

  const MealSlot({this.day, this.date, this.timing, this.dishId});

  @override
  List<Object?> get props => [day, date, timing, dishId];

  // Helper getters
  String get displayDay => day?.toLowerCase().capitalize() ?? '';
  String get displayTiming => timing?.toLowerCase().capitalize() ?? '';

  bool get isBreakfast => timing?.toLowerCase() == 'breakfast';
  bool get isLunch => timing?.toLowerCase() == 'lunch';
  bool get isDinner => timing?.toLowerCase() == 'dinner';

  bool get isToday {
    if (date == null) return false;
    final now = DateTime.now();
    return date!.year == now.year &&
        date!.month == now.month &&
        date!.day == now.day;
  }

  MealSlot copyWith({
    String? day,
    DateTime? date,
    String? timing,
    String? dishId,
  }) {
    return MealSlot(
      day: day ?? this.day,
      date: date ?? this.date,
      timing: timing ?? this.timing,
      dishId: dishId ?? this.dishId,
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
