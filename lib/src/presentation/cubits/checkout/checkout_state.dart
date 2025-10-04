// // lib/src/presentation/cubits/checkout/checkout_state.dart
// import 'package:equatable/equatable.dart';
// import 'package:foodam/src/domain/entities/address_entity.dart';
// import 'package:foodam/src/domain/entities/susbcription_entity.dart';
// // Use the DishSelection from week_selection_state.dart with alias for clarity
// import 'package:foodam/src/presentation/cubits/subscription/week_selection/week_selection_state.dart'
//     as WeekSelection;
//
// /// Base state for checkout flow
// abstract class CheckoutState extends Equatable {
//   const CheckoutState();
//
//   @override
//   List<Object?> get props => [];
// }
//
// /// Initial state when checkout hasn't started
// class CheckoutInitial extends CheckoutState {
//   const CheckoutInitial();
// }
//
// /// Loading state for async operations
// class CheckoutLoading extends CheckoutState {
//   final String? message;
//
//   const CheckoutLoading([this.message]);
//
//   @override
//   List<Object?> get props => [message];
// }
//
// /// Active checkout state with all data
// class CheckoutActive extends CheckoutState {
//   final WeekSelectionData weekData;
//   final List<Address>? addresses;
//   final String? selectedAddressId;
//   final String? instructions;
//   final int noOfPersons;
//   final SubscriptionPricing pricing;
//   final bool isSubmitting;
//
//   const CheckoutActive({
//     required this.weekData,
//     this.addresses,
//     this.selectedAddressId,
//     this.instructions,
//     this.noOfPersons = 1,
//     required this.pricing,
//     this.isSubmitting = false,
//   });
//
//   @override
//   List<Object?> get props => [
//     weekData,
//     addresses,
//     selectedAddressId,
//     instructions,
//     noOfPersons,
//     pricing,
//     isSubmitting,
//   ];
//
//   /// Check if form is ready for submission
//   bool get canSubmit =>
//       selectedAddressId?.isNotEmpty == true && noOfPersons > 0 && !isSubmitting;
//
//   /// Get missing validation fields
//   List<String> get missingFields {
//     final missing = <String>[];
//     if (selectedAddressId?.isEmpty != false) missing.add('Delivery Address');
//     if (noOfPersons <= 0) missing.add('Number of Persons');
//     return missing;
//   }
//
//   /// Calculate total amount including person multiplier
//   double get totalAmount => pricing.totalPrice * noOfPersons;
//
//   /// Get form completion percentage
//   double get completionPercentage {
//     int completed = 0;
//     if (selectedAddressId?.isNotEmpty == true) completed++;
//     if (noOfPersons > 0) completed++;
//     return completed / 2.0;
//   }
//
//   /// Create copy with updated values
//   CheckoutActive copyWith({
//     WeekSelectionData? weekData,
//     List<Address>? addresses,
//     String? selectedAddressId,
//     String? instructions,
//     int? noOfPersons,
//     SubscriptionPricing? pricing,
//     bool? isSubmitting,
//   }) {
//     return CheckoutActive(
//       weekData: weekData ?? this.weekData,
//       addresses: addresses ?? this.addresses,
//       selectedAddressId: selectedAddressId ?? this.selectedAddressId,
//       instructions: instructions ?? this.instructions,
//       noOfPersons: noOfPersons ?? this.noOfPersons,
//       pricing: pricing ?? this.pricing,
//       isSubmitting: isSubmitting ?? this.isSubmitting,
//     );
//   }
// }
//
// /// Subscription created successfully, ready for payment
// class CheckoutSubscriptionCreated extends CheckoutState {
//   final Subscription subscription;
//   final WeekSelectionData weekData;
//   final SubscriptionPricing pricing;
//   final String selectedAddressId;
//   final String? instructions;
//   final int noOfPersons;
//
//   const CheckoutSubscriptionCreated({
//     required this.subscription,
//     required this.weekData,
//     required this.pricing,
//     required this.selectedAddressId,
//     this.instructions,
//     required this.noOfPersons,
//   });
//
//   @override
//   List<Object?> get props => [
//     subscription,
//     weekData,
//     pricing,
//     selectedAddressId,
//     instructions,
//     noOfPersons,
//   ];
//
//   /// Calculate total amount
//   double get totalAmount => pricing.totalPrice * noOfPersons;
// }
//
// /// Checkout error state
// class CheckoutError extends CheckoutState {
//   final String message;
//   final WeekSelectionData? weekData;
//   final SubscriptionPricing? pricing;
//   final String? selectedAddressId;
//   final String? instructions;
//   final int? noOfPersons;
//
//   const CheckoutError({
//     required this.message,
//     this.weekData,
//     this.pricing,
//     this.selectedAddressId,
//     this.instructions,
//     this.noOfPersons,
//   });
//
//   @override
//   List<Object?> get props => [
//     message,
//     weekData,
//     pricing,
//     selectedAddressId,
//     instructions,
//     noOfPersons,
//   ];
//
//   /// Check if can retry
//   bool get canRetry =>
//       weekData != null &&
//       pricing != null &&
//       selectedAddressId?.isNotEmpty == true &&
//       (noOfPersons ?? 0) > 0;
// }
//
// /// ===================================================================
// /// Supporting Data Classes
// /// ===================================================================
//
// /// Extracted data from WeekSelectionCubit
// class WeekSelectionData extends Equatable {
//   final DateTime startDate;
//   final String defaultDietaryPreference;
//   final Map<int, CheckoutWeekConfig> weekConfigs;
//   final Map<int, List<WeekSelection.DishSelection>> groupedSelections;
//   final Map<int, String> weekPackageIds;
//   final int totalDuration;
//   final int totalMeals;
//
//   const WeekSelectionData({
//     required this.startDate,
//     required this.defaultDietaryPreference,
//     required this.weekConfigs,
//     required this.groupedSelections,
//     required this.weekPackageIds,
//     required this.totalDuration,
//     required this.totalMeals,
//   });
//
//   @override
//   List<Object?> get props => [
//     startDate,
//     defaultDietaryPreference,
//     weekConfigs,
//     groupedSelections,
//     weekPackageIds,
//     totalDuration,
//     totalMeals,
//   ];
//
//   /// Calculate end date
//   DateTime get endDate => startDate.add(Duration(days: totalDuration * 7 - 1));
//
//   /// Get meal distribution by type
//   Map<String, int> get mealTypeDistribution {
//     final distribution = <String, int>{'breakfast': 0, 'lunch': 0, 'dinner': 0};
//
//     for (final selections in groupedSelections.values) {
//       for (final selection in selections) {
//         final mealType = selection.timing.toLowerCase();
//         distribution[mealType] = (distribution[mealType] ?? 0) + 1;
//       }
//     }
//
//     return distribution;
//   }
//
//   /// Get all selections flattened
//   List<WeekSelection.DishSelection> get allSelections {
//     final all = <WeekSelection.DishSelection>[];
//     for (final selections in groupedSelections.values) {
//       all.addAll(selections);
//     }
//     return all;
//   }
// }
//
// /// Week configuration data for checkout (renamed to avoid conflicts)
// class CheckoutWeekConfig extends Equatable {
//   final int week;
//   final String dietaryPreference;
//   final int mealPlan;
//   final bool isComplete;
//
//   const CheckoutWeekConfig({
//     required this.week,
//     required this.dietaryPreference,
//     required this.mealPlan,
//     required this.isComplete,
//   });
//
//   @override
//   List<Object?> get props => [week, dietaryPreference, mealPlan, isComplete];
//
//   CheckoutWeekConfig copyWith({
//     int? week,
//     String? dietaryPreference,
//     int? mealPlan,
//     bool? isComplete,
//   }) {
//     return CheckoutWeekConfig(
//       week: week ?? this.week,
//       dietaryPreference: dietaryPreference ?? this.dietaryPreference,
//       mealPlan: mealPlan ?? this.mealPlan,
//       isComplete: isComplete ?? this.isComplete,
//     );
//   }
// }
//
// /// Pricing calculation for subscription
// class SubscriptionPricing extends Equatable {
//   final Map<int, double> weekPricing;
//   final double totalPrice;
//   final Map<int, WeekPricingDetails> weekDetails;
//
//   const SubscriptionPricing({
//     required this.weekPricing,
//     required this.totalPrice,
//     required this.weekDetails,
//   });
//
//   @override
//   List<Object?> get props => [weekPricing, totalPrice, weekDetails];
//
//   /// Get pricing for specific week
//   double getWeekPrice(int week) => weekPricing[week] ?? 0.0;
//
//   /// Get week pricing details
//   WeekPricingDetails? getWeekDetails(int week) => weekDetails[week];
//
//   /// Check if pricing is valid
//   bool get isValid => weekPricing.isNotEmpty && totalPrice > 0;
// }
//
// /// Detailed pricing information for a week
// class WeekPricingDetails extends Equatable {
//   final int week;
//   final int mealCount;
//   final double pricePerMeal;
//   final double weekTotal;
//   final String packageId;
//   final String dietaryPreference;
//
//   const WeekPricingDetails({
//     required this.week,
//     required this.mealCount,
//     required this.pricePerMeal,
//     required this.weekTotal,
//     required this.packageId,
//     required this.dietaryPreference,
//   });
//
//   @override
//   List<Object?> get props => [
//     week,
//     mealCount,
//     pricePerMeal,
//     weekTotal,
//     packageId,
//     dietaryPreference,
//   ];
// }
