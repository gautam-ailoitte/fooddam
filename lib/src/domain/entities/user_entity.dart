// lib/domain/entities/user.dart
class User {
  final String id;
  final String name;
  final String email;
  final bool hasActivePlan;
  final String? activePlanId;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.hasActivePlan,
    this.activePlanId,
  });
}

// lib/domain/entities/meal.dart
enum MealType {
  breakfast,
  lunch,
  dinner,
}

class Meal {
  final String id;
  final String name;
  final String description;
  final double price;
  final bool isVeg;
  final MealType type;
  final String imageUrl;

  Meal({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.isVeg,
    required this.type,
    required this.imageUrl,
  });
}

// lib/domain/entities/thali.dart
enum ThaliType {
  normal,
  nonVeg,
  deluxe,
}


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
  double get totalPrice {
    double total = basePrice;
    total += additionalPrice;
    return total;
  }
  
  // Calculate additional price from customizations
  double get additionalPrice {
    double extra = 0.0;
    for (final meal in selectedMeals) {
      // Only add price for non-default meals
      if (!defaultMeals.any((defaultMeal) => defaultMeal.id == meal.id)) {
        extra += meal.price;
      }
    }
    return extra;
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
    return copyWith(
      name: 'Customized $name',
      selectedMeals: newMeals,
    );
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

// lib/domain/entities/plan.dart
enum DayOfWeek {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday,
}

enum PlanDuration {
  sevenDays,
  fourteenDays,
  twentyEightDays,
}

class DailyMeals {
  final Thali? breakfast;
  final Thali? lunch;
  final Thali? dinner;

  // Calculate total price for all meals in a day
  double get dailyTotal {
    double total = 0;
    if (breakfast != null) total += breakfast!.totalPrice;
    if (lunch != null) total += lunch!.totalPrice;
    if (dinner != null) total += dinner!.totalPrice;
    return total;
  }
  
  // Check if this day has any customized meals
  bool get hasCustomizedMeals {
    if (breakfast != null && breakfast!.isCustomized) return true;
    if (lunch != null && lunch!.isCustomized) return true;
    if (dinner != null && dinner!.isCustomized) return true;
    return false;
  }
  
  // Get a summary of the day's meals
  String get summary {
    List<String> mealNames = [];
    if (breakfast != null) mealNames.add(breakfast!.name);
    if (lunch != null) mealNames.add(lunch!.name);
    if (dinner != null) mealNames.add(dinner!.name);
    
    if (mealNames.isEmpty) return "No meals selected";
    return mealNames.join(", ");
  }

  // Constructor
  DailyMeals({
    this.breakfast,
    this.lunch,
    this.dinner,
  });

  // CopyWith method for creating modified instances
  DailyMeals copyWith({
    Thali? breakfast,
    Thali? lunch,
    Thali? dinner,
  }) {
    return DailyMeals(
      breakfast: breakfast ?? this.breakfast,
      lunch: lunch ?? this.lunch,
      dinner: dinner ?? this.dinner,
    );
  }
  
  // Get meal by type
  Thali? getMealByType(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return breakfast;
      case MealType.lunch:
        return lunch;
      case MealType.dinner:
        return dinner;
      }
  }
  
  // Update meal of a specific type
  DailyMeals updateMeal(MealType type, Thali thali) {
    switch (type) {
      case MealType.breakfast:
        return copyWith(breakfast: thali);
      case MealType.lunch:
        return copyWith(lunch: thali);
      case MealType.dinner:
        return copyWith(dinner: thali);
      }
  }
  
  // Check if all meals are selected for this day
  bool get isComplete {
    return breakfast != null && lunch != null && dinner != null;
  }
  
  // Count how many meals are selected
  int get mealCount {
    int count = 0;
    if (breakfast != null) count++;
    if (lunch != null) count++;
    if (dinner != null) count++;
    return count;
  }
}

// Enhanced Plan entity

// lib/src/domain/entities/plan_entity.dart


class Plan {
  final String id;
  final String name;
  final bool isVeg;
  final PlanDuration duration;
  final DateTime? startDate;
  final DateTime? endDate;
  final Map<DayOfWeek, DailyMeals> mealsByDay;
  final double basePrice;
  final bool isCustomized;
  final bool isDraft;

  // Calculate total price considering all meals and any duration-based discounts
  double get totalPrice {
    double total = 0;
    
    // Sum up the price of all meals
    mealsByDay.forEach((day, meals) {
      total += meals.dailyTotal;
    });
    
    // Apply duration-based discounts
    switch (duration) {
      case PlanDuration.sevenDays:
        // No discount for 7 days
        break;
      case PlanDuration.fourteenDays:
        // 5% discount for 14 days
        total = total * 0.95;
        break;
      case PlanDuration.twentyEightDays:
        // 10% discount for 28 days
        total = total * 0.90;
        break;
    }
    
    return total;
  }
  
  // Get the number of days in the plan
  int get durationDays {
    switch (duration) {
      case PlanDuration.sevenDays:
        return 7;
      case PlanDuration.fourteenDays:
        return 14;
      case PlanDuration.twentyEightDays:
        return 28;
    }
  }
  
  // Get duration as readable text
  String get durationText {
    switch (duration) {
      case PlanDuration.sevenDays:
        return '7 Days';
      case PlanDuration.fourteenDays:
        return '14 Days';
      case PlanDuration.twentyEightDays:
        return '28 Days';
    }
  }
  
  // Check if the plan has been modified from template
  bool get isModified {
    if (!isCustomized) return false;
    
    // Count non-null meals
    int mealCount = 0;
    mealsByDay.forEach((day, meals) {
      if (meals.breakfast != null) mealCount++;
      if (meals.lunch != null) mealCount++;
      if (meals.dinner != null) mealCount++;
    });
    
    return mealCount > 0;
  }
  
  // Get short description of the plan
  String get shortDescription {
    return '$name (${isVeg ? 'Veg' : 'Non-Veg'}) - $durationText';
  }
  
  // Method for updating a specific meal
  Plan updateMeal({
    required DayOfWeek day,
    required MealType mealType,
    required Thali thali,
  }) {
    // Create a copy of the current plan's meals
    final updatedMealsByDay = Map<DayOfWeek, DailyMeals>.from(mealsByDay);
    
    // Get the current daily meals or create new
    final currentDailyMeals = updatedMealsByDay[day] ?? DailyMeals();
    
    // Create updated daily meals
    DailyMeals updatedDailyMeals;
    switch (mealType) {
      case MealType.breakfast:
        updatedDailyMeals = currentDailyMeals.copyWith(breakfast: thali);
        break;
      case MealType.lunch:
        updatedDailyMeals = currentDailyMeals.copyWith(lunch: thali);
        break;
      case MealType.dinner:
        updatedDailyMeals = currentDailyMeals.copyWith(dinner: thali);
        break;
    }
    
    // Update the map
    updatedMealsByDay[day] = updatedDailyMeals;
    
    // Return new plan
    return copyWith(
      mealsByDay: updatedMealsByDay,
      isCustomized: true,
    );
  }
  
  // Method to get a specific meal
  Thali? getMeal(DayOfWeek day, MealType mealType) {
    if (!mealsByDay.containsKey(day)) return null;
    
    final dailyMeals = mealsByDay[day]!;
    
    switch (mealType) {
      case MealType.breakfast:
        return dailyMeals.breakfast;
      case MealType.lunch:
        return dailyMeals.lunch;
      case MealType.dinner:
        return dailyMeals.dinner;
    }
  }
  
  // Check if the plan is fully configured (all meals selected)
  bool get isComplete {
    final requiredDays = DayOfWeek.values.length;
    final requiredMealsPerDay = 3; // breakfast, lunch, dinner
    
    int totalMeals = 0;
    mealsByDay.forEach((day, meals) {
      if (meals.breakfast != null) totalMeals++;
      if (meals.lunch != null) totalMeals++;
      if (meals.dinner != null) totalMeals++;
    });
    
    return totalMeals == requiredDays * requiredMealsPerDay;
  }

  // Constructor
  Plan({
    required this.id,
    required this.name,
    required this.isVeg,
    required this.duration,
    this.startDate,
    this.endDate,
    required this.mealsByDay,
    required this.basePrice,
    required this.isCustomized,
    this.isDraft = false,
  });

  // CopyWith method for creating modified instances
  Plan copyWith({
    String? id,
    String? name,
    bool? isVeg,
    PlanDuration? duration,
    DateTime? startDate,
    DateTime? endDate,
    Map<DayOfWeek, DailyMeals>? mealsByDay,
    double? basePrice,
    bool? isCustomized,
    bool? isDraft,
  }) {
    return Plan(
      id: id ?? this.id,
      name: name ?? this.name,
      isVeg: isVeg ?? this.isVeg,
      duration: duration ?? this.duration,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      mealsByDay: mealsByDay ?? this.mealsByDay,
      basePrice: basePrice ?? this.basePrice,
      isCustomized: isCustomized ?? this.isCustomized,
      isDraft: isDraft ?? this.isDraft,
    );
  }
}