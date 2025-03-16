import 'package:foodam/src/domain/entities/meal_entity.dart';

enum ThaliType { normal, nonVeg, deluxe }

// Enhanced Thali entity
class Thali {
  final String id;
  final String name;
  final ThaliType type;
  final double basePrice;
  final List<Meal> defaultMeals;
  final List<Meal> selectedMeals;
  final int maxCustomizations;

  // Calculate total price based on base price and any additional meals
  // Calculate total price based on base price and the current selection
  double get totalPrice {
    // Start with base price
    double total = basePrice;

    // Calculate total of all default meals
    double defaultMealsPrice = 0;
    for (final meal in defaultMeals) {
      defaultMealsPrice += meal.price;
    }

    // Calculate total of all selected meals
    double selectedMealsPrice = 0;
    for (final meal in selectedMeals) {
      selectedMealsPrice += meal.price;
    }

    // If selected meal price exceeds default meal price, add the difference
    if (selectedMealsPrice > defaultMealsPrice) {
      total += (selectedMealsPrice - defaultMealsPrice);
    }

    return total;
  }

  // Calculate additional price from customizations
  double get additionalPrice {
    // Calculate total of all default meals
    double defaultMealsPrice = 0;
    for (final meal in defaultMeals) {
      defaultMealsPrice += meal.price;
    }

    // Calculate total of all selected meals
    double selectedMealsPrice = 0;
    for (final meal in selectedMeals) {
      selectedMealsPrice += meal.price;
    }

    // The additional price is the difference, if positive
    double diff = selectedMealsPrice - defaultMealsPrice;
    return diff > 0 ? diff : 0;
  }

  // Method to check if meals match with another thali
  bool hasSameMeals(Thali other) {
    if (selectedMeals.length != other.selectedMeals.length) {
      return false;
    }

    // Create sorted copies of both lists
    final sortedMeals1 = List<Meal>.from(selectedMeals)
      ..sort((a, b) => a.id.compareTo(b.id));
    final sortedMeals2 = List<Meal>.from(other.selectedMeals)
      ..sort((a, b) => a.id.compareTo(b.id));

    // Compare each meal by ID
    for (int i = 0; i < sortedMeals1.length; i++) {
      if (sortedMeals1[i].id != sortedMeals2[i].id) {
        return false;
      }
    }

    return true;
  }

  // Constructor
  Thali({
    required this.id,
    required this.name,
    required this.type,
    required this.basePrice,
    required this.defaultMeals,
    required this.selectedMeals,
    required this.maxCustomizations,
  });

  // CopyWith method for creating modified instances
  Thali copyWith({
    String? id,
    String? name,
    ThaliType? type,
    double? basePrice,
    List<Meal>? defaultMeals,
    List<Meal>? selectedMeals,
    int? maxCustomizations,
  }) {
    return Thali(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      basePrice: basePrice ?? this.basePrice,
      defaultMeals: defaultMeals ?? this.defaultMeals,
      selectedMeals: selectedMeals ?? this.selectedMeals,
      maxCustomizations: maxCustomizations ?? this.maxCustomizations,
    );
  }

  // Create a customized thali from this one with new meal selections
  Thali customize(List<Meal> newMeals) {
    return copyWith(name: 'Customized $name', selectedMeals: newMeals);
  }

  // Check if a meal is included in this thali
  bool containsMeal(Meal meal) {
    return selectedMeals.any((m) => m.id == meal.id);
  }

  // Check if this thali is customized (differs from default)
  bool get isCustomized {
    if (selectedMeals.length != defaultMeals.length) {
      return true;
    }

    // Sort both lists for consistent comparison
    final sortedSelected = List<Meal>.from(selectedMeals)
      ..sort((a, b) => a.id.compareTo(b.id));
    final sortedDefault = List<Meal>.from(defaultMeals)
      ..sort((a, b) => a.id.compareTo(b.id));

    // Compare each meal
    for (int i = 0; i < sortedSelected.length; i++) {
      if (sortedSelected[i].id != sortedDefault[i].id) {
        return true;
      }
    }

    return false;
  }
}
