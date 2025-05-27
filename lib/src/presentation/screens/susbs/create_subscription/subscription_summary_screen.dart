// lib/src/presentation/screens/susbs/create_subscription/subscription_summary_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/constants/subscription_constants.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/route/app_router.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/core/widgets/primary_button.dart';
import 'package:foodam/core/widgets/secondary_button.dart';
import 'package:foodam/src/domain/entities/address_entity.dart';
import 'package:foodam/src/domain/entities/payment_entity.dart';
import 'package:foodam/src/presentation/cubits/payment/razor_pay_cubit/razor_pay_cubit/razor_pay_cubit_cubit.dart';
import 'package:foodam/src/presentation/cubits/payment/razor_pay_cubit/razor_pay_cubit/razor_pay_cubit_state.dart';
import 'package:foodam/src/presentation/cubits/subscription/planning/subscription_planning_cubit.dart';
import 'package:foodam/src/presentation/cubits/subscription/planning/subscription_planning_state.dart';
import 'package:foodam/src/presentation/cubits/user_profile/user_profile_cubit.dart';
import 'package:foodam/src/presentation/cubits/user_profile/user_profile_state.dart';
import 'package:intl/intl.dart';

class SubscriptionSummaryScreen extends StatefulWidget {
  const SubscriptionSummaryScreen({super.key});

  @override
  State<SubscriptionSummaryScreen> createState() =>
      _SubscriptionSummaryScreenState();
}

class _SubscriptionSummaryScreenState extends State<SubscriptionSummaryScreen> {
  String? _selectedAddressId;
  String? _deliveryInstructions;
  PaymentMethod _selectedPaymentMethod = PaymentMethod.upi;
  final LoggerService _logger = LoggerService();
  int _noOfPersons = 1;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadUserAddresses();

    final currentState = context.read<SubscriptionPlanningCubit>().state;
    _logger.d(
      'Summary screen initState - Current state: ${currentState.runtimeType}',
    );

    // 🔥 IMPROVED: Use micro task for better timing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.microtask(() {
        // 🔥 NEW: Micro task wrapper
        if (!mounted) return;

        final cubit = context.read<SubscriptionPlanningCubit>();
        final state = cubit.state;

        _logger.d('Post-frame state check: ${state.runtimeType}');

        if (state is PlanningComplete) {
          _logger.d('Transitioning from PlanningComplete to CheckoutActive');
          cubit.goToCheckout();
        } else if (state is WeekSelectionActive && state.isAllWeeksComplete) {
          _logger.d('Completing planning from WeekSelectionActive');
          cubit.ensureCheckoutState();
        } else if (state is CheckoutActive) {
          _logger.d('Already in CheckoutActive state');
        } else {
          _logger.w('Unexpected state in summary: ${state.runtimeType}');
          cubit.ensureCheckoutState();
        }
      });
    });
  }

  void _loadUserAddresses() {
    context.read<UserProfileCubit>().getUserProfile();
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(context),
      body: MultiBlocListener(
        listeners: [
          // 🔥 UPDATED: Enhanced planning state listener with detailed logging
          BlocListener<SubscriptionPlanningCubit, SubscriptionPlanningState>(
            listener: (context, state) {
              _logger.d(
                'Summary BlocListener - State change: ${state.runtimeType}',
              );

              if (state is SubscriptionPlanningError) {
                _logger.e('Planning error: ${state.message}');
                _showErrorSnackBar(context, state.message);
                setState(() => _isSubmitting = false);
              } else if (state is PlanningComplete) {
                _logger.d('Received PlanningComplete in summary listener');
                // This should trigger the checkout transition
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    context.read<SubscriptionPlanningCubit>().goToCheckout();
                  }
                });
              } else if (state is CheckoutActive) {
                _logger.d('CheckoutActive state received');
                // Update local state from cubit
                setState(() {
                  _selectedAddressId = state.selectedAddressId;
                  _deliveryInstructions = state.instructions;
                  _noOfPersons = state.noOfPersons;
                  _isSubmitting = state.isSubmitting;
                });
              }
              // 🔥 NEW: Handle subscription creation success
              else if (state is SubscriptionCreationSuccess) {
                _logger.d('Subscription creation successful');
                setState(() => _isSubmitting = false);

                // 🔥 CRITICAL: Trigger payment exactly like old checkout
                context
                    .read<RazorpayPaymentCubit>()
                    .processPaymentForSubscription(
                      state.subscription.id,
                      _selectedPaymentMethod,
                    );
              }
              // 🔥 NEW: Handle subscription creation error
              else if (state is SubscriptionCreationError) {
                _logger.e('Subscription creation failed: ${state.message}');
                setState(() => _isSubmitting = false);
                _showErrorSnackBar(context, state.message);
              }
            },
          ),
          // 🔥 UNCHANGED: Payment listener (same as old checkout)
          BlocListener<RazorpayPaymentCubit, RazorpayPaymentState>(
            listener: (context, state) {
              if (state is RazorpayPaymentLoading) {
                setState(() => _isSubmitting = true);
              } else if (state is RazorpayPaymentSuccessWithId) {
                setState(() => _isSubmitting = false);
                _showSuccessDialog(context);
              } else if (state is RazorpayPaymentError) {
                setState(() => _isSubmitting = false);
                _showErrorSnackBar(
                  context,
                  'Payment failed. Please try again.',
                );
                // delay one second
                Future.delayed(const Duration(seconds: 1), () {});
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRouter.mainRoute,
                  (route) => false,
                );
              }
            },
          ),
        ],
        child:
            BlocBuilder<SubscriptionPlanningCubit, SubscriptionPlanningState>(
              builder: (context, state) => _buildContent(context, state),
            ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        'Review & Checkout',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      backgroundColor: AppColors.primary,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => _discardAndStartOver(context),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Payment Successful!'),
            content: const Text(
              'Your subscription has been activated successfully.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    AppRouter.mainRoute,
                    (route) => false,
                  );
                },
                child: const Text('Go to Home'),
              ),
            ],
          ),
    );
  }

  // 🔥 FIXED: More robust content handling to prevent any error flashes
  Widget _buildContent(BuildContext context, SubscriptionPlanningState state) {
    _logger.d(
      'Summary screen building content for state: ${state.runtimeType}',
    );

    // 🔥 PRIORITY: Handle all possible states explicitly
    switch (state.runtimeType) {
      case SubscriptionPlanningLoading _:
        _logger.d('Showing loading for SubscriptionPlanningLoading');
        return _buildLoadingContent();

      case PlanningComplete _:
        _logger.d('Showing transition loading for PlanningComplete');
        return _buildTransitionLoadingContent();

      case CheckoutActive _:
        _logger.d('Showing checkout content for CheckoutActive');
        return _buildCheckoutContent(context, state);

      case SubscriptionCreationSuccess _:
        _logger.d('Showing checkout content for SubscriptionCreationSuccess');
        return _buildCheckoutContent(context, state);

      case SubscriptionCreationError _:
        _logger.d('Showing checkout content for SubscriptionCreationError');
        return _buildCheckoutContent(context, state);

      case SubscriptionPlanningError _:
        _logger.d('Showing error content for SubscriptionPlanningError');
        return _buildErrorContent(
          context,
          (state as SubscriptionPlanningError).message,
        );

      case SubscriptionPlanningInitial _:
        _logger.d('Showing loading for SubscriptionPlanningInitial');
        return _buildLoadingContent();

      default:
        _logger.w(
          'Unhandled state type: ${state.runtimeType} - showing loading',
        );
        return _buildLoadingContent();
    }
  }

  // 🔥 NEW: Specific loading for transition states
  Widget _buildTransitionLoadingContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: AppDimensions.marginMedium),
          const Text(
            'Preparing checkout...',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: AppDimensions.marginMedium),
          const Text(
            'Loading...',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // 🔥 NEW: Proper error content handling
  Widget _buildErrorContent(BuildContext context, String errorMessage) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.marginMedium),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: AppColors.error),
            SizedBox(height: AppDimensions.marginMedium),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.error,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppDimensions.marginSmall),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            SizedBox(height: AppDimensions.marginLarge),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SecondaryButton(
                  text: 'Start Over',
                  onPressed: () => _discardAndStartOver(context),
                ),
                SizedBox(width: AppDimensions.marginMedium),
                PrimaryButton(
                  text: 'Retry',
                  onPressed: () {
                    context.read<SubscriptionPlanningCubit>().reset();
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRouter.startSubscriptionPlanningRoute,
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 UPDATED: Handle multiple checkout-related states
  Widget _buildCheckoutContent(
    BuildContext context,
    SubscriptionPlanningState state,
  ) {
    // Extract common data from different states
    late DateTime startDate;
    late String dietaryPreference;
    late int duration;
    late int mealPlan;
    late Map<int, List<dynamic>> weekSelections;
    late Map<int, String> weekPackageIds;
    String? selectedAddressId;
    String? instructions;
    int noOfPersons = 1;

    if (state is CheckoutActive) {
      startDate = state.startDate;
      dietaryPreference = state.dietaryPreference;
      duration = state.duration;
      mealPlan = state.mealPlan;
      weekSelections = state.weekSelections;
      weekPackageIds = state.weekPackageIds;
      selectedAddressId = state.selectedAddressId;
      instructions = state.instructions;
      noOfPersons = state.noOfPersons;
    } else if (state is SubscriptionCreationSuccess) {
      startDate = state.startDate;
      dietaryPreference = state.dietaryPreference;
      duration = state.duration;
      mealPlan = state.mealPlan;
      weekSelections = state.weekSelections;
      weekPackageIds = state.weekPackageIds;
      selectedAddressId = state.selectedAddressId;
      instructions = state.instructions;
      noOfPersons = state.noOfPersons;
    } else if (state is SubscriptionCreationError) {
      startDate = state.startDate;
      dietaryPreference = state.dietaryPreference;
      duration = state.duration;
      mealPlan = state.mealPlan;
      weekSelections = state.weekSelections;
      weekPackageIds = state.weekPackageIds;
      selectedAddressId = state.selectedAddressId;
      instructions = state.instructions;
      noOfPersons = state.noOfPersons;
    } else {
      return _buildLoadingContent();
    }

    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppDimensions.marginMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Success header
                    _buildSuccessHeader(),
                    SizedBox(height: AppDimensions.marginMedium),

                    // Subscription overview
                    _buildSubscriptionOverview(
                      startDate,
                      dietaryPreference,
                      duration,
                      mealPlan,
                    ),
                    SizedBox(height: AppDimensions.marginMedium),

                    // Selection summary
                    // _buildSelectionSummary(weekSelections, duration, mealPlan),
                    // SizedBox(height: AppDimensions.marginMedium),
                    //
                    // // Meal distribution
                    // _buildMealDistribution(weekSelections),
                    _buildWeeklySelections(weekSelections, startDate, duration),
                    SizedBox(height: AppDimensions.marginMedium),

                    // 🔥 CHECKOUT SECTIONS
                    _buildPersonCountSection(noOfPersons),
                    SizedBox(height: AppDimensions.marginMedium),

                    _buildAddressSelectionSection(),
                    SizedBox(height: AppDimensions.marginMedium),

                    _buildDeliveryInstructionsSection(instructions),
                    SizedBox(height: AppDimensions.marginMedium),

                    _buildPaymentMethodSection(),
                    SizedBox(height: AppDimensions.marginMedium),

                    // Price breakdown
                    _buildPriceBreakdown(context, state),

                    // Add bottom padding for floating button
                    SizedBox(height: AppDimensions.marginLarge * 3),
                  ],
                ),
              ),
            ),
          ],
        ),

        // Loading overlay
        if (_isSubmitting)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Processing your order...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Fixed bottom action bar
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _buildBottomActionBar(
            context,
            state,
            weekSelections,
            noOfPersons,
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessHeader() {
    return Card(
      elevation: 0,
      color: AppColors.success.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.marginMedium),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 28,
              ),
            ),
            SizedBox(width: AppDimensions.marginMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Planning Complete!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Review your order and complete checkout',
                    style: TextStyle(
                      color: AppColors.success.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionOverview(
    DateTime startDate,
    String dietaryPreference,
    int duration,
    int mealPlan,
  ) {
    final endDate = startDate.add(Duration(days: duration * 7 - 1));

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.marginMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Subscription Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppDimensions.marginMedium),

            _buildSummaryRow(
              'Start Date',
              DateFormat('MMMM d, yyyy').format(startDate),
              Icons.calendar_today,
            ),
            _buildSummaryRow(
              'Duration',
              SubscriptionConstants.getDurationText(duration),
              Icons.schedule,
            ),
            _buildSummaryRow(
              'Dietary Preference',
              SubscriptionConstants.getDietaryPreferenceText(dietaryPreference),
              Icons.restaurant_menu,
            ),
            _buildSummaryRow(
              'Meals per Week',
              SubscriptionConstants.getMealPlanText(mealPlan),
              Icons.food_bank,
            ),
            _buildSummaryRow(
              'End Date',
              DateFormat('MMMM d, yyyy').format(endDate),
              Icons.event,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionSummary(
    Map<int, List<dynamic>> weekSelections,
    int duration,
    int mealPlan,
  ) {
    int totalSelections = 0;
    for (final selections in weekSelections.values) {
      totalSelections += selections.length;
    }

    final totalRequired = duration * mealPlan;
    final isComplete = totalSelections == totalRequired;

    return Card(
      elevation: 0,
      color:
          isComplete
              ? AppColors.success.withOpacity(0.05)
              : AppColors.warning.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color:
              isComplete
                  ? AppColors.success.withOpacity(0.3)
                  : AppColors.warning.withOpacity(0.3),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.marginMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isComplete ? Icons.check_circle : Icons.warning_amber,
                  color: isComplete ? AppColors.success : AppColors.warning,
                ),
                SizedBox(width: AppDimensions.marginSmall),
                Text(
                  'Meal Selection',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isComplete ? AppColors.success : AppColors.warning,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppDimensions.marginSmall),
            Text(
              isComplete
                  ? 'All meals selected successfully!'
                  : 'Some meals are missing',
              style: TextStyle(
                color: isComplete ? AppColors.success : AppColors.warning,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: AppDimensions.marginMedium),

            _buildSummaryRow(
              'Total Meals Selected',
              '$totalSelections',
              Icons.restaurant,
              isHighlighted: true,
            ),
            _buildSummaryRow(
              'Total Required',
              '$totalRequired',
              Icons.assignment,
            ),
            _buildSummaryRow(
              'Progress',
              '${((totalSelections / totalRequired) * 100).round()}%',
              Icons.timeline,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealDistribution(Map<int, List<dynamic>> weekSelections) {
    final distribution = <String, int>{'breakfast': 0, 'lunch': 0, 'dinner': 0};

    for (final selections in weekSelections.values) {
      for (final selection in selections) {
        if (selection.timing != null) {
          final mealType = selection.timing.toLowerCase();
          distribution[mealType] = (distribution[mealType] ?? 0) + 1;
        }
      }
    }

    int totalSelections = distribution.values.fold(
      0,
      (sum, count) => sum + count,
    );

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.marginMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Meal Distribution',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppDimensions.marginMedium),

            ...SubscriptionConstants.mealTypes.map((mealType) {
              final count = distribution[mealType] ?? 0;
              final percentage =
                  totalSelections > 0
                      ? (count / totalSelections * 100).round()
                      : 0;

              return Container(
                margin: EdgeInsets.only(bottom: AppDimensions.marginMedium),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: _getMealTypeColor(
                                  mealType,
                                ).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _getMealTypeIcon(mealType),
                                color: _getMealTypeColor(mealType),
                                size: 18,
                              ),
                            ),
                            SizedBox(width: AppDimensions.marginSmall),
                            Text(
                              SubscriptionConstants
                                  .mealTypeDisplayNames[mealType]!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '$count meals ($percentage%)',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: totalSelections > 0 ? count / totalSelections : 0,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getMealTypeColor(mealType),
                      ),
                      minHeight: 6,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklySelections(
    Map<int, List<dynamic>> weekSelections,
    DateTime startDate,
    int duration,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.marginMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly Meal Selections',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppDimensions.marginMedium),

            ...List.generate(duration, (index) {
              final week = index + 1;
              final selections = weekSelections[week] ?? [];
              final weekStartDate = startDate.add(
                Duration(days: (week - 1) * 7),
              );
              final weekEndDate = weekStartDate.add(const Duration(days: 6));

              return _buildWeekAccordion(
                week: week,
                selections: selections,
                weekStartDate: weekStartDate,
                weekEndDate: weekEndDate,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekAccordion({
    required int week,
    required List<dynamic> selections,
    required DateTime weekStartDate,
    required DateTime weekEndDate,
  }) {
    // Group selections by day and meal type
    final groupedSelections = <String, List<dynamic>>{};

    for (final selection in selections) {
      final dayKey = selection.day.toLowerCase();
      groupedSelections[dayKey] ??= [];
      groupedSelections[dayKey]!.add(selection);
    }

    // Sort days by week order
    final orderedDays = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];
    final sortedDays =
        orderedDays.where((day) => groupedSelections.containsKey(day)).toList();

    return Container(
      margin: EdgeInsets.only(bottom: AppDimensions.marginMedium),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(
          horizontal: AppDimensions.marginSmall,
        ),
        childrenPadding: EdgeInsets.symmetric(
          horizontal: AppDimensions.marginMedium,
          vertical: AppDimensions.marginSmall,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '$week',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            SizedBox(width: AppDimensions.marginSmall),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Week $week',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${DateFormat('MMM d').format(weekStartDate)} - ${DateFormat('MMM d').format(weekEndDate)}',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        subtitle: Text(
          '${selections.length} meals selected',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        children: [
          if (selections.isEmpty)
            Padding(
              padding: EdgeInsets.all(AppDimensions.marginMedium),
              child: Text(
                'No meals selected for this week',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            ...sortedDays.map((day) {
              final daySelections = groupedSelections[day]!;
              // Sort by meal type order
              daySelections.sort((a, b) {
                const mealOrder = {'breakfast': 0, 'lunch': 1, 'dinner': 2};
                return (mealOrder[a.timing.toLowerCase()] ?? 3).compareTo(
                  mealOrder[b.timing.toLowerCase()] ?? 3,
                );
              });

              return _buildDayMealsList(day, daySelections);
            }),
        ],
      ),
    );
  }

  Widget _buildDayMealsList(String day, List<dynamic> selections) {
    return Container(
      margin: EdgeInsets.only(bottom: AppDimensions.marginSmall),
      padding: EdgeInsets.all(AppDimensions.marginSmall),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _capitalize(day),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: AppDimensions.marginSmall),
          ...selections.map((selection) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(
                    _getMealTypeIcon(selection.timing),
                    size: 16,
                    color: _getMealTypeColor(selection.timing),
                  ),
                  SizedBox(width: AppDimensions.marginSmall),
                  Text(
                    '${_capitalize(selection.timing)}:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      selection.dishName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Color _getMealTypeColor(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Colors.orange;
      case 'lunch':
        return AppColors.accent;
      case 'dinner':
        return Colors.purple;
      default:
        return AppColors.primary;
    }
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  // 🔥 CHECKOUT SECTIONS
  Widget _buildPersonCountSection(int noOfPersons) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.marginMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Number of Persons',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'How many people will this subscription serve?',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            SizedBox(height: AppDimensions.marginMedium),

            Row(
              children: [
                IconButton(
                  onPressed:
                      _noOfPersons > 1
                          ? () {
                            setState(() => _noOfPersons--);
                            _updateCheckoutData();
                          }
                          : null,
                  icon: Icon(
                    Icons.remove_circle,
                    color: _noOfPersons > 1 ? AppColors.primary : Colors.grey,
                  ),
                ),
                SizedBox(width: AppDimensions.marginSmall),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$_noOfPersons',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: AppDimensions.marginSmall),
                IconButton(
                  onPressed:
                      _noOfPersons < 10
                          ? () {
                            setState(() => _noOfPersons++);
                            _updateCheckoutData();
                          }
                          : null,
                  icon: Icon(
                    Icons.add_circle,
                    color: _noOfPersons < 10 ? AppColors.primary : Colors.grey,
                  ),
                ),
                const Spacer(),
                Text(
                  _noOfPersons == 1 ? 'Person' : 'Persons',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressSelectionSection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.marginMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Delivery Address',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppDimensions.marginMedium),

            BlocBuilder<UserProfileCubit, UserProfileState>(
              builder: (context, state) {
                if (state is UserProfileLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is UserProfileLoaded && state.addresses != null) {
                  final addresses = state.addresses!;

                  if (addresses.isEmpty) {
                    return _buildNoAddressesWidget();
                  }

                  // Auto-select first address if none selected
                  if (_selectedAddressId == null && addresses.isNotEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() => _selectedAddressId = addresses.first.id);
                      _updateCheckoutData();
                    });
                  }

                  return Column(
                    children: [
                      ...addresses.map((address) => _buildAddressItem(address)),
                      SizedBox(height: AppDimensions.marginMedium),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            AppRouter.addAddressRoute,
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add New Address'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                        ),
                      ),
                    ],
                  );
                }

                return const Center(child: Text('Unable to load addresses'));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoAddressesWidget() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(AppDimensions.marginLarge),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                Icons.location_off,
                size: 48,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 16),
              const Text(
                'No addresses found',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Please add a delivery address to continue',
                style: TextStyle(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppDimensions.marginMedium),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, AppRouter.addAddressRoute);
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Address'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddressItem(Address address) {
    final isSelected = _selectedAddressId == address.id;

    return InkWell(
      onTap: () {
        setState(() => _selectedAddressId = address.id);
        _updateCheckoutData();
      },
      child: Container(
        margin: EdgeInsets.only(bottom: AppDimensions.marginSmall),
        padding: EdgeInsets.all(AppDimensions.marginSmall),
        decoration: BoxDecoration(
          color:
              isSelected ? AppColors.primary.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: address.id,
              groupValue: _selectedAddressId,
              onChanged: (value) {
                setState(() => _selectedAddressId = value);
                _updateCheckoutData();
              },
              activeColor: AppColors.primary,
            ),
            SizedBox(width: AppDimensions.marginSmall),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address.street,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${address.city}, ${address.state} ${address.zipCode}',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryInstructionsSection(String? instructions) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.marginMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Delivery Instructions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Add any special instructions for delivery (optional)',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            SizedBox(height: AppDimensions.marginMedium),
            TextFormField(
              initialValue: _deliveryInstructions,
              onChanged: (value) {
                setState(() => _deliveryInstructions = value);
                _updateCheckoutData();
              },
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'e.g., Ring the bell, call when at gate, etc.',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.marginMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppDimensions.marginMedium),

            _buildPaymentOption(
              title: 'UPI Payment',
              subtitle: 'Pay using any UPI app',
              icon: Icons.account_balance,
              value: PaymentMethod.upi,
            ),
            _buildPaymentOption(
              title: 'Credit Card',
              subtitle: 'Pay using credit card',
              icon: Icons.credit_card,
              value: PaymentMethod.creditCard,
            ),
            _buildPaymentOption(
              title: 'Debit Card',
              subtitle: 'Pay using debit card',
              icon: Icons.credit_card,
              value: PaymentMethod.debitCard,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required PaymentMethod value,
  }) {
    final isSelected = _selectedPaymentMethod == value;

    return InkWell(
      onTap: () => setState(() => _selectedPaymentMethod = value),
      child: Container(
        margin: EdgeInsets.only(bottom: AppDimensions.marginSmall),
        padding: EdgeInsets.all(AppDimensions.marginSmall),
        decoration: BoxDecoration(
          color:
              isSelected ? AppColors.primary.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? AppColors.primary.withOpacity(0.1)
                        : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primary : Colors.grey.shade700,
              ),
            ),
            SizedBox(width: AppDimensions.marginSmall),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Radio<PaymentMethod>(
              value: value,
              groupValue: _selectedPaymentMethod,
              onChanged: (newValue) {
                if (newValue != null) {
                  setState(() => _selectedPaymentMethod = newValue);
                }
              },
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceBreakdown(
    BuildContext context,
    SubscriptionPlanningState state,
  ) {
    _logger.d('🔍 ===== PRICE BREAKDOWN DEBUG =====');

    double basePricing = 0.0;
    int totalMeals = 0;
    int noOfPersons = 1;
    int duration = 1;

    if (state is CheckoutActive) {
      basePricing = state.totalPricing;
      totalMeals = state.allSelections.length;
      noOfPersons = state.noOfPersons;
      duration = state.duration;
    } else if (state is SubscriptionCreationSuccess) {
      basePricing = state.totalPricing;
      totalMeals = state.allSelections.length;
      noOfPersons = state.noOfPersons;
      duration = state.duration;
    } else if (state is SubscriptionCreationError) {
      basePricing = state.totalPricing;
      totalMeals = state.allSelections.length;
      noOfPersons = state.noOfPersons;
      duration = state.duration;
    }

    // 🔥 NEW: Calculate per-week price
    final weekPrice = duration > 0 ? basePricing / duration : 0.0;
    final subtotal = weekPrice * duration * noOfPersons;
    final total = subtotal;

    _logger.d('💰 Enhanced Calculation:');
    _logger.d('   Week Price: ₹$weekPrice');
    _logger.d('   × Duration: $duration weeks');
    _logger.d('   × Persons: $noOfPersons');
    _logger.d('   = Total: ₹$total');

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.marginMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Price Breakdown',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppDimensions.marginMedium),

            // Week price row
            _buildPriceRow(
              'Week Price (${(totalMeals / duration).round()} meals per week)',
              '₹${weekPrice.toStringAsFixed(0)}',
            ),

            // Duration multiplier
            _buildCalculationRow(
              '× Duration',
              '$duration weeks',
              showIcon: true,
            ),

            // Person multiplier
            _buildCalculationRow(
              '× Persons',
              '$noOfPersons ${noOfPersons == 1 ? 'person' : 'persons'}',
              showIcon: true,
            ),

            // Calculation line
            _buildCalculationLine(),

            const Divider(height: 32),

            // Total
            _buildPriceRow(
              'Total Amount',
              '₹${total.toStringAsFixed(0)}',
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculationRow(
    String label,
    String value, {
    bool showIcon = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppDimensions.marginSmall),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (showIcon) ...[
                Icon(Icons.close, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculationLine() {
    return Padding(
      padding: EdgeInsets.only(bottom: AppDimensions.marginSmall),
      child: Row(
        children: [
          Icon(Icons.drag_handle, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Expanded(
            child: Container(
              height: 1,
              color: AppColors.textSecondary.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 NEW: Helper method to get pricing from any state
  double _getTotalPricingFromState(SubscriptionPlanningState state) {
    if (state is CheckoutActive) {
      return state.totalPricing;
    } else if (state is SubscriptionCreationSuccess) {
      return state.totalPricing;
    } else if (state is SubscriptionCreationError) {
      return state.totalPricing;
    }
    return 0.0;
  }

  Widget _buildPriceRow(String label, String amount, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppDimensions.marginSmall),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? null : AppColors.textSecondary,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: FontWeight.bold,
              color: isTotal ? AppColors.primary : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(
    BuildContext context,
    SubscriptionPlanningState state,
    Map<int, List<dynamic>> weekSelections,
    int noOfPersons,
  ) {
    final canProceed = _selectedAddressId != null && !_isSubmitting;

    // 🔥 FIXED: Use real pricing instead of hardcoded
    final basePricing = _getTotalPricingFromState(state);
    final total = basePricing * noOfPersons;

    return Container(
      padding: EdgeInsets.all(AppDimensions.marginMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🔥 REPLACED: Error cards with snack bars - Only show if error state
            if (state is SubscriptionCreationError) ...[
              Container(
                padding: EdgeInsets.all(AppDimensions.marginMedium),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: AppColors.error, size: 24),
                    SizedBox(width: AppDimensions.marginSmall),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order Failed',
                            style: TextStyle(
                              color: AppColors.error,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            state.message,
                            style: TextStyle(
                              color: AppColors.error,
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

            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: SecondaryButton(
                    text: 'Discard',
                    icon: Icons.arrow_back,
                    onPressed: () => _discardAndStartOver(context),
                  ),
                ),
                SizedBox(width: AppDimensions.marginMedium),
                Expanded(
                  flex: 1,
                  child: SecondaryButton(
                    text: 'Order • ₹${total.toStringAsFixed(0)}',
                    icon: Icons.payment,
                    onPressed: () {
                      if (!canProceed) {
                        if (_selectedAddressId == null) {
                          _showErrorSnackBar(
                            context,
                            'Please select a delivery address',
                          );
                        } else {
                          _showErrorSnackBar(context, 'Unable to proceed');
                        }
                        return;
                      }
                      _placeOrder();
                    },
                    backgroundColor: AppColors.primary,
                    textColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value,
    IconData icon, {
    bool isHighlighted = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppDimensions.marginSmall),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: isHighlighted ? AppColors.primary : AppColors.textSecondary,
          ),
          SizedBox(width: AppDimensions.marginSmall),
          Text(
            label,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w600,
              color: isHighlighted ? AppColors.primary : Colors.black87,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _updateCheckoutData() {
    context.read<SubscriptionPlanningCubit>().updateCheckoutData(
      addressId: _selectedAddressId,
      instructions: _deliveryInstructions,
      noOfPersons: _noOfPersons,
    );
  }

  void _placeOrder() {
    if (_selectedAddressId == null) {
      _showErrorSnackBar(context, 'Please select a delivery address');
      return;
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Order'),
            content: const Text('Do you want to place this order?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _createSubscription();
                },
                child: const Text('Place Order'),
              ),
            ],
          ),
    );
  }

  void _createSubscription() {
    final state = context.read<SubscriptionPlanningCubit>().state;

    if (state is SubscriptionCreationError) {
      // Retry subscription creation
      context.read<SubscriptionPlanningCubit>().retryCreateSubscription();
    } else {
      // Create new subscription
      context.read<SubscriptionPlanningCubit>().createSubscription();
    }
  }

  void _discardAndStartOver(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Discard Order?'),
            content: const Text(
              'This will discard all your selections and return to the beginning. Are you sure?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<SubscriptionPlanningCubit>().reset();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRouter.mainRoute,
                    (route) => false,
                  );
                },
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: const Text('Discard'),
              ),
            ],
          ),
    );
  }

  // Helper methods

  IconData _getMealTypeIcon(String mealType) {
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
}
