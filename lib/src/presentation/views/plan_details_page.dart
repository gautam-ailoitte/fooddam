// lib/src/presentation/views/plan_details_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/string_constants.dart';
import 'package:foodam/src/domain/entities/daily_meals_entity.dart';
import 'package:foodam/src/domain/entities/dish_entity.dart';
import 'package:foodam/src/domain/entities/plan_entity.dart';
import 'package:foodam/src/presentation/cubits/draft_plan_cubit/draft_plan_cubit.dart';
import 'package:foodam/src/presentation/cubits/plan_customization_cubit/plan_customization_cubit.dart';
import 'package:foodam/src/presentation/helpers/plan_details_helper.dart';
import 'package:foodam/src/presentation/utlis/date_formatter_utility.dart';
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
    // Check if we have a plan in the customization cubit
    final customizationState = context.read<PlanCustomizationCubit>().state;
    if (customizationState is! PlanCustomizationActive) {
      // Check if we have a draft plan
      final draftState = context.read<DraftPlanCubit>().state;
      if (draftState is DraftPlanAvailable) {
        // Resume customization with draft plan
        context.read<PlanCustomizationCubit>().resumeCustomization(draftState.plan);
      } else {
        // No plan to customize, show error and navigate back
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(StringConstants.noPlanToCustomize)),
          );
          Navigator.of(context).pop();
        });
      }
    }
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
              tooltip: StringConstants.saveDraft,
            ),
            // Reset button
            IconButton(
              icon: Icon(Icons.restart_alt),
              onPressed: _showResetConfirmation,
              tooltip: StringConstants.resetPlan,
            ),
          ],
        ),
        body: BlocBuilder<PlanCustomizationCubit, PlanCustomizationState>(
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
                      child: Text(StringConstants.goBack),
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
          title: Text(StringConstants.discardCustomizations),
          content: Text(StringConstants.discardCustomizationsMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop('discard'),
              child: Text(StringConstants.discard),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop('save'),
              child: Text(StringConstants.save),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop('cancel'),
              child: Text(StringConstants.cancel),
            ),
          ],
        ),
      );
      
      if (result == 'discard') {
        // Clear draft and reset customization
        if(!mounted) return false;
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(StringConstants.draftSaved)),
      );
    }
  }
  
  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(StringConstants.resetPlan),
        content: Text(StringConstants.resetPlanConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(StringConstants.cancel),
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
            child: Text(StringConstants.resetPlan),
          ),
        ],
      ),
    );
  }
  
  void _proceedToPayment() {
    // Get the current plan
    final state = context.read<PlanCustomizationCubit>().state;
    if (state is PlanCustomizationActive) {
      final plan = state.plan;
      
      // Create a finalized version of the plan
      final finalPlan = plan.copyWith(isDraft: false);
      
      // Navigate directly to payment summary page
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PlanDetailsHelper.getPaymentSummaryPage(finalPlan),
        ),
      );
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
          PlanDetailsHelper.buildPlanSummaryCard(context, plan),
          
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
                  '${StringConstants.mealsFor} ${DateFormatter.getDayName(_selectedDay)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  StringConstants.customize,
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
}