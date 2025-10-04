// lib/src/presentation/widgets/past_orders_widget.dart (UPDATED)
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/src/domain/entities/order_entity.dart';
import 'package:intl/intl.dart';

class PastOrdersWidget extends StatefulWidget {
  final Map<DateTime, List<Order>> ordersByDate;
  final Function() onLoadMore;
  final bool isLoadingMore;
  final bool canLoadMore;

  const PastOrdersWidget({
    super.key,
    required this.ordersByDate,
    required this.onLoadMore,
    required this.isLoadingMore,
    required this.canLoadMore,
  });

  @override
  State<PastOrdersWidget> createState() => _PastOrdersWidgetState();
}

class _PastOrdersWidgetState extends State<PastOrdersWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Check if we're near the bottom
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        widget.canLoadMore &&
        !widget.isLoadingMore) {
      widget.onLoadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sort dates in reverse chronological order
    final dates =
        widget.ordersByDate.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: dates.length + (widget.canLoadMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= dates.length) {
          // Loading indicator at the bottom
          return Container(
            padding: EdgeInsets.all(AppDimensions.marginMedium),
            alignment: Alignment.center,
            child:
                widget.isLoadingMore
                    ? const CircularProgressIndicator(color: AppColors.primary)
                    : GestureDetector(
                      onTap: widget.onLoadMore,
                      child: Text(
                        'Load more...',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
          );
        }

        final date = dates[index];
        final orders = widget.ordersByDate[date]!;
        return _buildDateSection(context, date, orders);
      },
    );
  }

  Widget _buildDateSection(
    BuildContext context,
    DateTime date,
    List<Order> orders,
  ) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final isYesterday =
        date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;

    String dateText =
        isYesterday ? 'Yesterday' : DateFormat('EEEE, MMMM d').format(date);

    return Container(
      margin: EdgeInsets.only(
        left: AppDimensions.marginMedium,
        right: AppDimensions.marginMedium,
        bottom: AppDimensions.marginLarge,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(bottom: AppDimensions.marginSmall),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.marginMedium,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isYesterday ? AppColors.accent : Colors.grey.shade700,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.borderRadiusSmall,
                    ),
                  ),
                  child: Text(
                    dateText,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: AppDimensions.marginSmall),
                Text(
                  '${orders.length} meals',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          ...orders.map((order) => _buildOrderItem(context, order)),
        ],
      ),
    );
  }

  Widget _buildOrderItem(BuildContext context, Order order) {
    final Color accentColor = _getMealTypeColor(order.timing ?? 'lunch');

    return GestureDetector(
      onTap: () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => OrderMealDetailScreen(order: order),
        //   ),
        // );
      },
      child: Card(
        margin: EdgeInsets.only(bottom: AppDimensions.marginSmall),
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.marginMedium),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Meal image or placeholder
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    AppDimensions.borderRadiusSmall,
                  ),
                  image:
                      order.dish?.imageUrl != null &&
                              order.dish!.imageUrl!.isNotEmpty
                          ? DecorationImage(
                            image: NetworkImage(order.dish!.imageUrl!),
                            fit: BoxFit.cover,
                          )
                          : null,
                ),
                child:
                    order.dish?.imageUrl == null ||
                            order.dish!.imageUrl!.isEmpty
                        ? Icon(
                          _getMealTypeIcon(order.timing ?? 'lunch'),
                          color: accentColor,
                          size: 32,
                        )
                        : null,
              ),
              SizedBox(width: AppDimensions.marginMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          order.mealType,
                          style: Theme.of(
                            context,
                          ).textTheme.titleSmall?.copyWith(
                            color: accentColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _getFormattedTime(order),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      order.dish?.name ?? 'Unknown Dish',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (order.dish?.description != null &&
                        order.dish!.description.isNotEmpty) ...[
                      SizedBox(height: 4),
                      Text(
                        order.dish!.description,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    SizedBox(height: AppDimensions.marginSmall),
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 16,
                          color: AppColors.success,
                        ),
                        SizedBox(width: 4),
                        Text(
                          order.statusText,
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods
  IconData _getMealTypeIcon(String timing) {
    switch (timing.toLowerCase()) {
      case 'breakfast':
        return Icons.free_breakfast;
      case 'lunch':
        return Icons.lunch_dining;
      case 'dinner':
        return Icons.dinner_dining;
      default:
        return Icons.restaurant;
    }
  }

  Color _getMealTypeColor(String timing) {
    switch (timing.toLowerCase()) {
      case 'breakfast':
        return Colors.orange;
      case 'lunch':
        return AppColors.accent;
      case 'dinner':
        return Colors.purple;
      default:
        return AppColors.primary;
    }
  }

  String _getFormattedTime(Order order) {
    // Use estimated delivery time from order entity
    final estimatedTime = order.estimatedDeliveryTime;

    if (estimatedTime == null) return 'N/A';

    final hour =
        estimatedTime.hour > 12
            ? estimatedTime.hour - 12
            : estimatedTime.hour == 0
            ? 12
            : estimatedTime.hour;
    final period = estimatedTime.hour >= 12 ? 'PM' : 'AM';
    final minute = estimatedTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }
}
