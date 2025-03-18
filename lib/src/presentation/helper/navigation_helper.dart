// lib/src/presentation/helper/navigation_helper.dart

import 'package:flutter/material.dart';
import 'package:foodam/src/domain/entities/payment_entity.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';
import 'package:foodam/src/presentation/screens/active_plan_screen.dart';
import 'package:foodam/src/presentation/screens/auth/login_screen.dart';
import 'package:foodam/src/presentation/screens/auth/register_screen.dart';
import 'package:foodam/src/presentation/screens/home_screen.dart';
import 'package:foodam/src/presentation/screens/meal_customization_screen.dart';
import 'package:foodam/src/presentation/screens/meal_selection_screen.dart';
import 'package:foodam/src/presentation/screens/order_details_screen.dart';
import 'package:foodam/src/presentation/screens/payment_successful_screen.dart';
import 'package:foodam/src/presentation/screens/payment_summary_screen.dart';
import 'package:foodam/src/presentation/screens/plan_details_screen.dart';
import 'package:foodam/src/presentation/screens/plan_selection_screen.dart';
import 'package:foodam/src/presentation/screens/thali_selection_screen.dart';
import 'package:foodam/src/presentation/screens/user_profile_screen.dart';

class NavigationHelper {
  // Private constructor to prevent instantiation
  NavigationHelper._();
  
  // Authentication
  
  static void navigateToLogin(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false, // Remove all previous routes
    );
  }
  
  static void navigateToRegister(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }
  
  // Main Navigation
  
  static void navigateToHome(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false, // Remove all previous routes
    );
  }
  
  static void navigateToUserProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const UserProfileScreen()),
    );
  }
  
  // Plan Navigation
  
  static void navigateToPlanSelection(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PlanSelectionScreen()),
    );
  }
  
  static void navigateToPlanDetails(BuildContext context, Subscription subscription) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PlanDetailsScreen(subscription: subscription)),
    );
  }
  
  static void navigateToActivePlan(BuildContext context, Subscription subscription) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ActivePlanScreen(subscription: subscription)),
    );
  }
  
  // Meal Navigation
  
  static void navigateToMealSelection(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MealSelectionScreen()),
    );
  }
  
  static void navigateToMealCustomization(
    BuildContext context, 
    String mealId, 
    String mealType
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MealCustomizationScreen(
          mealId: mealId,
          mealType: mealType,
        ),
      ),
    );
  }
  
  static void navigateToThaliSelection(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ThaliSelectionScreen()),
    );
  }
  
  // Order Navigation
  
  static void navigateToOrderDetails(BuildContext context, String orderId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => OrderDetailsScreen(orderId: orderId)),
    );
  }
  
  // Payment Navigation
  
  static void navigateToPaymentSummary(BuildContext context, Subscription subscription) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PaymentSummaryScreen(subscription: subscription)),
    );
  }
  
  static void navigateToPaymentSuccessful(
    BuildContext context, 
    Payment payment, 
    Subscription subscription
  ) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentSuccessfulScreen(
          payment: payment,
          subscription: subscription,
        ),
      ),
      (route) => false, // Remove all previous routes
    );
  }
  
  // Helper for push-and-remove-until pattern
  static void navigateAndRemoveUntil(BuildContext context, Widget screen) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => screen),
      (route) => false,
    );
  }
  
  // Helper for push-replacement pattern
  static void navigateAndReplace(BuildContext context, Widget screen) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }
}