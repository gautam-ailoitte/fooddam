// lib/core/constants/string_constants.dart
class StringConstants {
  // Auth
  static const String login = 'Login';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String forgotPassword = 'Forgot Password?';
  static const String loginFailed = 'Login failed. Please check your credentials.';
  static const String logout = 'Log Out';
  static const String logoutConfirmation = 'Are you sure you want to log out?';
  static const String cancel = 'Cancel';
  
  // Home
  static const String activePlan = 'Active Plan';
  static const String noPlan = 'No active plan found';
  static const String selectPlan = 'Select a Plan';
  static const String startingApp = 'Starting app...';
  static const String todayMeals = "Today's Meals";
  static const String viewCompleteMenu = 'View Complete Menu';
  static const String hasPlan = 'Has Plan';
  static const String resumeDraft = 'Resume Draft Plan';
  static const String demoLogin = 'Demo Login';
  static const String appTitle = 'Meal Subscription';
  static const String noSubscription = 'Subscribe to a meal plan to get delicious food delivered to you every day.';
  
  // Plans
  static const String availablePlans = 'Available Plans';
  static const String customizePlan = 'Customize Plan';
  static const String planDetails = 'Plan Details';
  static const String proceedToPayment = 'Proceed to Payment';
  static const String chooseAPlan = 'Choose a Plan';
  static const String planDuration = 'Plan Duration';
  static const String selectMealType = 'Select Meal Type';
  static const String noPlansAvailable = 'No plans available';
  static const String noPlansForDuration = 'No plans available for the selected duration.';
  static const String clearDraft = 'Clear Draft';
  static const String noDraftToClear = 'No draft plan to clear';
  static const String clearDraftConfirmation = 'This will remove any saved draft plans. Continue?';
  static const String replaceDraftConfirmation = 'You already have a draft plan. Starting a new plan will replace it. Continue?';
  static const String replace = 'Replace';
  static const String clear = 'Clear';
  static const String continueWithSelectedPlan = 'Continue with Selected Plan';
  static const String totalAmount = 'Total Amount';
  static const String resetPlan = 'Reset Plan';
  static const String resetPlanConfirmation = 'This will reset all your customizations to default. Continue?';
  static const String saveDraft = 'Save Draft';
  static const String discardCustomizations = 'Discard Customizations?';
  static const String discardCustomizationsMessage = 'Going back will discard your customizations. Do you want to save them as a draft instead?';
  static const String discard = 'Discard';
  static const String save = 'Save Draft';
  
  // Meals
  static const String breakfast = 'Breakfast';
  static const String lunch = 'Lunch';
  static const String dinner = 'Dinner';
  static const String customizeThali = 'Customize Thali';
  static const String noMealSelected = 'No meal selected';
  static const String mealItems = 'Meal Items:';
  static const String price = 'Price: ';
  static const String dailyTotal = 'Daily Total';
  static const String selectDay = 'Select Day';
  
  // Thali
  static const String normalThali = 'Normal Thali';
  static const String nonVegThali = 'Non-Veg Thali';
  static const String deluxeThali = 'Deluxe Thali';
  static const String customize = 'Customize';
  static const String includes = 'Includes:';
  static const String selectThaliFor = 'Select a Thali for';
  static const String selectThaliMessage = 'You can choose from the following options or customize them';
  
  // Meal Customization
  static const String basePrice = 'Base Price:';
  static const String additionalPrice = 'Additional Price:';
  static const String totalPrice = 'Total Price:';
  static const String maxSelectionMessage = 'You can select up to';
  static const String selectedItems = 'Selected:';
  static const String availableItems = 'Available Items';
  static const String saveChanges = 'Save Changes';
  static const String done = 'Done';
  static const String resetSelections = 'Reset Selections';
  static const String selectionsReset = 'Selections reset to original';
  static const String pleaseSelectItems = 'Please select at least one item';
  static const String maxSelectionReached = 'Maximum selection reached';
  static const String moreItems = 'more items';
  
  // Days
  static const String monday = 'Monday';
  static const String tuesday = 'Tuesday';
  static const String wednesday = 'Wednesday';
  static const String thursday = 'Thursday';
  static const String friday = 'Friday';
  static const String saturday = 'Saturday';
  static const String sunday = 'Sunday';
  
  // Payment
  static const String orderSummary = 'Order Summary';
  static const String planDetailsTitle = 'Plan Details';
  static const String priceDetails = 'Price Details';
  static const String dailyBreakdown = 'Daily Breakdown';
  static const String paymentMethod = 'Payment Method';
  static const String completeOrder = 'Complete Order';
  static const String paymentSuccessful = 'Payment Successful!';
  static const String paymentSuccessMessage = 'Your meal plan has been activated successfully.';
  static const String goToHome = 'Go to Home';
  static const String planName = 'Plan Name';
  static const String planType = 'Plan Type';
  static const String duration = 'Duration';
  static const String totalMeals = 'Total Meals';
  static const String customizationCharges = 'Customization Charges';
  static const String discount = 'Discount';
  
  // Draft Plan
  static const String draftPlanFound = 'Draft Plan Found';
  static const String draftPlanFoundMessage = 'You have a saved draft plan. What would you like to do?';
  static const String startNewPlan = 'Start New Plan';
  static const String resumeDraftPlan = 'Resume Draft';
  static const String draftSaved = 'Draft saved';
  static const String progressSaved = 'Progress saved';
  static const String youHaveDraftPlan = 'You have a draft plan';
  static const String tapToResume = 'Tap to resume customization';
  
  // Errors
  static const String networkError = 'Network Error. Please check your connection.';
  static const String serverError = 'Server Error. Please try again later.';
  static const String unexpectedError = 'Unexpected Error. Please try again.';
  static const String noPlanToCustomize = 'Error: No plan to customize';
  static const String noCustomPlan = 'Error: No plan being customized';
  static const String routeNotFound = 'Route not found';
  static const String retry = 'Retry';
  static const String goBack = 'Go Back';
  
  // Plan Details
  static const String mealsFor = 'Meals for';
  static const String vegetarianPlan = 'Vegetarian Plan';
  static const String nonVegetarianPlan = 'Non-Vegetarian Plan';
  static const String vegetarian = 'Vegetarian';
  static const String nonVegetarian = 'Non-Vegetarian';
  static const String startDate = 'Start Date:';
  static const String endDate = 'End Date:';
  static const String noDateSet = 'No dates set';
  static const String planExpired = 'Plan has expired';
  static const String lastDayPlan = 'Last day of plan';
  static const String daysRemaining = 'days remaining';
  static const String dailyBreakfastLunchDinner = 'Daily: Breakfast, Lunch & Dinner';
  static const String startingAt = 'Starting at';
  static const String customizable = 'Customizable';
  static const String loadingPlans = 'Loading available plans...';
  static const String loadingSubscription = 'Loading subscription data...';
}