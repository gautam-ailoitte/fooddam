// lib/src/presentation/views/plan_selection_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/string_constants.dart';
import 'package:foodam/src/domain/entities/user_entity.dart';
import 'package:foodam/src/presentation/cubits/draft_plan_cubit/draft_plan_cubit.dart';
import 'package:foodam/src/presentation/cubits/plan_browse_cubit/plan_browse_cubit.dart';
import 'package:foodam/src/presentation/cubits/plan_customization_cubit/plan_customization_cubit.dart';
import 'package:foodam/src/presentation/utlis/helper.dart';
import 'package:foodam/src/presentation/widgets/common/app_loading.dart';
import 'package:foodam/src/presentation/widgets/common/error_widget.dart';
import 'package:foodam/src/presentation/widgets/plan_card_widget.dart';

class PlanSelectionPage extends StatefulWidget {
  const PlanSelectionPage({Key? key}) : super(key: key);
  
  @override
  State<PlanSelectionPage> createState() => _PlanSelectionPageState();
}

class _PlanSelectionPageState extends State<PlanSelectionPage> {
  int? _selectedPlanIndex;
  PlanDuration _selectedDuration = PlanDuration.sevenDays;
  
  @override
  void initState() {
    super.initState();
    // Load available plans
    context.read<PlanBrowseCubit>().loadAvailablePlans();
    // Check for draft plans
    context.read<DraftPlanCubit>().checkForDraft();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(StringConstants.availablePlans),
        actions: [
          // Draft plan button
          BlocBuilder<DraftPlanCubit, DraftPlanState>(
            builder: (context, state) {
              if (state is DraftPlanAvailable) {
                return IconButton(
                  icon: Icon(Icons.edit_document),
                  tooltip: 'Resume Draft',
                  onPressed: () => _resumeDraftPlan(state.plan),
                );
              }
              return SizedBox.shrink();
            },
          ),
          // Clear draft button
          IconButton(
            icon: Icon(Icons.delete_outline),
            onPressed: _clearDraft,
            tooltip: 'Clear Draft',
          ),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          // Listen for draft plan availability - show confirmation on first load
          BlocListener<DraftPlanCubit, DraftPlanState>(
            listener: (context, state) {
              if (state is DraftPlanAvailable) {
                // Only show confirmation dialog on initial load
                if (!_haveShownDraftConfirmation) {
                  _haveShownDraftConfirmation = true;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _showDraftConfirmation(state.plan);
                  });
                }
              }
            },
          ),
          // Listen for customization state to navigate to plan details
          BlocListener<PlanCustomizationCubit, PlanCustomizationState>(
            listener: (context, state) {
              if (state is PlanCustomizationActive) {
                NavigationHelper.goToPlanDetails(context);
              }
            },
          ),
        ],
        child: Column(
          children: [
            // Draft plan banner if available
            BlocBuilder<DraftPlanCubit, DraftPlanState>(
              builder: (context, state) {
                if (state is DraftPlanAvailable) {
                  return GestureDetector(
                    onTap: () => _resumeDraftPlan(state.plan),
                    child: Container(
                      margin: EdgeInsets.all(16),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.amber[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber[700]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.edit_document, color: Colors.amber[800]),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'You have a draft plan',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber[800],
                                  ),
                                ),
                                Text(
                                  'Tap to resume customization',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.amber[800],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.amber[800]),
                        ],
                      ),
                    ),
                  );
                }
                return SizedBox.shrink();
              },
            ),
            
            // Plan browsing interface
            Expanded(
              child: BlocBuilder<PlanBrowseCubit, PlanBrowseState>(
                builder: (context, state) {
                  if (state is PlanBrowseLoading) {
                    return AppLoading(message: 'Loading available plans...');
                  } else if (state is PlanBrowseError) {
                    return AppErrorWidget(
                      message: state.message,
                      onRetry: () => context.read<PlanBrowseCubit>().loadAvailablePlans(),
                    );
                  } else if (state is PlanBrowseLoaded) {
                    return _buildPlanList(context, state.plans);
                  }
                  return AppLoading();
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BlocBuilder<PlanBrowseCubit, PlanBrowseState>(
        builder: (context, state) {
          if (state is PlanBrowseLoaded && _selectedPlanIndex != null) {
            // Filter plans by duration to get correct plan index
            final filteredPlans = state.plans
                .where((plan) => plan.duration == _selectedDuration)
                .toList();
                
            if (_selectedPlanIndex! < filteredPlans.length) {
              final selectedPlan = filteredPlans[_selectedPlanIndex!];
              
              return SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: () => _startCustomization(selectedPlan),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'Continue with Selected Plan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }
          }
          return SizedBox.shrink();
        },
      ),
    );
  }
  
  // Track if we've shown the draft confirmation
  bool _haveShownDraftConfirmation = false;
  
  // Show confirmation dialog for draft plan
  void _showDraftConfirmation(Plan draftPlan) async {
    final result = await DialogHelper.showDraftActionDialog(context);
    if (!mounted) return;
    if (result == 'resume') {
      _resumeDraftPlan(draftPlan);
    } else if (result == 'new') {
      context.read<DraftPlanCubit>().clearDraft();
    }
  }
  
  // Resume customizing a draft plan
  void _resumeDraftPlan(Plan plan) {
    // Start customizing with draft plan
    context.read<PlanCustomizationCubit>().resumeCustomization(plan);
  }
  
  // Start customizing a new plan
  void _startCustomization(Plan plan) {
    // Capture cubit references
    final draftPlanCubit = context.read<DraftPlanCubit>();
    final planCustomizationCubit = context.read<PlanCustomizationCubit>();
    
    // Check if there's a draft plan
    final draftState = draftPlanCubit.state;
    if (draftState is DraftPlanAvailable) {
      // Show confirmation dialog
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text('Replace Draft Plan?'),
          content: Text('You already have a draft plan. Starting a new plan will replace it. Continue?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                // Use captured references
                draftPlanCubit.clearDraft();
                planCustomizationCubit.startCustomization(plan);
              },
              child: Text('Replace'),
            ),
          ],
        ),
      );
    } else {
      // No draft plan, start customizing immediately
      planCustomizationCubit.startCustomization(plan);
    }
  }
  
  // Clear draft plan with confirmation
  void _clearDraft() {
    // Capture the cubit reference to avoid context issues
    final draftPlanCubit = context.read<DraftPlanCubit>();
    final draftState = draftPlanCubit.state;
    
    if (draftState is! DraftPlanAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No draft plan to clear')),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Clear Draft Plan?'),
        content: Text('This will remove any saved draft plans. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // Use the captured reference rather than context.read
              draftPlanCubit.clearDraft();
            },
            child: Text('Clear'),
          ),
        ],
      ),
    );
  }

  // Build list of plans with duration filter
  Widget _buildPlanList(BuildContext context, List<Plan> plans) {
    if (plans.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sentiment_dissatisfied,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'No plans available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    // Filter plans by duration
    final filteredPlans = plans
        .where((plan) => plan.duration == _selectedDuration)
        .toList();

    return SingleChildScrollView(
      padding: EdgeInsets.only(top: 16, bottom: 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Choose a Plan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Choose duration section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Plan Duration',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          SizedBox(
            height: 80,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 12),
              children: [
                _buildDurationOption(context, '7 Days', PlanDuration.sevenDays),
                _buildDurationOption(context, '14 Days', PlanDuration.fourteenDays),
                _buildDurationOption(context, '28 Days', PlanDuration.twentyEightDays),
              ],
            ),
          ),
          
          Divider(height: 32),
          
          // Plans list
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Select Meal Type',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          SizedBox(height: 8),
          
          // Show message if no plans match the selected duration
          if (filteredPlans.isEmpty)
            Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'No plans available for the selected duration.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: filteredPlans.length,
              itemBuilder: (context, index) {
                final plan = filteredPlans[index];
                return PlanCard(
                  plan: plan,
                  isSelected: _selectedPlanIndex == index,
                  onSelect: () {
                    setState(() {
                      _selectedPlanIndex = index;
                    });
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  // Duration selection button
  Widget _buildDurationOption(
    BuildContext context,
    String label,
    PlanDuration duration,
  ) {
    final isSelected = duration == _selectedDuration;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDuration = duration;
          _selectedPlanIndex = null; // Reset selection when duration changes
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        width: 100,
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}