// lib/src/presentation/views/active_plan_page.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/string_constants.dart';
import 'package:foodam/src/domain/entities/daily_meals_entity.dart';
import 'package:foodam/src/domain/entities/plan_entity.dart';
import 'package:foodam/src/presentation/helpers/active_plan_helper.dart';
import 'package:foodam/src/presentation/utlis/date_formatter_utility.dart';
import 'package:foodam/src/presentation/utlis/price_formatter_utility.dart';

class ActivePlanPage extends StatefulWidget {
  final Plan plan;

  const ActivePlanPage({
    super.key,
    required this.plan,
  });

  @override
  State<ActivePlanPage> createState() => _ActivePlanPageState();
}

class _ActivePlanPageState extends State<ActivePlanPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: DayOfWeek.values.length,
      vsync: this,
    );
    
    // Set initial tab to today
    final today = DateTime.now().weekday - 1; // 0-based index
    if (today >= 0 && today < DayOfWeek.values.length) {
      _tabController.animateTo(today);
    }
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(StringConstants.activePlan),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: DayOfWeek.values.map((day) {
            return Tab(text: DateFormatter.getDayName(day));
          }).toList(),
          indicatorColor: Colors.white,
        ),
      ),
      body: Column(
        children: [
          // Plan summary card
          ActivePlanHelper.buildPlanSummaryCard(context, widget.plan),
          
          // Days and meals tabs
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: DayOfWeek.values.map((day) {
                return _buildDayMealsView(day);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayMealsView(DayOfWeek day) {
    final dailyMeals = widget.plan.mealsByDay[day] ?? DailyMeals();
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breakfast
          ActivePlanHelper.buildMealCard(
            context,
            icon: Icons.wb_sunny,
            title: StringConstants.breakfast,
            thali: dailyMeals.breakfast,
            time: '7:00 AM - 9:00 AM',
          ),

          // Lunch
          ActivePlanHelper.buildMealCard(
            context,
            icon: Icons.wb_sunny_outlined,
            title: StringConstants.lunch,
            thali: dailyMeals.lunch,
            time: '12:00 PM - 2:00 PM',
          ),

          // Dinner
          ActivePlanHelper.buildMealCard(
            context,
            icon: Icons.nightlight_round,
            title: StringConstants.dinner,
            thali: dailyMeals.dinner,
            time: '7:00 PM - 9:00 PM',
          ),
          
          // Daily total
          Card(
            margin: EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    StringConstants.dailyTotal,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    PriceFormatter.formatPrice(dailyMeals.dailyTotal),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}