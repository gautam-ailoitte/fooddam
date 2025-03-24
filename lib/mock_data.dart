

/// Simplified Mock Data for development and testing
class MockData {
  // Mock Token
  static const String mockToken = 'mock_jwt_token_for_development';

  // Mock User
  static final Map<String, dynamic> currentUser = {
    'id': 'usr_001',
    'email': 'user@example.com',
    'firstName': 'John',
    'lastName': 'Doe',
    'phone': '1234567890',
    'role': 'user',
  };

  // Mock Addresses - Simplified
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
    }
  ];

  // Mock Dishes - Reduced
  static final List<Map<String, dynamic>> dishes = [
    {
      'id': 'dish_001',
      'name': 'Vegan Buddha Bowl',
      'description': 'Nutritious bowl with quinoa and vegetables',
      'price': 14.5,
      'category': 'main_course',
      'imageUrl': 'https://example.com/buddha-bowl.jpg'
    },
    {
      'id': 'dish_002',
      'name': 'Garlic Parmesan Fries',
      'description': 'Crispy fries with garlic and parmesan',
      'price': 5.99,
      'category': 'side_dish',
      'imageUrl': 'https://example.com/garlic-fries.jpg'
    },
    {
      'id': 'dish_003',
      'name': 'Mango Lassii',
      'description': 'Yogurt-based mango drink',
      'price': 4.99,
      'category': 'beverage',
      'imageUrl': 'https://example.com/mango-lassi.jpg'
    }
  ];

  // Mock Meals - Reduced
  static final List<Map<String, dynamic>> meals = [
    {
      'id': 'meal_001',
      'name': 'Standard Veg Thali',
      'description': 'Complete vegetarian meal',
      'price': 24.99,
      'dishes': [
        dishes[0], // Vegan Buddha Bowl
        dishes[1], // Garlic Parmesan Fries
        dishes[2], // Mango Lassii
      ],
      'imageUrl': 'https://example.com/standard-thali.jpg',
      'isAvailable': true
    },
    {
      'id': 'meal_002',
      'name': 'Deluxe Veg Thali',
      'description': 'Premium vegetarian feast',
      'price': 34.5,
      'dishes': [
        dishes[0], // Vegan Buddha Bowl
        dishes[1], // Garlic Parmesan Fries
        dishes[2], // Mango Lassii
      ],
      'imageUrl': 'https://example.com/deluxe-thali.jpg',
      'isAvailable': true
    }
  ];

  // Mock Packages - Simplified
  static final List<Map<String, dynamic>> packages = [
    {
      'id': 'pkg_001',
      'name': 'Weekly Standard Veg Thali',
      'description': 'Premium Food at lowest price',
      'price': 2100,
      'slots': _createBasicWeeklyPlan('meal_001')
    },
    {
      'id': 'pkg_002',
      'name': 'Premium Weekly Package',
      'description': 'Premium meals for the whole week',
      'price': 2499,
      'slots': _createBasicWeeklyPlan('meal_002')
    }
  ];

  // Mock Active Subscriptions - Simplified
  static final List<Map<String, dynamic>> activeSubscriptions = [
    {
      'id': 'sub_001',
      'startDate': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
      'durationDays': 7,
      'package': 'pkg_001',
      'slots': _createBasicLunchPlan('meal_001'),
      'address': addresses[0],
      'instructions': 'Ring the bell',
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

  // Helper to create a basic weekly plan with the same meal
  static List<Map<String, dynamic>> _createBasicWeeklyPlan(String mealId) {
    final days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    final times = ['breakfast', 'lunch', 'dinner'];
    
    final List<Map<String, dynamic>> slots = [];
    
    for (final day in days) {
      for (final time in times) {
        slots.add({
          'day': day,
          'timing': time,
          'meal': mealId
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