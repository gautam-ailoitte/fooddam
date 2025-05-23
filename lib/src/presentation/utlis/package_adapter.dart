// // lib/src/presentation/utils/package_adapter.dart
// import 'package:foodam/src/domain/entities/pacakge_entity.dart';
//
// /// Utility class for adapting package entities to UI-friendly formats
// class PackageAdapter {
//   /// Get the starting price for a package from its price options
//   static double? getBasePrice(Package package) {
//     if (package.priceOptions == null || package.priceOptions!.isEmpty) {
//       return package.priceRange?.min;
//     }
//
//     // Sort price options by price
//     final sortedOptions = List.of(package.priceOptions!)
//       ..sort((a, b) => a.price.compareTo(b.price));
//
//     return sortedOptions.first.price;
//   }
//
//   /// Get price for a specific meal count
//   static double? getPriceForMealCount(Package package, int mealCount) {
//     if (package.priceOptions == null || package.priceOptions!.isEmpty) {
//       return package.priceRange?.min;
//     }
//
//     // Look for exact match
//     final exactMatch =
//         package.priceOptions!
//             .where((option) => option.numberOfMeals == mealCount)
//             .toList();
//
//     if (exactMatch.isNotEmpty) {
//       return exactMatch.first.price;
//     }
//
//     // Find closest match
//     final sortedOptions = List.of(package.priceOptions!)..sort(
//       (a, b) => (a.numberOfMeals - mealCount).abs().compareTo(
//         (b.numberOfMeals - mealCount).abs(),
//       ),
//     );
//
//     return sortedOptions.first.price;
//   }
//
//   /// Count meals by type (breakfast, lunch, dinner) from a package's slots
//   static Map<String, int> countMealsByType(Package package) {
//     final Map<String, int> counts = {'breakfast': 0, 'lunch': 0, 'dinner': 0};
//
//     // If package doesn't have mealSlots data, return default counts
//     // We use default counts since packages typically offer a consistent
//     // number of meals each week
//     if (package.dailyMeals == null || package.dailyMeals!.isEmpty) {
//       // Assuming a standard 7-day week with one meal per type per day
//       counts['breakfast'] = 7;
//       counts['lunch'] = 7;
//       counts['dinner'] = 7;
//       return counts;
//     }
//
//     // Count slots by meal type
//     for (final mealEntry in package.dailyMeals!.entries) {
//       final mealData = mealEntry.value;
//       if (mealData.hasBreakfast)
//         counts['breakfast'] = (counts['breakfast'] ?? 0) + 1;
//       if (mealData.hasLunch) counts['lunch'] = (counts['lunch'] ?? 0) + 1;
//       if (mealData.hasDinner) counts['dinner'] = (counts['dinner'] ?? 0) + 1;
//     }
//
//     return counts;
//   }
//
//   /// Check if a package is vegetarian based on its name or dietary preferences
//   static bool isVegetarian(Package package) {
//     // Check name first (quick heuristic)
//     final name = package.name.toLowerCase();
//     if (name.contains('veg') && !name.contains('non-veg')) {
//       return true;
//     }
//
//     // Check dietary preferences if available
//     if (package.dietaryPreferences != null) {
//       return package.dietaryPreferences!.any(
//         (pref) => pref.toLowerCase() == 'vegetarian',
//       );
//     }
//
//     return false;
//   }
//
//   /// Check if a package is non-vegetarian based on its name or dietary preferences
//   static bool isNonVegetarian(Package package) {
//     // Check name first (quick heuristic)
//     final name = package.name.toLowerCase();
//     if (name.contains('non-veg')) {
//       return true;
//     }
//
//     // Check dietary preferences if available
//     if (package.dietaryPreferences != null) {
//       return package.dietaryPreferences!.any(
//         (pref) => pref.toLowerCase() == 'non-vegetarian',
//       );
//     }
//
//     return false;
//   }
//
//   /// Get meal count options for a package
//   static List<int> getMealCountOptions(Package package) {
//     if (package.priceOptions == null || package.priceOptions!.isEmpty) {
//       // Default options if not specified
//       return [10, 15, 18, 21];
//     }
//
//     // Extract and sort meal count options
//     final options =
//         package.priceOptions!.map((option) => option.numberOfMeals).toList()
//           ..sort();
//
//     return options;
//   }
//
//   /// Get the total slot count for a package
//   static int getTotalSlotCount(Package package) {
//     // If explicitly provided, use that
//     if (package.noOfSlots > 0) {
//       return package.noOfSlots;
//     }
//
//     // Otherwise calculate from daily meals if available
//     if (package.dailyMeals != null) {
//       int count = 0;
//       for (final meal in package.dailyMeals!.values) {
//         if (meal.hasBreakfast) count++;
//         if (meal.hasLunch) count++;
//         if (meal.hasDinner) count++;
//       }
//       return count;
//     }
//
//     // Default to 21 (3 meals × 7 days)
//     return 21;
//   }
//
//   /// Format the package price for display
//   static String formatPrice(Package package) {
//     final basePrice = getBasePrice(package);
//     if (basePrice == null) return 'Price unavailable';
//
//     return '₹${basePrice.toStringAsFixed(0)}';
//   }
// }
