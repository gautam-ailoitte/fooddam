// lib/src/data/datasource/mock_data.dart
import 'dart:math';

class MockData {
  // Mock Token
  static const String mockToken = 'mock_jwt_token_for_development_eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9';

  // Mock Users
  static final Map<String, dynamic> currentUser = {
    'id': 'usr_001',
    'firstName': 'John',
    'lastName': 'Doe',
    'email': 'johndoe@example.com',
    'phone': '9876543210',
    'role': 'customer',
    'address': {
      'id': 'addr_001',
      'street': '123 Main Street',
      'city': 'Bangalore',
      'state': 'Karnataka',
      'zipCode': '560001',
      'coordinates': {
        'latitude': 12.9716,
        'longitude': 77.5946
      }
    },
    'dietaryPreferences': [
      'vegetarian',
      'gluten-free'
    ],
    'allergies': [
      'peanuts',
      'shellfish'
    ]
  };

  // Other Users for Admin Panel (if needed later)
  static final List<Map<String, dynamic>> users = [
    currentUser,
    {
      'id': 'usr_002',
      'firstName': 'Jane',
      'lastName': 'Smith',
      'email': 'janesmith@example.com',
      'phone': '9876543211',
      'role': 'customer',
      'address': {
        'id': 'addr_002',
        'street': '456 Park Avenue',
        'city': 'Mumbai',
        'state': 'Maharashtra',
        'zipCode': '400001',
        'coordinates': {
          'latitude': 19.0760,
          'longitude': 72.8777
        }
      },
      'dietaryPreferences': [
        'non-vegetarian'
      ],
      'allergies': [
        'dairy-free'
      ]
    },
    {
      'id': 'usr_003',
      'firstName': 'Raj',
      'lastName': 'Patel',
      'email': 'rajpatel@example.com',
      'phone': '9876543212',
      'role': 'customer',
      'address': {
        'id': 'addr_003',
        'street': '789 Lake View',
        'city': 'Delhi',
        'state': 'Delhi',
        'zipCode': '110001',
        'coordinates': {
          'latitude': 28.6139,
          'longitude': 77.2090
        }
      },
      'dietaryPreferences': [
        'vegetarian'
      ],
      'allergies': []
    }
  ];

  // Mock Subscription Plans
  static final List<Map<String, dynamic>> subscriptionPlans = [
    {
      'id': 'plan_001',
      'name': 'Vegetarian Basic Plan',
      'description': 'A simple vegetarian meal plan for everyday nutrition.',
      'price': 1499.0,
      'weeklyMealTemplate': [
        {'day': 'Monday', 'timing': 'Breakfast', 'meal': 'South Indian Breakfast'},
        {'day': 'Monday', 'timing': 'Lunch', 'meal': 'North Indian Thali'},
        {'day': 'Monday', 'timing': 'Dinner', 'meal': 'Light Dinner Combo'},
        {'day': 'Tuesday', 'timing': 'Breakfast', 'meal': 'Poha with Fruits'},
        {'day': 'Tuesday', 'timing': 'Lunch', 'meal': 'Rajasthani Thali'},
        {'day': 'Tuesday', 'timing': 'Dinner', 'meal': 'Light Soup and Sandwich'},
        {'day': 'Wednesday', 'timing': 'Breakfast', 'meal': 'Paratha with Curd'},
        {'day': 'Wednesday', 'timing': 'Lunch', 'meal': 'Gujarati Thali'},
        {'day': 'Wednesday', 'timing': 'Dinner', 'meal': 'Rice and Curry Combo'},
        {'day': 'Thursday', 'timing': 'Breakfast', 'meal': 'Upma with Chutney'},
        {'day': 'Thursday', 'timing': 'Lunch', 'meal': 'Bengali Thali'},
        {'day': 'Thursday', 'timing': 'Dinner', 'meal': 'Khichdi and Papad'},
        {'day': 'Friday', 'timing': 'Breakfast', 'meal': 'Idli Sambar'},
        {'day': 'Friday', 'timing': 'Lunch', 'meal': 'South Indian Thali'},
        {'day': 'Friday', 'timing': 'Dinner', 'meal': 'Roti and Dal'},
        {'day': 'Saturday', 'timing': 'Breakfast', 'meal': 'Aloo Paratha'},
        {'day': 'Saturday', 'timing': 'Lunch', 'meal': 'Punjabi Thali'},
        {'day': 'Saturday', 'timing': 'Dinner', 'meal': 'Mixed Vegetable Rice'},
        {'day': 'Sunday', 'timing': 'Breakfast', 'meal': 'Chole Bhature'},
        {'day': 'Sunday', 'timing': 'Lunch', 'meal': 'Festive Special Thali'},
        {'day': 'Sunday', 'timing': 'Dinner', 'meal': 'Pulao with Raita'},
      ],
      'breakdown': [
        {'day': 'Weekday', 'timing': 'Breakfast', 'price': 60.0},
        {'day': 'Weekday', 'timing': 'Lunch', 'price': 120.0},
        {'day': 'Weekday', 'timing': 'Dinner', 'price': 100.0},
        {'day': 'Weekend', 'timing': 'Breakfast', 'price': 80.0},
        {'day': 'Weekend', 'timing': 'Lunch', 'price': 150.0},
        {'day': 'Weekend', 'timing': 'Dinner', 'price': 120.0},
      ]
    },
    {
      'id': 'plan_002',
      'name': 'Non-Vegetarian Premium Plan',
      'description': 'A protein-rich meal plan with non-vegetarian options.',
      'price': 1899.0,
      'weeklyMealTemplate': [
        {'day': 'Monday', 'timing': 'Breakfast', 'meal': 'Egg Paratha'},
        {'day': 'Monday', 'timing': 'Lunch', 'meal': 'Chicken Thali'},
        {'day': 'Monday', 'timing': 'Dinner', 'meal': 'Fish Curry with Rice'},
        {'day': 'Tuesday', 'timing': 'Breakfast', 'meal': 'Egg Bhurji with Toast'},
        {'day': 'Tuesday', 'timing': 'Lunch', 'meal': 'Mutton Thali'},
        {'day': 'Tuesday', 'timing': 'Dinner', 'meal': 'Chicken Sandwich'},
        {'day': 'Wednesday', 'timing': 'Breakfast', 'meal': 'Chicken Keema Paratha'},
        {'day': 'Wednesday', 'timing': 'Lunch', 'meal': 'Fish Thali'},
        {'day': 'Wednesday', 'timing': 'Dinner', 'meal': 'Egg Curry with Rice'},
        {'day': 'Thursday', 'timing': 'Breakfast', 'meal': 'Omelette with Bread'},
        {'day': 'Thursday', 'timing': 'Lunch', 'meal': 'Chicken Biryani'},
        {'day': 'Thursday', 'timing': 'Dinner', 'meal': 'Mutton Soup with Bread'},
        {'day': 'Friday', 'timing': 'Breakfast', 'meal': 'Boiled Eggs with Fruits'},
        {'day': 'Friday', 'timing': 'Lunch', 'meal': 'Prawn Thali'},
        {'day': 'Friday', 'timing': 'Dinner', 'meal': 'Chicken Curry with Roti'},
        {'day': 'Saturday', 'timing': 'Breakfast', 'meal': 'Egg Dosa'},
        {'day': 'Saturday', 'timing': 'Lunch', 'meal': 'Special Non-Veg Thali'},
        {'day': 'Saturday', 'timing': 'Dinner', 'meal': 'Chicken Fried Rice'},
        {'day': 'Sunday', 'timing': 'Breakfast', 'meal': 'Chicken Sandwich'},
        {'day': 'Sunday', 'timing': 'Lunch', 'meal': 'Mutton Biryani'},
        {'day': 'Sunday', 'timing': 'Dinner', 'meal': 'Fish Curry with Appam'},
      ],
      'breakdown': [
        {'day': 'Weekday', 'timing': 'Breakfast', 'price': 80.0},
        {'day': 'Weekday', 'timing': 'Lunch', 'price': 150.0},
        {'day': 'Weekday', 'timing': 'Dinner', 'price': 130.0},
        {'day': 'Weekend', 'timing': 'Breakfast', 'price': 100.0},
        {'day': 'Weekend', 'timing': 'Lunch', 'price': 180.0},
        {'day': 'Weekend', 'timing': 'Dinner', 'price': 150.0},
      ]
    },
    {
      'id': 'plan_003',
      'name': 'Deluxe Premium Plan',
      'description': 'A gourmet meal plan with premium ingredients and chef specials.',
      'price': 2499.0,
      'weeklyMealTemplate': [
        {'day': 'Monday', 'timing': 'Breakfast', 'meal': 'Continental Breakfast'},
        {'day': 'Monday', 'timing': 'Lunch', 'meal': 'Premium North Indian Thali'},
        {'day': 'Monday', 'timing': 'Dinner', 'meal': 'Gourmet Dinner Combo'},
        {'day': 'Tuesday', 'timing': 'Breakfast', 'meal': 'Mediterranean Breakfast'},
        {'day': 'Tuesday', 'timing': 'Lunch', 'meal': 'Chef Special Thali'},
        {'day': 'Tuesday', 'timing': 'Dinner', 'meal': 'Italian Dinner'},
        {'day': 'Wednesday', 'timing': 'Breakfast', 'meal': 'French Breakfast'},
        {'day': 'Wednesday', 'timing': 'Lunch', 'meal': 'Fusion Thali'},
        {'day': 'Wednesday', 'timing': 'Dinner', 'meal': 'Asian Dinner Combo'},
        {'day': 'Thursday', 'timing': 'Breakfast', 'meal': 'Protein Rich Breakfast'},
        {'day': 'Thursday', 'timing': 'Lunch', 'meal': 'Seafood Thali'},
        {'day': 'Thursday', 'timing': 'Dinner', 'meal': 'Mexican Dinner'},
        {'day': 'Friday', 'timing': 'Breakfast', 'meal': 'Detox Breakfast'},
        {'day': 'Friday', 'timing': 'Lunch', 'meal': 'Premium South Indian Thali'},
        {'day': 'Friday', 'timing': 'Dinner', 'meal': 'Thai Dinner Combo'},
        {'day': 'Saturday', 'timing': 'Breakfast', 'meal': 'Japanese Breakfast'},
        {'day': 'Saturday', 'timing': 'Lunch', 'meal': 'Royal Nawabi Thali'},
        {'day': 'Saturday', 'timing': 'Dinner', 'meal': 'Chef\'s Signature Dinner'},
        {'day': 'Sunday', 'timing': 'Breakfast', 'meal': 'Brunch Special'},
        {'day': 'Sunday', 'timing': 'Lunch', 'meal': 'Premium Festive Thali'},
        {'day': 'Sunday', 'timing': 'Dinner', 'meal': 'International Cuisine Dinner'},
      ],
      'breakdown': [
        {'day': 'Weekday', 'timing': 'Breakfast', 'price': 120.0},
        {'day': 'Weekday', 'timing': 'Lunch', 'price': 200.0},
        {'day': 'Weekday', 'timing': 'Dinner', 'price': 180.0},
        {'day': 'Weekend', 'timing': 'Breakfast', 'price': 150.0},
        {'day': 'Weekend', 'timing': 'Lunch', 'price': 250.0},
        {'day': 'Weekend', 'timing': 'Dinner', 'price': 220.0},
      ]
    },
    {
      'id': 'plan_004',
      'name': 'Healthy Lite Plan',
      'description': 'A calorie-conscious meal plan for fitness enthusiasts.',
      'price': 1799.0,
      'weeklyMealTemplate': [
        {'day': 'Monday', 'timing': 'Breakfast', 'meal': 'Oats with Fruits'},
        {'day': 'Monday', 'timing': 'Lunch', 'meal': 'Quinoa Bowl'},
        {'day': 'Monday', 'timing': 'Dinner', 'meal': 'Grilled Vegetables with Soup'},
        {'day': 'Tuesday', 'timing': 'Breakfast', 'meal': 'Smoothie Bowl'},
        {'day': 'Tuesday', 'timing': 'Lunch', 'meal': 'Keto Thali'},
        {'day': 'Tuesday', 'timing': 'Dinner', 'meal': 'Protein Salad'},
        {'day': 'Wednesday', 'timing': 'Breakfast', 'meal': 'Egg Whites with Avocado'},
        {'day': 'Wednesday', 'timing': 'Lunch', 'meal': 'Grilled Chicken Salad'},
        {'day': 'Wednesday', 'timing': 'Dinner', 'meal': 'Steamed Fish with Veggies'},
        {'day': 'Thursday', 'timing': 'Breakfast', 'meal': 'Protein Pancakes'},
        {'day': 'Thursday', 'timing': 'Lunch', 'meal': 'Buddha Bowl'},
        {'day': 'Thursday', 'timing': 'Dinner', 'meal': 'Tofu Stir Fry'},
        {'day': 'Friday', 'timing': 'Breakfast', 'meal': 'Greek Yogurt with Berries'},
        {'day': 'Friday', 'timing': 'Lunch', 'meal': 'Mediterranean Bowl'},
        {'day': 'Friday', 'timing': 'Dinner', 'meal': 'Zucchini Noodles'},
        {'day': 'Saturday', 'timing': 'Breakfast', 'meal': 'Protein Shake with Toast'},
        {'day': 'Saturday', 'timing': 'Lunch', 'meal': 'Lean Protein Bowl'},
        {'day': 'Saturday', 'timing': 'Dinner', 'meal': 'Cauliflower Rice Bowl'},
        {'day': 'Sunday', 'timing': 'Breakfast', 'meal': 'Chia Seed Pudding'},
        {'day': 'Sunday', 'timing': 'Lunch', 'meal': 'Protein Packed Thali'},
        {'day': 'Sunday', 'timing': 'Dinner', 'meal': 'Light Soup with Multi-grain Bread'},
      ],
      'breakdown': [
        {'day': 'Weekday', 'timing': 'Breakfast', 'price': 90.0},
        {'day': 'Weekday', 'timing': 'Lunch', 'price': 140.0},
        {'day': 'Weekday', 'timing': 'Dinner', 'price': 110.0},
        {'day': 'Weekend', 'timing': 'Breakfast', 'price': 110.0},
        {'day': 'Weekend', 'timing': 'Lunch', 'price': 160.0},
        {'day': 'Weekend', 'timing': 'Dinner', 'price': 130.0},
      ]
    }
  ];

  // Mock Active Subscriptions
  static final List<Map<String, dynamic>> activeSubscriptions = [
    {
      'id': 'sub_001',
      'startDate': DateTime.now().subtract(Duration(days: 5)).toIso8601String(),
      'endDate': DateTime.now().add(Duration(days: 25)).toIso8601String(),
      'planId': 'plan_001',
      'deliveryAddress': users[0]['address'],
      'deliveryInstructions': 'Please leave at the door if not at home.',
      'paymentDetails': {
        'paymentStatus': 'paid'
      },
      'pauseDetails': {
        'isPaused': false
      },
      'subscriptionPlan': subscriptionPlans[0],
      'subscriptionStatus': 'active'
    },
    {
      'id': 'sub_002',
      'startDate': DateTime.now().subtract(Duration(days: 15)).toIso8601String(),
      'endDate': DateTime.now().add(Duration(days: 15)).toIso8601String(),
      'planId': 'plan_003',
      'deliveryAddress': users[0]['address'],
      'deliveryInstructions': 'Call me before delivery.',
      'paymentDetails': {
        'paymentStatus': 'paid'
      },
      'pauseDetails': {
        'isPaused': true
      },
      'subscriptionPlan': subscriptionPlans[2],
      'subscriptionStatus': 'paused'
    }
  ];

  // Mock Meals
  static final List<Map<String, dynamic>> meals = [
    {
      'id': 'meal_001',
      'name': 'South Indian Breakfast',
      'description': 'A traditional South Indian breakfast with idli, vada, and sambar.',
      'price': 120.0,
      'dishes': [
        {
          'id': 'dish_001',
          'name': 'Idli',
          'description': 'Steamed rice cakes, soft and fluffy.',
          'price': 40.0,
          'category': 'Main',
        },
        {
          'id': 'dish_002',
          'name': 'Vada',
          'description': 'Crispy savory donuts made from urad dal.',
          'price': 35.0,
          'category': 'Side',
        },
        {
          'id': 'dish_003',
          'name': 'Sambar',
          'description': 'Lentil-based vegetable stew with a tamarind broth.',
          'price': 30.0,
          'category': 'Gravy',
        },
        {
          'id': 'dish_004',
          'name': 'Coconut Chutney',
          'description': 'Freshly ground coconut chutney with green chilies.',
          'price': 15.0,
          'category': 'Condiment',
        }
      ],
      'ingredients': [
        'Rice', 'Urad Dal', 'Toor Dal', 'Tamarind', 'Vegetables', 'Coconut', 'Spices'
      ],
      'dietaryPreferences': [
        'vegetarian', 'gluten-free'
      ],
      'isAvailable': true
    },
    {
      'id': 'meal_002',
      'name': 'North Indian Thali',
      'description': 'A complete North Indian meal with a variety of dishes.',
      'price': 180.0,
      'dishes': [
        {
          'id': 'dish_005',
          'name': 'Paneer Butter Masala',
          'description': 'Cottage cheese cubes in a rich, creamy tomato gravy.',
          'price': 60.0,
          'category': 'Main',
        },
        {
          'id': 'dish_006',
          'name': 'Dal Tadka',
          'description': 'Yellow lentils tempered with cumin, garlic, and spices.',
          'price': 40.0,
          'category': 'Side',
        },
        {
          'id': 'dish_007',
          'name': 'Jeera Rice',
          'description': 'Basmati rice flavored with cumin seeds.',
          'price': 35.0,
          'category': 'Rice',
        },
        {
          'id': 'dish_008',
          'name': 'Butter Naan',
          'description': 'Soft bread baked in tandoor and brushed with butter.',
          'price': 25.0,
          'category': 'Bread',
        },
        {
          'id': 'dish_009',
          'name': 'Mixed Vegetable Raita',
          'description': 'Yogurt with mixed vegetables and spices.',
          'price': 20.0,
          'category': 'Accompaniment',
        }
      ],
      'ingredients': [
        'Paneer', 'Tomatoes', 'Cream', 'Lentils', 'Basmati Rice', 'Flour', 'Yogurt', 'Vegetables', 'Spices'
      ],
      'dietaryPreferences': [
        'vegetarian'
      ],
      'isAvailable': true
    },
    {
      'id': 'meal_003',
      'name': 'Chicken Thali',
      'description': 'A hearty thali with chicken as the main protein.',
      'price': 220.0,
      'dishes': [
        {
          'id': 'dish_010',
          'name': 'Butter Chicken',
          'description': 'Tender chicken pieces in a rich, creamy tomato gravy.',
          'price': 85.0,
          'category': 'Main',
        },
        {
          'id': 'dish_011',
          'name': 'Dal Makhani',
          'description': 'Black lentils and kidney beans in a creamy gravy.',
          'price': 45.0,
          'category': 'Side',
        },
        {
          'id': 'dish_012',
          'name': 'Pulao',
          'description': 'Fragrant rice cooked with mild spices.',
          'price': 40.0,
          'category': 'Rice',
        },
        {
          'id': 'dish_013',
          'name': 'Garlic Naan',
          'description': 'Soft bread with garlic flavor baked in tandoor.',
          'price': 30.0,
          'category': 'Bread',
        },
        {
          'id': 'dish_014',
          'name': 'Boondi Raita',
          'description': 'Yogurt with tiny gram flour balls and spices.',
          'price': 20.0,
          'category': 'Accompaniment',
        }
      ],
      'ingredients': [
        'Chicken', 'Tomatoes', 'Cream', 'Black Lentils', 'Kidney Beans', 'Basmati Rice', 'Flour', 'Garlic', 'Yogurt', 'Gram Flour', 'Spices'
      ],
      'dietaryPreferences': [
        'non-vegetarian'
      ],
      'isAvailable': true
    },
    {
      'id': 'meal_004',
      'name': 'Light Dinner Combo',
      'description': 'A light and nutritious dinner option for a healthy evening meal.',
      'price': 150.0,
      'dishes': [
        {
          'id': 'dish_015',
          'name': 'Vegetable Soup',
          'description': 'Clear soup with mixed vegetables and herbs.',
          'price': 50.0,
          'category': 'Soup',
        },
        {
          'id': 'dish_016',
          'name': 'Multigrain Roti',
          'description': 'Roti made with a mix of healthy grains.',
          'price': 25.0,
          'category': 'Bread',
        },
        {
          'id': 'dish_017',
          'name': 'Paneer Bhurji',
          'description': 'Scrambled cottage cheese with vegetables and spices.',
          'price': 60.0,
          'category': 'Main',
        },
        {
          'id': 'dish_018',
          'name': 'Green Salad',
          'description': 'Fresh mixed greens with a light dressing.',
          'price': 30.0,
          'category': 'Salad',
        }
      ],
      'ingredients': [
        'Vegetables', 'Mixed Grains', 'Paneer', 'Tomatoes', 'Onions', 'Bell Peppers', 'Herbs', 'Spices'
      ],
      'dietaryPreferences': [
        'vegetarian'
      ],
      'isAvailable': true
    },
    {
      'id': 'meal_005',
      'name': 'Continental Breakfast',
      'description': 'A hearty western-style breakfast to start your day.',
      'price': 180.0,
      'dishes': [
        {
          'id': 'dish_019',
          'name': 'Scrambled Eggs',
          'description': 'Fluffy scrambled eggs with herbs.',
          'price': 60.0,
          'category': 'Main',
        },
        {
          'id': 'dish_020',
          'name': 'Hash Browns',
          'description': 'Crispy grated potato patties.',
          'price': 40.0,
          'category': 'Side',
        },
        {
          'id': 'dish_021',
          'name': 'Baked Beans',
          'description': 'Navy beans in a tomato sauce.',
          'price': 35.0,
          'category': 'Side',
        },
        {
          'id': 'dish_022',
          'name': 'Toast with Butter',
          'description': 'Toasted bread slices with butter.',
          'price': 25.0,
          'category': 'Bread',
        },
        {
          'id': 'dish_023',
          'name': 'Fresh Fruit Bowl',
          'description': 'Assorted seasonal fruits.',
          'price': 40.0,
          'category': 'Fruit',
        }
      ],
      'ingredients': [
        'Eggs', 'Potatoes', 'Beans', 'Bread', 'Butter', 'Seasonal Fruits', 'Herbs', 'Spices'
      ],
      'dietaryPreferences': [
        'non-vegetarian'
      ],
      'isAvailable': true
    }
  ];

  // Mock detailed dish information
  static final Map<String, dynamic> dishDetails = {
    'dish_001': {
      'id': 'dish_001',
      'name': 'Idli',
      'description': 'Steamed rice cakes, soft and fluffy.',
      'price': 40.0,
      'category': 'Main',
      'dietaryPreferences': ['vegetarian', 'gluten-free'],
      'ingredients': ['Rice', 'Urad Dal', 'Salt', 'Water'],
      'nutritionalInfo': {
        'calories': 120.0,
        'protein': 3.5,
        'carbs': 25.5,
        'fat': 0.5
      },
      'quantity': {
        'value': 2.0,
        'unit': 'pieces'
      }
    },
    'dish_010': {
      'id': 'dish_010',
      'name': 'Butter Chicken',
      'description': 'Tender chicken pieces in a rich, creamy tomato gravy.',
      'price': 85.0,
      'category': 'Main',
      'dietaryPreferences': ['non-vegetarian'],
      'ingredients': [
        'Chicken', 'Tomatoes', 'Butter', 'Cream', 'Onions', 'Ginger', 'Garlic', 'Garam Masala', 'Kasuri Methi'
      ],
      'nutritionalInfo': {
        'calories': 320.0,
        'protein': 25.0,
        'carbs': 8.0,
        'fat': 22.0
      },
      'quantity': {
        'value': 200.0,
        'unit': 'grams'
      }
    }
  };

  // Mock Today's Meal Orders
  static final List<Map<String, dynamic>> todayMealOrders = [
    {
      'id': 'order_001',
      'subscriptionId': 'sub_001',
      'deliveryDate': DateTime.now().toIso8601String(),
      'mealType': 'Breakfast',
      'mealId': 'meal_001',
      'mealName': 'South Indian Breakfast',
      'status': 'delivered',
      'deliveredAt': DateTime.now().subtract(Duration(hours: 3)).toIso8601String(),
      'expectedTime': DateTime.now().subtract(Duration(hours: 4)).toIso8601String(),
    },
    {
      'id': 'order_002',
      'subscriptionId': 'sub_001',
      'deliveryDate': DateTime.now().toIso8601String(),
      'mealType': 'Lunch',
      'mealId': 'meal_002',
      'mealName': 'North Indian Thali',
      'status': 'coming',
      'expectedTime': DateTime.now().add(Duration(hours: 1)).toIso8601String(),
    },
    {
      'id': 'order_003',
      'subscriptionId': 'sub_001',
      'deliveryDate': DateTime.now().toIso8601String(),
      'mealType': 'Dinner',
      'mealId': 'meal_004',
      'mealName': 'Light Dinner Combo',
      'status': 'coming',
      'expectedTime': DateTime.now().add(Duration(hours: 6)).toIso8601String(),
    }
  ];

  // Mock Payment History
  static final List<Map<String, dynamic>> paymentHistory = [
    {
      'id': 'payment_001',
      'subscriptionId': 'sub_001',
      'amount': 1499.0,
      'method': 'credit_card',
      'status': 'paid',
      'timestamp': DateTime.now().subtract(Duration(days: 5)).toIso8601String(),
      'transactionId': 'txn_001',
    },
    {
      'id': 'payment_002',
      'subscriptionId': 'sub_002',
      'amount': 2499.0,
      'method': 'upi',
      'status': 'paid',
      'timestamp': DateTime.now().subtract(Duration(days: 15)).toIso8601String(),
      'transactionId': 'txn_002',
    }
  ];

  // Helper methods for getting a random or specific mock item
  static T getRandomItem<T>(List<T> items) {
    final random = Random();
    return items[random.nextInt(items.length)];
  }

  static Map<String, dynamic> getMeal(String mealId) {
    return meals.firstWhere(
        (meal) => meal['id'] == mealId,
        orElse: () => meals[0]
    );
  }

  static Map<String, dynamic> getDishDetail(String dishId) {
    if (dishDetails.containsKey(dishId)) {
      return dishDetails[dishId]!;
    }

    // If not found in details, search in meals and return basic info
    for (var meal in meals) {
      for (var dish in meal['dishes']) {
        if (dish['id'] == dishId) {
          return dish;
        }
      }
    }

    return {
      'id': dishId,
      'name': 'Unknown Dish',
      'description': 'Description not available',
      'price': 0.0,
      'category': 'Unknown',
    };
  }

  static List<Map<String, dynamic>> getMealsByType(String type) {
    return meals.where((meal) => 
      meal['dietaryPreferences'] != null && 
      meal['dietaryPreferences'].contains(type)
    ).toList();
  }

  static List<Map<String, dynamic>> getMealOrdersByDate(DateTime date) {
    final dateString = date.toIso8601String().split('T')[0];
    
    return todayMealOrders.where((order) => 
      order['deliveryDate'].split('T')[0] == dateString
    ).toList();
  }
}