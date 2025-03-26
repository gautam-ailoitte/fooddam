// lib/mock_data.dart
import 'dart:math';

/// Enhanced Mock Data for development and testing
/// 
/// This class provides a rich set of mock data for testing all app features
/// including edge cases and various data combinations.
class MockData {
  // Random generator for creating variability
  static final Random _random = Random();

  // Mock Token
  static const String mockToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJ1c3JfMDAxIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c';

  // =========================================================================
  // USER DATA
  // =========================================================================
  
  // Current User - The logged in user
  static final Map<String, dynamic> currentUser = {
    'id': 'usr_001',
    'email': 'john.doe@example.com',
    'firstName': 'John',
    'lastName': 'Doe',
    'phone': '9876543210',
    'role': 'customer',
    'dietaryPreferences': ['vegetarian', 'gluten-free'],
    'allergies': ['peanuts', 'shellfish']
  };
  
  // All Users - For admin features if needed
  static final List<Map<String, dynamic>> users = [
    currentUser,
    {
      'id': 'usr_002',
      'email': 'jane.smith@example.com',
      'firstName': 'Jane',
      'lastName': 'Smith',
      'phone': '9876543211',
      'role': 'customer',
      'dietaryPreferences': ['non-vegetarian'],
      'allergies': ['dairy']
    },
    {
      'id': 'usr_003',
      'email': 'raj.patel@example.com',
      'firstName': 'Raj',
      'lastName': 'Patel',
      'phone': '9876543212',
      'role': 'customer',
      'dietaryPreferences': ['vegetarian', 'jain'],
      'allergies': []
    },
    {
      'id': 'usr_004',
      'email': 'sarah.jones@example.com',
      'firstName': 'Sarah',
      'lastName': 'Jones',
      'phone': '9876543213',
      'role': 'customer',
      'dietaryPreferences': ['keto', 'paleo'],
      'allergies': ['gluten', 'soy']
    }
  ];

  // =========================================================================
  // ADDRESS DATA
  // =========================================================================
  
  // User Addresses - Multiple addresses for testing address selection
  static final List<Map<String, dynamic>> addresses = [
    {
      'id': 'addr_001',
      'street': '123 Main Street, Apartment 4B',
      'city': 'Bangalore',
      'state': 'Karnataka',
      'zipCode': '560001',
      'coordinates': {
        'latitude': 12.9716,
        'longitude': 77.5946
      }
    },
    {
      'id': 'addr_002',
      'street': '456 Park Avenue, Building C',
      'city': 'Mumbai',
      'state': 'Maharashtra',
      'zipCode': '400001',
      'coordinates': {
        'latitude': 19.0760,
        'longitude': 72.8777
      }
    },
    {
      'id': 'addr_003',
      'street': '789 Lake View Road',
      'city': 'Delhi',
      'state': 'Delhi',
      'zipCode': '110001',
      'coordinates': {
        'latitude': 28.6139,
        'longitude': 77.2090
      }
    },
    {
      'id': 'addr_004',
      'street': '42 Office Tower, Tech Park',
      'city': 'Bangalore',
      'state': 'Karnataka',
      'zipCode': '560037',
      'coordinates': {
        'latitude': 12.9782,
        'longitude': 77.6408
      }
    }
  ];

  // =========================================================================
  // DISH DATA
  // =========================================================================
  
  // Dishes - Individual components of meals
  static final List<Map<String, dynamic>> dishes = [
    // Breakfast Dishes
    {
      'id': 'dish_001',
      'name': 'Idli Sambar',
      'description': 'Soft steamed rice cakes served with lentil vegetable stew',
      'price': 80.0,
      'category': 'breakfast',
      'imageUrl': 'https://example.com/images/idli-sambar.jpg',
      'nutritionalInfo': {
        'calories': 180,
        'protein': 6,
        'carbs': 30,
        'fat': 2
      },
      'dietaryPreferences': ['vegetarian', 'gluten-free']
    },
    {
      'id': 'dish_002',
      'name': 'Masala Dosa',
      'description': 'Crispy rice crepe filled with spiced potato filling',
      'price': 90.0,
      'category': 'breakfast',
      'imageUrl': 'https://example.com/images/masala-dosa.jpg',
      'nutritionalInfo': {
        'calories': 250,
        'protein': 5,
        'carbs': 35,
        'fat': 10
      },
      'dietaryPreferences': ['vegetarian', 'gluten-free']
    },
    {
      'id': 'dish_003',
      'name': 'Poha',
      'description': 'Flattened rice cooked with onions, spices, and herbs',
      'price': 60.0,
      'category': 'breakfast',
      'imageUrl': 'https://example.com/images/poha.jpg',
      'nutritionalInfo': {
        'calories': 150,
        'protein': 4,
        'carbs': 30,
        'fat': 3
      },
      'dietaryPreferences': ['vegetarian', 'gluten-free']
    },
    {
      'id': 'dish_004',
      'name': 'Egg Bhurji',
      'description': 'Spiced scrambled eggs with onions and tomatoes',
      'price': 70.0,
      'category': 'breakfast',
      'imageUrl': 'https://example.com/images/egg-bhurji.jpg',
      'nutritionalInfo': {
        'calories': 180,
        'protein': 12,
        'carbs': 5,
        'fat': 14
      },
      'dietaryPreferences': ['non-vegetarian']
    },
    
    // Lunch Dishes
    {
      'id': 'dish_005',
      'name': 'Paneer Butter Masala',
      'description': 'Cottage cheese cubes in rich tomato gravy',
      'price': 140.0,
      'category': 'main_course',
      'imageUrl': 'https://example.com/images/paneer-butter-masala.jpg',
      'nutritionalInfo': {
        'calories': 320,
        'protein': 15,
        'carbs': 12,
        'fat': 25
      },
      'dietaryPreferences': ['vegetarian']
    },
    {
      'id': 'dish_006',
      'name': 'Dal Tadka',
      'description': 'Yellow lentils tempered with spices',
      'price': 100.0,
      'category': 'main_course',
      'imageUrl': 'https://example.com/images/dal-tadka.jpg',
      'nutritionalInfo': {
        'calories': 210,
        'protein': 12,
        'carbs': 30,
        'fat': 6
      },
      'dietaryPreferences': ['vegetarian', 'gluten-free']
    },
    {
      'id': 'dish_007',
      'name': 'Jeera Rice',
      'description': 'Rice cooked with cumin seeds',
      'price': 80.0,
      'category': 'rice',
      'imageUrl': 'https://example.com/images/jeera-rice.jpg',
      'nutritionalInfo': {
        'calories': 180,
        'protein': 4,
        'carbs': 40,
        'fat': 2
      },
      'dietaryPreferences': ['vegetarian', 'gluten-free']
    },
    {
      'id': 'dish_008',
      'name': 'Butter Chicken',
      'description': 'Chicken in creamy tomato gravy',
      'price': 160.0,
      'category': 'main_course',
      'imageUrl': 'https://example.com/images/butter-chicken.jpg',
      'nutritionalInfo': {
        'calories': 350,
        'protein': 25,
        'carbs': 10,
        'fat': 22
      },
      'dietaryPreferences': ['non-vegetarian']
    },
    
    // Dinner Dishes
    {
      'id': 'dish_009',
      'name': 'Roti',
      'description': 'Whole wheat flatbread',
      'price': 25.0,
      'category': 'bread',
      'imageUrl': 'https://example.com/images/roti.jpg',
      'nutritionalInfo': {
        'calories': 120,
        'protein': 4,
        'carbs': 25,
        'fat': 1
      },
      'dietaryPreferences': ['vegetarian']
    },
    {
      'id': 'dish_010',
      'name': 'Mixed Vegetable Curry',
      'description': 'Seasonal vegetables in spiced gravy',
      'price': 110.0,
      'category': 'main_course',
      'imageUrl': 'https://example.com/images/mixed-veg.jpg',
      'nutritionalInfo': {
        'calories': 180,
        'protein': 6,
        'carbs': 20,
        'fat': 9
      },
      'dietaryPreferences': ['vegetarian', 'gluten-free']
    },
    {
      'id': 'dish_011',
      'name': 'Chicken Biryani',
      'description': 'Fragrant rice cooked with chicken and spices',
      'price': 190.0,
      'category': 'rice',
      'imageUrl': 'https://example.com/images/chicken-biryani.jpg',
      'nutritionalInfo': {
        'calories': 450,
        'protein': 30,
        'carbs': 50,
        'fat': 16
      },
      'dietaryPreferences': ['non-vegetarian']
    },
    {
      'id': 'dish_012',
      'name': 'Gulab Jamun',
      'description': 'Sweet milk dumplings soaked in sugar syrup',
      'price': 60.0,
      'category': 'dessert',
      'imageUrl': 'https://example.com/images/gulab-jamun.jpg',
      'nutritionalInfo': {
        'calories': 180,
        'protein': 2,
        'carbs': 30,
        'fat': 6
      },
      'dietaryPreferences': ['vegetarian']
    },
    
    // Sides & Accompaniments
    {
      'id': 'dish_013',
      'name': 'Green Salad',
      'description': 'Fresh mixed vegetables with a lemon dressing',
      'price': 50.0,
      'category': 'side',
      'imageUrl': 'https://example.com/images/green-salad.jpg',
      'nutritionalInfo': {
        'calories': 60,
        'protein': 2,
        'carbs': 12,
        'fat': 1
      },
      'dietaryPreferences': ['vegetarian', 'vegan', 'gluten-free']
    },
    {
      'id': 'dish_014',
      'name': 'Raita',
      'description': 'Yogurt mixed with cucumber and spices',
      'price': 40.0,
      'category': 'side',
      'imageUrl': 'https://example.com/images/raita.jpg',
      'nutritionalInfo': {
        'calories': 80,
        'protein': 4,
        'carbs': 8,
        'fat': 3
      },
      'dietaryPreferences': ['vegetarian', 'gluten-free']
    },
    {
      'id': 'dish_015',
      'name': 'Papad',
      'description': 'Crispy lentil wafer',
      'price': 20.0,
      'category': 'side',
      'imageUrl': 'https://example.com/images/papad.jpg',
      'nutritionalInfo': {
        'calories': 40,
        'protein': 1,
        'carbs': 6,
        'fat': 2
      },
      'dietaryPreferences': ['vegetarian', 'gluten-free']
    }
  ];

  // =========================================================================
  // MEAL DATA
  // =========================================================================
  
  // Meals - Complete meal offerings composed of dishes
  static final List<Map<String, dynamic>> meals = [
    // Breakfast Meals
    {
      'id': 'meal_001',
      'name': 'South Indian Breakfast',
      'description': 'A traditional South Indian breakfast with idli, vada, and sambar.',
      'price': 120.0,
      'dishes': [
        dishes.firstWhere((dish) => dish['id'] == 'dish_001'),
        dishes.firstWhere((dish) => dish['id'] == 'dish_013')
      ],
      'imageUrl': 'https://example.com/images/south-indian-breakfast.jpg',
      'isAvailable': true,
      'dietaryPreferences': ['vegetarian', 'gluten-free']
    },
    {
      'id': 'meal_002',
      'name': 'North Indian Breakfast',
      'description': 'A hearty North Indian breakfast with poha and chai.',
      'price': 110.0,
      'dishes': [
        dishes.firstWhere((dish) => dish['id'] == 'dish_003'),
        dishes.firstWhere((dish) => dish['id'] == 'dish_014')
      ],
      'imageUrl': 'https://example.com/images/north-indian-breakfast.jpg',
      'isAvailable': true,
      'dietaryPreferences': ['vegetarian']
    },
    {
      'id': 'meal_003',
      'name': 'Protein Breakfast',
      'description': 'High-protein breakfast with eggs and vegetables.',
      'price': 130.0,
      'dishes': [
        dishes.firstWhere((dish) => dish['id'] == 'dish_004'),
        dishes.firstWhere((dish) => dish['id'] == 'dish_013')
      ],
      'imageUrl': 'https://example.com/images/protein-breakfast.jpg',
      'isAvailable': true,
      'dietaryPreferences': ['non-vegetarian']
    },
    
    // Lunch Meals
    {
      'id': 'meal_004',
      'name': 'Veg Lunch Thali',
      'description': 'Complete vegetarian lunch with dal, paneer, rice, and roti.',
      'price': 180.0,
      'dishes': [
        dishes.firstWhere((dish) => dish['id'] == 'dish_005'),
        dishes.firstWhere((dish) => dish['id'] == 'dish_006'),
        dishes.firstWhere((dish) => dish['id'] == 'dish_007'),
        dishes.firstWhere((dish) => dish['id'] == 'dish_009'),
        dishes.firstWhere((dish) => dish['id'] == 'dish_014')
      ],
      'imageUrl': 'https://example.com/images/veg-lunch-thali.jpg',
      'isAvailable': true,
      'dietaryPreferences': ['vegetarian']
    },
    {
      'id': 'meal_005',
      'name': 'Non-Veg Lunch Thali',
      'description': 'Complete non-vegetarian lunch with butter chicken, rice, and roti.',
      'price': 220.0,
      'dishes': [
        dishes.firstWhere((dish) => dish['id'] == 'dish_008'),
        dishes.firstWhere((dish) => dish['id'] == 'dish_007'),
        dishes.firstWhere((dish) => dish['id'] == 'dish_009'),
        dishes.firstWhere((dish) => dish['id'] == 'dish_014')
      ],
      'imageUrl': 'https://example.com/images/non-veg-lunch-thali.jpg',
      'isAvailable': true,
      'dietaryPreferences': ['non-vegetarian']
    },
    {
      'id': 'meal_006',
      'name': 'Healthy Lunch Bowl',
      'description': 'Balanced lunch bowl with mixed vegetables, dal, and rice.',
      'price': 160.0,
      'dishes': [
        dishes.firstWhere((dish) => dish['id'] == 'dish_006'),
        dishes.firstWhere((dish) => dish['id'] == 'dish_010'),
        dishes.firstWhere((dish) => dish['id'] == 'dish_007'),
        dishes.firstWhere((dish) => dish['id'] == 'dish_013')
      ],
      'imageUrl': 'https://example.com/images/healthy-lunch-bowl.jpg',
      'isAvailable': true,
      'dietaryPreferences': ['vegetarian', 'gluten-free']
    },
    
    // Dinner Meals
    {
      'id': 'meal_007',
      'name': 'Light Veg Dinner',
      'description': 'A light vegetarian dinner with mixed vegetables and roti.',
      'price': 150.0,
      'dishes': [
        dishes.firstWhere((dish) => dish['id'] == 'dish_010'),
        dishes.firstWhere((dish) => dish['id'] == 'dish_009'),
        dishes.firstWhere((dish) => dish['id'] == 'dish_014')
      ],
      'imageUrl': 'https://example.com/images/light-veg-dinner.jpg',
      'isAvailable': true,
      'dietaryPreferences': ['vegetarian']
    },
    {
      'id': 'meal_008',
      'name': 'Biryani Dinner',
      'description': 'Flavorful chicken biryani dinner with raita and papad.',
      'price': 230.0,
      'dishes': [
        dishes.firstWhere((dish) => dish['id'] == 'dish_011'),
        dishes.firstWhere((dish) => dish['id'] == 'dish_014'),
        dishes.firstWhere((dish) => dish['id'] == 'dish_015'),
        dishes.firstWhere((dish) => dish['id'] == 'dish_012')
      ],
      'imageUrl': 'https://example.com/images/biryani-dinner.jpg',
      'isAvailable': true,
      'dietaryPreferences': ['non-vegetarian']
    },
    {
      'id': 'meal_009',
      'name': 'Home Style Dinner',
      'description': 'Simple homestyle dinner with dal, vegetables, roti, and rice.',
      'price': 170.0,
      'dishes': [
        dishes.firstWhere((dish) => dish['id'] == 'dish_006'),
        dishes.firstWhere((dish) => dish['id'] == 'dish_010'),
        dishes.firstWhere((dish) => dish['id'] == 'dish_007'),
        dishes.firstWhere((dish) => dish['id'] == 'dish_009')
      ],
      'imageUrl': 'https://example.com/images/home-style-dinner.jpg',
      'isAvailable': true,
      'dietaryPreferences': ['vegetarian']
    },
    
    // Special Meals
    {
      'id': 'meal_010',
      'name': 'Jain Special Thali',
      'description': 'Special Jain meal without onions, garlic, and root vegetables.',
      'price': 190.0,
      'dishes': [
        {
          'id': 'dish_special_001',
          'name': 'Jain Dal',
          'description': 'Lentils prepared without onion and garlic',
          'price': 110.0,
          'category': 'main_course',
          'imageUrl': 'https://example.com/images/jain-dal.jpg',
          'dietaryPreferences': ['vegetarian', 'jain', 'gluten-free']
        },
        {
          'id': 'dish_special_002',
          'name': 'Jain Mixed Vegetables',
          'description': 'Vegetables prepared in Jain style',
          'price': 120.0,
          'category': 'main_course',
          'imageUrl': 'https://example.com/images/jain-veg.jpg',
          'dietaryPreferences': ['vegetarian', 'jain', 'gluten-free']
        },
        dishes.firstWhere((dish) => dish['id'] == 'dish_009')
      ],
      'imageUrl': 'https://example.com/images/jain-special-thali.jpg',
      'isAvailable': true,
      'dietaryPreferences': ['vegetarian', 'jain']
    },
    {
      'id': 'meal_011',
      'name': 'Keto Meal Box',
      'description': 'Low-carb, high-fat meal suitable for keto diet.',
      'price': 240.0,
      'dishes': [
        {
          'id': 'dish_special_003',
          'name': 'Keto Paneer Tikka',
          'description': 'Paneer cubes marinated and grilled',
          'price': 150.0,
          'category': 'main_course',
          'imageUrl': 'https://example.com/images/keto-paneer-tikka.jpg',
          'dietaryPreferences': ['vegetarian', 'keto', 'gluten-free']
        },
        {
          'id': 'dish_special_004',
          'name': 'Avocado Salad',
          'description': 'Fresh salad with avocado and olive oil dressing',
          'price': 90.0,
          'category': 'side',
          'imageUrl': 'https://example.com/images/avocado-salad.jpg',
          'dietaryPreferences': ['vegetarian', 'vegan', 'keto', 'gluten-free']
        }
      ],
      'imageUrl': 'https://example.com/images/keto-meal-box.jpg',
      'isAvailable': true,
      'dietaryPreferences': ['vegetarian', 'keto', 'gluten-free']
    },
    {
      'id': 'meal_012',
      'name': 'Weekend Special Feast',
      'description': 'A grand weekend feast with multiple delicacies.',
      'price': 350.0,
      'dishes': [
        dishes.firstWhere((dish) => dish['id'] == 'dish_005'),
        dishes.firstWhere((dish) => dish['id'] == 'dish_008'),
        dishes.firstWhere((dish) => dish['id'] == 'dish_007'),
        dishes.firstWhere((dish) => dish['id'] == 'dish_009'),
        dishes.firstWhere((dish) => dish['id'] == 'dish_014'),
        dishes.firstWhere((dish) => dish['id'] == 'dish_015'),
        dishes.firstWhere((dish) => dish['id'] == 'dish_012')
      ],
      'imageUrl': 'https://example.com/images/weekend-special-feast.jpg',
      'isAvailable': false,  // Not available currently
      'dietaryPreferences': ['non-vegetarian']
    }
  ];

  // =========================================================================
  // PACKAGE DATA
  // =========================================================================
  
  // Packages - Subscription packages offered to users
  static final List<Map<String, dynamic>> packages = [
    // Regular packages
    {
      'id': 'pkg_001',
      'name': 'Weekly Vegetarian Basic',
      'description': 'A simple vegetarian meal plan covering breakfast, lunch, and dinner.',
      'price': 1499.0,
      'slots': _createWeeklyPlanSlots(['vegetarian']),
      'imageUrl': 'https://example.com/images/veg-basic-plan.jpg',
      'type': 'vegetarian',
      'breakdown': [
        {'day': 'Weekday', 'timing': 'Breakfast', 'price': 60.0},
        {'day': 'Weekday', 'timing': 'Lunch', 'price': 120.0},
        {'day': 'Weekday', 'timing': 'Dinner', 'price': 100.0},
        {'day': 'Weekend', 'timing': 'Breakfast', 'price': 80.0},
        {'day': 'Weekend', 'timing': 'Lunch', 'price': 150.0},
        {'day': 'Weekend', 'timing': 'Dinner', 'price': 120.0}
      ]
    },
    {
      'id': 'pkg_002',
      'name': 'Weekly Non-Vegetarian Premium',
      'description': 'A protein-rich meal plan with non-vegetarian options.',
      'price': 1899.0,
      'slots': _createWeeklyPlanSlots(['non-vegetarian']),
      'imageUrl': 'https://example.com/images/non-veg-premium-plan.jpg',
      'type': 'non-vegetarian',
      'breakdown': [
        {'day': 'Weekday', 'timing': 'Breakfast', 'price': 80.0},
        {'day': 'Weekday', 'timing': 'Lunch', 'price': 150.0},
        {'day': 'Weekday', 'timing': 'Dinner', 'price': 130.0},
        {'day': 'Weekend', 'timing': 'Breakfast', 'price': 100.0},
        {'day': 'Weekend', 'timing': 'Lunch', 'price': 180.0},
        {'day': 'Weekend', 'timing': 'Dinner', 'price': 150.0}
      ]
    },
    {
      'id': 'pkg_003',
      'name': 'Deluxe Gourmet Plan',
      'description': 'A gourmet meal plan with premium ingredients and chef specials.',
      'price': 2499.0,
      'slots': _createWeeklyPlanSlots(['vegetarian', 'non-vegetarian']),
      'imageUrl': 'https://example.com/images/deluxe-gourmet-plan.jpg',
      'type': 'mixed',
      'breakdown': [
        {'day': 'Weekday', 'timing': 'Breakfast', 'price': 120.0},
        {'day': 'Weekday', 'timing': 'Lunch', 'price': 200.0},
        {'day': 'Weekday', 'timing': 'Dinner', 'price': 180.0},
        {'day': 'Weekend', 'timing': 'Breakfast', 'price': 150.0},
        {'day': 'Weekend', 'timing': 'Lunch', 'price': 250.0},
        {'day': 'Weekend', 'timing': 'Dinner', 'price': 220.0}
      ]
    },
    
    // Special diet packages
    {
      'id': 'pkg_004',
      'name': 'Healthy Lite Plan',
      'description': 'A calorie-conscious meal plan for fitness enthusiasts.',
      'price': 1799.0,
      'slots': _createWeeklyPlanSlotsForDietType('keto'),
      'imageUrl': 'https://example.com/images/healthy-lite-plan.jpg',
      'type': 'diet',
      'breakdown': [
        {'day': 'Weekday', 'timing': 'Breakfast', 'price': 90.0},
        {'day': 'Weekday', 'timing': 'Lunch', 'price': 140.0},
        {'day': 'Weekday', 'timing': 'Dinner', 'price': 110.0},
        {'day': 'Weekend', 'timing': 'Breakfast', 'price': 110.0},
        {'day': 'Weekend', 'timing': 'Lunch', 'price': 160.0},
        {'day': 'Weekend', 'timing': 'Dinner', 'price': 130.0}
      ]
    },
    {
      'id': 'pkg_005',
      'name': 'Jain Special Plan',
      'description': 'A meal plan catering to Jain dietary preferences.',
      'price': 1699.0,
      'slots': _createWeeklyPlanSlotsForDietType('jain'),
      'imageUrl': 'https://example.com/images/jain-special-plan.jpg',
      'type': 'jain',
      'breakdown': [
        {'day': 'Weekday', 'timing': 'Breakfast', 'price': 80.0},
        {'day': 'Weekday', 'timing': 'Lunch', 'price': 130.0},
        {'day': 'Weekday', 'timing': 'Dinner', 'price': 120.0},
        {'day': 'Weekend', 'timing': 'Breakfast', 'price': 90.0},
        {'day': 'Weekend', 'timing': 'Lunch', 'price': 150.0},
        {'day': 'Weekend', 'timing': 'Dinner', 'price': 140.0}
      ]
    },
    
    // Specific mealtime packages
    {
      'id': 'pkg_006',
      'name': 'Lunch Only Plan',
      'description': 'A plan focused on providing delicious lunches every day.',
      'price': 999.0,
      'slots': _createLunchOnlyPlanSlots(),
      'imageUrl': 'https://example.com/images/lunch-only-plan.jpg',
      'type': 'limited',
      'breakdown': [
        {'day': 'Weekday', 'timing': 'Lunch', 'price': 140.0},
        {'day': 'Weekend', 'timing': 'Lunch', 'price': 170.0}
      ]
    },
    {
      'id': 'pkg_007',
      'name': 'Weekend Special Plan',
      'description': 'Enjoy special meals during weekends only.',
      'price': 799.0,
      'slots': _createWeekendOnlyPlanSlots(),
      'imageUrl': 'https://example.com/images/weekend-special-plan.jpg',
      'type': 'limited',
      'breakdown': [
        {'day': 'Weekend', 'timing': 'Breakfast', 'price': 110.0},
        {'day': 'Weekend', 'timing': 'Lunch', 'price': 180.0},
        {'day': 'Weekend', 'timing': 'Dinner', 'price': 160.0}
      ]
    }
  ];

  // =========================================================================
  // SUBSCRIPTIONS DATA
  // =========================================================================
  
  // Active Subscriptions - User's active meal subscriptions
  static final List<Map<String, dynamic>> activeSubscriptions = [
    // Active subscription
    {
      'id': 'sub_001',
      'startDate': DateTime.now().subtract(Duration(days: 3)).toIso8601String(),
      'endDate': DateTime.now().add(Duration(days: 25)).toIso8601String(),
      'durationDays': 28,
      'package': 'pkg_001',
      'slots': _createBasicLunchPlan('meal_004'),
      'address': addresses[0],
      'instructions': 'Please ring the doorbell twice.',
      'paymentDetails': {
        'paymentStatus': 'paid',
        'transactionId': 'txn_001',
        'paymentMethod': 'credit_card',
        'paymentDate': DateTime.now().subtract(Duration(days: 3)).toIso8601String()
      },
      'pauseDetails': {
        'isPaused': false
      },
      'subscriptionStatus': 'active',
      'cloudKitchen': 'kitchen_001'
    },
    
    // Paused subscription
    {
      'id': 'sub_002',
      'startDate': DateTime.now().subtract(Duration(days: 10)).toIso8601String(),
      'endDate': DateTime.now().add(Duration(days: 18)).toIso8601String(),
      'durationDays': 28,
      'package': 'pkg_002',
      'slots': _createBasicDinnerPlan('meal_008'),
      'address': addresses[1],
      'instructions': 'Leave with security if not at home.',
      'paymentDetails': {
        'paymentStatus': 'paid',
        'transactionId': 'txn_002',
        'paymentMethod': 'upi',
        'paymentDate': DateTime.now().subtract(Duration(days: 10)).toIso8601String()
      },
      'pauseDetails': {
        'isPaused': true,
        'pausedOn': DateTime.now().subtract(Duration(days: 2)).toIso8601String(),
        'pausedUntil': DateTime.now().add(Duration(days: 5)).toIso8601String(),
        'reason': 'Travel'
      },
      'subscriptionStatus': 'paused',
      'cloudKitchen': 'kitchen_002'
    },
    
    // About to expire subscription
    {
      'id': 'sub_003',
      'startDate': DateTime.now().subtract(Duration(days: 25)).toIso8601String(),
      'endDate': DateTime.now().add(Duration(days: 3)).toIso8601String(),
      'durationDays': 28,
      'package': 'pkg_004',
      'slots': _createWeekdayBreakfastPlan('meal_001'),
      'address': addresses[0],
      'instructions': null,
      'paymentDetails': {
        'paymentStatus': 'paid',
        'transactionId': 'txn_003',
        'paymentMethod': 'net_banking',
        'paymentDate': DateTime.now().subtract(Duration(days: 25)).toIso8601String()
      },
      'pauseDetails': {
        'isPaused': false
      },
      'subscriptionStatus': 'active',
      'cloudKitchen': 'kitchen_001'
    },
    
    // Pending payment subscription
    {
      'id': 'sub_004',
      'startDate': DateTime.now().add(Duration(days: 1)).toIso8601String(),
      'endDate': DateTime.now().add(Duration(days: 29)).toIso8601String(),
      'durationDays': 28,
      'package': 'pkg_003',
      'slots': _createFullWeekPlan(),
      'address': addresses[2],
      'instructions': 'Call before delivery.',
      'paymentDetails': {
        'paymentStatus': 'pending',
        'transactionId': null,
        'paymentMethod': null,
        'paymentDate': null
      },
      'pauseDetails': {
        'isPaused': false
      },
      'subscriptionStatus': 'pending',
      'cloudKitchen': null
    }
  ];

  // =========================================================================
  // PAYMENT DATA
  // =========================================================================
  
  // Payment History - Records of payments made by user
  static final List<Map<String, dynamic>> paymentHistory = [
    {
      'id': 'payment_001',
      'subscriptionId': 'sub_001',
      'amount': 1499.0,
      'method': 'credit_card',
      'status': 'paid',
      'timestamp': DateTime.now().subtract(Duration(days: 3)).toIso8601String(),
      'transactionId': 'txn_001',
      'cardDetails': {
        'cardNumber': '**** **** **** 1234',
        'cardType': 'Visa'
      }
    },
    {
      'id': 'payment_002',
      'subscriptionId': 'sub_002',
      'amount': 1899.0,
      'method': 'upi',
      'status': 'paid',
      'timestamp': DateTime.now().subtract(Duration(days: 10)).toIso8601String(),
      'transactionId': 'txn_002',
      'upiDetails': {
        'upiId': 'user@okbank'
      }
    },
    {
      'id': 'payment_003',
      'subscriptionId': 'sub_003',
      'amount': 1799.0,
      'method': 'net_banking',
      'status': 'paid',
      'timestamp': DateTime.now().subtract(Duration(days: 25)).toIso8601String(),
      'transactionId': 'txn_003',
      'bankDetails': {
        'bankName': 'HDFC Bank'
      }
    },
    {
      'id': 'payment_004',
      'subscriptionId': 'sub_cancelled_001',
      'amount': 999.0,
      'method': 'credit_card',
      'status': 'refunded',
      'timestamp': DateTime.now().subtract(Duration(days: 45)).toIso8601String(),
      'refundTimestamp': DateTime.now().subtract(Duration(days: 40)).toIso8601String(),
      'transactionId': 'txn_004',
      'refundTransactionId': 'refund_001',
      'cardDetails': {
        'cardNumber': '**** **** **** 1234',
        'cardType': 'Visa'
      }
    }
  ];

  // =========================================================================
  // TODAY'S MEAL ORDERS
  // =========================================================================
  
  // Today's Meal Orders - Orders for today based on active subscriptions
  static List<Map<String, dynamic>> getTodayMealOrders() {
    final now = DateTime.now();
    final todayWeekday = _getWeekdayName(now.weekday);
    
    return [
      {
        'id': 'order_001',
        'subscriptionId': 'sub_001',
        'deliveryDate': now.toIso8601String(),
        'mealType': 'Breakfast',
        'mealId': _getMealIdForType('vegetarian', 'Breakfast'),
        'mealName': _getMealNameForId(_getMealIdForType('vegetarian', 'Breakfast')),
        'status': now.hour >= 10 ? 'delivered' : 'coming',
        'deliveredAt': now.hour >= 10 
            ? DateTime(now.year, now.month, now.day, 8, 30).toIso8601String() 
            : null,
        'expectedTime': DateTime(now.year, now.month, now.day, 8, 0).toIso8601String()
      },
      {
        'id': 'order_002',
        'subscriptionId': 'sub_001',
        'deliveryDate': now.toIso8601String(),
        'mealType': 'Lunch',
        'mealId': _getMealIdForType('vegetarian', 'Lunch'),
        'mealName': _getMealNameForId(_getMealIdForType('vegetarian', 'Lunch')),
        'status': now.hour >= 15 ? 'delivered' : 'coming',
        'deliveredAt': now.hour >= 15 
            ? DateTime(now.year, now.month, now.day, 13, 10).toIso8601String() 
            : null,
        'expectedTime': DateTime(now.year, now.month, now.day, 13, 0).toIso8601String()
      },
      {
        'id': 'order_003',
        'subscriptionId': 'sub_001',
        'deliveryDate': now.toIso8601String(),
        'mealType': 'Dinner',
        'mealId': _getMealIdForType('vegetarian', 'Dinner'),
        'mealName': _getMealNameForId(_getMealIdForType('vegetarian', 'Dinner')),
        'status': now.hour >= 21 ? 'delivered' : 'coming',
        'deliveredAt': now.hour >= 21 
            ? DateTime(now.year, now.month, now.day, 20, 5).toIso8601String() 
            : null,
        'expectedTime': DateTime(now.year, now.month, now.day, 20, 0).toIso8601String()
      },
      
      // Include meal from another active subscription for the same day
      {
        'id': 'order_004',
        'subscriptionId': 'sub_003',
        'deliveryDate': now.toIso8601String(),
        'mealType': 'Breakfast',
        'mealId': _getMealIdForType('vegetarian', 'Breakfast', true),
        'mealName': _getMealNameForId(_getMealIdForType('vegetarian', 'Breakfast', true)),
        'status': now.hour >= 10 ? 'delivered' : 'coming',
        'deliveredAt': now.hour >= 10 
            ? DateTime(now.year, now.month, now.day, 8, 45).toIso8601String() 
            : null,
        'expectedTime': DateTime(now.year, now.month, now.day, 8, 30).toIso8601String()
      }
    ];
  }

  // =========================================================================
  // HELPER METHODS
  // =========================================================================
  
  // Helper to create a basic weekly plan with slots for all days/meals
  static List<Map<String, dynamic>> _createWeeklyPlanSlots(List<String> dietTypes) {
    final days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    final timings = ['breakfast', 'lunch', 'dinner'];
    final slots = <Map<String, dynamic>>[];
    
    for (final day in days) {
      for (final timing in timings) {
        final dietType = dietTypes[_random.nextInt(dietTypes.length)];
        slots.add({
          'day': day,
          'timing': timing,
          'meal': _getMealIdForType(dietType, timing)
        });
      }
    }
    
    return slots;
  }
  
  // Helper to create a lunch-only plan
  static List<Map<String, dynamic>> _createLunchOnlyPlanSlots() {
    final days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    final slots = <Map<String, dynamic>>[];
    
    for (final day in days) {
      slots.add({
        'day': day,
        'timing': 'lunch',
        'meal': _getMealIdForType(_random.nextBool() ? 'vegetarian' : 'non-vegetarian', 'Lunch')
      });
    }
    
    return slots;
  }
  
  // Helper to create a weekend-only plan
  static List<Map<String, dynamic>> _createWeekendOnlyPlanSlots() {
    final days = ['saturday', 'sunday'];
    final timings = ['breakfast', 'lunch', 'dinner'];
    final slots = <Map<String, dynamic>>[];
    
    for (final day in days) {
      for (final timing in timings) {
        slots.add({
          'day': day,
          'timing': timing,
          'meal': _getMealIdForType(_random.nextBool() ? 'vegetarian' : 'non-vegetarian', timing)
        });
      }
    }
    
    return slots;
  }
  
  // Helper to create a plan with a specific diet type
  static List<Map<String, dynamic>> _createWeeklyPlanSlotsForDietType(String dietType) {
    final days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    final timings = ['breakfast', 'lunch', 'dinner'];
    final slots = <Map<String, dynamic>>[];
    
    // For diet types, we'd need special meals - for now, using vegetarian as placeholder
    for (final day in days) {
      for (final timing in timings) {
        slots.add({
          'day': day,
          'timing': timing,
          'meal': _getMealIdForType('vegetarian', timing)
        });
      }
    }
    
    return slots;
  }
  
  // Helper to create a basic lunch plan (weekdays only)
  static List<Map<String, dynamic>> _createBasicLunchPlan(String mealId) {
    final days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday'];
    return days.map((day) => {
      'day': day,
      'timing': 'lunch',
      'meal': mealId
    }).toList();
  }
  
  // Helper to create a basic dinner plan (all days)
  static List<Map<String, dynamic>> _createBasicDinnerPlan(String mealId) {
    final days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    return days.map((day) => {
      'day': day,
      'timing': 'dinner',
      'meal': mealId
    }).toList();
  }
  
  // Helper to create a weekday breakfast plan
  static List<Map<String, dynamic>> _createWeekdayBreakfastPlan(String mealId) {
    final days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday'];
    return days.map((day) => {
      'day': day,
      'timing': 'breakfast',
      'meal': mealId
    }).toList();
  }
  
  // Helper to create a full week plan with all meal types
  static List<Map<String, dynamic>> _createFullWeekPlan() {
    final days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    final timings = ['breakfast', 'lunch', 'dinner'];
    final slots = <Map<String, dynamic>>[];
    
    for (final day in days) {
      for (final timing in timings) {
        final isVeg = _random.nextBool();
        slots.add({
          'day': day,
          'timing': timing,
          'meal': _getMealIdForType(isVeg ? 'vegetarian' : 'non-vegetarian', timing)
        });
      }
    }
    
    return slots;
  }
  
  // Helper to get a meal ID for a specific diet type and timing
  static String _getMealIdForType(String dietType, String timing, [bool alternate = false]) {
    final matchingMeals = meals.where((meal) {
      // Check diet type
      final meetsPreference = dietType == 'vegetarian'
          ? (meal['dietaryPreferences'] as List).contains('vegetarian')
          : !(meal['dietaryPreferences'] as List).contains('vegetarian');
      
      // Check timing
      final matchesTiming = meal['dishes'].any((dish) {
        final category = dish['category'];
        if (timing.toLowerCase() == 'breakfast') {
          return category == 'breakfast';
        } else if (timing.toLowerCase() == 'lunch') {
          return category == 'main_course' || category == 'rice';
        } else { // dinner
          return category == 'main_course';
        }
      });
      
      return meetsPreference && matchesTiming;
    }).toList();
    
    if (matchingMeals.isEmpty) {
      // Fallback to any meal if no matches
      return meals.first['id'];
    }
    
    // If alternate is true, pick a different meal if possible
    if (alternate && matchingMeals.length > 1) {
      return matchingMeals[1]['id'];
    }
    
    return matchingMeals.first['id'];
  }
  
  // Helper to get a meal name by ID
  static String _getMealNameForId(String mealId) {
    final meal = meals.firstWhere(
      (meal) => meal['id'] == mealId,
      orElse: () => {'name': 'Unknown Meal'}
    );
    
    return meal['name'];
  }
  
  // Helper to get weekday name from number
  static String _getWeekdayName(int weekday) {
    final days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    return days[weekday - 1];
  }
  
  // =========================================================================
  // PUBLIC HELPER METHODS
  // =========================================================================
  
  // Get a meal by ID
  static Map<String, dynamic> getMealById(String mealId) {
    return meals.firstWhere(
      (meal) => meal['id'] == mealId,
      orElse: () => meals[0]
    );
  }

  // Get a dish by ID
  static Map<String, dynamic> getDishById(String dishId) {
    return dishes.firstWhere(
      (dish) => dish['id'] == dishId,
      orElse: () => dishes[0]
    );
  }

  // Get a package by ID
  static Map<String, dynamic> getPackageById(String packageId) {
    return packages.firstWhere(
      (pkg) => pkg['id'] == packageId,
      orElse: () => packages[0]
    );
  }

  // Get a subscription by ID
  static Map<String, dynamic> getSubscriptionById(String subscriptionId) {
    return activeSubscriptions.firstWhere(
      (sub) => sub['id'] == subscriptionId,
      orElse: () => activeSubscriptions[0]
    );
  }
  
  // Get a payment by ID
  static Map<String, dynamic> getPaymentById(String paymentId) {
    return paymentHistory.firstWhere(
      (payment) => payment['id'] == paymentId,
      orElse: () => paymentHistory[0]
    );
  }
  
  // Get an address by ID
  static Map<String, dynamic> getAddressById(String addressId) {
    return addresses.firstWhere(
      (address) => address['id'] == addressId,
      orElse: () => addresses[0]
    );
  }
  
  // Get all vegetarian meals
  static List<Map<String, dynamic>> getVegetarianMeals() {
    return meals.where((meal) {
      final prefs = meal['dietaryPreferences'] as List;
      return prefs.contains('vegetarian');
    }).toList();
  }
  
  // Get all non-vegetarian meals
  static List<Map<String, dynamic>> getNonVegetarianMeals() {
    return meals.where((meal) {
      final prefs = meal['dietaryPreferences'] as List;
      return !prefs.contains('vegetarian');
    }).toList();
  }
  
  // Get all vegetarian packages
  static List<Map<String, dynamic>> getVegetarianPackages() {
    return packages.where((pkg) => 
      pkg['type'] == 'vegetarian' || pkg['type'] == 'jain'
    ).toList();
  }
  
  // Get all non-vegetarian packages
  static List<Map<String, dynamic>> getNonVegetarianPackages() {
    return packages.where((pkg) => 
      pkg['type'] == 'non-vegetarian' || pkg['type'] == 'mixed'
    ).toList();
  }
  
  // Get active subscriptions (not paused)
  static List<Map<String, dynamic>> getTrueActiveSubscriptions() {
    return activeSubscriptions.where((sub) => 
      sub['subscriptionStatus'] == 'active' && 
      sub['pauseDetails']['isPaused'] == false
    ).toList();
  }
  
  // Get paused subscriptions
  static List<Map<String, dynamic>> getPausedSubscriptions() {
    return activeSubscriptions.where((sub) => 
      sub['subscriptionStatus'] == 'paused' || 
      sub['pauseDetails']['isPaused'] == true
    ).toList();
  }
  
  // Get pending subscriptions (payment not completed)
  static List<Map<String, dynamic>> getPendingSubscriptions() {
    return activeSubscriptions.where((sub) => 
      sub['subscriptionStatus'] == 'pending' || 
      sub['paymentDetails']['paymentStatus'] == 'pending'
    ).toList();
  }
}