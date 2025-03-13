// Updated PlanDetailsPage
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/string_constants.dart';
import 'package:foodam/src/domain/entities/user_entity.dart';
import 'package:foodam/src/presentation/cubits/draft_plan_cubit/draft_plan_cubit.dart';
import 'package:foodam/src/presentation/cubits/plan_customization_cubit/plan_customization_cubit.dart';
import 'package:foodam/src/presentation/payment_cubit/payment_cubit.dart';
import 'package:foodam/src/presentation/utlis/helper.dart';
import 'package:foodam/src/presentation/widgets/common/app_button.dart';
import 'package:foodam/src/presentation/widgets/common/app_loading.dart';
import 'package:foodam/src/presentation/widgets/daily_selector_widget.dart';
import 'package:foodam/src/presentation/widgets/meal_summary_widget.dart';

class PlanDetailsPage extends StatefulWidget {
  const PlanDetailsPage({super.key});

  @override
  State<PlanDetailsPage> createState() => _PlanDetailsPageState();
}

class _PlanDetailsPageState extends State<PlanDetailsPage> with RouteAware {
  final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
  DayOfWeek _selectedDay = DayOfWeek.monday;
  
  @override
  void initState() {
    super.initState();
    // Initialize any state here
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get the current route
    final ModalRoute<dynamic>? route = ModalRoute.of(context);
    if (route is PageRoute) {
      // Now it's properly cast as PageRoute
      routeObserver.subscribe(this, route);
    }
  }
  
  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }
  
  // This is now correctly overriding a method from RouteAware
  @override
  void didPopNext() {
    // Refresh state when returning to this page from another route
    setState(() {});
  }
  
  // // Add the other RouteAware methods that need to be implemented
  // @override
  // void didPush() {
  //   // Called when the current route has been pushed
  // }
  
  // @override
  // void didPop() {
  //   // Called when the current route has been popped
  // }
  
  // @override
  // void didPushNext() {
  //   // Called when a new route has been pushed and the current route is no longer visible
  // }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(StringConstants.planDetails),
          actions: [
            // Save draft button
            IconButton(
              icon: Icon(Icons.save),
              onPressed: _saveDraft,
              tooltip: 'Save Draft',
            ),
            // Reset button
            IconButton(
              icon: Icon(Icons.restart_alt),
              onPressed: _showResetConfirmation,
              tooltip: 'Reset Plan',
            ),
          ],
        ),
        body: MultiBlocListener(
          listeners: [
            BlocListener<PlanCustomizationCubit, PlanCustomizationState>(
              listener: (context, state) {
                if (state is PlanCustomizationCompleted) {
                  // Initiate payment process
                  context.read<PaymentCubit>().initiatePayment(state.plan);
                  // Navigate to payment
                  NavigationHelper.goToPayment(context);
                }
              },
            ),
            BlocListener<DraftPlanCubit, DraftPlanState>(
              listener: (context, state) {
                if (state is DraftPlanSaved) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Plan saved as draft')),
                  );
                } else if (state is DraftPlanError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }
              },
            ),
          ],
          child: BlocBuilder<PlanCustomizationCubit, PlanCustomizationState>(
            builder: (context, state) {
              if (state is PlanCustomizationLoading) {
                return AppLoading(message: 'Processing plan...');
              } else if (state is PlanCustomizationActive) {
                return _buildPlanDetailsContent(state.plan);
              } else if (state is PlanCustomizationError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(state.message),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Go Back'),
                      ),
                    ],
                  ),
                );
              }
              
              // If not in customization state, navigate back
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).pop();
              });
              
              return AppLoading();
            },
          ),
        ),
        bottomNavigationBar: BlocBuilder<PlanCustomizationCubit, PlanCustomizationState>(
          builder: (context, state) {
            if (state is PlanCustomizationActive) {
              return SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: AppButton(
                    label: StringConstants.proceedToPayment,
                    onPressed: _proceedToPayment,
                  ),
                ),
              );
            }
            return SizedBox.shrink();
          },
        ),
      ),
    );
  }
  
  Future<bool> _onWillPop() async {
    final state = context.read<PlanCustomizationCubit>().state;
    if (state is PlanCustomizationActive && state.plan.isModified) {
      // Show confirmation dialog
      final result = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Discard Customizations?'),
          content: Text('Going back will discard your customizations. Do you want to save them as a draft instead?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop('discard'),
              child: Text('Discard'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop('save'),
              child: Text('Save Draft'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop('cancel'),
              child: Text('Cancel'),
            ),
          ],
        ),
      );
      
      if (result == 'discard') {
        // Clear draft and reset customization
        context.read<DraftPlanCubit>().clearDraft();
        context.read<PlanCustomizationCubit>().reset();
        return true;
      } else if (result == 'save') {
        // Save draft
        _saveDraft();
        return true;
      }
      
      return false; // Don't pop if canceled
    }
    
    // If no customization or state is not active, reset and allow pop
    context.read<PlanCustomizationCubit>().reset();
    return true;
  }
  
  void _onDaySelected(DayOfWeek day) {
    setState(() {
      _selectedDay = day;
    });
  }
  
  void _saveDraft() {
    final state = context.read<PlanCustomizationCubit>().state;
    if (state is PlanCustomizationActive) {
      context.read<DraftPlanCubit>().saveDraft(state.plan);
    }
  }
  
  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset Plan?'),
        content: Text('This will reset all your customizations to default. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final state = context.read<PlanCustomizationCubit>().state;
              if (state is PlanCustomizationActive) {
                final templatePlan = state.plan.copyWith(
                  isCustomized: false,
                  mealsByDay: {}, // Reset meals
                );
                context.read<PlanCustomizationCubit>().startCustomization(templatePlan);
              }
            },
            child: Text('Reset'),
          ),
        ],
      ),
    );
  }
  
  void _proceedToPayment() {
    final state = context.read<PlanCustomizationCubit>().state;
    if (state is PlanCustomizationActive) {
      context.read<PlanCustomizationCubit>().saveCustomization();
    }
  }
  
  void _onMealEdit(MealType mealType) {
    NavigationHelper.goToThaliSelection(
      context,
      _selectedDay,
      mealType,
    );
  }
  
  Widget _buildPlanDetailsContent(Plan plan) {
    final dailyMeals = plan.mealsByDay[_selectedDay] ?? DailyMeals();
    
    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Plan summary card
          Card(
            margin: EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: plan.isVeg ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          plan.isVeg ? 'Veg' : 'Non-Veg',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          plan.durationText,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Amount',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '₹${plan.totalPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Day selector
          DaySelector(
            selectedDay: _selectedDay,
            onDaySelected: _onDaySelected,
            planDuration: plan.duration,
          ),
          
          // Divider
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Divider(),
          ),
          
          // Meals for selected day
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Meals for ${_getDayName(_selectedDay)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Customize',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
          
          // Meal summary
          MealSummary(
            dailyMeals: dailyMeals,
            onMealEdit: _onMealEdit,
          ),
        ],
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
}