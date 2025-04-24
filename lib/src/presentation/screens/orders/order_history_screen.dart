// // lib/src/presentation/screens/orders/order_history_screen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:foodam/core/constants/app_colors.dart';
// import 'package:foodam/core/widgets/app_loading.dart';
// import 'package:foodam/core/widgets/error_display_wideget.dart';
// import 'package:foodam/src/presentation/cubits/orders/orders_cubit.dart';
// import 'package:foodam/src/presentation/cubits/orders/orders_state.dart';
// import 'package:foodam/src/presentation/widgets/past_orders_widget.dart';

// class OrderHistoryScreen extends StatefulWidget {
//   const OrderHistoryScreen({super.key});

//   @override
//   State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
// }

// class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
//   @override
//   void initState() {
//     super.initState();
//     _loadOrderHistory();
//   }

//   void _loadOrderHistory() {
//     context.read<OrdersCubit>().loadPastOrders();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Order History'),
//         actions: [
//           IconButton(icon: Icon(Icons.refresh), onPressed: _loadOrderHistory),
//         ],
//       ),
//       body: RefreshIndicator(
//         onRefresh: () async {
//           _loadOrderHistory();
//           await Future.delayed(Duration(milliseconds: 300));
//         },
//         child: BlocBuilder<OrdersCubit, OrdersState>(
//           builder: (context, state) {
//             if (state is OrdersLoading) {
//               return AppLoading(message: 'Loading order history...');
//             } else if (state is OrdersError) {
//               return ErrorDisplayWidget(
//                 message: state.message,
//                 onRetry: _loadOrderHistory,
//               );
//             } else if (state is PastOrdersLoaded) {
//               return _buildOrdersContent(state);
//             }
//             return _buildEmptyState();
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildOrdersContent(PastOrdersLoaded state) {
//     if (!state.hasPastOrders) {
//       return _buildEmptyState();
//     }

//     return SingleChildScrollView(
//       physics: AlwaysScrollableScrollPhysics(),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildHeader(state),
//           PastOrdersWidget(ordersByDate: state.ordersByDate),
//         ],
//       ),
//     );
//   }

//   Widget _buildHeader(PastOrdersLoaded state) {
//     return Container(
//       padding: EdgeInsets.all(16),
//       margin: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade200,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Past Orders',
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           SizedBox(height: 8),
//           Text(
//             'You have enjoyed ${state.totalOrderCount} meal${state.totalOrderCount > 1 ? 's' : ''} so far.',
//             style: TextStyle(color: AppColors.textSecondary),
//           ),
//           SizedBox(height: 8),
//           Row(
//             children: [
//               Icon(Icons.history, size: 16, color: AppColors.textSecondary),
//               SizedBox(width: 4),
//               Text(
//                 'Orders from the past ${state.ordersByDate.length} day${state.ordersByDate.length > 1 ? 's' : ''}',
//                 style: TextStyle(
//                   color: AppColors.textSecondary,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
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
//                 Icons.history_outlined,
//                 size: 80,
//                 color: AppColors.textSecondary.withOpacity(0.5),
//               ),
//               SizedBox(height: 16),
//               Text(
//                 'No order history',
//                 style: Theme.of(context).textTheme.headlineSmall,
//                 textAlign: TextAlign.center,
//               ),
//               SizedBox(height: 8),
//               Text(
//                 'Your past orders will appear here once you start enjoying our meals.',
//                 style: Theme.of(context).textTheme.bodyMedium,
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
