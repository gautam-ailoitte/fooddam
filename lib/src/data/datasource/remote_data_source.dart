import 'package:foodam/core/errors/execption.dart';
import 'package:foodam/core/network/api_client.dart';
import 'package:foodam/mock_data.dart';
import 'package:foodam/src/data/models/meal_model.dart';
import 'package:foodam/src/data/models/plan_model.dart';
import 'package:foodam/src/data/models/thali_model.dart';
import 'package:foodam/src/data/models/user_model.dart';
import 'package:foodam/src/domain/entities/meal_entity.dart';
import 'package:foodam/src/domain/entities/thali_entity.dart';


abstract class RemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<bool> checkSubscriptionStatus();
  Future<List<MealModel>> getMealOptions(MealType type);
  Future<List<ThaliModel>> getThaliOptions(MealType type);
  Future<List<PlanModel>> getAvailablePlans();
  Future<PlanModel?> getActivePlan();
  Future<PlanModel> createPlan(PlanModel plan);
  Future<String> savePlanAndGetPaymentUrl(PlanModel plan);
  
  // New methods
  Future<PlanModel> resetPlanToDefaults(String planId);
  Future<Map<MealType, ThaliModel>> getDefaultThaliConfiguration();
  Future<void> synchronizeDraftPlan(PlanModel plan);
  Future<List<PlanModel>> getRecommendedPlans(UserModel user);
  Future<ThaliModel> getDefaultThali(MealType type, ThaliType preferredType);
  Future<void> createPlanFromTemplate(PlanModel template, bool setAsDraft);
}

class RemoteDataSourceImpl implements RemoteDataSource {
  final ApiClient client;

  RemoteDataSourceImpl({required this.client});

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      // Simulate API delay
      await Future.delayed(Duration(milliseconds: 800));
      
      // For demo purposes: simple credentials check
      if (email == 'user@example.com' && password == 'password123') {
        return MockData.getMockUser();
      } else {
        throw ServerException();
      }
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<bool> checkSubscriptionStatus() async {
    try {
      // Simulate API delay
      await Future.delayed(Duration(milliseconds: 600));
      
      // In a real app, this would check with the server
      // For demo purposes, return the mock user's subscription status
      final user = MockData.getMockUser();
      return user.hasActivePlan;
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<List<MealModel>> getMealOptions(MealType type) async {
    try {
      // Simulate API delay
      await Future.delayed(Duration(milliseconds: 700));
      
      // Return mock meals based on meal type
      switch (type) {
        case MealType.breakfast:
          return MockData.getMockBreakfastMeals();
        case MealType.lunch:
          return MockData.getMockLunchMeals();
        case MealType.dinner:
          return MockData.getMockDinnerMeals();
        }
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<List<ThaliModel>> getThaliOptions(MealType type) async {
    try {
      // Simulate API delay
      await Future.delayed(Duration(milliseconds: 700));
      
      // Return mock thalis based on meal type
      switch (type) {
        case MealType.breakfast:
          return MockData.getMockBreakfastThalis();
        case MealType.lunch:
          return MockData.getMockLunchThalis();
        case MealType.dinner:
          return MockData.getMockDinnerThalis();
        }
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<List<PlanModel>> getAvailablePlans() async {
    try {
      // Simulate API delay
      await Future.delayed(Duration(milliseconds: 800));
      
      return MockData.getMockPlanTemplates();
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<PlanModel?> getActivePlan() async {
    try {
      // Simulate API delay
      await Future.delayed(Duration(milliseconds: 700));
      
      return MockData.getMockActivePlan();
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<PlanModel> createPlan(PlanModel plan) async {
    try {
      // Simulate API delay
      await Future.delayed(Duration(milliseconds: 900));
      
      // In a real app, this would send the plan to the server
      // For demo purposes, just return the plan with a new ID
      return PlanModel.fromJson(plan.toJson()).copyWith(
        id: 'new_${plan.id}',
      );
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<String> savePlanAndGetPaymentUrl(PlanModel plan) async {
    try {
      // Simulate API delay
      await Future.delayed(Duration(milliseconds: 1000));
      
      // In a real app, this would send the plan to the server and get a payment URL
      // For demo purposes, return a fake payment URL
      return 'https://payment-gateway.example.com/checkout/${plan.id}';
    } catch (e) {
      throw ServerException();
    }
  }
  
  // New method implementations
  
  @override
  Future<PlanModel> resetPlanToDefaults(String planId) async {
    try {
      // Simulate API delay
      await Future.delayed(Duration(milliseconds: 800));
      
      // First get the plan
      final plans = await getAvailablePlans();
      final planToReset = plans.firstWhere(
        (p) => p.id == planId,
        orElse: () => plans.first,
      );
      
      // Use MockData helper to reset
      return MockData.resetPlanToDefaults(planToReset);
    } catch (e) {
      throw ServerException();
    }
  }
  
  @override
  Future<Map<MealType, ThaliModel>> getDefaultThaliConfiguration() async {
    try {
      // Simulate API delay
      await Future.delayed(Duration(milliseconds: 700));
      
      // Get default thalis for each meal type
      final breakfast = (await getThaliOptions(MealType.breakfast))[0];
      final lunch = (await getThaliOptions(MealType.lunch))[0];
      final dinner = (await getThaliOptions(MealType.dinner))[0];
      
      return {
        MealType.breakfast: breakfast,
        MealType.lunch: lunch,
        MealType.dinner: dinner,
      };
    } catch (e) {
      throw ServerException();
    }
  }
  
  @override
  Future<void> synchronizeDraftPlan(PlanModel plan) async {
    try {
      // Simulate API delay
      await Future.delayed(Duration(milliseconds: 800));
      
      // In a real app, this would sync the draft plan with the server
      // For demo purposes, we'll just wait
      return;
    } catch (e) {
      throw ServerException();
    }
  }
  
  @override
  Future<List<PlanModel>> getRecommendedPlans(UserModel user) async {
    try {
      // Simulate API delay
      await Future.delayed(Duration(milliseconds: 900));
      
      // Use MockData to get recommendations
      return MockData.getRecommendedPlans(user);
    } catch (e) {
      throw ServerException();
    }
  }
  
  @override
  Future<ThaliModel> getDefaultThali(MealType type, ThaliType preferredType) async {
    try {
      // Simulate API delay
      await Future.delayed(Duration(milliseconds: 600));
      
      // Get all thali options for this meal type
      final thalis = await getThaliOptions(type);
      
      // Find the one matching the preferred type
      return thalis.firstWhere(
        (thali) => thali.type == preferredType,
        orElse: () => thalis.first, // Default to first if not found
      );
    } catch (e) {
      throw ServerException();
    }
  }
  
  @override
  Future<void> createPlanFromTemplate(PlanModel template, bool setAsDraft) async {
    try {
      // Simulate API delay
      await Future.delayed(Duration(milliseconds: 850));
      
      // In a real app, this would create a new plan from the template
      // For demo purposes, we'll just wait
      return;
    } catch (e) {
      throw ServerException();
    }
  }
}
// lib/data/datasource/local_data_source.dart

// lib/src/data/datasource/local_data_source.dart


