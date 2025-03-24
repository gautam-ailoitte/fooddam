// lib/features/checkout/screens/checkout_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/route/app_router.dart';
import 'package:foodam/core/widgets/app_loading.dart';
import 'package:foodam/core/widgets/error_display_wideget.dart';
import 'package:foodam/core/widgets/primary_button.dart';
import 'package:foodam/core/widgets/secondary_button.dart';
import 'package:foodam/src/domain/entities/meal_slot_entity.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';
import 'package:foodam/src/presentation/cubits/pacakge_cubits/pacakage_cubit.dart';
import 'package:foodam/src/presentation/cubits/pacakge_cubits/pacakage_state.dart';
import 'package:foodam/src/presentation/cubits/subscription/create_subcription/create_subcription_cubit.dart';
import 'package:foodam/src/presentation/cubits/subscription/create_subcription/create_subcription_state.dart';
import 'package:foodam/src/presentation/cubits/user_profile/user_profile_cubit.dart';
import 'package:foodam/src/presentation/cubits/user_profile/user_profile_state.dart';
import 'package:foodam/src/presentation/widgets/check_out_widgets.dart';

class CheckoutScreen extends StatefulWidget {
  final String packageId;
  final List<MealSlot> mealSlots;
  final int personCount;

  const CheckoutScreen({
    super.key,
    required this.packageId,
    required this.mealSlots,
    this.personCount = 1,
  });

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String? _selectedAddressId;
  String? _deliveryInstructions;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    // Load package details
    context.read<PackageCubit>().loadPackageDetails(widget.packageId);
    
    // Load user addresses
    context.read<UserProfileCubit>().getUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
      ),
      body: BlocListener<CreateSubscriptionCubit, CreateSubscriptionState>(
        listener: (context, state) {
          if (state is CreateSubscriptionSuccess) {
            // Navigate to confirmation screen
            Navigator.of(context).pushReplacementNamed(
              AppRouter.confirmationRoute,
              arguments: state.subscription,
            );
          } else if (state is CreateSubscriptionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Column(
          children: [
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppDimensions.marginLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order summary
                    Text(
                      'Order Summary',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: AppDimensions.marginMedium),
                    BlocBuilder<PackageCubit, PackageState>(
                      builder: (context, state) {
                        if (state is PackageLoading) {
                          return AppLoading(message: 'Loading package details...');
                        } else if (state is PackageError) {
                          return ErrorDisplayWidget(
                            message: state.message,
                            onRetry: () => context.read<PackageCubit>().loadPackageDetails(widget.packageId),
                          );
                        } else if (state is PackageDetailLoaded) {
                          return CheckoutSummaryCard(
                            package: state.package,
                            mealSlots: widget.mealSlots,
                            personCount: widget.personCount,
                          );
                        }
                        return SizedBox.shrink();
                      },
                    ),
                    SizedBox(height: AppDimensions.marginLarge),
                    
                    // Delivery address section
                    Text(
                      'Delivery Address',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: AppDimensions.marginMedium),
                    BlocBuilder<UserProfileCubit, UserProfileState>(
                      builder: (context, state) {
                        if (state is UserProfileLoading) {
                          return AppLoading(message: 'Loading addresses...');
                        } else if (state is UserProfileError) {
                          return ErrorDisplayWidget(
                            message: state.message,
                            onRetry: () => context.read<UserProfileCubit>().getUserProfile(),
                          );
                        } else if (state is UserProfileLoaded) {
                          if (state.addresses == null || state.addresses!.isEmpty) {
                            return Card(
                              child: Padding(
                                padding: EdgeInsets.all(AppDimensions.marginLarge),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.location_off,
                                      size: 48,
                                      color: AppColors.warning,
                                    ),
                                    SizedBox(height: AppDimensions.marginMedium),
                                    Text(
                                      'No Addresses Found',
                                      style: Theme.of(context).textTheme.titleLarge,
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: AppDimensions.marginSmall),
                                    Text(
                                      'Please add a delivery address to continue',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: AppDimensions.marginMedium),
                                    SecondaryButton(
                                      text: 'Add New Address',
                                      onPressed: () {
                                        // Navigate to add address screen (would be implemented elsewhere)
                                      },
                                      icon: Icons.add_location_alt,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          
                          return Column(
                            children: [
                              ...state.addresses!.map((address) {
                                return AddressSelectionCard(
                                  address: address,
                                  isSelected: _selectedAddressId == address.id,
                                  onSelected: () {
                                    setState(() {
                                      _selectedAddressId = address.id;
                                    });
                                  },
                                );
                              }),
                              SizedBox(height: AppDimensions.marginMedium),
                              OutlinedButton.icon(
                                onPressed: () {
                                  // Navigate to add address screen (would be implemented elsewhere)
                                },
                                icon: Icon(Icons.add),
                                label: Text('Add New Address'),
                              ),
                            ],
                          );
                        }
                        return SizedBox.shrink();
                      },
                    ),
                    SizedBox(height: AppDimensions.marginLarge),
                    
                    // Delivery instructions
                    Text(
                      'Delivery Instructions',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: AppDimensions.marginMedium),
                    DeliveryInstructionsField(
                      value: _deliveryInstructions,
                      onChanged: (value) {
                        setState(() {
                          _deliveryInstructions = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            // Bottom action area
            BlocBuilder<CreateSubscriptionCubit, CreateSubscriptionState>(
              builder: (context, state) {
                final isLoading = state is CreateSubscriptionLoading;
                
                return Container(
                  padding: EdgeInsets.all(AppDimensions.marginLarge),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: SecondaryButton(
                          text: 'Back',
                          onPressed: isLoading ? null : () => Navigator.pop(context),
                          icon: Icons.arrow_back,
                        ),
                      ),
                      SizedBox(width: AppDimensions.marginMedium),
                      Expanded(
                        child: PrimaryButton(
                          text: 'Create Subscription',
                          onPressed: (_selectedAddressId != null && !isLoading)
                              ? _createSubscription
                              : null,
                          isLoading: isLoading,
                          icon: Icons.check,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _createSubscription() {
    if (_selectedAddressId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a delivery address')),
      );
      return;
    }

    final cubit = context.read<CreateSubscriptionCubit>();
    
    // Convert MealSlot list to MealDistribution list
    @Deprecated('Use MealSlot instead')
    final mealDistributions = widget.mealSlots.map((slot) {
      return MealDistribution(
        day: slot.day,
        mealTime: slot.timing,
        mealId: slot.mealId,
      );
    }).toList();
    
    // Set the necessary data for subscription creation
    cubit.selectPackage(widget.packageId);
    cubit.setMealDistributions(mealDistributions, widget.personCount);
    cubit.selectAddress(_selectedAddressId!);
    cubit.setInstructions(_deliveryInstructions);
    
    // Create the subscription
    cubit.createSubscription();
  }
}


class ConfirmationScreen extends StatelessWidget {
  final Subscription subscription;

  const ConfirmationScreen({
    Key? key,
    required this.subscription,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // Prevent going back from the confirmation screen
      onWillPop: () async => false,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(AppDimensions.marginLarge),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Success animation
                  // Container(
                  //   width: 200,
                  //   height: 200,
                  //   child: Lottie.asset(
                  //     'assets/animations/success.json',
                  //     repeat: false,
                  //     // Use a placeholder if animation file is not available
                  //     errorBuilder: (context, error, stackTrace) {
                  //       return Container(
                  //         decoration: BoxDecoration(
                  //           color: AppColors.primaryLight,
                  //           shape: BoxShape.circle,
                  //         ),
                  //         child: Icon(
                  //           Icons.check_circle,
                  //           size: 100,
                  //           color: AppColors.primary,
                  //         ),
                  //       );
                  //     },
                  //   ),
                  // ),
                  SizedBox(height: AppDimensions.marginLarge),
                  
                  Text(
                    'Subscription Created!',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppDimensions.marginMedium),
                  
                  Text(
                    'Your meal subscription has been successfully created. Your first delivery will be made according to your selected schedule.',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppDimensions.marginExtraLarge),
                  
                  // Order details
                  Container(
                    padding: EdgeInsets.all(AppDimensions.marginMedium),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
                      border: Border.all(color: AppColors.textSecondary),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow(
                          context,
                          'Subscription ID',
                          subscription.id,
                        ),
                        Divider(),
                        _buildDetailRow(
                          context,
                          'Total Meals',
                          '${subscription.slots.length}',
                        ),
                        Divider(),
                        _buildDetailRow(
                          context,
                          'Status',
                          _formatStatus(subscription.status),
                          valueColor: _getStatusColor(subscription.status),
                        ),
                      ],
                    ),
                  ),
                  
                  Spacer(),
                  
                  // Action buttons
                  PrimaryButton(
                    text: 'View My Subscriptions',
                    onPressed: () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        AppRouter.subscriptionsRoute,
                        (route) => false,
                      );
                    },
                    icon: Icons.visibility,
                  ),
                  SizedBox(height: AppDimensions.marginMedium),
                  SecondaryButton(
                    text: 'Back to Home',
                    onPressed: () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        AppRouter.mainRoute,
                        (route) => false,
                      );
                    },
                    icon: Icons.home,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: AppDimensions.marginSmall,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: valueColor,
                ),
          ),
        ],
      ),
    );
  }

  String _formatStatus(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.pending:
        return 'Pending';
      case SubscriptionStatus.active:
        return 'Active';
      case SubscriptionStatus.paused:
        return 'Paused';
      case SubscriptionStatus.cancelled:
        return 'Cancelled';
      case SubscriptionStatus.expired:
        return 'Expired';
    }
  }

  Color _getStatusColor(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.pending:
        return AppColors.warning;
      case SubscriptionStatus.active:
        return AppColors.success;
      case SubscriptionStatus.paused:
        return AppColors.warning;
      case SubscriptionStatus.cancelled:
        return AppColors.error;
      case SubscriptionStatus.expired:
        return AppColors.textSecondary;
    }
  }
}