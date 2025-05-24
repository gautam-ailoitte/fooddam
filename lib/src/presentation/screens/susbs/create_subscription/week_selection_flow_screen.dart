// lib/src/presentation/screens/susbs/create_subscription/week_selection_flow_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/constants/subscription_constants.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/route/app_router.dart';
import 'package:foodam/core/widgets/primary_button.dart';
import 'package:foodam/core/widgets/secondary_button.dart';
import 'package:foodam/src/domain/entities/meal_plan_item.dart';
import 'package:foodam/src/presentation/cubits/subscription/planning/subscription_planning_cubit.dart';
import 'package:foodam/src/presentation/cubits/subscription/planning/subscription_planning_state.dart';
import 'package:intl/intl.dart';

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
          context.read<SubscriptionPlanningCubit>().resetToPlanning();
        }
      },
      child: BlocConsumer<SubscriptionPlanningCubit, SubscriptionPlanningState>(
        listener: _handleStateChanges,
        builder: _buildScreenContent,
      ),
    );
  }

  void _handleStateChanges(
    BuildContext context,
    SubscriptionPlanningState state,
  ) {
    if (state is SubscriptionPlanningError) {
      _showErrorSnackBar(context, state.message);
    } else if (state is PlanningComplete) {
      Navigator.pushReplacementNamed(
        context,
        AppRouter.subscriptionSummaryRoute,
      );
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        action:
            message.contains('retry') || message.contains('Retry')
                ? SnackBarAction(
                  label: 'Retry',
                  textColor: Colors.white,
                  onPressed: () {
                    context.read<SubscriptionPlanningCubit>().retryLoadWeek();
                  },
                )
                : null,
      ),
    );
  }

  Widget _buildScreenContent(
    BuildContext context,
    SubscriptionPlanningState state,
  ) {
    // 🔍 DEBUG: Log every UI rebuild
    print('🏗️ UI REBUILDING - State: ${state.runtimeType}');

    if (state is WeekSelectionActive) {
      print(
        '📊 Week ${state.currentWeek} - Selections: ${state.currentWeekSelectionCount}/${state.mealPlan}',
      );
      print('✅ Week Complete: ${state.isCurrentWeekComplete}');
      print('🗂️ Selections Map: ${state.weekSelections}');
    }

    if (state is SubscriptionPlanningLoading) {
      return _buildLoadingScreen();
    }

    if (state is! WeekSelectionActive) {
      return _buildErrorScreen(context, state);
    }

    return _buildMainScreen(context, state);
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: AppDimensions.marginMedium),
            Text(
              'Loading your meal plan...',
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

  Widget _buildErrorScreen(
    BuildContext context,
    SubscriptionPlanningState state,
  ) {
    String title = 'Unable to Load';
    String message = 'Unable to load meal selection';
    String actionText = 'Try Again';
    VoidCallback? onPressed;

    if (state is SubscriptionPlanningError) {
      title = 'Error Loading Data';
      message = state.message;
      actionText = 'Retry';
      onPressed = () {
        context.read<SubscriptionPlanningCubit>().retryLoadWeek();
      };
    } else {
      onPressed = () {
        context.read<SubscriptionPlanningCubit>().startWeekSelection();
      };
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Meal Selection'),
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.read<SubscriptionPlanningCubit>().resetToPlanning();
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.marginMedium),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 80, color: AppColors.error),
              SizedBox(height: AppDimensions.marginMedium),
              Text(
                title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.error,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppDimensions.marginSmall),
              Text(
                message,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppDimensions.marginLarge),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SecondaryButton(
                    text: 'Start Over',
                    onPressed: () {
                      context.read<SubscriptionPlanningCubit>().reset();
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRouter.startSubscriptionPlanningRoute,
                        (route) => false,
                      );
                    },
                  ),
                  SizedBox(width: AppDimensions.marginMedium),
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
          _buildMealTypeTabs(state),
          Expanded(child: _buildWeekContent(context, state)),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(context, state),
    );
  }

  PreferredSizeWidget _buildAppBar(WeekSelectionActive state) {
    final weekStartDate = state.currentWeekStartDate;
    final weekEndDate = state.currentWeekEndDate;

    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          context.read<SubscriptionPlanningCubit>().resetToPlanning();
          Navigator.pop(context);
        },
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Week ${state.currentWeek} of ${state.duration}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            '${DateFormat('MMM d').format(weekStartDate)} - ${DateFormat('MMM d').format(weekEndDate)}',
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: _buildAppBarBottom(state),
      ),
    );
  }

  Widget _buildAppBarBottom(WeekSelectionActive state) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.marginMedium,
        vertical: AppDimensions.marginSmall,
      ),
      child: Column(
        children: [
          // Week progress indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(state.duration, (index) {
              final week = index + 1;
              final isCurrentWeek = week == state.currentWeek;

              // 🔥 FIXED: Check if week is complete using cubit state
              final weekSelections = state.weekSelections[week] ?? [];
              final isWeekComplete = weekSelections.length == state.mealPlan;
              final isCompletedWeek =
                  week < state.currentWeek && isWeekComplete;

              return GestureDetector(
                onTap: () {
                  context.read<SubscriptionPlanningCubit>().navigateToWeek(
                    week,
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: isCurrentWeek ? 28 : 24,
                    height: isCurrentWeek ? 28 : 24,
                    decoration: BoxDecoration(
                      color:
                          isCurrentWeek
                              ? Colors.white
                              : isCompletedWeek
                              ? AppColors.success
                              : isWeekComplete
                              ? AppColors.success
                              : Colors.white.withOpacity(0.3),
                      shape: BoxShape.circle,
                      border:
                          isCurrentWeek
                              ? Border.all(color: AppColors.accent, width: 2)
                              : null,
                    ),
                    child: Center(
                      child:
                          isCompletedWeek
                              ? Icon(Icons.check, color: Colors.white, size: 14)
                              : Text(
                                '$week',
                                style: TextStyle(
                                  color:
                                      isCurrentWeek
                                          ? AppColors.primary
                                          : isWeekComplete
                                          ? Colors.white
                                          : AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 10),
          // Selection progress
          _buildProgressIndicator(state),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(WeekSelectionActive state) {
    final selectedCount = state.currentWeekSelectionCount;
    final totalRequired = state.mealPlan;
    final progress = totalRequired > 0 ? selectedCount / totalRequired : 0.0;

    // 🔍 DEBUG: Log progress calculation
    print(
      '📈 Progress - Selected: $selectedCount, Required: $totalRequired, Progress: ${(progress * 100).round()}%',
    );

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$selectedCount/$totalRequired meals selected',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${(progress * 100).round()}%',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.white.withOpacity(0.3),
          valueColor: AlwaysStoppedAnimation<Color>(
            selectedCount == totalRequired
                ? AppColors.success
                : AppColors.accent,
          ),
          minHeight: 4,
        ),
      ],
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
              // 🔥 FIXED: Count selections by meal type using cubit state
              final currentWeekSelections =
                  state.weekSelections[state.currentWeek] ?? [];
              final typeSelections =
                  currentWeekSelections
                      .where(
                        (selection) =>
                            selection.timing.toLowerCase() ==
                            mealType.toLowerCase(),
                      )
                      .length;

              return Tab(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(SubscriptionConstants.mealTypeDisplayNames[mealType]!),
                    if (typeSelections > 0) ...[
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
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
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildWeekContent(BuildContext context, WeekSelectionActive state) {
    if (state.isCurrentWeekLoading) {
      return _buildWeekLoadingState();
    }

    if (state.currentWeekHasError) {
      return _buildWeekErrorState(context, state);
    }

    if (!state.isCurrentWeekLoaded) {
      return _buildNoDataState();
    }

    final mealPlanItems =
        context.read<SubscriptionPlanningCubit>().getCurrentWeekMealPlanItems();

    if (mealPlanItems.isEmpty) {
      return _buildEmptyMealsState();
    }

    return TabBarView(
      controller: _tabController,
      children:
          SubscriptionConstants.mealTypes.map((mealType) {
            return _buildMealTypeGrid(mealType, mealPlanItems, state);
          }).toList(),
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

        // 🔥 FIXED: Use cubit method with day included
        final isSelected = state.isDishSelected(
          item.dishId,
          item.day,
          item.timing,
        );
        final canSelect = isSelected || state.canSelectMore;

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
    // 🔍 DEBUG: Log selection state for each card
    final selectionKey = '${item.day}_${item.timing}_${item.dishId}';
    print(
      '🍽️ Card: $selectionKey - Selected: $isSelected, CanSelect: $canSelect',
    );

    // Add unique key to prevent selection confusion
    final cardKey = Key(
      '${state.currentWeek}_${item.day}_${item.timing}_${item.dishId}',
    );

    return Card(
      key: cardKey,
      margin: EdgeInsets.only(bottom: AppDimensions.marginMedium),
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color:
              isSelected
                  ? AppColors.primary
                  : item.isToday(state.startDate, state.currentWeek)
                  ? AppColors.accent
                  : Colors.transparent,
          width:
              isSelected || item.isToday(state.startDate, state.currentWeek)
                  ? 2
                  : 0,
        ),
      ),
      child: InkWell(
        onTap:
            canSelect
                ? () {
                  final packageId = state.currentWeekPackageId ?? '';
                  print(
                    '🔘 TAPPING: ${item.dishName} on ${item.day} ${item.timing}',
                  );

                  context.read<SubscriptionPlanningCubit>().toggleDishSelection(
                    item: item,
                    packageId: packageId,
                  );
                }
                : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.marginMedium),
          child: Row(
            children: [
              // Meal icon
              _buildMealIcon(item, isSelected),
              SizedBox(width: AppDimensions.marginMedium),
              // Meal info
              Expanded(child: _buildMealInfo(item, state)),
              // Selection checkbox
              _buildSelectionCheckbox(item, isSelected, canSelect, state),
            ],
          ),
        ),
      ),
    );
  }

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
    final isToday = item.isToday(state.startDate, state.currentWeek);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              item.formattedDay,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isToday) ...[
              SizedBox(width: AppDimensions.marginSmall),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'TODAY',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.accent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
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
        if (item.dietaryPreferences.isNotEmpty) ...[
          const SizedBox(height: 4),
          Wrap(
            spacing: 4,
            children:
                item.dietaryPreferences.take(2).map((pref) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _capitalize(pref),
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
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
                  final packageId = state.currentWeekPackageId ?? '';
                  // 🔥 FIXED: Use cubit method instead of service
                  context.read<SubscriptionPlanningCubit>().toggleDishSelection(
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Validation message
            if (!state.isCurrentWeekComplete) ...[
              Container(
                padding: EdgeInsets.all(AppDimensions.marginSmall),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber,
                      color: AppColors.warning,
                      size: 20,
                    ),
                    SizedBox(width: AppDimensions.marginSmall),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Week ${state.currentWeek} incomplete',
                            style: TextStyle(
                              color: AppColors.warning,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Select exactly ${state.mealPlan} meals to continue (${state.currentWeekSelectionCount}/${state.mealPlan} selected)',
                            style: TextStyle(
                              color: AppColors.warning,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppDimensions.marginMedium),
            ],

            // Navigation buttons
            Row(
              children: [
                if (state.canGoToPreviousWeek) ...[
                  Expanded(
                    child: SecondaryButton(
                      text: 'Previous Week',
                      onPressed: () {
                        context
                            .read<SubscriptionPlanningCubit>()
                            .previousWeek();
                      },
                    ),
                  ),
                  SizedBox(width: AppDimensions.marginMedium),
                ],
                Expanded(
                  child: PrimaryButton(
                    text:
                        state.canGoToNextWeek
                            ? 'Next Week'
                            : 'Complete Planning',
                    icon:
                        state.canGoToNextWeek
                            ? Icons.arrow_forward
                            : Icons.check_circle,
                    onPressed:
                        state.isCurrentWeekComplete
                            ? () {
                              context
                                  .read<SubscriptionPlanningCubit>()
                                  .nextWeek();
                            }
                            : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper widgets for loading/error states
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
        padding: EdgeInsets.all(AppDimensions.marginMedium),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            SizedBox(height: AppDimensions.marginMedium),
            Text(
              'Failed to load week data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.error,
              ),
            ),
            SizedBox(height: AppDimensions.marginSmall),
            Text(
              state.currentWeekError ?? 'Unknown error occurred',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            SizedBox(height: AppDimensions.marginLarge),
            PrimaryButton(
              text: 'Retry',
              onPressed: () {
                context.read<SubscriptionPlanningCubit>().retryLoadWeek();
              },
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

  // Helper methods
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

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
