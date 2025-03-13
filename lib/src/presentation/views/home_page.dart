// lib/src/presentation/views/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/string_constants.dart';
import 'package:foodam/mock_data.dart';
import 'package:foodam/src/domain/entities/user_entity.dart';
import 'package:foodam/src/presentation/cubits/active_plan_cubit/active_plan_cubit.dart';
import 'package:foodam/src/presentation/cubits/auth_cubit/auth_cubits.dart';
import 'package:foodam/src/presentation/cubits/draft_plan_cubit/draft_plan_cubit.dart';
import 'package:foodam/src/presentation/cubits/plan_customization_cubit/plan_customization_cubit.dart';
import 'package:foodam/src/presentation/utlis/helper.dart';
import 'package:foodam/src/presentation/widgets/common/app_button.dart';
import 'package:foodam/src/presentation/widgets/common/app_loading.dart';
import 'package:foodam/src/presentation/widgets/common/error_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _hasActivePlan = true;

  @override
  void initState() {
    super.initState();
    // Load active plan
    context.read<ActivePlanCubit>().loadActivePlan();
    // Check for draft plans
    context.read<DraftPlanCubit>().checkForDraft();
    // Initialize with mock data state
    _hasActivePlan = MockData.getMockUser().hasActivePlan;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meal Subscription'),
        actions: [
          // Toggle for mock data
          Row(
            children: [
              Text('Has Plan', style: TextStyle(fontSize: 12)),
              Switch(
                value: _hasActivePlan,
                onChanged: (value) {
                  setState(() {
                    _hasActivePlan = value;
                    // Toggle in mock data
                    MockData.toggleActivePlan();
                    // Reload active plan
                    context.read<ActivePlanCubit>().loadActivePlan();
                  });
                },
              ),
            ],
          ),
          // Draft plan button
          BlocBuilder<DraftPlanCubit, DraftPlanState>(
            builder: (context, state) {
              if (state is DraftPlanAvailable) {
                return IconButton(
                  icon: Icon(Icons.edit_note),
                  tooltip: 'Resume Draft Plan',
                  onPressed: () {
                    _resumeDraftPlan(state.plan);
                  },
                );
              }
              return SizedBox.shrink();
            },
          ),
          // Logout button
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: _showLogoutDialog,
          ),
        ],
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, authState) {
          if (authState is AuthUnauthenticated) {
            NavigationHelper.goToHome(context); // Will go to login
          }
        },
        builder: (context, authState) {
          if (authState is AuthAuthenticated) {
            return BlocBuilder<ActivePlanCubit, ActivePlanState>(
              builder: (context, planState) {
                if (planState is ActivePlanLoading) {
                  return AppLoading(message: 'Loading subscription data...');
                } else if (planState is ActivePlanLoaded) {
                  return _buildActivePlanView(context, planState.activePlan);
                } else if (planState is ActivePlanNotFound) {
                  return BlocBuilder<DraftPlanCubit, DraftPlanState>(
                    builder: (context, draftState) {
                      final draftPlan =
                          (draftState is DraftPlanAvailable)
                              ? draftState.plan
                              : null;
                      return _buildNoPlanView(context, draftPlan);
                    },
                  );
                } else if (planState is ActivePlanError) {
                  return AppErrorWidget(
                    message: planState.message,
                    onRetry:
                        () => context.read<ActivePlanCubit>().loadActivePlan(),
                  );
                }
                return AppLoading();
              },
            );
          }
          return AppLoading();
        },
      ),
    );
  }

  void _resumeDraftPlan(Plan plan) {
    // Start customizing with draft plan
    context.read<PlanCustomizationCubit>().resumeCustomization(plan);
    // Navigate to details
    NavigationHelper.goToPlanDetails(context);
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Log Out'),
            content: Text('Are you sure you want to log out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<AuthCubit>().logout();
                },
                child: Text('Log Out'),
              ),
            ],
          ),
    );
  }

  Widget _buildActivePlanView(BuildContext context, Plan plan) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active plan card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 8),
                      Text(
                        StringConstants.activePlan,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    plan.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    plan.isVeg ? 'Vegetarian Plan' : 'Non-Vegetarian Plan',
                    style: TextStyle(
                      fontSize: 16,
                      color: plan.isVeg ? Colors.green : Colors.red,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.date_range, size: 16, color: Colors.grey[600]),
                      SizedBox(width: 8),
                      Text(
                        'Start Date: ${plan.startDate != null ? "${plan.startDate!.day}/${plan.startDate!.month}/${plan.startDate!.year}" : "Not started yet"}',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.date_range, size: 16, color: Colors.grey[600]),
                      SizedBox(width: 8),
                      Text(
                        'End Date: ${plan.endDate != null ? "${plan.endDate!.day}/${plan.endDate!.month}/${plan.endDate!.year}" : "Not set"}',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  Divider(height: 32),
                  AppButton(
                    label: 'View Complete Menu',
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).pushNamed('/active-plan', arguments: plan);
                    },
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 24),

          // Today's meal section
          Text(
            "Today's Meals",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),

          // Today's meals cards
          _buildTodayMealCard(
            context,
            icon: Icons.wb_sunny,
            title: StringConstants.breakfast,
            thaliName:
                _getTodayMeal(plan, MealType.breakfast)?.name ?? 'Not selected',
            time: '7:00 AM - 9:00 AM',
          ),

          _buildTodayMealCard(
            context,
            icon: Icons.wb_sunny_outlined,
            title: StringConstants.lunch,
            thaliName:
                _getTodayMeal(plan, MealType.lunch)?.name ?? 'Not selected',
            time: '12:00 PM - 2:00 PM',
          ),

          _buildTodayMealCard(
            context,
            icon: Icons.nightlight_round,
            title: StringConstants.dinner,
            thaliName:
                _getTodayMeal(plan, MealType.dinner)?.name ?? 'Not selected',
            time: '7:00 PM - 9:00 PM',
          ),
        ],
      ),
    );
  }

  Widget _buildNoPlanView(BuildContext context, Plan? draftPlan) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Show draft plan card if available
            if (draftPlan != null)
              GestureDetector(
                onTap: () {
                  // Start customizing the draft plan
                  context.read<PlanCustomizationCubit>().resumeCustomization(
                    draftPlan,
                  );
                  // Navigate to plan details
                  NavigationHelper.goToPlanDetails(context);
                },
                child: Container(
                  margin: EdgeInsets.only(bottom: 24),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber[700]!),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.edit_document, color: Colors.amber[800]),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'You have a draft plan',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber[800],
                                  ),
                                ),
                                Text(
                                  'Tap to resume customization',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.amber[800],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.amber[800],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            Icon(Icons.restaurant_menu, size: 80, color: Colors.grey[400]),
            SizedBox(height: 24),
            Text(
              StringConstants.noPlan,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              'Subscribe to a meal plan to get delicious food delivered to you every day.',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            AppButton(
              label: StringConstants.selectPlan,
              onPressed: () {
                Navigator.of(context).pushNamed('/plan-selection');
              },
            ),
          ],
        ),
      ),
    );
  }

  Thali? _getTodayMeal(Plan plan, MealType mealType) {
    // Get today's day of week
    final today = DateTime.now().weekday;
    DayOfWeek dayOfWeek;

    switch (today) {
      case 1:
        dayOfWeek = DayOfWeek.monday;
        break;
      case 2:
        dayOfWeek = DayOfWeek.tuesday;
        break;
      case 3:
        dayOfWeek = DayOfWeek.wednesday;
        break;
      case 4:
        dayOfWeek = DayOfWeek.thursday;
        break;
      case 5:
        dayOfWeek = DayOfWeek.friday;
        break;
      case 6:
        dayOfWeek = DayOfWeek.saturday;
        break;
      case 7:
        dayOfWeek = DayOfWeek.sunday;
        break;
      default:
        dayOfWeek = DayOfWeek.monday;
    }

    // Use the helper method from our enhanced Plan model
    return plan.getMeal(dayOfWeek, mealType);
  }

  Widget _buildTodayMealCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String thaliName,
    required String time,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Theme.of(context).colorScheme.primary),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 4),
                  Text(thaliName, style: TextStyle(fontSize: 14)),
                  SizedBox(height: 4),
                  Text(
                    time,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}