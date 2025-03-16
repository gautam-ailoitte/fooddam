// lib/src/presentation/views/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/string_constants.dart';
import 'package:foodam/mock_data.dart';
import 'package:foodam/src/domain/entities/meal_entity.dart';
import 'package:foodam/src/domain/entities/plan_entity.dart';
import 'package:foodam/src/presentation/cubits/active_plan_cubit/active_plan_cubit.dart';
import 'package:foodam/src/presentation/cubits/auth_cubit/auth_cubits.dart';
import 'package:foodam/src/presentation/cubits/draft_plan_cubit/draft_plan_cubit.dart';
import 'package:foodam/src/presentation/cubits/plan_customization_cubit/plan_customization_cubit.dart';
import 'package:foodam/src/presentation/helpers/home_page_helper.dart';
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
        title: Text(StringConstants.appTitle),
        actions: [
          // Toggle for mock data
          Row(
            children: [
              Text(StringConstants.hasPlan, style: TextStyle(fontSize: 12)),
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
                  tooltip: StringConstants.resumeDraft,
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
                  return AppLoading(message: StringConstants.loadingSubscription);
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
            title: Text(StringConstants.logout),
            content: Text(StringConstants.logoutConfirmation),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(StringConstants.cancel),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<AuthCubit>().logout();
                },
                child: Text(StringConstants.logout),
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
                    plan.isVeg ? StringConstants.vegetarianPlan : StringConstants.nonVegetarianPlan,
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
                        '${StringConstants.startDate} ${HomePageHelper.formatDate(plan.startDate)}',
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
                        '${StringConstants.endDate} ${HomePageHelper.formatDate(plan.endDate)}',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  Divider(height: 32),
                  AppButton(
                    label: StringConstants.viewCompleteMenu,
                    onPressed: () {
                      NavigationHelper.goToActivePlan(context, plan);
                    },
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 24),

          // Today's meal section
          Text(
            StringConstants.todayMeals,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),

          // Today's meals cards
          HomePageHelper.buildTodayMealCard(
            context,
            icon: Icons.wb_sunny,
            title: StringConstants.breakfast,
            thaliName: HomePageHelper.getTodayMealName(plan, MealType.breakfast),
            time: '7:00 AM - 9:00 AM',
          ),

          HomePageHelper.buildTodayMealCard(
            context,
            icon: Icons.wb_sunny_outlined,
            title: StringConstants.lunch,
            thaliName: HomePageHelper.getTodayMealName(plan, MealType.lunch),
            time: '12:00 PM - 2:00 PM',
          ),

          HomePageHelper.buildTodayMealCard(
            context,
            icon: Icons.nightlight_round,
            title: StringConstants.dinner,
            thaliName: HomePageHelper.getTodayMealName(plan, MealType.dinner),
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
                                  StringConstants.youHaveDraftPlan,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber[800],
                                  ),
                                ),
                                Text(
                                  StringConstants.tapToResume,
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
              StringConstants.noSubscription,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            AppButton(
              label: StringConstants.selectPlan,
              onPressed: () {
                NavigationHelper.goToPlanSelection(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}