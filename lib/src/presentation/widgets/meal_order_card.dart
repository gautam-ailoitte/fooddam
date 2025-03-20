// lib/src/presentation/widgets/meal_order_card.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/src/domain/entities/meal_order_entity.dart';
import 'package:foodam/src/presentation/utlis/date_formatter.dart';

class MealOrderCard extends StatelessWidget {
  final MealOrder order;
  final String statusMessage;
  
  const MealOrderCard({
    super.key,
    required this.order,
    required this.statusMessage,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormatter();
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildStatusIndicator(),
                AppSpacing.hMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.mealName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        statusMessage,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _getStatusTextColor(),
                        ),
                      ),
                    ],
                  ),
                ),
                if (order.status == OrderStatus.coming) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      dateFormatter.formatTime(order.expectedTime),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    switch (order.status) {
      case OrderStatus.coming:
        return Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: AppColors.accent,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withOpacity(0.3),
                blurRadius: 4,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Pulse(
            duration: Duration(seconds: 2),
          ),
        );
      case OrderStatus.delivered:
        return Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
            color: AppColors.success,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check,
            size: 8,
            color: Colors.white,
          ),
        );
      case OrderStatus.noMeal:
        return Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: AppColors.textSecondary,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.textSecondary.withOpacity(0.3),
              width: 2,
            ),
          ),
        );
      case OrderStatus.notChosen:
        return Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.textSecondary,
              width: 2,
              style: BorderStyle.solid,
            ),
          ),
        );
    }
  }

  Color _getStatusTextColor() {
    switch (order.status) {
      case OrderStatus.coming:
        return AppColors.accent;
      case OrderStatus.delivered:
        return AppColors.success;
      case OrderStatus.noMeal:
      case OrderStatus.notChosen:
        return AppColors.textSecondary;
    }
  }
}

class Pulse extends StatefulWidget {
  final Duration duration;
  
  const Pulse({
    Key? key,
    this.duration = const Duration(milliseconds: 1500),
  }) : super(key: key);

  @override
  _PulseState createState() => _PulseState();
}

class _PulseState extends State<Pulse> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: 1.0 - _animation.value * 0.5,
          child: Container(),
        );
      },
    );
  }
}