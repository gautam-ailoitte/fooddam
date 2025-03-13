// lib/mock_data.dart
import 'package:foodam/src/data/models/user_model.dart';
import 'package:foodam/src/domain/entities/user_entity.dart';

class MockData {
  static bool _hasActivePlan = true;

  // Method to toggle active plan status
  static void toggleActivePlan() {
    _hasActivePlan = !_hasActivePlan;
  }

  // Helper to create default meals for all days of week
  static Map<DayOfWeek, DailyMealsModel> createDefaultMeals(bool isVeg) {
    final Map<DayOfWeek, DailyMealsModel> defaultMeals = {};
    
    for (final day in DayOfWeek.values) {
      if (isVeg) {
        defaultMeals[day] = DailyMealsModel(
          breakfast: getMockBreakfastThalis()[0], // Normal veg breakfast
          lunch: getMockLunchThalis()[0],         // Normal veg lunch
          dinner: getMockDinnerThalis()[0],       // Normal veg dinner
        );
      } else {
        defaultMeals[day] = DailyMealsModel(
          breakfast: getMockBreakfastThalis()[1], // Non-veg breakfast
          lunch: getMockLunchThalis()[1],         // Non-veg lunch
          dinner: getMockDinnerThalis()[1],       // Non-veg dinner
        );
      }
    }
    
    return defaultMeals;
  }

  // Mock User
  static UserModel getMockUser() {
    return UserModel(
      id: 'user123',
      name: 'John Doe',
      email: 'user@example.com',
      hasActivePlan: _hasActivePlan,
      activePlanId: _hasActivePlan ? 'plan001' : null,
    );
  }

  // Mock Meals
  static List<MealModel> getMockBreakfastMeals() {
    return [
      MealModel(
        id: 'bm001',
        name: 'Paratha',
        description: 'Delicious stuffed paratha with butter',
        price: 40.0,
        isVeg: true,
        type: MealType.breakfast,
        imageUrl: 'https://example.com/paratha.jpg',
      ),
      MealModel(
        id: 'bm002',
        name: 'Poha',
        description: 'Flattened rice with peanuts and vegetables',
        price: 35.0,
        isVeg: true,
        type: MealType.breakfast,
        imageUrl: 'https://example.com/poha.jpg',
      ),
      MealModel(
        id: 'bm003',
        name: 'Upma',
        description: 'Savory semolina porridge',
        price: 30.0,
        isVeg: true,
        type: MealType.breakfast,
        imageUrl: 'https://example.com/upma.jpg',
      ),
      MealModel(
        id: 'bm004',
        name: 'Idli Sambar',
        description: 'Steamed rice cakes with lentil soup',
        price: 45.0,
        isVeg: true,
        type: MealType.breakfast,
        imageUrl: 'https://example.com/idli.jpg',
      ),
      MealModel(
        id: 'bm005',
        name: 'Omelette',
        description: 'Fluffy egg omelette with veggies',
        price: 50.0,
        isVeg: false,
        type: MealType.breakfast,
        imageUrl: 'https://example.com/omelette.jpg',
      ),
    ];
  }

  static List<MealModel> getMockLunchMeals() {
    return [
      MealModel(
        id: 'lm001',
        name: 'Dal',
        description: 'Lentil curry cooked with spices',
        price: 50.0,
        isVeg: true,
        type: MealType.lunch,
        imageUrl: 'https://example.com/dal.jpg',
      ),
      MealModel(
        id: 'lm002',
        name: 'Paneer Butter Masala',
        description: 'Cottage cheese in rich tomato gravy',
        price: 90.0,
        isVeg: true,
        type: MealType.lunch,
        imageUrl: 'https://example.com/paneer.jpg',
      ),
      MealModel(
        id: 'lm003',
        name: 'Aloo Gobi',
        description: 'Potato and cauliflower curry',
        price: 60.0,
        isVeg: true,
        type: MealType.lunch,
        imageUrl: 'https://example.com/aloogobi.jpg',
      ),
      MealModel(
        id: 'lm004',
        name: 'Butter Chicken',
        description: 'Tender chicken in rich tomato gravy',
        price: 120.0,
        isVeg: false,
        type: MealType.lunch,
        imageUrl: 'https://example.com/butterchicken.jpg',
      ),
      MealModel(
        id: 'lm005',
        name: 'Mutton Curry',
        description: 'Spicy mutton curry with aromatic spices',
        price: 150.0,
        isVeg: false,
        type: MealType.lunch,
        imageUrl: 'https://example.com/muttoncurry.jpg',
      ),
      MealModel(
        id: 'lm006',
        name: 'Rice',
        description: 'Steamed basmati rice',
        price: 30.0,
        isVeg: true,
        type: MealType.lunch,
        imageUrl: 'https://example.com/rice.jpg',
      ),
      MealModel(
        id: 'lm007',
        name: 'Roti',
        description: 'Whole wheat flatbread',
        price: 10.0,
        isVeg: true,
        type: MealType.lunch,
        imageUrl: 'https://example.com/roti.jpg',
      ),
    ];
  }

  static List<MealModel> getMockDinnerMeals() {
    return [
      MealModel(
        id: 'dm001',
        name: 'Mixed Vegetable',
        description: 'Assorted vegetables cooked with spices',
        price: 70.0,
        isVeg: true,
        type: MealType.dinner,
        imageUrl: 'https://example.com/mixveg.jpg',
      ),
      MealModel(
        id: 'dm002',
        name: 'Palak Paneer',
        description: 'Cottage cheese in spinach gravy',
        price: 90.0,
        isVeg: true,
        type: MealType.dinner,
        imageUrl: 'https://example.com/palakpaneer.jpg',
      ),
      MealModel(
        id: 'dm003',
        name: 'Chicken Curry',
        description: 'Chicken cooked in spicy gravy',
        price: 110.0,
        isVeg: false,
        type: MealType.dinner,
        imageUrl: 'https://example.com/chickencurry.jpg',
      ),
      MealModel(
        id: 'dm004',
        name: 'Fish Curry',
        description: 'Fish cooked in tangy gravy',
        price: 130.0,
        isVeg: false,
        type: MealType.dinner,
        imageUrl: 'https://example.com/fishcurry.jpg',
      ),
      MealModel(
        id: 'dm005',
        name: 'Naan',
        description: 'Leavened flatbread from tandoor',
        price: 20.0,
        isVeg: true,
        type: MealType.dinner,
        imageUrl: 'https://example.com/naan.jpg',
      ),
      MealModel(
        id: 'dm006',
        name: 'Jeera Rice',
        description: 'Cumin flavored rice',
        price: 40.0,
        isVeg: true,
        type: MealType.dinner,
        imageUrl: 'https://example.com/jeerarice.jpg',
      ),
    ];
  }

  // Mock Thali options
  static List<ThaliModel> getMockBreakfastThalis() {
    final breakfastMeals = getMockBreakfastMeals();

    return [
      ThaliModel(
        id: 'bt001',
        name: 'Normal Breakfast Thali',
        type: ThaliType.normal,
        basePrice: 70.0,
        defaultMeals: [breakfastMeals[1], breakfastMeals[2]],
        selectedMeals: [breakfastMeals[1], breakfastMeals[2]],
        maxCustomizations: 3,
      ),
      ThaliModel(
        id: 'bt002',
        name: 'Non-Veg Breakfast Thali',
        type: ThaliType.nonVeg,
        basePrice: 100.0,
        defaultMeals: [breakfastMeals[0], breakfastMeals[4]],
        selectedMeals: [breakfastMeals[0], breakfastMeals[4]],
        maxCustomizations: 3,
      ),
      ThaliModel(
        id: 'bt003',
        name: 'Deluxe Breakfast Thali',
        type: ThaliType.deluxe,
        basePrice: 120.0,
        defaultMeals: [breakfastMeals[0], breakfastMeals[3], breakfastMeals[4]],
        selectedMeals: [
          breakfastMeals[0],
          breakfastMeals[3],
          breakfastMeals[4],
        ],
        maxCustomizations: 4,
      ),
    ];
  }

  static List<ThaliModel> getMockLunchThalis() {
    final lunchMeals = getMockLunchMeals();

    return [
      ThaliModel(
        id: 'lt001',
        name: 'Normal Lunch Thali',
        type: ThaliType.normal,
        basePrice: 120.0,
        defaultMeals: [
          lunchMeals[0],
          lunchMeals[2],
          lunchMeals[5],
          lunchMeals[6],
        ],
        selectedMeals: [
          lunchMeals[0],
          lunchMeals[2],
          lunchMeals[5],
          lunchMeals[6],
        ],
        maxCustomizations: 5,
      ),
      ThaliModel(
        id: 'lt002',
        name: 'Non-Veg Lunch Thali',
        type: ThaliType.nonVeg,
        basePrice: 180.0,
        defaultMeals: [
          lunchMeals[0],
          lunchMeals[3],
          lunchMeals[5],
          lunchMeals[6],
        ],
        selectedMeals: [
          lunchMeals[0],
          lunchMeals[3],
          lunchMeals[5],
          lunchMeals[6],
        ],
        maxCustomizations: 5,
      ),
      ThaliModel(
        id: 'lt003',
        name: 'Deluxe Lunch Thali',
        type: ThaliType.deluxe,
        basePrice: 250.0,
        defaultMeals: [
          lunchMeals[0],
          lunchMeals[1],
          lunchMeals[4],
          lunchMeals[5],
          lunchMeals[6],
        ],
        selectedMeals: [
          lunchMeals[0],
          lunchMeals[1],
          lunchMeals[4],
          lunchMeals[5],
          lunchMeals[6],
        ],
        maxCustomizations: 6,
      ),
    ];
  }

  static List<ThaliModel> getMockDinnerThalis() {
    final dinnerMeals = getMockDinnerMeals();

    return [
      ThaliModel(
        id: 'dt001',
        name: 'Normal Dinner Thali',
        type: ThaliType.normal,
        basePrice: 110.0,
        defaultMeals: [dinnerMeals[0], dinnerMeals[5]],
        selectedMeals: [dinnerMeals[0], dinnerMeals[5]],
        maxCustomizations: 4,
      ),
      ThaliModel(
        id: 'dt002',
        name: 'Non-Veg Dinner Thali',
        type: ThaliType.nonVeg,
        basePrice: 170.0,
        defaultMeals: [dinnerMeals[2], dinnerMeals[4], dinnerMeals[5]],
        selectedMeals: [dinnerMeals[2], dinnerMeals[4], dinnerMeals[5]],
        maxCustomizations: 4,
      ),
      ThaliModel(
        id: 'dt003',
        name: 'Deluxe Dinner Thali',
        type: ThaliType.deluxe,
        basePrice: 220.0,
        defaultMeals: [
          dinnerMeals[1],
          dinnerMeals[3],
          dinnerMeals[4],
          dinnerMeals[5],
        ],
        selectedMeals: [
          dinnerMeals[1],
          dinnerMeals[3],
          dinnerMeals[4],
          dinnerMeals[5],
        ],
        maxCustomizations: 5,
      ),
    ];
  }

  // Mock Plan Templates
  static List<PlanModel> getMockPlanTemplates() {
    // Create meals for veg and non-veg plans
    final vegDefaultMeals = createDefaultMeals(true);
    final nonVegDefaultMeals = createDefaultMeals(false);
    
    return [
      // Vegetarian Plans
      PlanModel(
        id: 'plan001',
        name: 'Vegetarian Basic Plan',
        isVeg: true,
        duration: PlanDuration.sevenDays,
        mealsByDay: vegDefaultMeals,
        basePrice: 2100.0,
        isCustomized: false,
        isDraft: false,
      ),
      PlanModel(
        id: 'plan002',
        name: 'Vegetarian Standard Plan',
        isVeg: true,
        duration: PlanDuration.fourteenDays,
        mealsByDay: vegDefaultMeals,
        basePrice: 3990.0, // Small discount for 14 days
        isCustomized: false,
        isDraft: false,
      ),
      PlanModel(
        id: 'plan003',
        name: 'Vegetarian Premium Plan',
        isVeg: true,
        duration: PlanDuration.twentyEightDays,
        mealsByDay: vegDefaultMeals,
        basePrice: 7700.0, // Larger discount for 28 days
        isCustomized: false,
        isDraft: false,
      ),
      PlanModel(
        id: 'plan004',
        name: 'Non-Veg Basic Plan',
        isVeg: false,
        duration: PlanDuration.sevenDays,
        mealsByDay: nonVegDefaultMeals,
        basePrice: 3150.0,
        isCustomized: false,
        isDraft: false,
      ),
      PlanModel(
        id: 'plan005',
        name: 'Non-Veg Standard Plan',
        isVeg: false,
        duration: PlanDuration.fourteenDays,
        mealsByDay: nonVegDefaultMeals,
        basePrice: 5950.0, // Small discount for 14 days
        isCustomized: false,
        isDraft: false,
      ),
      PlanModel(
        id: 'plan006',
        name: 'Non-Veg Premium Plan',
        isVeg: false,
        duration: PlanDuration.twentyEightDays,
        mealsByDay: nonVegDefaultMeals,
        basePrice: 11550.0, // Larger discount for 28 days
        isCustomized: false,
        isDraft: false,
      ),
    ];
  }

  // Method to get active plan with some customizations
  static PlanModel? getMockActivePlan() {
    if (!_hasActivePlan) return null;
    
    final plan = getMockPlanTemplates()[0];

    // Add some customizations
    final updatedMealsByDay = Map<DayOfWeek, DailyMealsModel>.from(
      plan.mealsByDay,
    );

    // Customize Monday's dinner
    final mondayMeals = updatedMealsByDay[DayOfWeek.monday]!;
    updatedMealsByDay[DayOfWeek.monday] = DailyMealsModel(
      breakfast: mondayMeals.breakfast,
      lunch: mondayMeals.lunch,
      dinner: getMockDinnerThalis()[2], // Deluxe dinner for Monday
    );

    // Set start and end dates
    final now = DateTime.now();
    final startDate = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: 2));
    final endDate = startDate.add(Duration(days: 6)); // For a 7-day plan

    return PlanModel(
      id: plan.id,
      name: plan.name,
      isVeg: plan.isVeg,
      duration: plan.duration,
      startDate: startDate,
      endDate: endDate,
      mealsByDay: updatedMealsByDay,
      basePrice: plan.basePrice,
      isCustomized: true,
      isDraft: false,
    );
  }
  
  // New methods
  
  // Method to reset a plan to default state
  static PlanModel resetPlanToDefaults(PlanModel plan) {
    // Get the default meals based on plan type
    final defaultMeals = createDefaultMeals(plan.isVeg);
    
    // Return plan with reset meals
    return PlanModel(
      id: plan.id,
      name: plan.name,
      isVeg: plan.isVeg,
      duration: plan.duration,
      startDate: plan.startDate,
      endDate: plan.endDate,
      mealsByDay: defaultMeals,
      basePrice: plan.basePrice,
      isCustomized: false,
      isDraft: true,
    );
  }
  
  // Method to get default thali for meal type and preference
  static ThaliModel getDefaultThali(MealType type, bool isVeg) {
    switch (type) {
      case MealType.breakfast:
        return isVeg ? getMockBreakfastThalis()[0] : getMockBreakfastThalis()[1];
      case MealType.lunch:
        return isVeg ? getMockLunchThalis()[0] : getMockLunchThalis()[1];
      case MealType.dinner:
        return isVeg ? getMockDinnerThalis()[0] : getMockDinnerThalis()[1];
      default:
        return getMockLunchThalis()[0]; // Default to normal lunch thali
    }
  }
  
  // Method to get recommended plans based on user
  static List<PlanModel> getRecommendedPlans(UserModel user) {
    final allPlans = getMockPlanTemplates();
    
    // In a real app, we'd use user preferences to filter and sort plans
    // For this mock, simply return plans that match user's diet preference
    if (user.hasActivePlan) {
      // If user has active plan, recommend plans of same type but different duration
      final activePlan = getMockActivePlan();
      if (activePlan != null) {
        return allPlans
          .where((p) => p.isVeg == activePlan.isVeg && p.duration != activePlan.duration)
          .toList();
      }
    }
    
    // Otherwise, just return the first few plans
    return allPlans.take(3).toList();
  }
  
  // Method to create a customized thali
  static ThaliModel customizeThali(ThaliModel thali, List<MealModel> selectedMeals) {
    return ThaliModel(
      id: thali.id,
      name: 'Customized ${thali.name}',
      type: thali.type,
      basePrice: thali.basePrice,
      defaultMeals: thali.defaultMeals,
      selectedMeals: selectedMeals,
      maxCustomizations: thali.maxCustomizations,
    );
  }
  
  // Method to get a thali for a specific meal with a specific type
  static ThaliModel getThaliByType(MealType mealType, ThaliType thaliType) {
    switch (mealType) {
      case MealType.breakfast:
        return getMockBreakfastThalis().firstWhere(
          (thali) => thali.type == thaliType,
          orElse: () => getMockBreakfastThalis()[0],
        );
      case MealType.lunch:
        return getMockLunchThalis().firstWhere(
          (thali) => thali.type == thaliType,
          orElse: () => getMockLunchThalis()[0],
        );
      case MealType.dinner:
        return getMockDinnerThalis().firstWhere(
          (thali) => thali.type == thaliType,
          orElse: () => getMockDinnerThalis()[0],
        );
      default:
        return getMockLunchThalis()[0];
    }
  }
  
  // Method to create a draft plan from a template
  static PlanModel createDraftPlan(PlanModel template) {
    return template.copyWith(
      id: 'draft_${template.id}',
      isDraft: true,
      isCustomized: false,
    );
  }
  
  // Method to update a meal in a plan
  static PlanModel updatePlanMeal(
    PlanModel plan,
    DayOfWeek day,
    MealType mealType,
    ThaliModel thali,
  ) {
    // Create a copy of the current plan's meals
    final updatedMealsByDay = Map<DayOfWeek, DailyMealsModel>.from(plan.mealsByDay);
    
    // Get the current daily meals or create new
    final currentDailyMeals = updatedMealsByDay[day] ?? DailyMealsModel();
    
    // Update based on meal type
    DailyMealsModel? updatedDailyMeals;
    switch (mealType) {
      case MealType.breakfast:
        updatedDailyMeals = currentDailyMeals.copyWith(breakfast: thali) as DailyMealsModel?;
        break;
      case MealType.lunch:
        updatedDailyMeals = currentDailyMeals.copyWith(lunch: thali) as DailyMealsModel?;
        break;
      case MealType.dinner:
        updatedDailyMeals = currentDailyMeals.copyWith(dinner: thali) as DailyMealsModel?;
        break;
    }
    
    // Update the map
    updatedMealsByDay[day] = updatedDailyMeals!;
    
    // Return updated plan
    return plan.copyWith(
      mealsByDay: updatedMealsByDay,
      isCustomized: true,
    );
  }
}