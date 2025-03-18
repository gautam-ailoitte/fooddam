// lib/src/presentation/screens/meals/meal_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/constants/string_constants.dart';
import 'package:foodam/core/layout/app_scaffold.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/widgets/app_card.dart';
import 'package:foodam/core/widgets/app_empty_state.dart';
import 'package:foodam/core/widgets/app_error_widget.dart';
import 'package:foodam/core/widgets/app_loading.dart';
import 'package:foodam/core/widgets/app_section_header.dart';
import 'package:foodam/src/domain/entities/dish_entity.dart';
import 'package:foodam/src/domain/entities/order_entity.dart';
import 'package:foodam/src/presentation/cubits/meal_customization/meal_customization_cubit.dart';
import 'package:foodam/src/presentation/cubits/meal_customization/meal_customization_state.dart';
import 'package:foodam/src/presentation/cubits/order/order_cubit.dart';
import 'package:foodam/src/presentation/cubits/order/order_state.dart';
import 'package:foodam/src/presentation/screens/meal_customization_screen.dart';
import 'package:foodam/src/presentation/screens/order_details_screen.dart';
import 'package:intl/intl.dart';

class MealSelectionScreen extends StatefulWidget {
  const MealSelectionScreen({Key? key}) : super(key: key);

  @override
  State<MealSelectionScreen> createState() => _MealSelectionScreenState();
}

class _MealSelectionScreenState extends State<MealSelectionScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedDayIndex = 0;
  DateTime _selectedDate = DateTime.now();
  final List<String> _mealTypes = ['breakfast', 'lunch', 'dinner'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    // Load available meals
    context.read<MealCustomizationCubit>().getAvailableMeals();
    
    // Load upcoming orders to show scheduled meals
    context.read<OrderCubit>().getUpcomingOrders();
  }

  void _selectDay(int index, DateTime date) {
    setState(() {
      _selectedDayIndex = index;
      _selectedDate = date;
    });
  }

  void _navigateToMealCustomization(String mealId, String mealType) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MealCustomizationScreen(
          mealId: mealId,
          mealType: mealType,
        ),
      ),
    );

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Meal customization complete!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _navigateToOrderDetails(Order order) {
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetailsScreen(orderId: order.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: StringConstants.viewCompleteMenu,
      body: Column(
        children: [
          // Day selector
          _buildDaySelector(),
          
          // Meal type tabs
          TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: const [
              Tab(text: 'Breakfast'),
              Tab(text: 'Lunch'),
              Tab(text: 'Dinner'),
            ],
          ),
          
          // Meal content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMealTypeContent('breakfast'),
                _buildMealTypeContent('lunch'),
                _buildMealTypeContent('dinner'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelector() {
    // Generate dates for next 7 days
    final dates = List.generate(7, (index) {
      return DateTime.now().add(Duration(days: index));
    });

    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected = _selectedDayIndex == index;
          
          // Check if today or tomorrow
          String dayLabel;
          if (index == 0) {
            dayLabel = 'Today';
          } else if (index == 1) {
            dayLabel = 'Tomorrow';
          } else {
            dayLabel = DateFormat('EEE').format(date); // Day name
          }
          
          return GestureDetector(
            onTap: () => _selectDay(index, date),
            child: Container(
              width: 70,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.1)
                    : AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.divider,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayLabel,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM').format(date),
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMealTypeContent(String mealType) {
    return BlocBuilder<OrderCubit, OrderState>(
      builder: (context, orderState) {
        // First check if we have a scheduled meal for this day and type
        if (orderState is UpcomingOrdersLoaded) {
          // Find order for the selected date
          final ordersForDate = orderState.orders.where((order) {
            return order.deliveryDate.year == _selectedDate.year &&
                   order.deliveryDate.month == _selectedDate.month &&
                   order.deliveryDate.day == _selectedDate.day;
          }).toList();
          
          if (ordersForDate.isNotEmpty) {
            // Check if this meal type is in the order
            for (var order in ordersForDate) {
              final hasMealType = order.meals.any((meal) => meal.mealType == mealType);
              
              if (hasMealType) {
                return _buildScheduledMealCard(order, mealType);
              }
            }
          }
        }
        
        // If no scheduled meal, show available options
        return _buildAvailableMealsContent(mealType);
      },
    );
  }

  Widget _buildScheduledMealCard(Order order, String mealType) {
    // Find the ordered meal
    final orderedMeal = order.meals.firstWhere(
      (meal) => meal.mealType == mealType,
      orElse: () => const OrderedMeal(
        mealType: '',
        dietPreference: '',
        quantity: 0,
      ),
    );
    
    if (orderedMeal.mealType.isEmpty) {
      return _buildAvailableMealsContent(mealType);
    }
    
    // Get time slot for this meal type
    String timeSlot;
    switch (mealType) {
      case 'breakfast':
        timeSlot = StringConstants.breakfastTime;
        break;
      case 'lunch':
        timeSlot = StringConstants.lunchTime;
        break;
      case 'dinner':
        timeSlot = StringConstants.dinnerTime;
        break;
      default:
        timeSlot = '';
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(
            title: 'Your Scheduled ${mealType.substring(0, 1).toUpperCase()}${mealType.substring(1)}',
          ),
          AppSpacing.vSm,
          AppCard(
            onTap: () => _navigateToOrderDetails(order),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      timeSlot,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    _buildOrderStatusBadge(context, order.status),
                  ],
                ),
                AppSpacing.vSm,
                Divider(),
                AppSpacing.vSm,
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: orderedMeal.dietPreference.toLowerCase() == 'vegetarian'
                            ? AppColors.vegetarian
                            : AppColors.nonVegetarian,
                        shape: BoxShape.circle,
                      ),
                    ),
                    AppSpacing.hSm,
                    Text(
                      '${orderedMeal.dietPreference} (Qty: ${orderedMeal.quantity})',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                AppSpacing.vMd,
                Text(
                  'Delivery to: ${order.deliveryAddress.street}, ${order.deliveryAddress.city}',
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                AppSpacing.vSm,
                Text(
                  'Order #${order.orderNumber}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          AppSpacing.vLg,
          const Divider(),
          AppSpacing.vLg,
          
          // Show other available options
          AppSectionHeader(
            title: 'Other Available Options',
          ),
          AppSpacing.vMd,
          
          // Show available meals below the scheduled one
          _buildAvailableMealsContent(mealType, showHeader: false),
        ],
      ),
    );
  }

  Widget _buildAvailableMealsContent(String mealType, {bool showHeader = true}) {
    return BlocBuilder<MealCustomizationCubit, MealCustomizationState>(
      builder: (context, state) {
        if (state is MealCustomizationLoading) {
          return const Center(child: AppLoading());
        } else if (state is MealCustomizationError) {
          return AppErrorWidget(
            message: state.message,
            onRetry: _loadData,
            retryText: StringConstants.retry,
          );
        } else if (state is MealsLoaded) {
          if (state.meals.isEmpty) {
            return const AppEmptyState(
              message: 'No meals available',
              icon: Icons.restaurant_menu,
            );
          }
          
          // Format meal type for display
          final formattedMealType = '${mealType.substring(0, 1).toUpperCase()}${mealType.substring(1)}';
          
          // Filter meals based on dietary preferences or other criteria if needed
          final meals = state.meals;
          
          // Get time slot for this meal type
          String timeSlot;
          switch (mealType) {
            case 'breakfast':
              timeSlot = StringConstants.breakfastTime;
              break;
            case 'lunch':
              timeSlot = StringConstants.lunchTime;
              break;
            case 'dinner':
              timeSlot = StringConstants.dinnerTime;
              break;
            default:
              timeSlot = '';
          }
          
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (showHeader) ...[
                AppSectionHeader(
                  title: 'Available $formattedMealType Options',
                  subtitle: timeSlot,
                ),
                AppSpacing.vMd,
              ],
              ...meals.map((meal) => _buildMealCard(meal, mealType)).toList(),
            ],
          );
        }
        
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildMealCard(meal, String mealType) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 16),
      onTap: () => _navigateToMealCustomization(meal.id, mealType),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Meal image placeholder
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(8),
                  image: meal.imageUrl.isNotEmpty
                      ? DecorationImage(
                          image: AssetImage(meal.imageUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: meal.imageUrl.isEmpty
                    ? const Icon(
                        Icons.restaurant,
                        color: AppColors.textSecondary,
                        size: 40,
                      )
                    : null,
              ),
              AppSpacing.hMd,
              
              // Meal details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    AppSpacing.vXs,
                    Text(
                      meal.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    AppSpacing.vSm,
                    
                    // Dietary preferences
                    Wrap(
                      spacing: 8,
                      children: meal.dietaryPreferences.map((pref) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getDietaryPreferenceColor(pref).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            pref.toString().split('.').last,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: _getDietaryPreferenceColor(pref),
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.vMd,
          Divider(),
          AppSpacing.vSm,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₹${meal.price.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Row(
                children: [
                  Text(
                    StringConstants.customize,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                        ),
                  ),
                  AppSpacing.hXs,
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStatusBadge(BuildContext context, OrderStatus status) {
    final Color color;
    final String text;

    switch (status) {
      case OrderStatus.pending:
        color = AppColors.warning;
        text = 'Pending';
        break;
      case OrderStatus.confirmed:
        color = AppColors.info;
        text = 'Confirmed';
        break;
      case OrderStatus.preparing:
        color = AppColors.accent;
        text = 'Preparing';
        break;
      case OrderStatus.ready:
        color = AppColors.success;
        text = 'Ready';
        break;
      case OrderStatus.outForDelivery:
        color = AppColors.primary;
        text = 'On Way';
        break;
      case OrderStatus.delivered:
        color = AppColors.success;
        text = 'Delivered';
        break;
      case OrderStatus.cancelled:
        color = AppColors.error;
        text = 'Cancelled';
        break;
      default:
        color = AppColors.textSecondary;
        text = 'Unknown';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Color _getDietaryPreferenceColor(DietaryPreference preference) {
    switch (preference) {
      case DietaryPreference.vegetarian:
        return AppColors.vegetarian;
      case DietaryPreference.nonVegetarian:
        return AppColors.nonVegetarian;
      case DietaryPreference.vegan:
        return Colors.green.shade700;
      case DietaryPreference.glutenFree:
        return Colors.orange;
      case DietaryPreference.dairyFree:
        return Colors.blue;
      case DietaryPreference.nutFree:
        return Colors.brown;
      case DietaryPreference.pescatarian:
        return Colors.cyan;
      case DietaryPreference.keto:
        return Colors.purple;
      case DietaryPreference.paleo:
        return Colors.amber.shade700;
      default:
        return AppColors.textSecondary;
    }
  }
}