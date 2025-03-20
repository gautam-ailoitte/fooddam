import 'dart:convert';

import 'package:foodam/core/constants/app_constants.dart';
import 'package:foodam/core/errors/execption.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/core/service/storage_service.dart';
import 'package:foodam/mock_data.dart';
import 'package:foodam/src/data/model/meal_model.dart';
import 'package:foodam/src/data/model/meal_order_model.dart';
import 'package:foodam/src/data/model/plan_model.dart';
import 'package:foodam/src/data/model/subscription_model.dart';
import 'package:foodam/src/data/model/user_model.dart';

abstract class LocalDataSource {
  // Auth
  Future<void> cacheToken(String token);
  Future<String?> getToken();
  Future<void> clearToken();
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getUser();

  // Subscriptions
  Future<void> cacheActiveSubscriptions(List<SubscriptionModel> subscriptions);
  Future<List<SubscriptionModel>?> getActiveSubscriptions();
  Future<void> cacheSubscriptionPlans(List<SubscriptionPlanModel> plans);
  Future<List<SubscriptionPlanModel>?> getSubscriptionPlans();

  // Meals
  Future<void> cacheAvailableMeals(List<MealModel> meals);
  Future<List<MealModel>?> getAvailableMeals();
  Future<void> cacheMeal(MealModel meal);
  Future<MealModel?> getMeal(String mealId);

  // Meal Orders
  Future<void> cacheTodayMealOrders(List<MealOrderModel> orders);
  Future<List<MealOrderModel>?> getTodayMealOrders();

  // Draft Plan
  Future<void> cacheDraftMealPlanSelection(Map<String, dynamic> selection);
  Future<Map<String, dynamic>?> getDraftMealPlanSelection();
  Future<void> clearDraftMealPlanSelection();
}


class LocalDataSourceImpl implements LocalDataSource {
  final StorageService storageService;
  final LoggerService _logger = LoggerService();
  
  // Keys
  static const String _tokenKey = AppConstants.tokenKey;
  static const String _userKey = AppConstants.userKey;
  static const String _activeSubscriptionsKey = 'CACHED_ACTIVE_SUBSCRIPTIONS';
  static const String _subscriptionPlansKey = 'CACHED_SUBSCRIPTION_PLANS';
  static const String _availableMealsKey = 'CACHED_AVAILABLE_MEALS';
  static const String _mealPrefix = 'CACHED_MEAL_';
  static const String _todayMealOrdersKey = 'CACHED_TODAY_MEAL_ORDERS';
  static const String _draftMealPlanSelectionKey = 'CACHED_DRAFT_MEAL_PLAN_SELECTION';
  
  // Flag to initialize with mock data - helpful for development
  final bool initWithMockData;

  LocalDataSourceImpl({
    required this.storageService,
    this.initWithMockData = true,
  }) {
    if (initWithMockData) {
      _initializeMockData();
    }
  }
  
  // Initialize storage with mock data for faster development
  Future<void> _initializeMockData() async {
    _logger.d('Initializing local storage with mock data', tag: 'MOCK');
    
    // Only init if data doesn't exist yet
    if (!(await _hasInitializedMockData())) {
      try {
        // Cache token
        await storageService.setString(_tokenKey, MockData.mockToken);
        
        // Cache user
        await storageService.setString(_userKey, json.encode(MockData.currentUser));
        
        // Cache active subscriptions
        final subscriptionsJson = json.encode(MockData.activeSubscriptions);
        await storageService.setString(_activeSubscriptionsKey, subscriptionsJson);
        
        // Cache subscription plans
        final plansJson = json.encode(MockData.subscriptionPlans);
        await storageService.setString(_subscriptionPlansKey, plansJson);
        
        // Cache available meals
        final mealsJson = json.encode(MockData.meals);
        await storageService.setString(_availableMealsKey, mealsJson);
        
        // Cache today's meal orders
        final ordersJson = json.encode(MockData.todayMealOrders);
        await storageService.setString(_todayMealOrdersKey, ordersJson);
        
        // Cache individual meals
        for (var meal in MockData.meals) {
          await storageService.setString(_mealPrefix + meal['id'], json.encode(meal));
        }
        
        // Set flag to indicate mock data was initialized
        await storageService.setBool('MOCK_DATA_INITIALIZED', true);
        
        _logger.d('Mock data initialization completed', tag: 'MOCK');
      } catch (e) {
        _logger.e('Error initializing mock data', error: e, tag: 'MOCK');
      }
    } else {
      _logger.d('Mock data already initialized, skipping', tag: 'MOCK');
    }
  }
  
  Future<bool> _hasInitializedMockData() async {
    return storageService.getBool('MOCK_DATA_INITIALIZED') ?? false;
  }

  @override
  Future<void> cacheToken(String token) async {
    try {
      await storageService.setString(_tokenKey, token);
      _logger.d('Cached token', tag: 'CACHE');
    } catch (e) {
      _logger.e('Error caching token', error: e, tag: 'CACHE');
      throw CacheException();
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      final token = storageService.getString(_tokenKey);
      _logger.d('Retrieved token: ${token != null ? 'exists' : 'null'}', tag: 'CACHE');
      return token;
    } catch (e) {
      _logger.e('Error getting token', error: e, tag: 'CACHE');
      throw CacheException();
    }
  }

  @override
  Future<void> clearToken() async {
    try {
      await storageService.remove(_tokenKey);
      _logger.d('Cleared token', tag: 'CACHE');
    } catch (e) {
      _logger.e('Error clearing token', error: e, tag: 'CACHE');
      throw CacheException();
    }
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      await storageService.setString(_userKey, json.encode(user.toJson()));
      _logger.d('Cached user: ${user.id}', tag: 'CACHE');
    } catch (e) {
      _logger.e('Error caching user', error: e, tag: 'CACHE');
      throw CacheException();
    }
  }

  @override
  Future<UserModel?> getUser() async {
    try {
      final userString = storageService.getString(_userKey);
      if (userString == null) {
        _logger.d('No cached user found', tag: 'CACHE');
        return null;
      }
      
      final userJson = json.decode(userString);
      _logger.d('Retrieved cached user: ${userJson['id']}', tag: 'CACHE');
      return UserModel.fromJson(userJson);
    } catch (e) {
      _logger.e('Error getting cached user', error: e, tag: 'CACHE');
      throw CacheException();
    }
  }

  @override
  Future<void> cacheActiveSubscriptions(List<SubscriptionModel> subscriptions) async {
    try {
      final jsonList = subscriptions.map((sub) => sub.toJson()).toList();
      await storageService.setString(_activeSubscriptionsKey, json.encode(jsonList));
      _logger.d('Cached ${subscriptions.length} active subscriptions', tag: 'CACHE');
    } catch (e) {
      _logger.e('Error caching active subscriptions', error: e, tag: 'CACHE');
      throw CacheException();
    }
  }

  @override
  Future<List<SubscriptionModel>?> getActiveSubscriptions() async {
    try {
      final subsString = storageService.getString(_activeSubscriptionsKey);
      if (subsString == null) {
        _logger.d('No cached active subscriptions found', tag: 'CACHE');
        return null;
      }
      
      final jsonList = json.decode(subsString) as List<dynamic>;
      _logger.d('Retrieved ${jsonList.length} cached active subscriptions', tag: 'CACHE');
      return jsonList.map((json) => SubscriptionModel.fromJson(json)).toList();
    } catch (e) {
      _logger.e('Error getting cached active subscriptions', error: e, tag: 'CACHE');
      throw CacheException();
    }
  }

  @override
  Future<void> cacheSubscriptionPlans(List<SubscriptionPlanModel> plans) async {
    try {
      final jsonList = plans.map((plan) => plan.toJson()).toList();
      await storageService.setString(_subscriptionPlansKey, json.encode(jsonList));
      _logger.d('Cached ${plans.length} subscription plans', tag: 'CACHE');
    } catch (e) {
      _logger.e('Error caching subscription plans', error: e, tag: 'CACHE');
      throw CacheException();
    }
  }

  @override
  Future<List<SubscriptionPlanModel>?> getSubscriptionPlans() async {
    try {
      final plansString = storageService.getString(_subscriptionPlansKey);
      if (plansString == null) {
        _logger.d('No cached subscription plans found', tag: 'CACHE');
        return null;
      }
      
      final jsonList = json.decode(plansString) as List<dynamic>;
      _logger.d('Retrieved ${jsonList.length} cached subscription plans', tag: 'CACHE');
      return jsonList.map((json) => SubscriptionPlanModel.fromJson(json)).toList();
    } catch (e) {
      _logger.e('Error getting cached subscription plans', error: e, tag: 'CACHE');
      throw CacheException();
    }
  }

  @override
  Future<void> cacheAvailableMeals(List<MealModel> meals) async {
    try {
      final jsonList = meals.map((meal) => meal.toJson()).toList();
      await storageService.setString(_availableMealsKey, json.encode(jsonList));
      _logger.d('Cached ${meals.length} available meals', tag: 'CACHE');
    } catch (e) {
      _logger.e('Error caching available meals', error: e, tag: 'CACHE');
      throw CacheException();
    }
  }

  @override
  Future<List<MealModel>?> getAvailableMeals() async {
    try {
      final mealsString = storageService.getString(_availableMealsKey);
      if (mealsString == null) {
        _logger.d('No cached available meals found', tag: 'CACHE');
        return null;
      }
      
      final jsonList = json.decode(mealsString) as List<dynamic>;
      _logger.d('Retrieved ${jsonList.length} cached available meals', tag: 'CACHE');
      return jsonList.map((json) => MealModel.fromJson(json)).toList();
    } catch (e) {
      _logger.e('Error getting cached available meals', error: e, tag: 'CACHE');
      throw CacheException();
    }
  }

  @override
  Future<void> cacheMeal(MealModel meal) async {
    try {
      await storageService.setString(
        _mealPrefix + meal.id,
        json.encode(meal.toJson()),
      );
      _logger.d('Cached meal: ${meal.id}', tag: 'CACHE');
    } catch (e) {
      _logger.e('Error caching meal', error: e, tag: 'CACHE');
      throw CacheException();
    }
  }

  @override
  Future<MealModel?> getMeal(String mealId) async {
    try {
      final mealString = storageService.getString(_mealPrefix + mealId);
      if (mealString == null) {
        _logger.d('No cached meal found for ID: $mealId', tag: 'CACHE');
        return null;
      }
      
      final mealJson = json.decode(mealString);
      _logger.d('Retrieved cached meal: $mealId', tag: 'CACHE');
      return MealModel.fromJson(mealJson);
    } catch (e) {
      _logger.e('Error getting cached meal', error: e, tag: 'CACHE');
      throw CacheException();
    }
  }

  @override
  Future<void> cacheTodayMealOrders(List<MealOrderModel> orders) async {
    try {
      final jsonList = orders.map((order) => order.toJson()).toList();
      await storageService.setString(_todayMealOrdersKey, json.encode(jsonList));
      _logger.d('Cached ${orders.length} today meal orders', tag: 'CACHE');
    } catch (e) {
      _logger.e('Error caching today meal orders', error: e, tag: 'CACHE');
      throw CacheException();
    }
  }

  @override
  Future<List<MealOrderModel>?> getTodayMealOrders() async {
    try {
      final ordersString = storageService.getString(_todayMealOrdersKey);
      if (ordersString == null) {
        _logger.d('No cached today meal orders found', tag: 'CACHE');
        return null;
      }
      
      final jsonList = json.decode(ordersString) as List<dynamic>;
      _logger.d('Retrieved ${jsonList.length} cached today meal orders', tag: 'CACHE');
      return jsonList.map((json) => MealOrderModel.fromJson(json)).toList();
    } catch (e) {
      _logger.e('Error getting cached today meal orders', error: e, tag: 'CACHE');
      throw CacheException();
    }
  }

  @override
  Future<void> cacheDraftMealPlanSelection(Map<String, dynamic> selection) async {
    try {
      await storageService.setString(
        _draftMealPlanSelectionKey, 
        json.encode(selection),
      );
      _logger.d('Cached draft meal plan selection', tag: 'CACHE');
    } catch (e) {
      _logger.e('Error caching draft meal plan selection', error: e, tag: 'CACHE');
      throw CacheException();
    }
  }

  @override
  Future<Map<String, dynamic>?> getDraftMealPlanSelection() async {
    try {
      final selectionString = storageService.getString(_draftMealPlanSelectionKey);
      if (selectionString == null) {
        _logger.d('No cached draft meal plan selection found', tag: 'CACHE');
        return null;
      }
      
      final selection = json.decode(selectionString) as Map<String, dynamic>;
      _logger.d('Retrieved cached draft meal plan selection', tag: 'CACHE');
      return selection;
    } catch (e) {
      _logger.e('Error getting cached draft meal plan selection', error: e, tag: 'CACHE');
      throw CacheException();
    }
  }

  @override
  Future<void> clearDraftMealPlanSelection() async {
    try {
      await storageService.remove(_draftMealPlanSelectionKey);
      _logger.d('Cleared draft meal plan selection', tag: 'CACHE');
    } catch (e) {
      _logger.e('Error clearing draft meal plan selection', error: e, tag: 'CACHE');
      throw CacheException();
    }
  }
}