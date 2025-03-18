// lib/src/data/datasource/remote_data_source.dart
import 'dart:math';
import 'package:foodam/core/errors/execption.dart';
import 'package:foodam/mock_data.dart';
import 'package:foodam/src/domain/entities/user_entity.dart';
import 'package:foodam/src/domain/entities/address_entity.dart';
import 'package:foodam/src/domain/entities/dish_entity.dart';
import 'package:foodam/src/domain/entities/meal_entity.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';
import 'package:foodam/src/domain/entities/order_entity.dart';
import 'package:foodam/src/domain/entities/payment_entity.dart';

abstract class RemoteDataSource {
  // User
  Future<User> registerUser({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
    required Address address,
    List<DietaryPreference>? dietaryPreferences,
    List<String>? allergies,
  });
  
  Future<User> loginUser(String email, String password);
  
  Future<User> updateUserProfile({
    String? firstName,
    String? lastName,
    String? phone,
    Address? address,
    List<DietaryPreference>? dietaryPreferences,
    List<String>? allergies,
  });
  
  Future<bool> updatePassword(String currentPassword, String newPassword);
  
  Future<Address> addUserAddress(Address address);
  
  Future<List<Address>> getUserAddresses();
  
  // Dish
  Future<List<Dish>> getDishes({
    FoodCategory? category,
    DietaryPreference? dietaryPreference,
    double? minPrice,
    double? maxPrice,
    int limit = 10,
    int skip = 0,
  });
  
  Future<Dish> getDishById(String id);
  
  Future<List<Dish>> searchDishes(String query);
  
  Future<List<Dish>> getDishesByIds(List<String> ids);
  
  // Meal
  Future<List<Meal>> getMeals({
    DietaryPreference? dietaryPreference,
    double? minPrice,
    double? maxPrice,
    int limit = 10,
    int skip = 0,
  });
  
  Future<Meal> getMealById(String id);
  
  Future<List<Meal>> searchMeals(String query);
  
  Future<List<Meal>> getMealsByDietaryPreference(DietaryPreference preference);
  
  // Subscription
  Future<List<Subscription>> getAvailableSubscriptions();
  
  Future<Subscription?> getActiveSubscription();
  
  Future<Subscription> createSubscription({
    required SubscriptionDuration duration,
    required DateTime startDate,
    required List<MealPreference> mealPreferences,
    required DeliverySchedule deliverySchedule,
    required Address deliveryAddress,
    String? paymentMethodId,
  });
  
  Future<Subscription> customizeSubscription(
    String subscriptionId, {
    List<MealPreference>? mealPreferences,
    DeliverySchedule? deliverySchedule,
    Address? deliveryAddress,
  });
  
  Future<String> saveSubscriptionAndGetPaymentUrl(Subscription subscription);
  
  // Order
  Future<Order> createOrder({
    required String subscriptionId,
    required DateTime deliveryDate,
    required Map<String, dynamic> deliveryAddress,
    required List<Map<String, dynamic>> meals,
    String? cloudKitchenId,
    required double totalAmount,
    String? deliveryInstructions,
  });
  
  Future<List<Order>> getUserOrders({
    OrderStatus? status,
    int limit = 10,
    int skip = 0,
  });
  
  Future<Order> getOrderById(String id);
  
  Future<Order> updateOrderStatus(String id, OrderStatus status);
  
  Future<void> cancelOrder(String id);
  
  // Payment
  Future<Payment> processPayment({
    required String orderId,
    required PaymentMethod paymentMethod,
    String? couponCode,
    Map<String, dynamic>? paymentDetails,
  });
  
  Future<Coupon> verifyCoupon(String couponCode, double orderAmount);
  
  Future<List<Payment>> getPaymentHistory({
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 10,
  });
}

class RemoteDataSourceImpl implements RemoteDataSource {
  // User methods
  @override
  Future<User> registerUser({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
    required Address address,
    List<DietaryPreference>? dietaryPreferences,
    List<String>? allergies,
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Check if user already exists
    final existingUser = MockData.users.where((user) => user.email == email).firstOrNull;
    if (existingUser != null) {
      throw ServerException();
    }
    
    // Create new user
    final newUser = User(
      id: 'usr${MockData.users.length + 1}',
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      address: address,
      dietaryPreferences: dietaryPreferences,
      allergies: allergies,
      role: UserRole.user,
      createdAt: DateTime.now(),
    );
    
    // In a real app, you would add this to the database
    // For mock, we'll just return it
    return newUser;
  }

  @override
  Future<User> loginUser(String email, String password) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Find user with matching email
    final user = MockData.users.where((user) => user.email == email).firstOrNull;
    
    if (user == null) {
      throw ServerException();
    }
    
    // In a real app, you would check password hash
    // For mock, we'll just return the user
    return user;
  }

  @override
  Future<User> updateUserProfile({
    String? firstName,
    String? lastName,
    String? phone,
    Address? address,
    List<DietaryPreference>? dietaryPreferences,
    List<String>? allergies,
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // For mock purposes, we'll just use the first user from our mock data
    final user = MockData.users.first;
    
    // Create updated user
    final updatedUser = User(
      id: user.id,
      firstName: firstName ?? user.firstName,
      lastName: lastName ?? user.lastName,
      email: user.email,
      phone: phone ?? user.phone,
      address: address ?? user.address,
      dietaryPreferences: dietaryPreferences ?? user.dietaryPreferences,
      allergies: allergies ?? user.allergies,
      role: user.role,
      createdAt: user.createdAt,
      updatedAt: DateTime.now(),
    );
    
    return updatedUser;
  }

  @override
  Future<bool> updatePassword(String currentPassword, String newPassword) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // For mock purposes, always return success
    return true;
  }

  @override
  Future<Address> addUserAddress(Address address) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // For mock purposes, just return the address
    return address;
  }

  @override
  Future<List<Address>> getUserAddresses() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Return mock addresses
    return MockData.addresses;
  }

  // Dish methods
  @override
  Future<List<Dish>> getDishes({
    FoodCategory? category,
    DietaryPreference? dietaryPreference,
    double? minPrice,
    double? maxPrice,
    int limit = 10,
    int skip = 0,
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Filter dishes based on parameters
    var filteredDishes = MockData.dishes;
    
    if (category != null) {
      filteredDishes = filteredDishes.where((dish) => dish.category == category).toList();
    }
    
    if (dietaryPreference != null) {
      filteredDishes = filteredDishes.where((dish) => dish.dietaryPreferences.contains(dietaryPreference)).toList();
    }
    
    if (minPrice != null) {
      filteredDishes = filteredDishes.where((dish) => dish.price >= minPrice).toList();
    }
    
    if (maxPrice != null) {
      filteredDishes = filteredDishes.where((dish) => dish.price <= maxPrice).toList();
    }
    
    // Apply pagination
    final startIndex = skip;
    final endIndex = min(skip + limit, filteredDishes.length);
    
    if (startIndex >= filteredDishes.length) {
      return [];
    }
    
    return filteredDishes.sublist(startIndex, endIndex);
  }

  @override
  Future<Dish> getDishById(String id) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Find dish with matching ID
    final dish = MockData.dishes.where((dish) => dish.id == id).firstOrNull;
    
    if (dish == null) {
      throw ServerException();
    }
    
    return dish;
  }

  @override
  Future<List<Dish>> searchDishes(String query) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Search dishes by name or description
    final lowercaseQuery = query.toLowerCase();
    
    return MockData.dishes.where((dish) {
      return dish.name.toLowerCase().contains(lowercaseQuery) ||
             dish.description.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  @override
  Future<List<Dish>> getDishesByIds(List<String> ids) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Find dishes with matching IDs
    return MockData.dishes.where((dish) => ids.contains(dish.id)).toList();
  }

  // Meal methods
  @override
  Future<List<Meal>> getMeals({
    DietaryPreference? dietaryPreference,
    double? minPrice,
    double? maxPrice,
    int limit = 10,
    int skip = 0,
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Filter meals based on parameters
    var filteredMeals = MockData.meals;
    
    if (dietaryPreference != null) {
      filteredMeals = filteredMeals.where((meal) => meal.dietaryPreferences.contains(dietaryPreference)).toList();
    }
    
    if (minPrice != null) {
      filteredMeals = filteredMeals.where((meal) => meal.price >= minPrice).toList();
    }
    
    if (maxPrice != null) {
      filteredMeals = filteredMeals.where((meal) => meal.price <= maxPrice).toList();
    }
    
    // Apply pagination
    final startIndex = skip;
    final endIndex = min(skip + limit, filteredMeals.length);
    
    if (startIndex >= filteredMeals.length) {
      return [];
    }
    
    return filteredMeals.sublist(startIndex, endIndex);
  }

  @override
  Future<Meal> getMealById(String id) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Find meal with matching ID
    final meal = MockData.meals.where((meal) => meal.id == id).firstOrNull;
    
    if (meal == null) {
      throw ServerException();
    }
    
    return meal;
  }

  @override
  Future<List<Meal>> searchMeals(String query) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Search meals by name or description
    final lowercaseQuery = query.toLowerCase();
    
    return MockData.meals.where((meal) {
      return meal.name.toLowerCase().contains(lowercaseQuery) ||
             meal.description.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  @override
  Future<List<Meal>> getMealsByDietaryPreference(DietaryPreference preference) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Filter meals by dietary preference
    return MockData.meals.where((meal) => meal.dietaryPreferences.contains(preference)).toList();
  }

  // Subscription methods
  @override
  Future<List<Subscription>> getAvailableSubscriptions() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Return all subscriptions for mock data
    return MockData.subscriptions;
  }

  @override
  Future<Subscription?> getActiveSubscription() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Return the first active subscription (if any)
    return MockData.subscriptions
        .where((sub) => sub.status == SubscriptionStatus.active)
        .firstOrNull;
  }

  @override
  Future<Subscription> createSubscription({
    required SubscriptionDuration duration,
    required DateTime startDate,
    required List<MealPreference> mealPreferences,
    required DeliverySchedule deliverySchedule,
    required Address deliveryAddress,
    String? paymentMethodId,
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Calculate end date based on duration
    final int durationDays;
    switch (duration) {
      case SubscriptionDuration.sevenDays:
        durationDays = 7;
        break;
      case SubscriptionDuration.fourteenDays:
        durationDays = 14;
        break;
      case SubscriptionDuration.twentyEightDays:
        durationDays = 28;
        break;
      case SubscriptionDuration.monthly:
        durationDays = 30;
        break;
      case SubscriptionDuration.quarterly:
        durationDays = 90;
        break;
      case SubscriptionDuration.halfYearly:
        durationDays = 180;
        break;
      case SubscriptionDuration.yearly:
        durationDays = 365;
        break;
    }
    
    final endDate = startDate.add(Duration(days: durationDays));
    
    // Calculate base price (simplified)
    final basePrice = 250.0 * durationDays; // Assuming 250 per day
    
    // Create new subscription
    final newSubscription = Subscription(
      id: 'sub${MockData.subscriptions.length + 1}',
      userId: MockData.users.first.id, // Use first user for mock
      duration: duration,
      startDate: startDate,
      endDate: endDate,
      status: SubscriptionStatus.active,
      basePrice: basePrice,
      totalPrice: basePrice, // Same as base price for now
      isCustomized: false,
      mealPreferences: mealPreferences,
      deliverySchedule: deliverySchedule,
      deliveryAddress: deliveryAddress,
      paymentMethodId: paymentMethodId,
      createdAt: DateTime.now(),
    );
    
    return newSubscription;
  }

  @override
  Future<Subscription> customizeSubscription(
    String subscriptionId, {
    List<MealPreference>? mealPreferences,
    DeliverySchedule? deliverySchedule,
    Address? deliveryAddress,
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Find subscription with matching ID
    final subscription = MockData.subscriptions
        .where((sub) => sub.id == subscriptionId)
        .firstOrNull;
    
    if (subscription == null) {
      throw ServerException();
    }
    
    // Create customized subscription with additional price
    final customizedSubscription = Subscription(
      id: subscription.id,
      userId: subscription.userId,
      duration: subscription.duration,
      startDate: subscription.startDate,
      endDate: subscription.endDate,
      status: subscription.status,
      basePrice: subscription.basePrice,
      totalPrice: subscription.basePrice * 1.1, // 10% more for customization
      isCustomized: true,
      mealPreferences: mealPreferences ?? subscription.mealPreferences,
      deliverySchedule: deliverySchedule ?? subscription.deliverySchedule,
      deliveryAddress: deliveryAddress ?? subscription.deliveryAddress,
      paymentMethodId: subscription.paymentMethodId,
      createdAt: subscription.createdAt,
      updatedAt: DateTime.now(),
    );
    
    return customizedSubscription;
  }

  @override
  Future<String> saveSubscriptionAndGetPaymentUrl(Subscription subscription) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Return mock payment URL
    return 'https://mockpayment.com/pay/${subscription.id}';
  }

  // Order methods
  @override
  Future<Order> createOrder({
    required String subscriptionId,
    required DateTime deliveryDate,
    required Map<String, dynamic> deliveryAddress,
    required List<Map<String, dynamic>> meals,
    String? cloudKitchenId,
    required double totalAmount,
    String? deliveryInstructions,
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Convert delivery address map to Address entity
    final address = Address(
      street: deliveryAddress['street'],
      city: deliveryAddress['city'],
      state: deliveryAddress['state'],
      zipCode: deliveryAddress['zipCode'],
      country: deliveryAddress['country'],
      coordinates: deliveryAddress['coordinates'] != null
          ? Coordinates(
              latitude: deliveryAddress['coordinates']['latitude'],
              longitude: deliveryAddress['coordinates']['longitude'],
            )
          : null,
    );
    
    // Convert meals map to OrderedMeal list
    final orderedMeals = meals.map((mealMap) {
      return OrderedMeal(
        mealType: mealMap['mealType'],
        dietPreference: mealMap['dietPreference'],
        quantity: mealMap['quantity'],
      );
    }).toList();
    
    // Generate order number
    final orderNumber = 'ORD-${DateTime.now().millisecondsSinceEpoch}';
    
    // Create new order
    final newOrder = Order(
      id: 'ord${MockData.orders.length + 1}',
      orderNumber: orderNumber,
      userId: MockData.users.first.id, // Use first user for mock
      subscriptionId: subscriptionId,
      deliveryDate: deliveryDate,
      deliveryAddress: address,
      cloudKitchenId: cloudKitchenId,
      status: OrderStatus.pending,
      paymentStatus: PaymentStatus.pending,
      totalAmount: totalAmount,
      meals: orderedMeals,
      deliveryInstructions: deliveryInstructions,
      createdAt: DateTime.now(),
    );
    
    return newOrder;
  }

  @override
  Future<List<Order>> getUserOrders({
    OrderStatus? status,
    int limit = 10,
    int skip = 0,
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Filter orders based on status
    var filteredOrders = MockData.orders;
    
    if (status != null) {
      filteredOrders = filteredOrders.where((order) => order.status == status).toList();
    }
    
    // Apply pagination
    final startIndex = skip;
    final endIndex = min(skip + limit, filteredOrders.length);
    
    if (startIndex >= filteredOrders.length) {
      return [];
    }
    
    return filteredOrders.sublist(startIndex, endIndex);
  }

  @override
  Future<Order> getOrderById(String id) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Find order with matching ID
    final order = MockData.orders.where((order) => order.id == id).firstOrNull;
    
    if (order == null) {
      throw ServerException();
    }
    
    return order;
  }

  @override
  Future<Order> updateOrderStatus(String id, OrderStatus status) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Find order with matching ID
    final order = MockData.orders.where((order) => order.id == id).firstOrNull;
    
    if (order == null) {
      throw ServerException();
    }
    
    // Create updated order with new status
    final updatedOrder = Order(
      id: order.id,
      orderNumber: order.orderNumber,
      userId: order.userId,
      subscriptionId: order.subscriptionId,
      deliveryDate: order.deliveryDate,
      deliveryAddress: order.deliveryAddress,
      cloudKitchenId: order.cloudKitchenId,
      status: status,
      paymentStatus: order.paymentStatus,
      totalAmount: order.totalAmount,
      meals: order.meals,
      deliveryInstructions: order.deliveryInstructions,
      createdAt: order.createdAt,
      updatedAt: DateTime.now(),
    );
    
    return updatedOrder;
  }

  @override
  Future<void> cancelOrder(String id) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Find order with matching ID
    final order = MockData.orders.where((order) => order.id == id).firstOrNull;
    
    if (order == null) {
      throw ServerException();
    }
    
    // In a real app, you would update the order status in the database
    // For mock, we'll just return
    return;
  }

  // Payment methods
  @override
  Future<Payment> processPayment({
    required String orderId,
    required PaymentMethod paymentMethod,
    String? couponCode,
    Map<String, dynamic>? paymentDetails,
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Find order with matching ID
    final order = MockData.orders.where((order) => order.id == orderId).firstOrNull;
    
    if (order == null) {
      throw ServerException();
    }
    
    // Generate transaction ID
    final transactionId = 'txn-${DateTime.now().millisecondsSinceEpoch}';
    
    // Calculate final amount (apply coupon if provided)
    double finalAmount = order.totalAmount;
    if (couponCode != null) {
      final coupon = MockData.coupons.where((c) => c.code == couponCode).firstOrNull;
      if (coupon != null) {
        if (coupon.discountType == 'percentage') {
          final discountAmount = (coupon.discountValue / 100) * finalAmount;
          finalAmount -= discountAmount;
        } else { // fixed amount
          finalAmount -= coupon.discountValue;
        }
        finalAmount = max(0, finalAmount); // Ensure amount doesn't go below 0
      }
    }
    
    // Create new payment
    final newPayment = Payment(
      id: 'pay${MockData.payments.length + 1}',
      orderId: orderId,
      userId: order.userId,
      amount: finalAmount,
      currency: 'INR',
      paymentMethod: paymentMethod,
      status: PaymentStatus.paid, // Assume payment is successful for mock
      transactionId: transactionId,
      paymentGatewayResponse: {'status': 'success'},
      createdAt: DateTime.now(),
    );
    
    return newPayment;
  }

  @override
  Future<Coupon> verifyCoupon(String couponCode, double orderAmount) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Find coupon with matching code
    final coupon = MockData.coupons.where((c) => c.code == couponCode).firstOrNull;
    
    if (coupon == null) {
      throw ServerException();
    }
    
    // Check if coupon is active
    if (!coupon.isActive) {
      throw ServerException();
    }
    
    // Check if coupon is valid based on dates
    final now = DateTime.now();
    if (now.isBefore(coupon.validFrom) || now.isAfter(coupon.validUntil)) {
      throw ServerException();
    }
    
    // Check if order amount meets minimum requirement
    if (coupon.minOrderAmount != null && orderAmount < coupon.minOrderAmount!) {
      throw ServerException();
    }
    
    return coupon;
  }

  @override
  Future<List<Payment>> getPaymentHistory({
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 10,
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Filter payments based on date range
    var filteredPayments = MockData.payments;
    
    if (startDate != null) {
      filteredPayments = filteredPayments.where((payment) => payment.createdAt.isAfter(startDate)).toList();
    }
    
    if (endDate != null) {
      filteredPayments = filteredPayments.where((payment) => payment.createdAt.isBefore(endDate)).toList();
    }
    
    // Apply pagination
    final skip = (page - 1) * limit;
    final startIndex = skip;
    final endIndex = min(skip + limit, filteredPayments.length);
    
    if (startIndex >= filteredPayments.length) {
      return [];
    }
    
    return filteredPayments.sublist(startIndex, endIndex);
  }
}