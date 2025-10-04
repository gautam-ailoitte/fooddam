// // lib/src/presentation/screens/checkout/checkout_screen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:foodam/core/constants/app_colors.dart';
// import 'package:foodam/core/layout/app_spacing.dart';
// import 'package:foodam/core/route/app_router.dart';
// import 'package:foodam/core/service/dialog_service.dart';
// import 'package:foodam/core/theme/enhanced_app_them.dart';
// import 'package:foodam/src/domain/entities/address_entity.dart';
// import 'package:foodam/src/domain/entities/payment_entity.dart';
// import 'package:foodam/src/presentation/cubits/payment/razor_pay_cubit/razor_pay_cubit/razor_pay_cubit_cubit.dart';
// import 'package:foodam/src/presentation/cubits/payment/razor_pay_cubit/razor_pay_cubit/razor_pay_cubit_state.dart';
// import 'package:foodam/src/presentation/cubits/subscription/create_subcription/create_subcription_cubit.dart';
// import 'package:foodam/src/presentation/cubits/subscription/create_subcription/create_subcription_state.dart';
// import 'package:foodam/src/presentation/cubits/user_profile/user_profile_cubit.dart';
// import 'package:foodam/src/presentation/cubits/user_profile/user_profile_state.dart';
// import 'package:intl/intl.dart';
//
// class CheckoutScreen extends StatefulWidget {
//   const CheckoutScreen({super.key});
//
//   @override
//   State<CheckoutScreen> createState() => _CheckoutScreenState();
// }
//
// class _CheckoutScreenState extends State<CheckoutScreen> {
//   String? _selectedAddressId;
//   String? _deliveryInstructions;
//   PaymentMethod _selectedPaymentMethod = PaymentMethod.upi;
//   bool _isLoading = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadUserAddresses();
//
//     // Load any previously entered instructions
//     final state = context.read<SubscriptionCreationCubit>().state;
//     if (state is MealSelectionActive) {
//       _deliveryInstructions = state.instructions;
//       _selectedAddressId = state.addressId;
//     }
//   }
//
//   void _loadUserAddresses() {
//     context.read<UserProfileCubit>().getUserProfile();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Checkout'),
//         backgroundColor: AppColors.primary,
//         elevation: 0,
//       ),
//       body: BlocBuilder<SubscriptionCreationCubit, SubscriptionCreationState>(
//         builder: (context, subscriptionState) {
//           if (subscriptionState is! MealSelectionActive) {
//             return const Center(child: Text('Unable to load checkout details'));
//           }
//
//           return MultiBlocListener(
//             listeners: [
//               // Subscription creation listener
//               BlocListener<
//                 SubscriptionCreationCubit,
//                 SubscriptionCreationState
//               >(
//                 listener: (context, state) {
//                   if (state is SubscriptionCreationLoading) {
//                     setState(() {
//                       _isLoading = true;
//                     });
//                   } else if (state is SubscriptionCreationSuccess) {
//                     setState(() {
//                       _isLoading = false;
//                     });
//
//                     // Process payment
//                     context
//                         .read<RazorpayPaymentCubit>()
//                         .processPaymentForSubscription(
//                           state.subscription.id,
//                           _selectedPaymentMethod,
//                         );
//                   } else if (state is SubscriptionCreationError) {
//                     setState(() {
//                       _isLoading = false;
//                     });
//
//                     AppDialogs.showAlertDialog(
//                       context: context,
//                       title: 'Error',
//                       message: state.message,
//                       buttonText: 'OK',
//                     );
//                   }
//                 },
//               ),
//
//               // Payment listener
//               BlocListener<RazorpayPaymentCubit, RazorpayPaymentState>(
//                 listener: (context, state) {
//                   if (state is RazorpayPaymentLoading) {
//                     setState(() {
//                       _isLoading = true;
//                     });
//                   } else if (state is RazorpayPaymentSuccessWithId) {
//                     setState(() {
//                       _isLoading = false;
//                     });
//
//                     AppDialogs.showSuccessDialog(
//                       context: context,
//                       title: 'Payment Successful',
//                       message:
//                           'Your subscription has been activated successfully.',
//                       buttonText: 'Go to Home',
//                       onPressed: () {
//                         // context
//                         //     .read<SubscriptionCubit>()
//                         //     .loadActiveSubscriptions(); //todo:
//                         Navigator.of(context).pushNamedAndRemoveUntil(
//                           AppRouter.mainRoute,
//                           (route) => false,
//                         );
//                       },
//                     );
//                   } else if (state is RazorpayPaymentError) {
//                     setState(() {
//                       _isLoading = false;
//                     });
//
//                     AppDialogs.showAlertDialog(
//                       context: context,
//                       title: 'Payment Failed',
//                       message:
//                           'Payment could not be processed. Please try again.',
//                       buttonText: 'OK',
//                     );
//                   }
//                 },
//               ),
//             ],
//             child: Stack(
//               children: [
//                 SingleChildScrollView(
//                   padding: EdgeInsets.all(AppDimensions.marginMedium),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       _buildOrderSummaryCard(subscriptionState),
//                       SizedBox(height: AppDimensions.marginMedium),
//                       _buildWeekBreakdownCard(subscriptionState),
//                       SizedBox(height: AppDimensions.marginMedium),
//                       _buildAddressSelectionCard(),
//                       SizedBox(height: AppDimensions.marginMedium),
//                       _buildDeliveryInstructionsCard(),
//                       SizedBox(height: AppDimensions.marginMedium),
//                       _buildPaymentMethodCard(),
//                       const SizedBox(height: 100),
//                     ],
//                   ),
//                 ),
//
//                 if (_isLoading)
//                   Positioned.fill(
//                     child: Container(
//                       color: Colors.black.withOpacity(0.5),
//                       child: const Center(
//                         child: CircularProgressIndicator(color: Colors.white),
//                       ),
//                     ),
//                   ),
//
//                 Positioned(
//                   left: 0,
//                   right: 0,
//                   bottom: 0,
//                   child: _buildBottomActionBar(subscriptionState),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildOrderSummaryCard(MealSelectionActive state) {
//     return Card(
//       elevation: 0,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Container(
//         decoration: EnhancedTheme.cardDecoration,
//         padding: EdgeInsets.all(AppDimensions.marginMedium),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Order Summary',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: AppDimensions.marginMedium),
//
//             _buildSummaryRow(
//               'Start Date',
//               DateFormat('MMM d, yyyy').format(state.startDate),
//             ),
//             _buildSummaryRow(
//               'End Date',
//               DateFormat('MMM d, yyyy').format(state.endDate),
//             ),
//             _buildSummaryRow(
//               'Duration',
//               '${state.durationDays} days (${state.weekSelections.length} weeks)',
//             ),
//             _buildSummaryRow('Meals per Week', '${state.mealCountPerWeek}'),
//             _buildSummaryRow('Total Meals', '${state.totalSelectedMeals}'),
//             _buildSummaryRow('Number of People', '${state.personCount}'),
//
//             Divider(height: 32),
//
//             _buildSummaryRow(
//               'Price per Week',
//               '₹${state.pricePerWeek.toStringAsFixed(0)}',
//             ),
//             _buildSummaryRow(
//               'Number of Weeks',
//               '${state.weekSelections.length}',
//             ),
//             if (state.personCount > 1)
//               _buildSummaryRow('Person Multiplier', '×${state.personCount}'),
//
//             SizedBox(height: AppDimensions.marginSmall),
//             _buildSummaryRow(
//               'Total Amount',
//               '₹${state.totalPrice.toStringAsFixed(0)}',
//               isTotal: true,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildWeekBreakdownCard(MealSelectionActive state) {
//     return Card(
//       elevation: 0,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Container(
//         decoration: EnhancedTheme.cardDecoration,
//         padding: EdgeInsets.all(AppDimensions.marginMedium),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Week-by-Week Breakdown',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: AppDimensions.marginMedium),
//
//             ...state.weekSelections.map((week) {
//               return Container(
//                 margin: EdgeInsets.only(bottom: AppDimensions.marginSmall),
//                 padding: EdgeInsets.all(AppDimensions.marginSmall),
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade50,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Row(
//                   children: [
//                     Container(
//                       width: 40,
//                       height: 40,
//                       decoration: BoxDecoration(
//                         color: AppColors.primary.withOpacity(0.1),
//                         shape: BoxShape.circle,
//                       ),
//                       child: Center(
//                         child: Text(
//                           '${week.weekNumber}',
//                           style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: AppColors.primary,
//                           ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(width: AppDimensions.marginSmall),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Week ${week.weekNumber}',
//                             style: const TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           Text(
//                             '${DateFormat('MMM d').format(week.weekStartDate)} - ${DateFormat('MMM d').format(week.weekEndDate)}',
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: AppColors.textSecondary,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       children: [
//                         Text(
//                           '${week.selectedMealCount} meals',
//                           style: const TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                         Text(
//                           '₹${state.pricePerWeek.toStringAsFixed(0)}',
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: AppColors.textSecondary,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               );
//             }).toList(),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildAddressSelectionCard() {
//     return Card(
//       elevation: 0,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Container(
//         decoration: EnhancedTheme.cardDecoration,
//         padding: EdgeInsets.all(AppDimensions.marginMedium),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Delivery Address',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: AppDimensions.marginMedium),
//
//             BlocBuilder<UserProfileCubit, UserProfileState>(
//               builder: (context, state) {
//                 if (state is UserProfileLoading) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//
//                 if (state is UserProfileLoaded && state.addresses != null) {
//                   final addresses = state.addresses!;
//
//                   if (addresses.isEmpty) {
//                     return Column(
//                       children: [
//                         const Text(
//                           'No addresses found. Please add an address.',
//                           style: TextStyle(color: AppColors.textSecondary),
//                         ),
//                         SizedBox(height: AppDimensions.marginMedium),
//                         ElevatedButton.icon(
//                           onPressed: () {
//                             Navigator.pushNamed(context, '/profile');
//                           },
//                           icon: const Icon(Icons.add),
//                           label: const Text('Add Address'),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: AppColors.primary,
//                             foregroundColor: Colors.white,
//                           ),
//                         ),
//                       ],
//                     );
//                   }
//
//                   if (_selectedAddressId == null && addresses.isNotEmpty) {
//                     WidgetsBinding.instance.addPostFrameCallback((_) {
//                       setState(() {
//                         _selectedAddressId = addresses.first.id;
//                       });
//                     });
//                   }
//
//                   return Column(
//                     children: [
//                       ...addresses.map((address) => _buildAddressItem(address)),
//                       SizedBox(height: AppDimensions.marginMedium),
//                       TextButton.icon(
//                         onPressed: () {
//                           Navigator.pushNamed(context, '/profile');
//                         },
//                         icon: const Icon(Icons.add),
//                         label: const Text('Add New Address'),
//                         style: TextButton.styleFrom(
//                           foregroundColor: AppColors.primary,
//                         ),
//                       ),
//                     ],
//                   );
//                 }
//
//                 return const Center(child: Text('Unable to load addresses'));
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildAddressItem(Address address) {
//     final isSelected = _selectedAddressId == address.id;
//
//     return InkWell(
//       onTap: () {
//         setState(() {
//           _selectedAddressId = address.id;
//         });
//
//         // Update in cubit
//         context.read<SubscriptionCreationCubit>().updateDeliveryDetails(
//           addressId: address.id,
//         );
//       },
//       child: Container(
//         margin: EdgeInsets.only(bottom: AppDimensions.marginSmall),
//         padding: EdgeInsets.all(AppDimensions.marginSmall),
//         decoration: BoxDecoration(
//           color:
//               isSelected ? AppColors.primary.withOpacity(0.05) : Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: isSelected ? AppColors.primary : Colors.grey.shade300,
//             width: isSelected ? 2 : 1,
//           ),
//         ),
//         child: Row(
//           children: [
//             Radio<String>(
//               value: address.id,
//               groupValue: _selectedAddressId,
//               onChanged: (value) {
//                 setState(() {
//                   _selectedAddressId = value;
//                 });
//
//                 context.read<SubscriptionCreationCubit>().updateDeliveryDetails(
//                   addressId: value,
//                 );
//               },
//               activeColor: AppColors.primary,
//             ),
//             SizedBox(width: AppDimensions.marginSmall),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     address.street,
//                     style: const TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     '${address.city}, ${address.state} ${address.zipCode}',
//                     style: TextStyle(
//                       color: AppColors.textSecondary,
//                       fontSize: 14,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDeliveryInstructionsCard() {
//     return Card(
//       elevation: 0,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Container(
//         decoration: EnhancedTheme.cardDecoration,
//         padding: EdgeInsets.all(AppDimensions.marginMedium),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Delivery Instructions',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Add any special instructions for delivery',
//               style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
//             ),
//             SizedBox(height: AppDimensions.marginMedium),
//             TextFormField(
//               initialValue: _deliveryInstructions,
//               onChanged: (value) {
//                 setState(() {
//                   _deliveryInstructions = value;
//                 });
//
//                 context.read<SubscriptionCreationCubit>().updateDeliveryDetails(
//                   instructions: value,
//                 );
//               },
//               maxLines: 3,
//               decoration: InputDecoration(
//                 hintText: 'e.g., Ring the bell, call when at gate, etc.',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(color: Colors.grey.shade300),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: const BorderSide(
//                     color: AppColors.primary,
//                     width: 2,
//                   ),
//                 ),
//                 filled: true,
//                 fillColor: Colors.grey.shade50,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPaymentMethodCard() {
//     return Card(
//       elevation: 0,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Container(
//         decoration: EnhancedTheme.cardDecoration,
//         padding: EdgeInsets.all(AppDimensions.marginMedium),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Payment Method',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: AppDimensions.marginMedium),
//
//             _buildPaymentOption(
//               title: 'UPI Payment',
//               subtitle: 'Pay using any UPI app',
//               icon: Icons.account_balance,
//               value: PaymentMethod.upi,
//             ),
//             _buildPaymentOption(
//               title: 'Credit Card',
//               subtitle: 'Pay using credit card',
//               icon: Icons.credit_card,
//               value: PaymentMethod.creditCard,
//             ),
//             _buildPaymentOption(
//               title: 'Debit Card',
//               subtitle: 'Pay using debit card',
//               icon: Icons.credit_card,
//               value: PaymentMethod.debitCard,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPaymentOption({
//     required String title,
//     required String subtitle,
//     required IconData icon,
//     required PaymentMethod value,
//   }) {
//     final isSelected = _selectedPaymentMethod == value;
//
//     return InkWell(
//       onTap: () {
//         setState(() {
//           _selectedPaymentMethod = value;
//         });
//       },
//       child: Container(
//         margin: EdgeInsets.only(bottom: AppDimensions.marginSmall),
//         padding: EdgeInsets.all(AppDimensions.marginSmall),
//         decoration: BoxDecoration(
//           color:
//               isSelected ? AppColors.primary.withOpacity(0.05) : Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: isSelected ? AppColors.primary : Colors.grey.shade300,
//             width: isSelected ? 2 : 1,
//           ),
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 40,
//               height: 40,
//               decoration: BoxDecoration(
//                 color:
//                     isSelected
//                         ? AppColors.primary.withOpacity(0.1)
//                         : Colors.grey.shade100,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Icon(
//                 icon,
//                 color: isSelected ? AppColors.primary : Colors.grey.shade700,
//               ),
//             ),
//             SizedBox(width: AppDimensions.marginSmall),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: const TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   Text(
//                     subtitle,
//                     style: TextStyle(
//                       color: AppColors.textSecondary,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Radio<PaymentMethod>(
//               value: value,
//               groupValue: _selectedPaymentMethod,
//               onChanged: (newValue) {
//                 if (newValue != null) {
//                   setState(() {
//                     _selectedPaymentMethod = newValue;
//                   });
//                 }
//               },
//               activeColor: AppColors.primary,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildBottomActionBar(MealSelectionActive state) {
//     final canProceed = _selectedAddressId != null && !_isLoading;
//
//     return Container(
//       padding: EdgeInsets.all(AppDimensions.marginMedium),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, -4),
//           ),
//         ],
//       ),
//       child: SafeArea(
//         child: Row(
//           children: [
//             Expanded(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Total Amount',
//                     style: TextStyle(
//                       color: AppColors.textSecondary,
//                       fontSize: 12,
//                     ),
//                   ),
//                   Text(
//                     '₹${state.totalPrice.toStringAsFixed(0)}',
//                     style: const TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: AppColors.primary,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(width: AppDimensions.marginMedium),
//             Expanded(
//               child: ElevatedButton(
//                 onPressed: canProceed ? _placeOrder : null,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.primary,
//                   disabledBackgroundColor: Colors.grey.shade300,
//                   foregroundColor: Colors.white,
//                   disabledForegroundColor: Colors.grey.shade500,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   elevation: 0,
//                 ),
//                 child: const Text('Place Order'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
//     return Padding(
//       padding: EdgeInsets.only(bottom: AppDimensions.marginSmall),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: TextStyle(
//               color: isTotal ? null : AppColors.textSecondary,
//               fontSize: isTotal ? 16 : 14,
//               fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
//             ),
//           ),
//           Text(
//             value,
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: isTotal ? 18 : 14,
//               color: isTotal ? AppColors.primary : null,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _placeOrder() {
//     if (_selectedAddressId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please select a delivery address')),
//       );
//       return;
//     }
//
//     AppDialogs.showConfirmationDialog(
//       context: context,
//       title: 'Confirm Order',
//       message: 'Do you want to place this order?',
//       confirmText: 'Place Order',
//       cancelText: 'Cancel',
//     ).then((confirmed) {
//       if (confirmed == true) {
//         context.read<SubscriptionCreationCubit>().createSubscription();
//       }
//     });
//   }
// }
