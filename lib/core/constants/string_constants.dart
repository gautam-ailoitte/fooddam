// lib/core/constants/string_constants.dart
class StringConstants {
  // App
  static const String appTitle = 'TiffinHub';
  static const String tagline = 'Delicious meals delivered to your doorstep';
  static const String ok = 'OK';
  static const String cancel = 'Cancel';
  static const String retry = 'Retry';
  static const String save = 'Save';
  static const String reset = 'Reset';
  static const String edit = 'Edit';
  static const String delete = 'Delete';
  static const String confirm = 'Confirm';
  static const String startingApp = 'Starting app...';
  static const String continueText = 'Continue';
  static const String skip = 'Skip';
  static const String select = 'Select';
  static const String back = 'Back';
  static const String next = 'Next';
  static const String apply = 'Apply';
  static const String completed = 'Completed';
  static const String day = 'day';
  static const String days = 'days';
  static const String expired = 'Expired';
  static const String active = 'Active';
  static const String paused = 'Paused';
  static const String cancelled = 'Cancelled';

  // Auth
  static const String login = 'Login';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String forgotPassword = 'Forgot Password?';
  static const String loginFailed = 'Login failed. Please check your credentials.';
  static const String logout = 'Log Out';
  static const String logoutConfirmation = 'Are you sure you want to log out?';
  static const String demoLogin = 'Demo Login';
  static const String loggingIn = 'Logging in...';

  // Validators
  static const String emailRequired = 'Please enter your email';
  static const String invalidEmail = 'Please enter a valid email';
  static const String passwordRequired = 'Please enter your password';
  static const String passwordTooShort = 'Password must be at least 6 characters';
  static const String fieldRequired = 'This field is required';
  static const String isRequired = 'is required';
  static const String invalidNumber = 'Please enter a valid number';
  static const String phoneRequired = 'Please enter your phone number';
  static const String invalidPhone = 'Please enter a valid 10-digit phone number';

  // Home
  static const String activePlan = 'Active Plan';
  static const String noPlan = 'No active plan found';
  static const String selectPlan = 'Select a Plan';
  static const String todayMeals = "Today's Meals";
  static const String viewCompleteMenu = 'View Complete Menu';
  static const String hasPlan = 'Has Plan';
  static const String resumeDraft = 'Resume Draft Plan';
  static const String noSubscription = 'Subscribe to a meal plan to get delicious food delivered to you every day.';
  static const String draftPlanAvailable = 'You have a draft plan';
  static const String tapToResume = 'Tap to resume customization';
  static const String loadingSubscriptionData = 'Loading subscription data...';

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
  static const String draftSaved = 'Draft saved';
  static const String progressSaved = 'Progress saved';
  static const String distributeMeals = 'Distribute Meals';
  static const String allocateYourMeals = 'Allocate Your Meals';
  static const String distributeMealsMessage = 'Distribute your meals across breakfast, lunch, and dinner.';
  static const String allocatedMeals = 'Allocated Meals';
  static const String distributeByDate = 'Distribute By Date';
  static const String distributeByDateMessage = 'Select dates for each meal type based on your allocation.';
  static const String selectedDates = 'Selected Dates';
  static const String continueToMealSelection = 'Continue to Meal Selection';
  static const String pleaseDistributeAllMeals = 'Please distribute all allocated meals across dates';
  static const String cannotAllocateMoreThanTotal = 'Cannot allocate more than total meals';

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
  static const String mealsFor = 'Meals for';
  static const String breakfastTime = '7:00 AM - 9:00 AM';
  static const String lunchTime = '12:00 PM - 2:00 PM';
  static const String dinnerTime = '7:00 PM - 9:00 PM';
  static const String comingSoon = 'Coming soon';
  static const String deliveredAt = 'Delivered at';
  static const String expectedAt = 'Expected at';
  static const String noMealScheduled = 'No meal scheduled for this slot';
  static const String loadingPlans = 'Loading available plans...';
  static const String loadingSubscription = 'Loading subscription...';
  static const String loadingMeals = 'Loading available meals...';

  // Thali
  static const String normalThali = 'Normal Thali';
  static const String nonVegThali = 'Non-Veg Thali';
  static const String deluxeThali = 'Deluxe Thali';
  static const String customize = 'Customize';
  static const String includes = 'Includes:';
  static const String selectThaliFor = 'Select a Thali for';
  static const String selectThaliMessage = 'You can choose from the following options or customize them';
  static const String selectThali = 'Select Thali';
  static const String step = 'Step';
  static const String of = 'of';
  static const String complete = 'Complete';
  static const String noMealsAvailable = 'No meals available for this slot';

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
  static const String startDate = 'Start Date';
  static const String endDate = 'End Date';
  static const String duration = 'Duration';
  static const String totalMeals = 'Total Meals';

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
  static const String totalMealCount = 'Total Meals';
  static const String customizationCharges = 'Customization Charges';
  static const String discount = 'Discount';
  static const String total = 'Total';
  static const String creditCard = 'Credit Card';
  static const String debitCard = 'Debit Card';
  static const String upi = 'UPI';
  static const String netBanking = 'Net Banking';
  static const String wallet = 'Wallet';
  static const String cash = 'Cash on Delivery';
  static const String processingPayment = 'Processing payment...';
  static const String preparingOrderSummary = 'Preparing your order summary...';

  // Draft Plan
  static const String draftPlanFound = 'Draft Plan Found';
  static const String draftPlanFoundMessage = 'You have a saved draft plan. What would you like to do?';
  static const String startNewPlan = 'Start New Plan';
  static const String resumeDraftPlan = 'Resume Draft';
  static const String youHaveDraftPlan = 'You have a draft plan';

  // Errors
  static const String networkError = 'Network Error. Please check your connection.';
  static const String serverError = 'Server Error. Please try again later.';
  static const String unexpectedError = 'Unexpected Error. Please try again.';
  static const String noPlanToCustomize = 'Error: No plan to customize';
  static const String noCustomPlan = 'Error: No plan being customized';
  static const String routeNotFound = 'Route not found';
  static const String goBack = 'Go Back';
  static const String errorNoPlanCustomize = 'Error: No plan being customized';
  static const String errorNoDraftPlan = 'No draft plan to clear';
  static const String errorCompletePreviousSteps = 'Please complete previous steps first';
  static const String errorSelectPlanFirst = 'Please select a plan first';
  static const String startDateCannotBeAfterEndDate = 'Start date cannot be after end date';
  static const String dateRangeMustMatch = 'The selected date range must match the selected duration';
  static const String noMealSelectionData = 'No meal selection data available';

  // Plan Details
  static const String vegetarianPlan = 'Vegetarian Plan';
  static const String nonVegetarianPlan = 'Non-Vegetarian Plan';
  static const String vegetarian = 'Vegetarian';
  static const String nonVegetarian = 'Non-Vegetarian';
  static const String noDateSet = 'No dates set';
  static const String planExpired = 'Plan has expired';
  static const String lastDayPlan = 'Last day of plan';
  static const String daysRemaining = 'days remaining';
  static const String dailyBreakfastLunchDinner = 'Daily: Breakfast, Lunch & Dinner';
  static const String startingAt = 'Starting at';
  static const String customizable = 'Customizable';

  // User Profile
  static const String profile = 'Profile';
  static const String personalInfo = 'Personal Information';
  static const String firstName = 'First Name';
  static const String lastName = 'Last Name';
  static const String phone = 'Phone';
  static const String address = 'Address';
  static const String dietaryPreferences = 'Dietary Preferences';
  static const String allergies = 'Allergies';
  static const String paymentHistory = 'Payment History';
  static const String orderHistory = 'Order History';
  static const String editProfile = 'Edit Profile';
  static const String saveProfile = 'Save Profile';
  static const String updateSuccess = 'Profile updated successfully';
  static const String updateError = 'Failed to update profile';
  static const String addAddress = 'Add Address';
  static const String editAddress = 'Edit Address';
  static const String defaultAddress = 'Default Address';
  static const String setAsDefault = 'Set as Default';
  static const String street = 'Street';
  static const String city = 'City';
  static const String state = 'State';
  static const String zipCode = 'ZIP Code';
}