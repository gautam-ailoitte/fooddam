// lib/src/presentation/screens/plan/plan_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/constants/string_constants.dart';
import 'package:foodam/core/layout/app_scaffold.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/widgets/app_empty_state.dart';
import 'package:foodam/core/widgets/app_error_widget.dart';
import 'package:foodam/core/widgets/app_loading.dart';
import 'package:foodam/src/domain/entities/subscription_plan_entity.dart';
import 'package:foodam/src/presentation/cubits/meal_plan/meal_plan_cubit.dart';
import 'package:foodam/src/presentation/cubits/subscription_plan/subscription_plan_cubit.dart';
import 'package:foodam/src/presentation/cubits/subscription_plan/subscription_plan_state.dart';
import 'package:foodam/src/presentation/widgets/plan_card.dart';

class PlanSelectionScreen extends StatefulWidget {
  const PlanSelectionScreen({super.key});

  @override
  State<PlanSelectionScreen> createState() => _PlanSelectionScreenState();
}

class _PlanSelectionScreenState extends State<PlanSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilterType = '';

  @override
  void initState() {
    super.initState();
    context.read<SubscriptionPlansCubit>().getSubscriptionPlans();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: StringConstants.selectPlan,
      body: Column(
        children: [
          _buildFilterSection(),
          
          Expanded(
            child: BlocBuilder<SubscriptionPlansCubit, SubscriptionPlansState>(
              builder: (context, state) {
                if (state is SubscriptionPlansLoading) {
                  return const Center(
                    child: AppLoading(message: StringConstants.loadingPlans),
                  );
                } else if (state is SubscriptionPlansError) {
                  return AppErrorWidget(
                    message: state.message,
                    retryText: StringConstants.retry,
                    onRetry: () {
                      context.read<SubscriptionPlansCubit>().getSubscriptionPlans();
                    },
                  );
                } else if (state is SubscriptionPlansLoaded) {
                  if (state.filteredPlans.isEmpty) {
                    return AppEmptyState(
                      message: StringConstants.noPlansAvailable,
                      icon: Icons.search_off,
                    );
                  }
                  
                  return ListView.builder(
                    padding: AppSpacing.pagePadding,
                    itemCount: state.filteredPlans.length,
                    itemBuilder: (context, index) {
                      final plan = state.filteredPlans[index];
                      return PlanCard(
                        plan: plan,
                        onTap: () => _selectPlan(plan),
                      );
                    },
                  );
                }
                
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search field
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search plans',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _filterPlans(null);
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.backgroundLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onChanged: _filterPlans,
          ),
          
          AppSpacing.vMd,
          
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', ''),
                _buildFilterChip('Vegetarian', 'vegetarian'),
                _buildFilterChip('Non-Vegetarian', 'non-vegetarian'),
                _buildFilterChip('Premium', 'premium'),
                _buildFilterChip('Deluxe', 'deluxe'),
                _buildFilterChip('Healthy', 'healthy'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String filterType) {
    final isSelected = _selectedFilterType == filterType;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilterType = selected ? filterType : '';
          });
          context.read<SubscriptionPlansCubit>().filterPlansByType(
            selected ? filterType : '',
          );
        },
        backgroundColor: AppColors.backgroundLight,
        selectedColor: AppColors.primary,
        checkmarkColor: Colors.white,
      ),
    );
  }

  void _filterPlans(String? query) {
    // This could be more sophisticated with proper filtering logic
    if (query?.isNotEmpty ?? false) {
      context.read<SubscriptionPlansCubit>().filterPlansByType(query!);
    } else {
      context.read<SubscriptionPlansCubit>().filterPlansByType(_selectedFilterType);
    }
  }

  void _selectPlan(SubscriptionPlan plan) {
    // When a plan is selected, initialize the meal plan selection process
    final mealPlanCubit = context.read<MealPlanSelectionCubit>();
    mealPlanCubit.selectPlanType(plan);
    
    Navigator.pushNamed(context, '/plan-duration');
  }
}