// lib/src/data/mock_data.dart
class MockData {
  // Mock Token
  static const String mockToken = 'mock_jwt_token_for_development_eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9';

  // Mock User
  static final Map<String, dynamic> currentUser = {
    'id': 'usr_001',
    'email': 'johndoe@example.com',
    'firstName': 'John',
    'lastName': 'Doe',
    'phone': '9876543210',
    'role': 'user',
  };

  // Mock Addresses
  static final List<Map<String, dynamic>> addresses = [
    {
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
    {
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
    {
      'id': 'addr_003',
      'street': '789 Lake View',
      'city': 'Delhi',
      'state': 'Delhi',
      'zipCode': '110001',
      'coordinates': {
        'latitude': 28.6139,
        'longitude': 77.2090
      }
    }
  ];

  // Mock Dishes
  static final List<Map<String, dynamic>> dishes = [
    {
      'id': 'dish_001',
      'name': 'Vegan Buddha Bowl',
      'description': 'Nutritious bowl with quinoa, roasted vegetables and tahini dressing',
      'price': 14.5,
      'category': 'main_course',
      'imageUrl': 'https://example.com/buddha-bowl.jpg'
    },
    {
      'id': 'dish_002',
      'name': 'Garlic Parmesan Fries',
      'description': 'Crispy fries tossed in garlic and parmesan',
      'price': 5.99,
      'category': 'side_dish',
      'imageUrl': 'https://example.com/garlic-fries.jpg'
    },
    {
      'id': 'dish_003',
      'name': 'Mango Lassii',
      'description': 'Traditional yogurt-based mango drink',
      'price': 4.99,
      'category': 'beverage',
      'imageUrl': 'https://example.com/mango-lassi.jpg'
    },
    {
      'id': 'dish_004',
      'name': 'Vegetable Spring Rolls',
      'description': 'Crispy fried rolls with vegetable filling',
      'price': 6.75,
      'category': 'snack',
      'imageUrl': 'https://example.com/spring-rolls.jpg'
    },
    {
      'id': 'dish_005',
      'name': 'Caprese Skewers',
      'description': 'Mozzarella, cherry tomatoes and basil on skewers',
      'price': 9.5,
      'category': 'appetizer',
      'imageUrl': 'https://example.com/caprese.jpg'
    },
    {
      'id': 'dish_006',
      'name': 'Tomato Basil Soup',
      'description': 'Creamy tomato soup with fresh basil',
      'price': 7.25,
      'category': 'soup',
      'imageUrl': 'https://example.com/tomato-soup.jpg'
    },
    {
      'id': 'dish_007',
      'name': 'Grilled Chicken Salad',
      'description': 'Fresh salad with grilled chicken breast and honey mustard dressing',
      'price': 12.99,
      'category': 'main_course',
      'imageUrl': 'https://example.com/chicken-salad.jpg'
    },
    {
      'id': 'dish_008',
      'name': 'Green Smoothie',
      'description': 'Refreshing blend of spinach, mango and almond milk',
      'price': 6.5,
      'category': 'beverage',
      'imageUrl': 'https://example.com/green-smoothie.jpg'
    },
    {
      'id': 'dish_009',
      'name': 'Chocolate Lava Cake',
      'description': 'Warm chocolate cake with gooey molten center',
      'price': 8.99,
      'category': 'dessert',
      'imageUrl': 'https://example.com/lava-cake.jpg'
    },
    {
      'id': 'dish_010',
      'name': 'Grilled Salmon',
      'description': 'Atlantic salmon with lemon butter sauce',
      'price': 18.99,
      'category': 'main_course',
      'imageUrl': 'https://example.com/grilled-salmon.jpg'
    }
  ];

  // Mock Meals
  static final List<Map<String, dynamic>> meals = [
    {
      'id': '67dc49fb9cf68009bc1baeb6',
      'name': 'Standard Veg Thali',
      'description': 'Complete vegetarian meal with multiple courses',
      'price': 24.99,
      'dishes': [
        dishes[0], // Vegan Buddha Bowl
        dishes[1], // Garlic Parmesan Fries
        dishes[2], // Mango Lassii
      ],
      'dietaryPreferences': ['vegetarian'],
      'imageUrl': 'https://example.com/standard-thali.jpg',
      'isAvailable': true
    },
    {
      'id': '67dc537b9cf68009bc1baec3',
      'name': 'Deluxe Veg Thali',
      'description': 'Premium vegetarian feast with 5 items',
      'price': 34.5,
      'dishes': [
        dishes[0], // Vegan Buddha Bowl
        dishes[3], // Vegetable Spring Rolls
        dishes[4], // Caprese Skewers
        dishes[5], // Tomato Basil Soup
      ],
      'dietaryPreferences': ['vegetarian'],
      'imageUrl': 'https://example.com/deluxe-thali.jpg',
      'isAvailable': true
    },
    {
      'id': '67dd5bcf50b78a63731ed19d',
      'name': 'Dosa',
      'description': 'A south indian dish.',
      'price': 300,
      'dishes': [
        dishes[0], // Vegan Buddha Bowl
        dishes[3], // Vegetable Spring Rolls
        dishes[4], // Caprese Skewers
        dishes[5], // Tomato Basil Soup
      ],
      'dietaryPreferences': ['vegetarian'],
      'imageUrl': 'https://example.com/dosa.jpg',
      'isAvailable': true
    },
    {
      'id': '67de88c950b78a63731ed49d',
      'name': 'New Veg Thali',
      'description': 'Veg thali for testing only',
      'price': 99.94,
      'dishes': [
        dishes[6], // Grilled Chicken Salad
        dishes[7], // Green Smoothie
        dishes[3], // Vegetable Spring Rolls
        dishes[8], // Chocolate Lava Cake
        dishes[6], // Grilled Chicken Salad
        dishes[9], // Grilled Salmon
      ],
      'dietaryPreferences': ['non-vegetarian'],
      'imageUrl': 'https://example.com/new-veg-thali.jpg',
      'isAvailable': true
    },
    {
      'id': '67de8c5350b78a63731ed520',
      'name': 'Deluxe Non Veg Thali',
      'description': 'Premium non-vegetarian feast with 5 items',
      'price': 42.50,
      'dishes': [
        dishes[6], // Grilled Chicken Salad
        dishes[9], // Grilled Salmon
        dishes[3], // Vegetable Spring Rolls
        dishes[4], // Caprese Skewers
      ],
      'dietaryPreferences': ['non-vegetarian'],
      'imageUrl': 'https://example.com/deluxe-non-veg-thali.jpg',
      'isAvailable': true
    },
    {
      'id': '67de8cd350b78a63731ed52a',
      'name': 'Veg Thali',
      'description': 'Simple vegetarian thali',
      'price': 34.5,
      'dishes': [
        dishes[5], // Tomato Basil Soup
      ],
      'dietaryPreferences': ['vegetarian'],
      'imageUrl': 'https://example.com/veg-thali.jpg',
      'isAvailable': true
    }
  ];

  // Helper function to create slot with meal
  static Map<String, dynamic> _createSlot(String day, String timing, String mealId) {
    final meal = meals.firstWhere((m) => m['id'] == mealId, orElse: () => meals[0]);
    return {
      'day': day,
      'timing': timing,
      'meal': meal
    };
  }

  // Mock Packages
  static final List<Map<String, dynamic>> packages = [
    {
      'id': '67e0dd62e4a8a60b532a1ab0',
      'name': 'Weekly Standard Veg Thali',
      'description': 'Get Premium Food at lowest price',
      'price': 2100,
      'slots': [
        _createSlot('monday', 'breakfast', '67dc49fb9cf68009bc1baeb6'),
        _createSlot('monday', 'lunch', '67dc537b9cf68009bc1baec3'),
        _createSlot('monday', 'dinner', '67dd5bcf50b78a63731ed19d'),
        _createSlot('tuesday', 'breakfast', '67de88c950b78a63731ed49d'),
        _createSlot('tuesday', 'lunch', '67de8c5350b78a63731ed520'),
        _createSlot('tuesday', 'dinner', '67de8cd350b78a63731ed52a'),
        _createSlot('wednesday', 'breakfast', '67dc49fb9cf68009bc1baeb6'),
        _createSlot('wednesday', 'lunch', '67dc537b9cf68009bc1baec3'),
        _createSlot('wednesday', 'dinner', '67dd5bcf50b78a63731ed19d'),
        _createSlot('thursday', 'breakfast', '67de88c950b78a63731ed49d'),
        _createSlot('thursday', 'lunch', '67de8c5350b78a63731ed520'),
        _createSlot('thursday', 'dinner', '67de8cd350b78a63731ed52a'),
        _createSlot('friday', 'breakfast', '67dc49fb9cf68009bc1baeb6'),
        _createSlot('friday', 'lunch', '67dc537b9cf68009bc1baec3'),
        _createSlot('friday', 'dinner', '67dd5bcf50b78a63731ed19d'),
        _createSlot('saturday', 'breakfast', '67dc49fb9cf68009bc1baeb6'),
        _createSlot('saturday', 'lunch', '67dc537b9cf68009bc1baec3'),
        _createSlot('saturday', 'dinner', '67dd5bcf50b78a63731ed19d'),
        _createSlot('sunday', 'breakfast', '67de88c950b78a63731ed49d'),
        _createSlot('sunday', 'lunch', '67de8c5350b78a63731ed520'),
        _createSlot('sunday', 'dinner', '67de8cd350b78a63731ed52a'),
      ]
    },
    {
      'id': 'pkg_002',
      'name': 'Premium Non-Veg Weekly Package',
      'description': 'Delicious non-vegetarian meals for the whole week',
      'price': 2499,
      'slots': [
        _createSlot('monday', 'breakfast', '67de88c950b78a63731ed49d'),
        _createSlot('monday', 'lunch', '67de8c5350b78a63731ed520'),
        _createSlot('monday', 'dinner', '67de8c5350b78a63731ed520'),
        _createSlot('tuesday', 'breakfast', '67de88c950b78a63731ed49d'),
        _createSlot('tuesday', 'lunch', '67de8c5350b78a63731ed520'),
        _createSlot('tuesday', 'dinner', '67de8c5350b78a63731ed520'),
        _createSlot('wednesday', 'breakfast', '67de88c950b78a63731ed49d'),
        _createSlot('wednesday', 'lunch', '67de8c5350b78a63731ed520'),
        _createSlot('wednesday', 'dinner', '67de8c5350b78a63731ed520'),
        _createSlot('thursday', 'breakfast', '67de88c950b78a63731ed49d'),
        _createSlot('thursday', 'lunch', '67de8c5350b78a63731ed520'),
        _createSlot('thursday', 'dinner', '67de8c5350b78a63731ed520'),
        _createSlot('friday', 'breakfast', '67de88c950b78a63731ed49d'),
        _createSlot('friday', 'lunch', '67de8c5350b78a63731ed520'),
        _createSlot('friday', 'dinner', '67de8c5350b78a63731ed520'),
        _createSlot('saturday', 'breakfast', '67de88c950b78a63731ed49d'),
        _createSlot('saturday', 'lunch', '67de8c5350b78a63731ed520'),
        _createSlot('saturday', 'dinner', '67de8c5350b78a63731ed520'),
        _createSlot('sunday', 'breakfast', '67de88c950b78a63731ed49d'),
        _createSlot('sunday', 'lunch', '67de8c5350b78a63731ed520'),
        _createSlot('sunday', 'dinner', '67de8c5350b78a63731ed520'),
      ]
    },
    {
      'id': 'pkg_003',
      'name': 'Vegetarian Breakfast Package',
      'description': 'Daily vegetarian breakfast options',
      'price': 1299,
      'slots': [
        _createSlot('monday', 'breakfast', '67dc49fb9cf68009bc1baeb6'),
        _createSlot('tuesday', 'breakfast', '67dc49fb9cf68009bc1baeb6'),
        _createSlot('wednesday', 'breakfast', '67dc49fb9cf68009bc1baeb6'),
        _createSlot('thursday', 'breakfast', '67dc49fb9cf68009bc1baeb6'),
        _createSlot('friday', 'breakfast', '67dc49fb9cf68009bc1baeb6'),
        _createSlot('saturday', 'breakfast', '67dc49fb9cf68009bc1baeb6'),
        _createSlot('sunday', 'breakfast', '67dc49fb9cf68009bc1baeb6'),
      ]
    }
  ];

  // Mock Active Subscriptions
  static final List<Map<String, dynamic>> activeSubscriptions = [
    {
      'id': '67e0ee2c2751a114a0fa094a',
      'startDate': '2025-03-20T00:00:00.000Z',
      'durationDays': 7,
      'package': '67e0dd62e4a8a60b532a1ab0',
      'slots': [
        {
          'day': 'monday',
          'timing': 'lunch',
          'meal': '67dc537b9cf68009bc1baec3'
        },
        {
          'day': 'tuesday',
          'timing': 'lunch',
          'meal': '67de8c5350b78a63731ed520'
        },
        {
          'day': 'wednesday',
          'timing': 'lunch',
          'meal': '67dc537b9cf68009bc1baec3'
        },
        {
          'day': 'thursday',
          'timing': 'lunch',
          'meal': '67de8c5350b78a63731ed520'
        },
        {
          'day': 'friday',
          'timing': 'lunch',
          'meal': '67dc537b9cf68009bc1baec3'
        }
      ],
      'address': {
        'id': '67e0d60401b6625b3d72953a',
        'street': 'Some street name',
        'city': 'Surat',
        'state': 'Gujrat',
        'zipCode': '234223',
        'coordinates': {
          'latitude': 0,
          'longitude': 0
        }
      },
      'instructions': 'Ring the bell',
      'paymentDetails': {
        'paymentStatus': 'pending'
      },
      'pauseDetails': {
        'isPaused': false
      },
      'subscriptionStatus': 'active',
      'cloudKitchen': ''
    },
    {
      'id': 'sub_002',
      'startDate': '2025-03-15T00:00:00.000Z',
      'durationDays': 30,
      'package': 'pkg_002',
      'slots': [
        {
          'day': 'monday',
          'timing': 'breakfast',
          'meal': '67de88c950b78a63731ed49d'
        },
        {
          'day': 'tuesday',
          'timing': 'breakfast',
          'meal': '67de88c950b78a63731ed49d'
        },
        {
          'day': 'wednesday',
          'timing': 'breakfast',
          'meal': '67de88c950b78a63731ed49d'
        },
        {
          'day': 'thursday',
          'timing': 'breakfast',
          'meal': '67de88c950b78a63731ed49d'
        },
        {
          'day': 'friday',
          'timing': 'breakfast',
          'meal': '67de88c950b78a63731ed49d'
        }
      ],
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
      'instructions': 'Call before delivery',
      'paymentDetails': {
        'paymentStatus': 'paid'
      },
      'pauseDetails': {
        'isPaused': true
      },
      'subscriptionStatus': 'paused',
      'cloudKitchen': ''
    },
    {
      'id': 'sub_003',
      'startDate': '2025-04-01T00:00:00.000Z',
      'durationDays': 14,
      'package': 'pkg_003',
      'slots': [
        {
          'day': 'monday',
          'timing': 'breakfast',
          'meal': '67dc49fb9cf68009bc1baeb6'
        },
        {
          'day': 'tuesday',
          'timing': 'breakfast',
          'meal': '67dc49fb9cf68009bc1baeb6'
        },
        {
          'day': 'wednesday',
          'timing': 'breakfast',
          'meal': '67dc49fb9cf68009bc1baeb6'
        },
        {
          'day': 'thursday',
          'timing': 'breakfast',
          'meal': '67dc49fb9cf68009bc1baeb6'
        },
        {
          'day': 'friday',
          'timing': 'breakfast',
          'meal': '67dc49fb9cf68009bc1baeb6'
        }
      ],
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
      'instructions': 'Leave at the door',
      'paymentDetails': {
        'paymentStatus': 'paid'
      },
      'pauseDetails': {
        'isPaused': false
      },
      'subscriptionStatus': 'active',
      'cloudKitchen': ''
    }
  ];

  // Helper method to get a meal by ID
  static Map<String, dynamic> getMealById(String mealId) {
    return meals.firstWhere(
      (meal) => meal['id'] == mealId,
      orElse: () => meals[0]
    );
  }

  // Helper method to get a dish by ID
  static Map<String, dynamic> getDishById(String dishId) {
    return dishes.firstWhere(
      (dish) => dish['id'] == dishId,
      orElse: () => dishes[0]
    );
  }

  // Helper method to get meals by dietary preference
  static List<Map<String, dynamic>> getMealsByPreference(String preference) {
    return meals.where((meal) => 
      meal['dietaryPreferences'] != null && 
      meal['dietaryPreferences'].contains(preference)
    ).toList();
  }

  // Helper method to get a package by ID
  static Map<String, dynamic> getPackageById(String packageId) {
    return packages.firstWhere(
      (pkg) => pkg['id'] == packageId,
      orElse: () => packages[0]
    );
  }

  // Helper method to get a subscription by ID
  static Map<String, dynamic> getSubscriptionById(String subscriptionId) {
    return activeSubscriptions.firstWhere(
      (sub) => sub['id'] == subscriptionId,
      orElse: () => activeSubscriptions[0]
    );
  }
}