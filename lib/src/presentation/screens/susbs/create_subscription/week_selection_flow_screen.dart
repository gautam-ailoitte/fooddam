// lib/src/presentation/screens/subscription/week_selection_flow_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/constants/subscription_constants.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/route/app_router.dart';
import 'package:foodam/core/widgets/primary_button.dart';
import 'package:foodam/core/widgets/secondary_button.dart';
import 'package:foodam/src/domain/entities/meal_plan_item.dart';
import 'package:foodam/src/presentation/screens/susbs/create_subscription/week_configuration_bottom_sheet.dart';

import '../../../cubits/subscription/week_selection/week_selection_cubit.dart';
import '../../../cubits/subscription/week_selection/week_selection_state.dart';
import 'enhanced_meal_selection_card.dart';
import 'meal_toggle_controls.dart';

/// ===================================================================
/// 📝 NEW: WeekSelectionFlowScreen with dynamic week progression
/// Features:
/// - Week-by-week configuration and selection
/// - Dynamic "Add Week N+1" flow
/// - Toggle functionality for bulk selection
/// - Per-week validation and progress tracking
/// ===================================================================
class WeekSelectionFlowScreen extends StatefulWidget {
  const WeekSelectionFlowScreen({super.key});

  @override
  State<WeekSelectionFlowScreen> createState() =>
      _WeekSelectionFlowScreenState();
}

class _WeekSelectionFlowScreenState extends State<WeekSelectionFlowScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  final bool _isNavigating = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _tabController = TabController(
      length: SubscriptionConstants.mealTypes.length,
      vsync: this,
    );
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return PopScope(
      onPopInvoked: (didPop) {
        if (didPop) {
          // Navigate back to start planning
          Navigator.pushReplacementNamed(
            context,
            AppRouter.startSubscriptionPlanningRoute,
          );
        }
      },
      child: BlocConsumer<WeekSelectionCubit, WeekSelectionState>(
        listener: _handleStateChanges,
        builder: _buildScreenContent,
      ),
    );
  }

  void _handleStateChanges(BuildContext context, WeekSelectionState state) {
    // if (state is WeekSelectionError) {
    //   if (!_isNavigating) {
    //     _showErrorSnackBar(context, state.message);
    //   }
    // }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        action:
            message.contains('retry') || message.contains('Retry')
                ? SnackBarAction(
                  label: 'Retry',
                  textColor: Colors.white,
                  onPressed: () {
                    context.read<WeekSelectionCubit>().retryCurrentWeek();
                  },
                )
                : null,
      ),
    );
  }

  void _showValidationSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.warning,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildScreenContent(BuildContext context, WeekSelectionState state) {
    if (_isNavigating) {
      return _buildNavigationLoadingScreen();
    }

    if (state is! WeekSelectionActive) {
      return _buildErrorScreen(context, state);
    }

    return _buildMainScreen(context, state);
  }

  Widget _buildNavigationLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: AppDimensions.marginMedium),
            Text(
              'Processing...',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingScreen(String? message) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: AppDimensions.marginMedium),
            Text(
              message ?? 'Loading your meal plan...',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(BuildContext context, WeekSelectionState state) {
    String title = 'Unable to Load';
    String message = 'Unable to load meal selection';
    String actionText = 'Try Again';
    VoidCallback? onPressed;

    // Since WeekSelectionError no longer exists, handle generic error
    onPressed = () {
      Navigator.pushReplacementNamed(
        context,
        AppRouter.startSubscriptionPlanningRoute,
      );
    };

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Meal Selection'),
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(
              context,
              AppRouter.startSubscriptionPlanningRoute,
            );
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 80, color: AppColors.error),
              SizedBox(height: AppSpacing.md),
              Text(
                title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.error,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                message,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SecondaryButton(
                    text: 'Start Over',
                    onPressed: () {
                      context.read<WeekSelectionCubit>().reset();
                      Navigator.pushReplacementNamed(
                        context,
                        AppRouter.startSubscriptionPlanningRoute,
                      );
                    },
                  ),
                  SizedBox(width: AppSpacing.md),
                  PrimaryButton(text: actionText, onPressed: onPressed),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainScreen(BuildContext context, WeekSelectionActive state) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(state),
      body: Column(
        children: [
          // Week Progress Section
          _buildWeekProgressSection(state),

          // ADD THIS: Quick Action Bar for bulk selections
          if (state.isCurrentWeekConfigured && state.currentWeekData != null)
            QuickActionBar(state: state),

          // Current Week Info
          if (state.isCurrentWeekConfigured) ...[
            // _buildCurrentWeekInfoSection(state),
            _buildMealTypeTabs(state),
          ],
          Expanded(child: _buildWeekContent(context, state)),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(context, state),
    );
  }

  PreferredSizeWidget _buildAppBar(WeekSelectionActive state) {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      toolbarHeight: 56,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          Navigator.pushReplacementNamed(
            context,
            AppRouter.startSubscriptionPlanningRoute,
          );
        },
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Week ${state.currentWeek} Planning',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            '${state.maxWeeksConfigured} week${state.maxWeeksConfigured > 1 ? 's' : ''} configured',
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, AppRouter.packagesRoute);
          },
          child: const Text(
            "View Plans",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  /// 📝 NEW: Week progress indicators showing configured weeks
  Widget _buildWeekProgressSection(WeekSelectionActive state) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.marginMedium),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        border: Border(
          bottom: BorderSide(
            color: AppColors.primary.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Week indicators
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                final week = index + 1;
                final isConfigured = state.weekConfigs.containsKey(week);
                final isCurrentWeek = week == state.currentWeek;
                final isComplete =
                    isConfigured &&
                    (state.weekConfigs[week]?.isComplete ?? false);

                return GestureDetector(
                  onTap:
                      isConfigured
                          ? () => context
                              .read<WeekSelectionCubit>()
                              .navigateToWeek(week)
                          : null,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: isCurrentWeek ? 32 : 28,
                      height: isCurrentWeek ? 32 : 28,
                      decoration: BoxDecoration(
                        color:
                            isCurrentWeek
                                ? AppColors.primary
                                : isComplete
                                ? AppColors.success
                                : isConfigured
                                ? AppColors.accent
                                : Colors.grey.shade300,
                        shape: BoxShape.circle,
                        border:
                            isCurrentWeek
                                ? Border.all(color: AppColors.accent, width: 2)
                                : null,
                      ),
                      child: Center(
                        child:
                            isComplete
                                ? Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 14,
                                )
                                : Text(
                                  '$week',
                                  style: TextStyle(
                                    color:
                                        isConfigured
                                            ? Colors.white
                                            : Colors.grey.shade600,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          // Add week button or checkout button
          if (state.maxWeeksConfigured < 4 &&
              state.validateCurrentWeek().isValid)
            _buildAddWeekButton(state)
          else if (state.maxWeeksConfigured > 0)
            _buildCheckoutButton(),
        ],
      ),
    );
  }

  Widget _buildAddWeekButton(WeekSelectionActive state) {
    return OutlinedButton.icon(
      onPressed:
          () => _showWeekConfigurationBottomSheet(
            context,
            state.maxWeeksConfigured + 1,
            state.planningData.dietaryPreference,
          ),
      icon: Icon(Icons.add, size: 16, color: AppColors.primary),
      label: Text(
        'Add Week ${state.maxWeeksConfigured + 1}',
        style: TextStyle(color: AppColors.primary, fontSize: 12),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: AppColors.primary),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
    );
  }

  Widget _buildCheckoutButton() {
    return OutlinedButton.icon(
      onPressed: () {
        // TODO: Navigate to checkout/summary
        _showValidationSnackBar(context, 'Checkout feature coming soon!');
      },
      icon: Icon(Icons.shopping_cart, size: 16, color: AppColors.success),
      label: Text(
        'Checkout',
        style: TextStyle(color: AppColors.success, fontSize: 12),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: AppColors.success),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
    );
  }

  /// 📝 NEW: Current week info with dietary preference and meal plan
  Widget _buildCurrentWeekInfoSection(WeekSelectionActive state) {
    final weekConfig = state.currentWeekConfig!;
    final validation = state.validateCurrentWeek();

    return Container(
      margin: EdgeInsets.all(AppDimensions.marginMedium),
      padding: EdgeInsets.all(AppDimensions.marginMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Week config info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.restaurant_menu,
                      color: AppColors.primary,
                      size: 16,
                    ),
                    SizedBox(width: AppDimensions.marginSmall),
                    Text(
                      '${weekConfig.mealPlan} meals • ${SubscriptionConstants.getDietaryPreferenceText(weekConfig.dietaryPreference)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppDimensions.marginSmall),
                Row(
                  children: [
                    Icon(
                      validation.isValid ? Icons.check_circle : Icons.schedule,
                      color:
                          validation.isValid
                              ? AppColors.success
                              : AppColors.warning,
                      size: 16,
                    ),
                    SizedBox(width: AppDimensions.marginSmall),
                    Text(
                      validation.message,
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            validation.isValid
                                ? AppColors.success
                                : AppColors.warning,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Selection progress
          Container(
            padding: EdgeInsets.all(AppDimensions.marginSmall),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${validation.selectedMeals}/${validation.requiredMeals}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealTypeTabs(WeekSelectionActive state) {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppColors.primary,
        indicatorWeight: 3,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
        tabs:
            SubscriptionConstants.mealTypes.map((mealType) {
              final currentWeekSelections = state.getSelectionsForWeek(
                state.currentWeek,
              );
              final typeSelections =
                  currentWeekSelections
                      .where(
                        (selection) =>
                            selection.timing.toLowerCase() ==
                            mealType.toLowerCase(),
                      )
                      .length;

              return Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(SubscriptionConstants.mealTypeDisplayNames[mealType]!),
                    if (typeSelections > 0) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$typeSelections',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                    // 📝 NEW: Toggle button for meal type
                    IconButton(
                      onPressed: () {
                        context.read<WeekSelectionCubit>().toggleMealType(
                          mealType,
                        );
                      },
                      icon: Icon(
                        Icons.select_all,
                        size: 16,
                        color: AppColors.primary.withOpacity(0.7),
                      ),
                      tooltip: 'Toggle all $mealType meals',
                      padding: const EdgeInsets.all(2),
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildWeekContent(BuildContext context, WeekSelectionActive state) {
    if (!state.isCurrentWeekConfigured) {
      return _buildWeekNotConfiguredState(state);
    }

    // Check if data is null (loading state)
    if (state.currentWeekData == null) {
      return _buildWeekLoadingState();
    }

    final weekData = state.currentWeekData!;

    // Check if data is invalid
    if (!weekData.isValid) {
      return _buildWeekErrorState(context, state);
    }

    // Check if no meals available
    if (weekData.availableMeals?.isEmpty ?? true) {
      return _buildEmptyMealsState();
    }

    return TabBarView(
      controller: _tabController,
      children:
          SubscriptionConstants.mealTypes.map((mealType) {
            return _buildMealTypeGrid(
              mealType,
              weekData.availableMeals!,
              state,
            );
          }).toList(),
    );
  }

  Widget _buildWeekNotConfiguredState(WeekSelectionActive state) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.marginMedium),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.settings, size: 80, color: AppColors.textSecondary),
            SizedBox(height: AppDimensions.marginMedium),
            Text(
              'Configure Week ${state.currentWeek}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: AppDimensions.marginSmall),
            Text(
              'Set your dietary preference and meal plan for this week',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppDimensions.marginLarge),
            PrimaryButton(
              text: 'Configure Week ${state.currentWeek}',
              onPressed:
                  () => _showWeekConfigurationBottomSheet(
                    context,
                    state.currentWeek,
                    state.planningData.dietaryPreference,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealTypeGrid(
    String mealType,
    List<MealPlanItem> allItems,
    WeekSelectionActive state,
  ) {
    final typeMealItems =
        allItems
            .where(
              (item) => item.timing.toLowerCase() == mealType.toLowerCase(),
            )
            .toList();

    if (typeMealItems.isEmpty) {
      return _buildEmptyMealTypeState(mealType);
    }

    return ListView.builder(
      key: PageStorageKey('${mealType}_list'),
      controller: _scrollController,
      padding: EdgeInsets.all(AppDimensions.marginMedium),
      itemCount: typeMealItems.length,
      itemBuilder: (context, index) {
        final item = typeMealItems[index];
        final isSelected = state.isDishSelected(
          state.currentWeek,
          item.dishId,
          item.day,
          item.timing,
        );

        final validation = state.validateCurrentWeek();
        final canSelect = isSelected || validation.missingMeals > 0;

        return _buildMealCard(
          item: item,
          isSelected: isSelected,
          canSelect: canSelect,
          state: state,
        );
      },
    );
  }

  Widget _buildMealCard({
    required MealPlanItem item,
    required bool isSelected,
    required bool canSelect,
    required WeekSelectionActive state,
  }) {
    return EnhancedMealSelectionCard(
      item: item,
      isSelected: isSelected,
      canSelect: canSelect,
      state: state,
      onTap: () {
        final packageId = state.currentWeekData?.packageId ?? '';
        context.read<WeekSelectionCubit>().toggleMealSelection(
          week: state.currentWeek,
          item: item,
          packageId: packageId,
        );
      },
    );
  }

  // Widget _buildMealCard({
  //   required MealPlanItem item,
  //   required bool isSelected,
  //   required bool canSelect,
  //   required WeekSelectionActive state,
  // }) {
  //   final cardKey = Key(
  //     '${state.currentWeek}_${item.day}_${item.timing}_${item.dishId}',
  //   );
  //
  //   return Card(
  //     key: cardKey,
  //     margin: EdgeInsets.only(bottom: AppDimensions.marginMedium),
  //     elevation: isSelected ? 4 : 1,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.circular(12),
  //       side: BorderSide(
  //         color: isSelected ? AppColors.primary : Colors.transparent,
  //         width: isSelected ? 2 : 0,
  //       ),
  //     ),
  //     child: InkWell(
  //       onTap:
  //           canSelect
  //               ? () {
  //                 final packageId = state.currentWeekData?.packageId ?? '';
  //                 context.read<WeekSelectionCubit>().toggleMealSelection(
  //                   week: state.currentWeek,
  //                   item: item,
  //                   packageId: packageId,
  //                 );
  //               }
  //               : () {
  //                 final validation = state.validateCurrentWeek();
  //                 _showValidationSnackBar(
  //                   context,
  //                   'Maximum ${validation.requiredMeals} meals allowed for this week',
  //                 );
  //               },
  //       borderRadius: BorderRadius.circular(12),
  //       child: Padding(
  //         padding: EdgeInsets.all(AppDimensions.marginMedium),
  //         child: Row(
  //           children: [
  //             _buildMealIcon(item, isSelected),
  //             SizedBox(width: AppDimensions.marginMedium),
  //             Expanded(child: _buildMealInfo(item, state)),
  //             _buildSelectionCheckbox(item, isSelected, canSelect, state),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildMealIcon(MealPlanItem item, bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color:
            isSelected
                ? AppColors.primary.withOpacity(0.1)
                : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Icon(
        _getMealIcon(item.timing),
        color: isSelected ? AppColors.primary : Colors.grey.shade600,
        size: 24,
      ),
    );
  }

  Widget _buildMealInfo(MealPlanItem item, WeekSelectionActive state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.formattedDay,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          item.dishName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (item.dishDescription.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            item.dishDescription,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildSelectionCheckbox(
    MealPlanItem item,
    bool isSelected,
    bool canSelect,
    WeekSelectionActive state,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Checkbox(
        value: isSelected,
        onChanged:
            canSelect
                ? (_) {
                  final packageId = state.currentWeekData?.packageId ?? '';
                  context.read<WeekSelectionCubit>().toggleMealSelection(
                    week: state.currentWeek,
                    item: item,
                    packageId: packageId,
                  );
                }
                : null,
        activeColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    );
  }

  Widget _buildBottomNavigation(
    BuildContext context,
    WeekSelectionActive state,
  ) {
    if (!state.isCurrentWeekConfigured) {
      return Container(
        padding: EdgeInsets.all(AppDimensions.marginMedium),
        child: SafeArea(
          child: PrimaryButton(
            text: 'Configure Week ${state.currentWeek}',
            onPressed:
                () => _showWeekConfigurationBottomSheet(
                  context,
                  state.currentWeek,
                  state.planningData.dietaryPreference,
                ),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(AppDimensions.marginMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (state.canGoToPreviousWeek) ...[
              Expanded(
                child: SecondaryButton(
                  text: 'Previous Week',
                  onPressed: () {
                    context.read<WeekSelectionCubit>().previousWeek();
                  },
                ),
              ),
              SizedBox(width: AppDimensions.marginMedium),
            ],
            if (state.canGoToNextWeek &&
                state.maxWeeksConfigured > state.currentWeek) ...[
              Expanded(
                child: PrimaryButton(
                  text: 'Next Week',
                  icon: Icons.arrow_forward,
                  onPressed: () {
                    context.read<WeekSelectionCubit>().nextWeek();
                  },
                ),
              ),
            ] else ...[
              Expanded(
                child: PrimaryButton(
                  text:
                      state.validateCurrentWeek().isValid
                          ? 'Week Complete'
                          : 'Complete Selection',
                  icon:
                      state.validateCurrentWeek().isValid
                          ? Icons.check_circle
                          : Icons.schedule,
                  onPressed:
                      state.validateCurrentWeek().isValid
                          ? null // Week is complete, user can add more weeks or checkout
                          : () {
                            final validation = state.validateCurrentWeek();
                            _showValidationSnackBar(
                              context,
                              validation.message,
                            );
                          },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Helper widgets for loading/error states (simplified versions)
  Widget _buildWeekLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: AppDimensions.marginMedium),
          const Text(
            'Loading week data...',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekErrorState(BuildContext context, WeekSelectionActive state) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            SizedBox(height: AppSpacing.md),
            Text(
              'Failed to load week data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.error,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Unable to load meal data for this week',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              text: 'Retry',
              onPressed:
                  () => context.read<WeekSelectionCubit>().retryCurrentWeek(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, size: 64, color: AppColors.textSecondary),
          SizedBox(height: AppDimensions.marginMedium),
          Text(
            'No meal data available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMealsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_menu, size: 64, color: AppColors.textSecondary),
          SizedBox(height: AppDimensions.marginMedium),
          Text(
            'No meals available this week',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMealTypeState(String mealType) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.marginMedium),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getMealIcon(mealType),
              size: 64,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: AppDimensions.marginMedium),
            Text(
              'No ${mealType.toLowerCase()} options available',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getMealIcon(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Icons.free_breakfast;
      case 'lunch':
        return Icons.lunch_dining;
      case 'dinner':
        return Icons.dinner_dining;
      default:
        return Icons.restaurant;
    }
  }

  /// 📝 UPDATED: Show week configuration bottom sheet using the component
  Future<void> _showWeekConfigurationBottomSheet(
    BuildContext context,
    int week,
    String defaultDietaryPreference,
  ) async {
    final result = await WeekConfigurationBottomSheet.show(
      context,
      week: week,
      defaultDietaryPreference: defaultDietaryPreference,
    );

    // Result is true if configuration was successful, false if cancelled
    if (result == true && mounted) {
      // Configuration was successful, the cubit state should be updated
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Week $week configured successfully!'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
