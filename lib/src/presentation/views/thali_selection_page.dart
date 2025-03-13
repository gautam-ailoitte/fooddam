// lib/src/presentation/views/thali_selection_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/string_constants.dart';
import 'package:foodam/src/domain/entities/user_entity.dart';
import 'package:foodam/src/presentation/cubits/draft_plan_cubit/draft_plan_cubit.dart';
import 'package:foodam/src/presentation/cubits/plan_customization_cubit/plan_customization_cubit.dart';
import 'package:foodam/src/presentation/cubits/thali_selection_subit/thali_selection_cubit.dart';
import 'package:foodam/src/presentation/widgets/common/app_loading.dart';
import 'package:foodam/src/presentation/widgets/common/error_widget.dart';
import 'package:foodam/src/presentation/widgets/thali_card_widget.dart';

class ThaliSelectionPage extends StatefulWidget {
  final DayOfWeek dayOfWeek;
  final MealType mealType;
  
  const ThaliSelectionPage({
    super.key,
    required this.dayOfWeek,
    required this.mealType,
  });
  
  @override
  State<ThaliSelectionPage> createState() => _ThaliSelectionPageState();
}

class _ThaliSelectionPageState extends State<ThaliSelectionPage> {
  @override
  void initState() {
    super.initState();
    // Load thali options
    context.read<ThaliSelectionCubit>().loadThaliOptions(
      widget.mealType,
      widget.dayOfWeek,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select ${_getMealTypeTitle()} Thali'),
        actions: [
          // Save draft button
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveDraft,
          ),
        ],
      ),
      body: BlocConsumer<ThaliSelectionCubit, ThaliSelectionState>(
        listener: (context, state) {
          if (state is ThaliSelected) {
            // Get current plan from customization cubit
            final customizationCubit = context.read<PlanCustomizationCubit>();
            final currentPlan = customizationCubit.getCurrentPlan();
            
            if (currentPlan != null) {
              // Update meal in plan
              customizationCubit.updateMeal(
                day: state.day,
                mealType: state.mealType,
                thali: state.selectedThali,
              );
              
              // Go back
              Navigator.of(context).pop();
            } else {
              // Show error
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: No plan being customized')),
              );
            }
          }
        },
        builder: (context, state) {
          if (state is ThaliSelectionLoading) {
            return AppLoading(message: 'Loading thali options...');
          } else if (state is ThaliSelectionError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () => context.read<ThaliSelectionCubit>().loadThaliOptions(
                widget.mealType,
                widget.dayOfWeek,
              ),
            );
          } else if (state is ThaliOptionsLoaded) {
            return _buildThaliOptions(context, state.thaliOptions);
          }
          
          return AppLoading();
        },
      ),
    );
  }
  
  void _saveDraft() {
    final customizationCubit = context.read<PlanCustomizationCubit>();
    final currentPlan = customizationCubit.getCurrentPlan();
    
    if (currentPlan != null) {
      context.read<DraftPlanCubit>().saveDraft(currentPlan);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Progress saved')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: No plan being customized')),
      );
    }
  }
  
  String _getMealTypeTitle() {
    switch (widget.mealType) {
      case MealType.breakfast:
        return StringConstants.breakfast;
      case MealType.lunch:
        return StringConstants.lunch;
      case MealType.dinner:
        return StringConstants.dinner;
      default:
        return '';
    }
  }
  
  Widget _buildThaliOptions(BuildContext context, List<Thali> thalis) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Select a Thali for ${_getMealTypeTitle()}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'You can choose from the following options or customize them',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
          SizedBox(height: 8),
          // Thali options
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: thalis.length,
            itemBuilder: (context, index) {
              final thali = thalis[index];
              return ThaliCard(
                thali: thali,
                isSelected: false, // We don't track selection here
                onSelect: () {
                  // Directly select the thali without customization
                  context.read<ThaliSelectionCubit>().selectThali(
                    thali,
                    widget.dayOfWeek,
                    widget.mealType,
                  );
                },
                onCustomize: () {
                  // Navigate to customization page
                  Navigator.of(context).pushNamed(
                    '/meal-customization',
                    arguments: {
                      'thali': thali,
                      'dayOfWeek': widget.dayOfWeek,
                      'mealType': widget.mealType,
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}