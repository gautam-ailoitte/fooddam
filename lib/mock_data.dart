// lib/mock_data.dart

import 'package:foodam/src/domain/entities/user_entity.dart';
import 'package:foodam/src/domain/entities/address_entity.dart';
import 'package:foodam/src/domain/entities/dish_entity.dart';
import 'package:foodam/src/domain/entities/meal_entity.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';
import 'package:foodam/src/domain/entities/order_entity.dart';
import 'package:foodam/src/domain/entities/payment_entity.dart';

class MockData {
  // Demo users
  static final users = [
    User(
      id: 'usr1',
      firstName: 'John',
      lastName: 'Doe',
      email: 'john.doe@example.com',
      phone: '9876543210',
      address: addresses[0],
      dietaryPreferences: [DietaryPreference.nonVegetarian],
      allergies: ['Peanuts'],
      role: UserRole.user,
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
    ),
    User(
      id: 'usr2',
      firstName: 'Jane',
      lastName: 'Smith',
      email: 'jane.smith@example.com',
      phone: '8765432109',
      address: addresses[1],
      dietaryPreferences: [DietaryPreference.vegetarian],
      allergies: ['Lactose'],
      role: UserRole.user,
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
    ),
  ];

  // Demo addresses
  static final addresses = [
    Address(
      street: '123 Main St',
      city: 'Bangalore',
      state: 'Karnataka',
      zipCode: '560001',
      country: 'India',
      coordinates: const Coordinates(
        latitude: 12.9716,
        longitude: 77.5946,
      ),
    ),
    Address(
      street: '456 Park Ave',
      city: 'Mumbai',
      state: 'Maharashtra',
      zipCode: '400001',
      country: 'India',
      coordinates: const Coordinates(
        latitude: 19.0760,
        longitude: 72.8777,
      ),
    ),
  ];

  // Demo dishes
  static final dishes = [
    // Curry category
    Dish(
      id: 'dish1',
      name: 'Paneer Butter Masala',
      description: 'Cottage cheese cubes in creamy tomato sauce',
      price: 120.0,
      category: FoodCategory.mainCourse,
      dietaryPreferences: [DietaryPreference.vegetarian],
      imageUrl: 'assets/images/dishes/paneer_butter_masala.jpg',
      nutritionalInfo: const NutritionalValue(
        calories: 320,
        protein: 15,
        carbs: 12,
        fat: 22,
      ),
      quantity: const Quantity(value: 200, unit: QuantityUnit.grams),
      ingredients: ['Paneer', 'Tomato', 'Cream', 'Butter', 'Spices'],
    ),
    Dish(
      id: 'dish2',
      name: 'Butter Chicken',
      description: 'Tender chicken in rich buttery tomato sauce',
      price: 150.0,
      category: FoodCategory.mainCourse,
      dietaryPreferences: [DietaryPreference.nonVegetarian],
      imageUrl: 'assets/images/dishes/butter_chicken.jpg',
      nutritionalInfo: const NutritionalValue(
        calories: 380,
        protein: 25,
        carbs: 10,
        fat: 25,
      ),
      quantity: const Quantity(value: 200, unit: QuantityUnit.grams),
      ingredients: ['Chicken', 'Tomato', 'Cream', 'Butter', 'Spices'],
    ),
    Dish(
      id: 'dish3',
      name: 'Dal Makhani',
      description: 'Creamy black lentils cooked overnight',
      price: 100.0,
      category: FoodCategory.mainCourse,
      dietaryPreferences: [DietaryPreference.vegetarian],
      imageUrl: 'assets/images/dishes/dal_makhani.jpg',
      nutritionalInfo: const NutritionalValue(
        calories: 250,
        protein: 12,
        carbs: 30,
        fat: 10,
      ),
      quantity: const Quantity(value: 200, unit: QuantityUnit.grams),
      ingredients: ['Black lentils', 'Kidney beans', 'Cream', 'Butter', 'Spices'],
    ),
    
    // Rice category
    Dish(
      id: 'dish4',
      name: 'Jeera Rice',
      description: 'Basmati rice tempered with cumin',
      price: 80.0,
      category: FoodCategory.sideDish,
      dietaryPreferences: [DietaryPreference.vegetarian, DietaryPreference.vegan],
      imageUrl: 'assets/images/dishes/jeera_rice.jpg',
      nutritionalInfo: const NutritionalValue(
        calories: 180,
        protein: 3,
        carbs: 40,
        fat: 2,
      ),
      quantity: const Quantity(value: 150, unit: QuantityUnit.grams),
      ingredients: ['Basmati rice', 'Cumin', 'Ghee'],
    ),
    Dish(
      id: 'dish5',
      name: 'Veg Pulao',
      description: 'Rice cooked with mixed vegetables and spices',
      price: 100.0,
      category: FoodCategory.sideDish,
      dietaryPreferences: [DietaryPreference.vegetarian],
      imageUrl: 'assets/images/dishes/veg_pulao.jpg',
      nutritionalInfo: const NutritionalValue(
        calories: 220,
        protein: 5,
        carbs: 45,
        fat: 5,
      ),
      quantity: const Quantity(value: 200, unit: QuantityUnit.grams),
      ingredients: ['Basmati rice', 'Mixed vegetables', 'Spices'],
    ),
    
    // Bread category
    Dish(
      id: 'dish6',
      name: 'Tandoori Roti',
      description: 'Whole wheat flatbread baked in tandoor',
      price: 20.0,
      category: FoodCategory.sideDish,
      dietaryPreferences: [DietaryPreference.vegetarian, DietaryPreference.vegan],
      imageUrl: 'assets/images/dishes/tandoori_roti.jpg',
      nutritionalInfo: const NutritionalValue(
        calories: 120,
        protein: 4,
        carbs: 20,
        fat: 1,
      ),
      quantity: const Quantity(value: 1, unit: QuantityUnit.pieces),
      ingredients: ['Whole wheat flour', 'Salt'],
    ),
    Dish(
      id: 'dish7',
      name: 'Butter Naan',
      description: 'Soft leavened flatbread brushed with butter',
      price: 30.0,
      category: FoodCategory.sideDish,
      dietaryPreferences: [DietaryPreference.vegetarian],
      imageUrl: 'assets/images/dishes/butter_naan.jpg',
      nutritionalInfo: const NutritionalValue(
        calories: 180,
        protein: 5,
        carbs: 25,
        fat: 7,
      ),
      quantity: const Quantity(value: 1, unit: QuantityUnit.pieces),
      ingredients: ['All-purpose flour', 'Yogurt', 'Butter'],
    ),
    
    // Dessert category
    Dish(
      id: 'dish8',
      name: 'Gulab Jamun',
      description: 'Deep-fried milk solids soaked in sugar syrup',
      price: 60.0,
      category: FoodCategory.dessert,
      dietaryPreferences: [DietaryPreference.vegetarian],
      imageUrl: 'assets/images/dishes/gulab_jamun.jpg',
      nutritionalInfo: const NutritionalValue(
        calories: 220,
        protein: 3,
        carbs: 40,
        fat: 8,
      ),
      quantity: const Quantity(value: 2, unit: QuantityUnit.pieces),
      ingredients: ['Milk powder', 'Flour', 'Sugar', 'Cardamom'],
    ),
    Dish(
      id: 'dish9',
      name: 'Rasgulla',
      description: 'Cottage cheese balls in sugar syrup',
      price: 50.0,
      category: FoodCategory.dessert,
      dietaryPreferences: [DietaryPreference.vegetarian],
      imageUrl: 'assets/images/dishes/rasgulla.jpg',
      nutritionalInfo: const NutritionalValue(
        calories: 180,
        protein: 4,
        carbs: 35,
        fat: 3,
      ),
      quantity: const Quantity(value: 2, unit: QuantityUnit.pieces),
      ingredients: ['Cottage cheese', 'Sugar', 'Rose water'],
    ),
  ];

  // Demo meal categories
  static final mealCategories = [
    // Categories for a basic Indian thali
    MealCategory(
      name: 'Main Curry',
      description: 'Select a main curry for your meal',
      options: [
        MealOption(dishId: 'dish1'),
        MealOption(dishId: 'dish2'),
        MealOption(dishId: 'dish3'),
      ],
      minSelections: 1,
      maxSelections: 1,
      isRequired: true,
    ),
    MealCategory(
      name: 'Rice/Grain',
      description: 'Select a rice dish',
      options: [
        MealOption(dishId: 'dish4'),
        MealOption(dishId: 'dish5'),
      ],
      minSelections: 0,
      maxSelections: 1,
    ),
    MealCategory(
      name: 'Bread',
      description: 'Select bread items',
      options: [
        MealOption(dishId: 'dish6'),
        MealOption(dishId: 'dish7'),
      ],
      minSelections: 0,
      maxSelections: 2,
    ),
    MealCategory(
      name: 'Dessert',
      description: 'Select a dessert to end your meal',
      options: [
        MealOption(dishId: 'dish8'),
        MealOption(dishId: 'dish9'),
      ],
      minSelections: 0,
      maxSelections: 1,
    ),
  ];

  // Demo meals
  static final meals = [
    Meal(
      id: 'meal1',
      name: 'Vegetarian Thali',
      description: 'A complete vegetarian meal with curry, rice, bread, and dessert',
      price: 250.0,
      categories: [
        mealCategories[0], // Main Curry (vegetarian options)
        mealCategories[1], // Rice/Grain
        mealCategories[2], // Bread
        mealCategories[3], // Dessert
      ],
      dietaryPreferences: [DietaryPreference.vegetarian],
      imageUrl: 'assets/images/meals/veg_thali.jpg',
    ),
    Meal(
      id: 'meal2',
      name: 'Non-Vegetarian Thali',
      description: 'A complete non-vegetarian meal with curry, rice, bread, and dessert',
      price: 300.0,
      categories: [
        mealCategories[0], // Main Curry (non-veg options)
        mealCategories[1], // Rice/Grain
        mealCategories[2], // Bread
        mealCategories[3], // Dessert
      ],
      dietaryPreferences: [DietaryPreference.nonVegetarian],
      imageUrl: 'assets/images/meals/non_veg_thali.jpg',
    ),
  ];

  // Demo meal preferences
  static final mealPreferences = [
    MealPreference(
      mealType: 'breakfast',
      preferences: [DietaryPreference.vegetarian],
      quantity: 1,
    ),
    MealPreference(
      mealType: 'lunch',
      preferences: [DietaryPreference.nonVegetarian],
      quantity: 1,
    ),
    MealPreference(
      mealType: 'dinner',
      preferences: [DietaryPreference.vegetarian],
      quantity: 1,
    ),
  ];

  // Demo delivery schedule
  static final deliverySchedule = DeliverySchedule(
    daysOfWeek: [1, 2, 3, 4, 5], // Monday to Friday
    preferredTimeSlot: 'morning',
  );

  // Demo subscriptions
  static final subscriptions = [
    Subscription(
      id: 'sub1',
      userId: 'usr1',
      duration: SubscriptionDuration.sevenDays,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 7)),
      status: SubscriptionStatus.active,
      basePrice: 1750.0, // 250 * 7 days
      totalPrice: 1750.0,
      isCustomized: false,
      mealPreferences: mealPreferences,
      deliverySchedule: deliverySchedule,
      deliveryAddress: addresses[0],
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Subscription(
      id: 'sub2',
      userId: 'usr2',
      duration: SubscriptionDuration.fourteenDays,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 14)),
      status: SubscriptionStatus.active,
      basePrice: 3500.0, // 250 * 14 days
      totalPrice: 3500.0,
      isCustomized: false,
      mealPreferences: mealPreferences,
      deliverySchedule: deliverySchedule,
      deliveryAddress: addresses[1],
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  // Demo orders
  static final orders = [
    Order(
      id: 'ord1',
      orderNumber: 'ORD-2023-001',
      userId: 'usr1',
      subscriptionId: 'sub1',
      deliveryDate: DateTime.now().add(const Duration(days: 1)),
      deliveryAddress: addresses[0],
      status: OrderStatus.confirmed,
      paymentStatus: PaymentStatus.paid,
      totalAmount: 250.0,
      meals: [
        const OrderedMeal(
          mealType: 'breakfast',
          dietPreference: 'vegetarian',
          quantity: 1,
        ),
        const OrderedMeal(
          mealType: 'lunch',
          dietPreference: 'vegetarian',
          quantity: 1,
        ),
        const OrderedMeal(
          mealType: 'dinner',
          dietPreference: 'vegetarian',
          quantity: 1,
        ),
      ],
      deliveryInstructions: 'Leave at front door',
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
  ];

  // Demo payments
  static final payments = [
    Payment(
      id: 'pay1',
      orderId: 'ord1',
      userId: 'usr1',
      amount: 250.0,
      currency: 'INR',
      paymentMethod: PaymentMethod.creditCard,
      status: PaymentStatus.paid,
      transactionId: 'txn-1234567890',
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
  ];
  
  // Demo coupons
  static final coupons = [
    Coupon(
      id: 'cpn1',
      code: 'WELCOME20',
      discountType: 'percentage',
      discountValue: 20.0,
      minOrderAmount: 500.0,
      maxDiscountAmount: 200.0,
      validFrom: DateTime.now().subtract(const Duration(days: 30)),
      validUntil: DateTime.now().add(const Duration(days: 30)),
      usageLimit: 1,
      usageCount: 0,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
  ];
}