// // lib/src/presentation/cubits/subscription/subscription_detail_cubit.dart
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:foodam/core/service/logger_service.dart';
// import 'package:foodam/src/domain/entities/meal_order_entity.dart';
// import 'package:foodam/src/domain/usecase/subscription/pause_subscription_usecase.dart';
// import 'package:foodam/src/domain/usecase/subscription/resume_susbcription_usecase.dart';
// import 'package:foodam/src/domain/usecase/subscription/cancel_susbcritpion_usecase.dart';
// import 'package:foodam/src/presentation/cubits/subscription/subscription_details/subscription_details_state.dart';
// import 'package:foodam/src/presentation/utlis/date_formatter.dart';

// class SubscriptionDetailCubit extends Cubit<SubscriptionDetailState> {
//   final PauseSubscriptionUseCase _pauseSubscriptionUseCase;
//   final ResumeSubscriptionUseCase _resumeSubscriptionUseCase;
//   final CancelSubscriptionUseCase _cancelSubscriptionUseCase;
//   final LoggerService _logger = LoggerService();
//   final DateFormatter _dateFormatter = DateFormatter();

//   SubscriptionDetailCubit({
//     required PauseSubscriptionUseCase pauseSubscriptionUseCase,
//     required ResumeSubscriptionUseCase resumeSubscriptionUseCase,
//     required CancelSubscriptionUseCase cancelSubscriptionUseCase,
//   }) : 
//     _pauseSubscriptionUseCase = pauseSubscriptionUseCase,
//     _resumeSubscriptionUseCase = resumeSubscriptionUseCase,
//     _cancelSubscriptionUseCase = cancelSubscriptionUseCase,
//     super(SubscriptionDetailInitial());

//   Future<void> getSubscriptionDetails(String subscriptionId) async {
//     emit(SubscriptionDetailLoading());
    
//     final subscriptionResult = await _getSubscriptionDetailsUseCase(subscriptionId);
    
//     await subscriptionResult.fold(
//       (failure) {
//         _logger.e('Failed to get subscription details', error: failure);
//         emit(SubscriptionDetailError('Failed to load subscription details'));
//       },
//       (subscription) async {
//         final ordersResult = await _getMealOrdersBySubscriptionUseCase(subscriptionId);
        
//         ordersResult.fold(
//           (failure) {
//             _logger.e('Failed to get subscription orders', error: failure);
//             // We still show the subscription, just without orders
//             final daysRemaining = _calculateDaysRemaining(subscription.endDate);
            
//             emit(SubscriptionDetailLoaded(
//               subscription: subscription,
//               daysRemaining: daysRemaining,
//             ));
//           },
//           (orders) {
//             final daysRemaining = _calculateDaysRemaining(subscription.endDate);
            
//             // Organize orders by day and meal type
//             final ordersMap = _organizeOrdersByDayAndType(orders);
            
//             _logger.i('Subscription details loaded: ${subscription.id}');
//             emit(SubscriptionDetailLoaded(
//               subscription: subscription,
//               upcomingOrders: orders,
//               daysRemaining: daysRemaining,
//               ordersByDayAndType: ordersMap,
//             ));
//           },
//         );
//       },
//     );
//   }

//   Future<void> pauseSubscription(String subscriptionId, DateTime untilDate) async {
//     emit(SubscriptionDetailActionInProgress('pause'));
    
//     final params = PauseSubscriptionParams(
//       subscriptionId: subscriptionId, 
//       until: untilDate
//     );
    
//     final result = await _pauseSubscriptionUseCase(params);
    
//     result.fold(
//       (failure) {
//         _logger.e('Failed to pause subscription', error: failure);
//         emit(SubscriptionDetailError('Failed to pause subscription'));
//       },
//       (_) {
//         _logger.i('Subscription paused successfully: $subscriptionId');
//         emit(SubscriptionDetailActionSuccess(
//           action: 'pause',
//           message: 'Your subscription has been paused until ${_dateFormatter.formatDate(untilDate)}'
//         ));
//         // Refresh details after action
//         getSubscriptionDetails(subscriptionId);
//       },
//     );
//   }

//   Future<void> resumeSubscription(String subscriptionId) async {
//     emit(SubscriptionDetailActionInProgress('resume'));
    
//     final result = await _resumeSubscriptionUseCase(subscriptionId);
    
//     result.fold(
//       (failure) {
//         _logger.e('Failed to resume subscription', error: failure);
//         emit(SubscriptionDetailError('Failed to resume subscription'));
//       },
//       (_) {
//         _logger.i('Subscription resumed successfully: $subscriptionId');
//         emit(SubscriptionDetailActionSuccess(
//           action: 'resume',
//           message: 'Your subscription has been resumed successfully'
//         ));
//         // Refresh details after action
//         getSubscriptionDetails(subscriptionId);
//       },
//     );
//   }

//   Future<void> cancelSubscription(String subscriptionId) async {
//     emit(SubscriptionDetailActionInProgress('cancel'));
    
//     final result = await _cancelSubscriptionUseCase(subscriptionId);
    
//     result.fold(
//       (failure) {
//         _logger.e('Failed to cancel subscription', error: failure);
//         emit(SubscriptionDetailError('Failed to cancel subscription'));
//       },
//       (_) {
//         _logger.i('Subscription cancelled successfully: $subscriptionId');
//         emit(SubscriptionDetailActionSuccess(
//           action: 'cancel',
//           message: 'Your subscription has been cancelled'
//         ));
//       },
//     );
//   }

//   int _calculateDaysRemaining(DateTime endDate) {
//     final now = DateTime.now();
//     final difference = endDate.difference(now).inDays;
//     return difference > 0 ? difference : 0;
//   }
  
//   // Helper method to organize meal orders by day and meal type
//   Map<String, Map<String, List<MealOrder>>> _organizeOrdersByDayAndType(List<MealOrder> orders) {
//     final Map<String, Map<String, List<MealOrder>>> result = {};
    
//     for (final order in orders) {
//       // Get the day of the week
//       final day = _dateFormatter.getWeekday(order.orderDate);
      
//       // Initialize the day map if not already present
//       if (!result.containsKey(day)) {
//         result[day] = {};
//       }
      
//       // Initialize the meal type list if not already present
//       if (!result[day]!.containsKey(order.mealType)) {
//         result[day]![order.mealType] = [];
//       }
      
//       // Add the order to the appropriate list
//       result[day]![order.mealType]!.add(order);
//     }
    
//     return result;
//   }
// }