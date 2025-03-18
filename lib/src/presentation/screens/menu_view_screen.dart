// lib/src/presentation/screens/menu/menu_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/constants/string_constants.dart';
import 'package:foodam/core/layout/app_scaffold.dart';
import 'package:foodam/core/widgets/app_loading.dart';
import 'package:foodam/core/widgets/app_error_widget.dart';
import 'package:foodam/src/presentation/cubits/menu/menu_cubit.dart';
import 'package:foodam/src/presentation/widgets/day_selector.dart';
import 'package:foodam/src/presentation/widgets/meal_list.dart';
import 'package:foodam/src/presentation/widgets/meal_type_tab.dart';
import 'package:intl/intl.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      type: ScaffoldType.withAppBar,
      title: StringConstants.viewCompleteMenu,
      body: BlocBuilder<MenuCubit, MenuState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date selector
              DateSelector(
                selectedDate: context.read<MenuCubit>().selectedDate,
                onDateSelected: (date) {
                  context.read<MenuCubit>().loadMenuForDate(date);
                },
              ),
              
              // Meal type tabs
              MealTypeTabs(
                selectedMealType: context.read<MenuCubit>().selectedMealType,
                onMealTypeSelected: (mealType) {
                  context.read<MenuCubit>().setMealType(mealType);
                },
              ),
              
              // Flexible content that shows either loading, error, or meal list
              Expanded(
                child: _buildContent(context, state),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, MenuState state) {
    if (state is MenuInitial) {
      // Trigger menu load on initial state
      Future.microtask(() => context.read<MenuCubit>().initMenu());
      return const AppLoading();
    }
    
    if (state is MenuLoading) {
      return const AppLoading();
    }
    
    if (state is MenuError) {
      return AppErrorWidget(
        message: state.message,
        onRetry: () => context.read<MenuCubit>().initMenu(),
        retryText: StringConstants.retry,
      );
    }
    
    if (state is MenuLoaded) {
      return MealList(
        dishes: state.availableDishes,
        mealType: state.selectedMealType,
        selectedDate: state.selectedDate,
      );
    }
    
    // Fallback for any unhandled state
    return const Center(
      child: Text('Something went wrong. Please try again.'),
    );
  }
}