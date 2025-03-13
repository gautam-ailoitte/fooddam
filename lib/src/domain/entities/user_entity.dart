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

  double get totalPrice {
    double total = basePrice;
    for (final meal in selectedMeals) {
      if (!defaultMeals.contains(meal)) {
        total += meal.price;
      }
    }
    return total;
  }
  
  // Method to check if meals match
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
  
  // Method to calculate additional price beyond base
  double get additionalPrice {
    double extra = 0.0;
    for (final meal in selectedMeals) {
      if (!defaultMeals.contains(meal)) {
        extra += meal.price;
      }
    }
    return extra;
  }

  Thali({
    required this.id,
    required this.name,
    required this.type,
    required this.basePrice,
    required this.defaultMeals,
    required this.selectedMeals,
    required this.maxCustomizations,
  });

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

  DailyMeals({
    this.breakfast,
    this.lunch,
    this.dinner,
  });

  double get dailyTotal {
    double total = 0;
    if (breakfast != null) total += breakfast!.totalPrice;
    if (lunch != null) total += lunch!.totalPrice;
    if (dinner != null) total += dinner!.totalPrice;
    return total;
  }

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
}



// Enhanced Plan entity

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

  double get totalPrice {
    double total = 0;
    mealsByDay.forEach((day, meals) {
      total += meals.dailyTotal;
    });
    
    // Apply any discounts based on duration
    return total;
  }
  
  // New method for updating a specific meal
  Plan updateMeal({
    required DayOfWeek day,
    required MealType mealType,
    required Thali thali,
  }) {
    // Create new mealsByDay map
    final updatedMealsByDay = Map<DayOfWeek, DailyMeals>.from(this.mealsByDay);
    
    // Get current daily meals or create new
    final currentDailyMeals = updatedMealsByDay[day] ?? DailyMeals();
    
    // Update based on meal type
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
    
    return null; // Default return (shouldn't reach here with proper enum)
  }

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