// lib/src/presentation/screens/subscription/week_selection_flow_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/constants/subscription_constants.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/route/app_router.dart';
import 'package:foodam/core/widgets/primary_button.dart';
import 'package:foodam/core/widgets/secondary_button.dart';
import 'package:foodam/src/domain/services/week_data_service.dart';
import 'package:foodam/src/presentation/cubits/subscription/planning/subscription_planning_cubit.dart';
import 'package:intl/intl.dart';

import '../../../cubits/subscription/planning/subscription_planning_state.dart';

class WeekSelectionFlowScreen extends StatefulWidget {
  const WeekSelectionFlowScreen({super.key});

  @override
  State<WeekSelectionFlowScreen> createState() =>
      _WeekSelectionFlowScreenState();
}

class _WeekSelectionFlowScreenState extends State<WeekSelectionFlowScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  TabController? _tabController;
  ScrollController? _scrollController;

  // Track navigation context for restoration
  int _currentTabIndex = 0;
  bool _isRestoringState = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _restoreNavigationContext();
  }

  void _initializeControllers() {
    _tabController = TabController(length: 3, vsync: this);
    _scrollController = ScrollController();

    // Listen to tab changes for context preservation
    _tabController?.addListener(() {
      if (_tabController?.indexIsChanging == false) {
        _currentTabIndex = _tabController?.index ?? 0;
        _storeNavigationContext();
      }
    });

    // Listen to scroll changes for context preservation
    _scrollController?.addListener(() {
      _storeNavigationContext();
    });
  }

  void _restoreNavigationContext() {
    // Get stored navigation context from cubit
    final context =
        this.context.read<SubscriptionPlanningCubit>().getNavigationContext();

    _currentTabIndex = context['activeTab'] ?? 0;
    final scrollPosition = context['scrollPosition'] ?? 0.0;

    // Restore tab index
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_tabController != null && _currentTabIndex < _tabController!.length) {
        _tabController!.index = _currentTabIndex;
      }

      // Restore scroll position
      if (_scrollController != null && _scrollController!.hasClients) {
        _scrollController!.jumpTo(scrollPosition);
      }
    });
  }

  void _storeNavigationContext() {
    if (!_isRestoringState) {
      context.read<SubscriptionPlanningCubit>().storeNavigationContext(
        activeTab: _currentTabIndex,
        scrollPosition: _scrollController?.offset ?? 0.0,
      );
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _scrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return PopScope(
      onPopInvoked: (didPop) {
        if (didPop) {
          _storeNavigationContext();
          context.read<SubscriptionPlanningCubit>().resetToPlanning();
        }
      },
      child: BlocConsumer<SubscriptionPlanningCubit, SubscriptionPlanningState>(
        listener: (context, state) {
          _handleStateChanges(context, state);
        },
        builder: (context, state) {
          return _buildScreenContent(context, state);
        },
      ),
    );
  }

  void _handleStateChanges(
    BuildContext context,
    SubscriptionPlanningState state,
  ) {
    if (state is SubscriptionPlanningError) {
      _showErrorSnackBar(context, state.message);

      // Auto-redirect if error indicates navigation needed
      if (state.message.contains('Redirecting to start') ||
          state.message.contains('start over')) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRouter.startSubscriptionPlanningRoute,
              (route) => false,
            );
          }
        });
      }
    } else if (state is PlanningComplete) {
      // Store context before navigation
      _storeNavigationContext();

      // Replace navigation to prevent stack buildup
      Navigator.pushReplacementNamed(
        context,
        AppRouter.subscriptionSummaryRoute,
      );
    } else if (state is WeekSelectionActive) {
      // Restore navigation context when returning to this state
      _isRestoringState = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _restoreNavigationContext();
        _isRestoringState = false;
      });
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
            SizedBox(height: AppDimensions.marginSmall),
            Text(
              'Please wait while we prepare your options',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
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
      if (state.message.contains('start over') ||
          state.message.contains('Redirecting')) {
        title = 'Redirecting...';
        message = state.message;
        actionText = 'Go to Start';
        onPressed = () {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRouter.startSubscriptionPlanningRoute,
            (route) => false,
          );
        };
      } else {
        title = 'Error Loading Data';
        message = state.message;
        actionText = 'Retry';
        onPressed = () {
          context.read<SubscriptionPlanningCubit>().retryLoadWeek();
        };
      }
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
      appBar: _buildEnhancedAppBar(state),
      body: Column(
        children: [
          // Enhanced meal type tabs
          _buildEnhancedMealTypeTabs(state),
          // Week content with improved state handling
          Expanded(child: _buildWeekContent(context, state)),
        ],
      ),
      bottomNavigationBar: _buildEnhancedBottomNavigation(context, state),
    );
  }

  PreferredSizeWidget _buildEnhancedAppBar(WeekSelectionActive state) {
    final weekStartDate = state.startDate.add(
      Duration(days: (state.currentWeek - 1) * 7),
    );
    final weekEndDate = weekStartDate.add(const Duration(days: 6));

    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          _storeNavigationContext();
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
              final isValidWeek = state.isWeekValid(week);
              final isCompletedWeek = week < state.currentWeek && isValidWeek;

              return GestureDetector(
                onTap: () {
                  _storeNavigationContext();
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
                              : isValidWeek
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
                                          : isValidWeek
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
          // Enhanced meal selection progress
          _buildProgressIndicator(state),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(WeekSelectionActive state) {
    final selectedCount = state.getSelectedMealCount(state.currentWeek);
    final totalRequired = state.mealPlan;
    final progress = totalRequired > 0 ? selectedCount / totalRequired : 0.0;

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

  Widget _buildEnhancedMealTypeTabs(WeekSelectionActive state) {
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
              // Get count of selected meals for this type in current week
              final typeSelections =
                  state.selections
                      .where(
                        (s) =>
                            s.week == state.currentWeek &&
                            s.mealType.toLowerCase() == mealType.toLowerCase(),
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
    // Handle loading state
    if (state.isCurrentWeekLoading()) {
      return _buildWeekLoadingState();
    }

    // Handle error state
    if (state.currentWeekHasError()) {
      return _buildWeekErrorState(context, state);
    }

    // Handle no data state
    if (!state.isCurrentWeekLoaded()) {
      return _buildNoDataState(context);
    }

    // Get meal options for current week
    final mealOptions =
        context.read<SubscriptionPlanningCubit>().getCurrentWeekMealOptions();

    if (mealOptions.isEmpty) {
      return _buildEmptyMealsState();
    }

    // Build enhanced tab content
    return EnhancedWeekMealSelectionWidget(
      key: ValueKey('week_${state.currentWeek}'),
      weekState: state,
      mealOptions: mealOptions,
      tabController: _tabController!,
      scrollController: _scrollController!,
      onNavigationContextChanged: _storeNavigationContext,
    );
  }

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
          SizedBox(height: AppDimensions.marginSmall),
          Text(
            'Preparing your meal options',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
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
              state.getCurrentWeekError() ?? 'Unknown error occurred',
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

  Widget _buildNoDataState(BuildContext context) {
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
          SizedBox(height: AppDimensions.marginSmall),
          const Text(
            'Please try refreshing or contact support',
            textAlign: TextAlign.center,
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
          SizedBox(height: AppDimensions.marginSmall),
          const Text(
            'Please check back later for updated options',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedBottomNavigation(
    BuildContext context,
    WeekSelectionActive state,
  ) {
    final canGoNext = state.currentWeek < state.duration;
    final canGoPrevious = state.currentWeek > 1;
    final isCurrentWeekValid = state.isWeekValid(state.currentWeek);

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
            // Enhanced validation message
            if (!isCurrentWeekValid) ...[
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
                            'Select exactly ${state.mealPlan} meals to continue (${state.getSelectedMealCount(state.currentWeek)}/${state.mealPlan} selected)',
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

            // Enhanced navigation buttons
            Row(
              children: [
                if (canGoPrevious) ...[
                  Expanded(
                    child: SecondaryButton(
                      text: 'Previous Week',
                      onPressed: () {
                        _storeNavigationContext();
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
                    text: canGoNext ? 'Next Week' : 'Complete Planning',
                    icon: canGoNext ? Icons.arrow_forward : Icons.check_circle,
                    onPressed:
                        isCurrentWeekValid
                            ? () {
                              _storeNavigationContext();
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
}

// Enhanced meal selection widget with better state management
class EnhancedWeekMealSelectionWidget extends StatefulWidget {
  final WeekSelectionActive weekState;
  final List<MealOption> mealOptions;
  final TabController tabController;
  final ScrollController scrollController;
  final VoidCallback onNavigationContextChanged;

  const EnhancedWeekMealSelectionWidget({
    super.key,
    required this.weekState,
    required this.mealOptions,
    required this.tabController,
    required this.scrollController,
    required this.onNavigationContextChanged,
  });

  @override
  State<EnhancedWeekMealSelectionWidget> createState() =>
      _EnhancedWeekMealSelectionWidgetState();
}

class _EnhancedWeekMealSelectionWidgetState
    extends State<EnhancedWeekMealSelectionWidget>
    with AutomaticKeepAliveClientMixin {
  // Local state for instant UI updates
  late Set<String> _localSelections;
  bool _isUpdating = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeLocalSelections();
    _setupScrollListener();
  }

  void _initializeLocalSelections() {
    _localSelections =
        widget.weekState.selections
            .where((s) => s.week == widget.weekState.currentWeek)
            .map((s) => s.id.split('_').last)
            .toSet();
  }

  void _setupScrollListener() {
    widget.scrollController.addListener(() {
      if (!_isUpdating) {
        widget.onNavigationContextChanged();
      }
    });
  }

  @override
  void didUpdateWidget(EnhancedWeekMealSelectionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update local selections if week changed
    if (oldWidget.weekState.currentWeek != widget.weekState.currentWeek) {
      _initializeLocalSelections();
    }
  }

  void _toggleMealSelection(MealOption mealOption) {
    if (_isUpdating) return;

    setState(() {
      _isUpdating = true;
      final mealId = mealOption.id;

      if (_localSelections.contains(mealId)) {
        _localSelections.remove(mealId);
      } else {
        if (_localSelections.length < widget.weekState.mealPlan) {
          _localSelections.add(mealId);
        } else {
          _showMealLimitReachedMessage();
          _isUpdating = false;
          return;
        }
      }
    });

    // Update cubit state after local state update
    context.read<SubscriptionPlanningCubit>().toggleMealSelection(
      week: widget.weekState.currentWeek,
      mealOption: mealOption,
    );

    // Small delay to prevent rapid updates
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    });
  }

  void _showMealLimitReachedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Cannot select more than ${widget.weekState.mealPlan} meals for this week',
        ),
        backgroundColor: AppColors.warning,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return TabBarView(
      controller: widget.tabController,
      children:
          SubscriptionConstants.mealTypes.map((mealType) {
            return _buildMealTypeGrid(mealType);
          }).toList(),
    );
  }

  Widget _buildMealTypeGrid(String mealType) {
    final typeMealOptions =
        widget.mealOptions
            .where(
              (option) =>
                  option.mealType.toLowerCase() == mealType.toLowerCase(),
            )
            .toList();

    if (typeMealOptions.isEmpty) {
      return _buildEmptyMealTypeState(mealType);
    }

    return ListView.builder(
      controller: widget.scrollController,
      padding: EdgeInsets.all(AppDimensions.marginMedium),
      itemCount: typeMealOptions.length,
      itemBuilder: (context, index) {
        final mealOption = typeMealOptions[index];
        final isSelected = _localSelections.contains(mealOption.id);
        final canSelect =
            isSelected || _localSelections.length < widget.weekState.mealPlan;

        return _buildEnhancedMealCard(
          mealOption: mealOption,
          isSelected: isSelected,
          canSelect: canSelect,
        );
      },
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
            SizedBox(height: AppDimensions.marginSmall),
            Text(
              'Check other meal types or try a different week',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedMealCard({
    required MealOption mealOption,
    required bool isSelected,
    required bool canSelect,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: AppDimensions.marginMedium),
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color:
              isSelected
                  ? AppColors.primary
                  : mealOption.isToday
                  ? AppColors.accent
                  : Colors.transparent,
          width: isSelected || mealOption.isToday ? 2 : 0,
        ),
      ),
      child: InkWell(
        onTap:
            canSelect && !_isUpdating
                ? () => _toggleMealSelection(mealOption)
                : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.marginMedium),
          child: Row(
            children: [
              // Enhanced dish image placeholder
              _buildMealIcon(mealOption, isSelected),
              SizedBox(width: AppDimensions.marginMedium),

              // Enhanced meal info
              Expanded(child: _buildMealInfo(mealOption)),

              // Enhanced actions
              _buildMealActions(mealOption, isSelected, canSelect),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMealIcon(MealOption mealOption, bool isSelected) {
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
        _getMealIcon(mealOption.mealType),
        color: isSelected ? AppColors.primary : Colors.grey.shade600,
        size: 24,
      ),
    );
  }

  Widget _buildMealInfo(MealOption mealOption) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              _capitalize(mealOption.dayName),
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (mealOption.isToday) ...[
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
          mealOption.dish.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (mealOption.dish.description.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            mealOption.dish.description,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        if (mealOption.dish.dietaryPreferences.isNotEmpty) ...[
          const SizedBox(height: 4),
          Wrap(
            spacing: 4,
            children:
                mealOption.dish.dietaryPreferences.take(2).map((pref) {
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

  Widget _buildMealActions(
    MealOption mealOption,
    bool isSelected,
    bool canSelect,
  ) {
    return Column(
      children: [
        // Detail button
        IconButton(
          onPressed: () => _showMealDetail(mealOption),
          icon: Icon(Icons.info_outline, color: AppColors.primary),
          iconSize: 20,
        ),

        // Enhanced selection checkbox
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: Checkbox(
            value: isSelected,
            onChanged:
                canSelect && !_isUpdating
                    ? (_) => _toggleMealSelection(mealOption)
                    : null,
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ],
    );
  }

  void _showMealDetail(MealOption mealOption) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildMealDetailSheet(mealOption),
    );
  }

  Widget _buildMealDetailSheet(MealOption mealOption) {
    return Container(
      margin: EdgeInsets.all(AppDimensions.marginMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.marginMedium),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getMealIcon(mealOption.mealType),
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: AppDimensions.marginMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_capitalize(mealOption.dayName)} ${mealOption.mealTypeDisplay}',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        mealOption.dish.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            SizedBox(height: AppDimensions.marginMedium),

            // Description
            if (mealOption.dish.description.isNotEmpty) ...[
              Text(
                mealOption.dish.description,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              SizedBox(height: AppDimensions.marginMedium),
            ],

            // Dietary preferences
            if (mealOption.dish.dietaryPreferences.isNotEmpty) ...[
              const Text(
                'Dietary Information',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children:
                    mealOption.dish.dietaryPreferences.map((pref) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _capitalize(pref),
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ],
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
