// // lib/src/domain/entities/dish_selection.dart
// import 'package:equatable/equatable.dart';
//
// import 'meal_plan_item.dart';
//
// /// Represents a user's selection of a specific dish for a specific day, timing, and week
// class DishSelection extends Equatable {
//   final String id; // Format: "week_day_timing_dishId"
//   final int week;
//   final String day; // monday, tuesday, etc.
//   final String timing; // breakfast, lunch, dinner
//   final String dishId; // The actual dish ID from calculated plan
//   final String dishName;
//   final DateTime date; // Actual date for this selection
//   final String packageId; // Package ID for this week
//
//   const DishSelection({
//     required this.id,
//     required this.week,
//     required this.day,
//     required this.timing,
//     required this.dishId,
//     required this.dishName,
//     required this.date,
//     required this.packageId,
//   });
//
//   @override
//   List<Object?> get props => [
//     id,
//     week,
//     day,
//     timing,
//     dishId,
//     dishName,
//     date,
//     packageId,
//   ];
//
//   /// Factory to create DishSelection from MealPlanItem
//   factory DishSelection.fromMealPlanItem({
//     required int week,
//     required MealPlanItem item,
//     required DateTime date,
//     required String packageId,
//   }) {
//     final id = '${week}_${item.day}_${item.timing}_${item.dishId}';
//
//     return DishSelection(
//       id: id,
//       week: week,
//       day: item.day,
//       timing: item.timing,
//       dishId: item.dishId,
//       dishName: item.dishName,
//       date: date,
//       packageId: packageId,
//     );
//   }
//
//   /// Convert to API slot format
//   Map<String, dynamic> toApiSlot() {
//     return {
//       'day': day.toLowerCase(),
//       'date': date.toUtc().toIso8601String(),
//       'timing': timing.toLowerCase(),
//       'meal': dishId, // This is what API expects
//     };
//   }
//
//   /// Helper getters
//   String get mealType => timing;
//   String get displayText => '$dishName ($timing)';
//   bool get isToday {
//     final now = DateTime.now();
//     return date.year == now.year &&
//         date.month == now.month &&
//         date.day == now.day;
//   }
//
//   /// Copy with new values
//   DishSelection copyWith({
//     String? id,
//     int? week,
//     String? day,
//     String? timing,
//     String? dishId,
//     String? dishName,
//     DateTime? date,
//     String? packageId,
//   }) {
//     return DishSelection(
//       id: id ?? this.id,
//       week: week ?? this.week,
//       day: day ?? this.day,
//       timing: timing ?? this.timing,
//       dishId: dishId ?? this.dishId,
//       dishName: dishName ?? this.dishName,
//       date: date ?? this.date,
//       packageId: packageId ?? this.packageId,
//     );
//   }
// }
