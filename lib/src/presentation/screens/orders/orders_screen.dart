// lib/src/presentation/screens/orders/orders_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/core/widgets/app_loading.dart';
import 'package:foodam/core/widgets/error_display_wideget.dart';
import 'package:foodam/src/data/client/dio_api_client.dart';
import 'package:foodam/src/data/model/order_model.dart';
import 'package:foodam/src/domain/entities/order_entity.dart';
import 'package:foodam/src/presentation/cubits/orders/orders_cubit.dart';
import 'package:foodam/src/presentation/cubits/orders/orders_state.dart';
import 'package:foodam/src/presentation/widgets/past_orders_widget.dart';
import 'package:foodam/src/presentation/widgets/todays_order_widget.dart';
import 'package:foodam/src/presentation/widgets/upcoming_orders_widget.dart';
import 'package:get_it/get_it.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  bool _isLoading = false;
  final LoggerService _logger = LoggerService();
  bool _isInitialized = false;

  // Debug data
  String _debugApiResult = "No API call made yet";
  bool _isDebugApiLoading = false;
  Map<DateTime, List<Order>> _debugOrdersByDate = {};
  List<Order> _debugOrders = [];
  bool _hasDebugData = false;
  bool _showDebugData = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      // Setup tab listener
      _tabController.addListener(_handleTabChange);

      // Initial load of data
      _isInitialized = true;
      _loadDataForCurrentTab();
    }
  }

  @override
  void dispose() {
    _logger.d('Orders screen disposing', tag: 'OrdersScreen');
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      _loadDataForCurrentTab();
    }
  }

  // Direct API call to debug the orders endpoint
  Future<void> _debugApiCall() async {
    setState(() {
      _isDebugApiLoading = true;
      _debugApiResult = "Loading...";
      _debugOrdersByDate = {};
      _debugOrders = [];
      _hasDebugData = false;
    });

    try {
      // Get the API client directly from GetIt
      final apiClient = GetIt.instance<DioApiClient>();

      // Determine which API endpoint to call based on current tab
      String endpoint;
      switch (_tabController.index) {
        case 1:
          endpoint = '/api/users/upcoming-orders';
          break;
        case 2:
          endpoint = '/api/users/past-orders';
          break;
        case 0:
        default:
          // For today's orders, use upcoming orders and filter for today
          endpoint = '/api/users/upcoming-orders';
          break;
      }

      _logger.d("Making direct API call to $endpoint", tag: "DEBUG_API");

      final response = await apiClient.get(endpoint);

      _logger.d(
        "API Response received: ${response.toString().substring(0, min(200, response.toString().length))}...",
        tag: "DEBUG_API",
      );

      if (response['status'] == 'success' && response.containsKey('data')) {
        final List<dynamic> ordersData = response['data'];
        _logger.d(
          "Successfully got ${ordersData.length} orders",
          tag: "DEBUG_API",
        );

        // Try to parse into OrderModels
        final parsedOrders = <OrderModel>[];
        for (var i = 0; i < ordersData.length; i++) {
          try {
            final order = OrderModel.fromJson(ordersData[i]);
            parsedOrders.add(order);
            _logger.d(
              "Successfully parsed order $i: ${order.meal.name}",
              tag: "DEBUG_API",
            );
          } catch (e) {
            _logger.e("Error parsing order at index $i: $e", tag: "DEBUG_API");
          }
        }

        // Convert models to entities
        final orderEntities =
            parsedOrders.map((model) => model.toEntity()).toList();

        // Filter orders for today if on the Today tab
        if (_tabController.index == 0) {
          final now = DateTime.now();
          final todayOrders =
              orderEntities
                  .where(
                    (order) =>
                        order.date.year == now.year &&
                        order.date.month == now.month &&
                        order.date.day == now.day,
                  )
                  .toList();
          _debugOrders = todayOrders;
        } else {
          _debugOrders = orderEntities;
        }

        // Group by date for display
        final Map<DateTime, List<Order>> ordersByDate = {};
        for (var order in _debugOrders) {
          final date = DateTime(
            order.date.year,
            order.date.month,
            order.date.day,
          );
          if (!ordersByDate.containsKey(date)) {
            ordersByDate[date] = [];
          }
          ordersByDate[date]!.add(order);
        }

        setState(() {
          _debugApiResult =
              "SUCCESS: Loaded ${_debugOrders.length} orders out of ${ordersData.length} from API";
          _debugOrdersByDate = ordersByDate;
          _hasDebugData = _debugOrders.isNotEmpty;
          _showDebugData = true;
        });
      } else {
        setState(() {
          _debugApiResult =
              "ERROR: Invalid response format - ${response.toString().substring(0, min(100, response.toString().length))}...";
        });
      }
    } catch (e) {
      _logger.e("Error during direct API call: $e", tag: "DEBUG_API");
      setState(() {
        _debugApiResult = "ERROR: $e";
      });
    } finally {
      setState(() {
        _isDebugApiLoading = false;
      });
    }
  }

  // Helper method to get minimum of two numbers
  int min(int a, int b) {
    return a < b ? a : b;
  }

  Future<void> _loadDataForCurrentTab() async {
    if (_isLoading || !mounted) {
      _logger.d(
        'Skipping load, already loading or not mounted',
        tag: 'OrdersScreen',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get the globally provided cubit
      final ordersCubit = context.read<OrdersCubit>();

      switch (_tabController.index) {
        case 0:
          _logger.d('Loading today tab data', tag: 'OrdersScreen');
          await ordersCubit.loadTodayOrders();
          break;
        case 1:
          _logger.d('Loading upcoming tab data', tag: 'OrdersScreen');
          await ordersCubit.loadUpcomingOrders();
          break;
        case 2:
          _logger.d('Loading history tab data', tag: 'OrdersScreen');
          await ordersCubit.loadPastOrders();
          break;
      }
    } catch (e) {
      _logger.e('Error loading tab data: $e', tag: 'OrdersScreen');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Use debug data to display content when Cubit fails
  Widget _buildTabContentWithDebugOption(int tabIndex) {
    if (_showDebugData && _hasDebugData) {
      switch (tabIndex) {
        case 0:
          // Today tab
          final Map<String, List<Order>> ordersByType = {
            'Breakfast': [],
            'Lunch': [],
            'Dinner': [],
          };

          // Group orders by meal type
          for (final order in _debugOrders) {
            final mealType = order.mealType;
            if (ordersByType.containsKey(mealType)) {
              ordersByType[mealType]!.add(order);
            }
          }

          // Determine current meal period
          final now = DateTime.now();
          final hour = now.hour;
          String currentMealPeriod;

          if (hour < 11) {
            currentMealPeriod = 'Breakfast';
          } else if (hour < 16) {
            currentMealPeriod = 'Lunch';
          } else {
            currentMealPeriod = 'Dinner';
          }

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Today\'s Meals (${_debugOrders.length}) - DEBUG MODE',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ),
                TodayOrdersWidget(
                  ordersByType: ordersByType,
                  currentMealPeriod: currentMealPeriod,
                ),
                const SizedBox(height: 100),
              ],
            ),
          );

        case 1:
          // Upcoming tab
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Upcoming Meals (${_debugOrders.length}) - DEBUG MODE',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ),
                UpcomingOrdersWidget(ordersByDate: _debugOrdersByDate),
                const SizedBox(height: 100),
              ],
            ),
          );

        case 2:
          // History tab
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Past Orders (${_debugOrders.length}) - DEBUG MODE',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ),
                PastOrdersWidget(ordersByDate: _debugOrdersByDate),
                const SizedBox(height: 100),
              ],
            ),
          );

        default:
          return Center(child: Text('Invalid tab index: $tabIndex'));
      }
    } else {
      return blocBuilderForTab(tabIndex);
    }
  }

  // Use Bloc builder for each tab
  Widget blocBuilderForTab(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return _buildTodayOrdersTab();
      case 1:
        return _buildUpcomingOrdersTab();
      case 2:
        return _buildOrderHistoryTab();
      default:
        return Center(child: Text('Invalid tab index: $tabIndex'));
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Meals'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadDataForCurrentTab,
              tooltip: 'Refresh',
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Today'),
            Tab(text: 'Upcoming'),
            Tab(text: 'History'),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorWeight: 3,
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              _buildTabContentWithDebugOption(0),
              _buildTabContentWithDebugOption(1),
              _buildTabContentWithDebugOption(2),
            ],
          ),
          // Debug API result overlay
          if (_isDebugApiLoading || _debugApiResult != "No API call made yet")
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      _debugApiResult.startsWith("ERROR")
                          ? Colors.red.withOpacity(0.9)
                          : Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "API Debug Result:",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Toggle to use debug data for UI
                            if (_hasDebugData)
                              Switch(
                                value: _showDebugData,
                                onChanged: (value) {
                                  setState(() {
                                    _showDebugData = value;
                                  });
                                },
                                activeColor: Colors.green,
                                activeTrackColor: Colors.green.withOpacity(0.5),
                              ),
                            IconButton(
                              icon: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                              onPressed: () {
                                setState(() {
                                  _debugApiResult = "No API call made yet";
                                  _debugOrdersByDate = {};
                                  _debugOrders = [];
                                  _hasDebugData = false;
                                  _showDebugData = false;
                                });
                              },
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (_isDebugApiLoading)
                      Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Loading...",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      )
                    else
                      Text(
                        _debugApiResult,
                        style: TextStyle(color: Colors.white),
                      ),
                    if (_hasDebugData) ...[
                      SizedBox(height: 8),
                      Text(
                        "Parsed data by date: ${_debugOrdersByDate.length} days",
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 8),
                      Container(
                        height: 100,
                        child: ListView(
                          children:
                              _debugOrdersByDate.entries.map((entry) {
                                final date = entry.key;
                                final orders = entry.value;
                                return Text(
                                  "${date.toString().split(' ')[0]}: ${orders.length} orders",
                                  style: TextStyle(color: Colors.white70),
                                );
                              }).toList(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _debugApiCall,
        backgroundColor: Colors.orange,
        tooltip: 'Debug API Call',
        child: Icon(
          _isDebugApiLoading ? Icons.hourglass_top : Icons.bug_report,
        ),
      ),
    );
  }

  Widget _buildTodayOrdersTab() {
    return RefreshIndicator(
      onRefresh: () async {
        if (!_isLoading) {
          await context.read<OrdersCubit>().loadTodayOrders();
        }
      },
      child: BlocBuilder<OrdersCubit, OrdersState>(
        buildWhen: (previous, current) {
          return current is OrdersLoading ||
              current is OrdersError ||
              current is TodayOrdersLoaded;
        },
        builder: (context, state) {
          // Extract data from state to prevent UI errors if state changes
          final bool isLoading = state is OrdersLoading;
          final String? errorMessage =
              state is OrdersError ? state.message : null;

          // Handle loading state
          if (isLoading && _isLoading) {
            return const AppLoading(message: 'Loading today\'s meals...');
          }

          // Handle error state
          if (errorMessage != null) {
            return ErrorDisplayWidget(
              message: errorMessage,
              onRetry: () => context.read<OrdersCubit>().loadTodayOrders(),
            );
          }

          // Handle data states
          if (state is TodayOrdersLoaded) {
            return _buildTodayOrdersContent(state);
          }

          // Initial state or fallback
          return const Center(
            child: Text(
              'No data available - tap the debug button to test API directly',
            ),
          );
        },
      ),
    );
  }

  Widget _buildTodayOrdersContent(TodayOrdersLoaded state) {
    if (!state.hasOrdersToday) {
      return Center(child: Text('No orders found for today'));
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Today\'s Meals (${state.orders.length})',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          TodayOrdersWidget(
            ordersByType: state.ordersByType,
            currentMealPeriod: state.currentMealPeriod,
          ),
          // Add some bottom padding for better scrolling
          const SizedBox(height: 100), // Extra padding for debug overlay
        ],
      ),
    );
  }

  Widget _buildUpcomingOrdersTab() {
    return RefreshIndicator(
      onRefresh: () async {
        if (!_isLoading) {
          await context.read<OrdersCubit>().loadUpcomingOrders();
        }
      },
      child: BlocBuilder<OrdersCubit, OrdersState>(
        buildWhen: (previous, current) {
          return current is OrdersLoading ||
              current is OrdersError ||
              current is UpcomingOrdersLoaded;
        },
        builder: (context, state) {
          // Handle loading state
          if (_isLoading) {
            return const AppLoading(message: 'Loading upcoming meals...');
          }

          // Handle error state
          if (state is OrdersError) {
            return ErrorDisplayWidget(
              message: state.message,
              onRetry: () => context.read<OrdersCubit>().loadUpcomingOrders(),
            );
          }

          // Handle data states
          if (state is UpcomingOrdersLoaded) {
            if (!state.hasUpcomingOrders) {
              return Center(child: Text('No upcoming orders found'));
            }

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Upcoming Meals (${state.orders.length})',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  UpcomingOrdersWidget(ordersByDate: state.ordersByDate),
                  // Extra padding for debug overlay
                  const SizedBox(height: 100),
                ],
              ),
            );
          }

          // Initial state or fallback
          return const Center(
            child: Text(
              'No data available - tap the debug button to test API directly',
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderHistoryTab() {
    return RefreshIndicator(
      onRefresh: () async {
        if (!_isLoading) {
          await context.read<OrdersCubit>().loadPastOrders();
        }
      },
      child: BlocBuilder<OrdersCubit, OrdersState>(
        buildWhen: (previous, current) {
          return current is OrdersLoading ||
              current is OrdersError ||
              current is PastOrdersLoaded;
        },
        builder: (context, state) {
          // Handle loading state
          if (state is OrdersLoading && _isLoading) {
            return const AppLoading(message: 'Loading order history...');
          }

          // Handle error state
          if (state is OrdersError) {
            return ErrorDisplayWidget(
              message: state.message,
              onRetry: () => context.read<OrdersCubit>().loadPastOrders(),
            );
          }

          // Handle data state
          if (state is PastOrdersLoaded) {
            if (!state.hasPastOrders) {
              return Center(child: Text('No order history found'));
            }

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Past Orders (${state.orders.length})',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  PastOrdersWidget(ordersByDate: state.ordersByDate),
                  // Extra padding for debug overlay
                  const SizedBox(height: 100),
                ],
              ),
            );
          }

          // Initial state or fallback
          return const Center(
            child: Text(
              'No data available - tap the debug button to test API directly',
            ),
          );
        },
      ),
    );
  }
}
