// Updated ActivePlanPage
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/string_constants.dart';
import 'package:foodam/core/utils/date_utils.dart';
import 'package:foodam/src/domain/entities/user_entity.dart';

class ActivePlanPage extends StatefulWidget {
  final Plan plan;

  const ActivePlanPage({
    super.key,
    required this.plan,
  });

  @override
  _ActivePlanPageState createState() => _ActivePlanPageState();
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
            return Tab(text: _getDayName(day));
          }).toList(),
          indicatorColor: Colors.white,
        ),
      ),
      body: Column(
        children: [
          // Plan summary card
          _buildPlanSummaryCard(),
          
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

  Widget _buildPlanSummaryCard() {
    final plan = widget.plan;
    
    return Card(
      margin: EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            // Plan icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.restaurant_menu,
                color: Theme.of(context).colorScheme.primary,
                size: 32,
              ),
            ),
            SizedBox(width: 16),
            
            // Plan details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    plan.isVeg ? 'Vegetarian Plan' : 'Non-Vegetarian Plan',
                    style: TextStyle(
                      fontSize: 14,
                      color: plan.isVeg ? Colors.green : Colors.red,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 4),
                      Text(
                        _getPlanDurationText(plan),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
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
          _buildMealCard(
            title: StringConstants.breakfast,
            thali: dailyMeals.breakfast,
            icon: Icons.wb_sunny,
            timeSlot: '7:00 AM - 9:00 AM',
          ),
          
          // Lunch
          _buildMealCard(
            title: StringConstants.lunch,
            thali: dailyMeals.lunch,
            icon: Icons.wb_sunny_outlined,
            timeSlot: '12:00 PM - 2:00 PM',
          ),
          
          // Dinner
          _buildMealCard(
            title: StringConstants.dinner,
            thali: dailyMeals.dinner,
            icon: Icons.nightlight_round,
            timeSlot: '7:00 PM - 9:00 PM',
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
                    'Daily Total',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '₹${dailyMeals.dailyTotal.toStringAsFixed(2)}',
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

  Widget _buildMealCard({
    required String title,
    required Thali? thali,
    required IconData icon,
    required String timeSlot,
  }) {
    if (thali == null) {
      return Card(
        margin: EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: Colors.grey[500],
                ),
              ),
              SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'No meal selected',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
    
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Meal header
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _getThaliColor(thali.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: _getThaliColor(thali.type),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getThaliColor(thali.type).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              thali.name,
                              style: TextStyle(
                                fontSize: 12,
                                color: _getThaliColor(thali.type),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Spacer(),
                          Text(
                            timeSlot,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Divider
            Divider(height: 24),
            
            // Meal items
            Text(
              'Meal Items:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: thali.selectedMeals.length,
              itemBuilder: (context, index) {
                final meal = thali.selectedMeals[index];
                return Row(
                  children: [
                    Icon(
                      meal.isVeg ? Icons.eco : Icons.restaurant,
                      size: 14,
                      color: meal.isVeg ? Colors.green : Colors.red,
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        meal.name,
                        style: TextStyle(
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                );
              },
            ),
            
            // Thali price
            Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Price: ',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '₹${thali.totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getDayName(DayOfWeek day) {
    switch (day) {
      case DayOfWeek.monday:
        return StringConstants.monday;
      case DayOfWeek.tuesday:
        return StringConstants.tuesday;
      case DayOfWeek.wednesday:
        return StringConstants.wednesday;
      case DayOfWeek.thursday:
        return StringConstants.thursday;
      case DayOfWeek.friday:
        return StringConstants.friday;
      case DayOfWeek.saturday:
        return StringConstants.saturday;
      case DayOfWeek.sunday:
        return StringConstants.sunday;
    }
  }

  String _getPlanDurationText(Plan plan) {
    String durationText = '';
    
    switch (plan.duration) {
      case PlanDuration.sevenDays:
        durationText = '7 Days';
        break;
      case PlanDuration.fourteenDays:
        durationText = '14 Days';
        break;
      case PlanDuration.twentyEightDays:
        durationText = '28 Days';
        break;
    }
    
    if (plan.startDate != null && plan.endDate != null) {
      final startDateStr = DateUtil.formatDate(plan.startDate!);
      final endDateStr = DateUtil.formatDate(plan.endDate!);
      return '$durationText Plan ($startDateStr to $endDateStr)';
    }
    
    return '$durationText Plan';
  }

  Color _getThaliColor(ThaliType type) {
    switch (type) {
      case ThaliType.normal:
        return Colors.green;
      case ThaliType.nonVeg:
        return Colors.red;
      case ThaliType.deluxe:
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }
}