// // lib/src/presentation/screens/orders/upcoming_orders_screen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:foodam/core/constants/app_colors.dart';
// import 'package:foodam/core/widgets/app_loading.dart';
// import 'package:foodam/core/widgets/error_display_wideget.dart';
// import 'package:foodam/src/presentation/cubits/orders/orders_cubit.dart';
// import 'package:foodam/src/presentation/cubits/orders/orders_state.dart';
// import 'package:foodam/src/presentation/widgets/upcoming_orders_widget.dart';

// class UpcomingOrdersScreen extends StatefulWidget {
//   const UpcomingOrdersScreen({super.key});

//   @override
//   State<UpcomingOrdersScreen> createState() => _UpcomingOrdersScreenState();
// }

// class _UpcomingOrdersScreenState extends State<UpcomingOrdersScreen> {
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadUpcomingOrders();
//   }

//   Future<void> _loadUpcomingOrders() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       await context.read<OrdersCubit>().loadUpcomingOrders();
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error loading orders: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Upcoming Meals'),
//         backgroundColor: AppColors.primary,
//         foregroundColor: Colors.white,
//         actions: [
//           if (_isLoading)
//             Padding(
//               padding: const EdgeInsets.all(12.0),
//               child: SizedBox(
//                 width: 24,
//                 height: 24,
//                 child: CircularProgressIndicator(
//                   strokeWidth: 2,
//                   color: Colors.white,
//                 ),
//               ),
//             )
//           else
//             IconButton(
//               icon: Icon(Icons.refresh),
//               onPressed: _loadUpcomingOrders,
//               tooltip: 'Refresh',
//             ),
//         ],
//       ),
//       body: RefreshIndicator(
//         onRefresh: () async {
//           await _loadUpcomingOrders();
//         },
//         child: BlocBuilder<OrdersCubit, OrdersState>(
//           builder: (context, state) {
//             // Handle loading state
//             if (state is OrdersLoading && _isLoading) {
//               return AppLoading(message: 'Loading upcoming meals...');
//             }

//             // Handle error state
//             if (state is OrdersError) {
//               return ErrorDisplayWidget(
//                 message: state.message,
//                 onRetry: _loadUpcomingOrders,
//               );
//             }

//             // Handle data state
//             if (state is UpcomingOrdersLoaded) {
//               return _buildOrdersContent(state);
//             }

//             // Fallback for initial or unknown state
//             return _buildEmptyState();
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildOrdersContent(UpcomingOrdersLoaded state) {
//     if (!state.hasUpcomingOrders) {
//       return _buildEmptyState();
//     }

//     return SingleChildScrollView(
//       physics: AlwaysScrollableScrollPhysics(),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildHeader(state),
//           UpcomingOrdersWidget(ordersByDate: state.ordersByDate),
//           // Add some bottom padding
//           SizedBox(height: 32),
//         ],
//       ),
//     );
//   }

//   Widget _buildHeader(UpcomingOrdersLoaded state) {
//     return Container(
//       padding: EdgeInsets.all(16),
//       margin: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: AppColors.accent.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(Icons.event_available, color: AppColors.accent),
//               SizedBox(width: 8),
//               Text(
//                 'Upcoming Meals',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//             ],
//           ),
//           SizedBox(height: 12),
//           Text(
//             'You have ${state.totalOrderCount} upcoming meal${state.totalOrderCount > 1 ? 's' : ''} scheduled.',
//             style: TextStyle(color: AppColors.textSecondary),
//           ),
//           SizedBox(height: 8),
//           Row(
//             children: [
//               Icon(Icons.calendar_today, size: 16, color: AppColors.accent),
//               SizedBox(width: 4),
//               Text(
//                 'Meals scheduled across ${state.ordersByDate.length} day${state.ordersByDate.length > 1 ? 's' : ''}',
//                 style: TextStyle(
//                   color: AppColors.accent,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//           if (state.totalOrderCount > 0) ...[
//             SizedBox(height: 12),
//             Container(
//               padding: EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: AppColors.accent.withOpacity(0.3)),
//               ),
//               child: Row(
//                 children: [
//                   Icon(Icons.info_outline, color: AppColors.accent, size: 20),
//                   SizedBox(width: 8),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Meal Delivery Schedule',
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: AppColors.textPrimary,
//                           ),
//                         ),
//                         SizedBox(height: 4),
//                         Text(
//                           'Breakfast: 7:30-8:30 AM\nLunch: 12:00-1:00 PM\nDinner: 7:00-8:00 PM',
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: AppColors.textSecondary,
//                             height: 1.4,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: SingleChildScrollView(
//         physics: AlwaysScrollableScrollPhysics(),
//         child: Padding(
//           padding: EdgeInsets.all(24),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 Icons.event_available_outlined,
//                 size: 80,
//                 color: AppColors.textSecondary.withOpacity(0.5),
//               ),
//               SizedBox(height: 16),
//               Text(
//                 'No upcoming meals',
//                 style: Theme.of(context).textTheme.headlineSmall,
//                 textAlign: TextAlign.center,
//               ),
//               SizedBox(height: 8),
//               Text(
//                 'Add a new subscription to get delicious meals delivered to your doorstep.',
//                 style: Theme.of(context).textTheme.bodyMedium,
//                 textAlign: TextAlign.center,
//               ),
//               SizedBox(height: 24),
//               ElevatedButton.icon(
//                 onPressed: _loadUpcomingOrders,
//                 icon: Icon(Icons.refresh),
//                 label: Text('Check Again'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.accent,
//                   foregroundColor: Colors.white,
//                   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
