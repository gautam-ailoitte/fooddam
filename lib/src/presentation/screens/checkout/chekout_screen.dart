// lib/src/presentation/screens/checkout/checkout_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/route/app_router.dart';
import 'package:foodam/core/service/dialog_service.dart';
import 'package:foodam/core/theme/enhanced_app_them.dart';
import 'package:foodam/src/domain/entities/address_entity.dart';
import 'package:foodam/src/domain/entities/meal_slot_entity.dart';
import 'package:foodam/src/domain/entities/pacakge_entity.dart';
import 'package:foodam/src/domain/entities/payment_entity.dart';
import 'package:foodam/src/presentation/cubits/pacakge_cubits/pacakage_cubit.dart';
import 'package:foodam/src/presentation/cubits/pacakge_cubits/pacakage_state.dart';
import 'package:foodam/src/presentation/cubits/payment/razor_pay_cubit/razor_pay_cubit/razor_pay_cubit_cubit.dart';
import 'package:foodam/src/presentation/cubits/payment/razor_pay_cubit/razor_pay_cubit/razor_pay_cubit_state.dart';
import 'package:foodam/src/presentation/cubits/subscription/create_subcription/create_subcription_cubit.dart';
import 'package:foodam/src/presentation/cubits/subscription/create_subcription/create_subcription_state.dart';
import 'package:foodam/src/presentation/cubits/subscription/subscription/subscription_details_cubit.dart';
import 'package:foodam/src/presentation/cubits/user_profile/user_profile_cubit.dart';
import 'package:foodam/src/presentation/cubits/user_profile/user_profile_state.dart';
import 'package:intl/intl.dart';

class CheckoutScreen extends StatefulWidget {
  final String packageId;
  final List<MealSlot> mealSlots;
  final int personCount;
  final DateTime startDate;
  final int durationDays;

  const CheckoutScreen({
    super.key,
    required this.packageId,
    required this.mealSlots,
    required this.personCount,
    required this.startDate,
    required this.durationDays,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String? _selectedAddressId;
  String? _deliveryInstructions;
  PaymentMethod _selectedPaymentMethod = PaymentMethod.upi;
  bool _isLoading = false;
  Package? _package;
  bool _isPackageLoading = true;
  double _packagePrice = 0;
  double _totalAmount = 0;
  String? _paymentId;
  String? _orderId;
  String? _signature;
  String? _subscriptionId;

  // Dynamic pricing variables
  double _pricePerMeal = 0;
  double _dynamicPrice = 0;

  final _formattedDateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _loadUserAddresses();
    // We need to use addPostFrameCallback to ensure the widget is built
    // before we call the cubit to avoid potential race conditions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPackageDetails();
    });
  }

  Future<void> _loadPackageDetails() async {
    setState(() {
      _isPackageLoading = true;
    });

    try {
      // Load package from cubit
      final packageCubit = context.read<PackageCubit>();
      await packageCubit.loadPackageDetails(widget.packageId);

      // Extract package from state
      final state = packageCubit.state;
      Package? package;

      if (state is PackageDetailLoaded) {
        package = state.package;
      } else if (state is PackageLoaded) {
        // package = state.getPackageById(widget.packageId);
      }

      // Force a complete state update including price calculations
      if (mounted) {
        setState(() {
          _package = package;
          _isPackageLoading = false;
          _updatePriceCalculations(); // Calculate all prices immediately
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isPackageLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading package details: ${e.toString()}'),
          ),
        );
      }
    }
  }

  // New method to update all price calculations in one place
  void _updatePriceCalculations() {
    if (_package != null) {
      _packagePrice = _package!.price * widget.personCount;

      // Calculate dynamic pricing
      _pricePerMeal = (_package!.price * widget.personCount) / 21;
      _dynamicPrice = _pricePerMeal * widget.mealSlots.length;

      _totalAmount = _dynamicPrice;
    } else {
      _packagePrice = 0;
      _totalAmount = 0;
      _pricePerMeal = 0;
      _dynamicPrice = 0;
    }
  }

  void _loadUserAddresses() {
    context.read<UserProfileCubit>().getUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: MultiBlocListener(
        listeners: [
          // Create Subscription listener - process first
          BlocListener<CreateSubscriptionCubit, CreateSubscriptionState>(
            listener: (context, state) {
              if (state is CreateSubscriptionLoading) {
                setState(() {
                  _isLoading = true;
                });
              } else if (state is CreateSubscriptionSuccess) {
                if (state.subscriptionId != null) {
                  setState(() {
                    _subscriptionId = state.subscriptionId;
                  });

                  // Proceed to payment with subscription ID
                  final paymentCubit = context.read<RazorpayPaymentCubit>();
                  paymentCubit.processPaymentForSubscription(
                    state.subscriptionId!,
                    _selectedPaymentMethod,
                  );
                } else {
                  setState(() {
                    _isLoading = false;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Subscription created but unable to process payment. Please try again.',
                      ),
                    ),
                  );
                }
              } else if (state is CreateSubscriptionError) {
                setState(() {
                  _isLoading = false;
                });

                AppDialogs.showAlertDialog(
                  context: context,
                  title: 'Failed to Create Subscription',
                  message: state.message,
                  buttonText: 'Try Again',
                  onPressed: () {
                    // Refresh active subscriptions
                    context.read<SubscriptionCubit>().loadActiveSubscriptions();
                    // navigate to main screen
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRouter.mainRoute,
                      (route) => false,
                    );
                  },
                );
              }
            },
          ),

          // Razorpay Payment listener - process after subscription
          BlocListener<RazorpayPaymentCubit, RazorpayPaymentState>(
            listener: (context, state) {
              if (state is RazorpayPaymentLoading) {
                setState(() {
                  _isLoading = true;
                });
              } else if (state is RazorpayPaymentSuccessWithId) {
                // Store payment details
                setState(() {
                  _isLoading = false;
                  _paymentId = state.paymentId;
                  _orderId = state.orderId;
                  _signature = state.signature;
                });

                // Show success dialog
                AppDialogs.showSuccessDialog(
                  context: context,
                  title: 'Payment Successful',
                  message: 'Your subscription has been activated successfully.',
                  buttonText: 'Go to Home',
                  onPressed: () {
                    // Refresh active subscriptions
                    context.read<SubscriptionCubit>().loadActiveSubscriptions();

                    // Navigate to home screen
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRouter.mainRoute,
                      (route) => false,
                    );
                  },
                );
              } else if (state is RazorpayPaymentError) {
                setState(() {
                  _isLoading = false;
                });

                AppDialogs.showAlertDialog(
                  context: context,
                  title: 'Payment Failed',
                  message:
                      " Unexpected Error Sending Back to HomeScreen", // no state message here
                  buttonText: 'Home',
                  onPressed: () {
                    // Refresh active subscriptions
                    context.read<SubscriptionCubit>().loadActiveSubscriptions();
                    // navigate to main screen
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRouter.mainRoute,
                      (route) => false,
                    );
                  },
                );
              } else if (state is RazorpayExternalWallet) {
                // Just show a message that external wallet was selected
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Processing payment with ${state.walletName}...',
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
        ],
        child: SafeArea(
          child: Stack(
            children: [
              // Main content
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order summary
                    _buildOrderSummaryCard(),
                    const SizedBox(height: 16),

                    // Address selection
                    _buildAddressSelectionCard(),
                    const SizedBox(height: 16),

                    // Delivery instructions
                    _buildDeliveryInstructionsCard(),
                    const SizedBox(height: 16),

                    // Payment method
                    _buildPaymentMethodCard(),
                    const SizedBox(height: 80), // Space for bottom bar
                  ],
                ),
              ),

              // Loading overlay
              if (_isLoading)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
                ),

              // Bottom action bar
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildBottomActionBar(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _placeOrder() {
    if (!_canProceed()) return;

    // Show a confirmation dialog first
    AppDialogs.showConfirmationDialog(
      context: context,
      title: 'Confirm Order',
      message:
          'Do you want to place this order for ₹${_totalAmount.toStringAsFixed(0)}?',
      confirmText: 'Place Order',
      cancelText: 'Cancel',
    ).then((confirmed) {
      if (confirmed == true) {
        // First create subscription, then process payment
        _createSubscriptionAndPay();
      }
    });
  }

  // New method to create subscription first, then process payment
  void _createSubscriptionAndPay() {
    if (_selectedAddressId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a delivery address')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final cubit = context.read<CreateSubscriptionCubit>();

    // Reset cubit state first to avoid any stale data
    cubit.resetState();

    // First select the package
    cubit.selectPackage(widget.packageId);

    // Set subscription details
    cubit.setSubscriptionDetails(
      startDate: widget.startDate,
      durationDays: widget.durationDays,
    );

    // Set meal distributions
    cubit.setMealDistributions(widget.mealSlots, widget.personCount);

    // Set the address and instructions
    cubit.selectAddress(_selectedAddressId!);
    cubit.setInstructions(_deliveryInstructions);

    // Create the subscription
    cubit.createSubscription();
  }

  Widget _buildOrderSummaryCard() {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: EnhancedTheme.cardDecoration,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Package details
            _buildPackageDetails(),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Order details
            Column(
              children: [
                _buildSummaryRow(
                  label: 'Start Date',
                  value: _formattedDateFormat.format(widget.startDate),
                ),
                const SizedBox(height: 8),
                _buildSummaryRow(
                  label: 'Duration',
                  value: '${widget.durationDays} days',
                ),
                const SizedBox(height: 8),
                _buildSummaryRow(
                  label: 'Meals',
                  value: '${widget.mealSlots.length}',
                ),
                const SizedBox(height: 8),
                _buildSummaryRow(
                  label: 'Number of People',
                  value: '${widget.personCount}',
                ),
                const SizedBox(height: 16),
                Divider(color: Colors.grey.shade200),
                const SizedBox(height: 16),

                // Total calculation with dynamic pricing
                _buildSummaryRow(
                  label: 'Original Package Price',
                  value: '₹${_packagePrice.toStringAsFixed(0)}',
                  labelStyle: const TextStyle(fontWeight: FontWeight.normal),
                  valueStyle: TextStyle(
                    fontWeight: FontWeight.normal,
                    decoration: TextDecoration.lineThrough,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                _buildSummaryRow(
                  label: 'Adjusted Price',
                  value: '₹${_dynamicPrice.toStringAsFixed(0)}',
                  labelStyle: const TextStyle(fontWeight: FontWeight.normal),
                  valueStyle: const TextStyle(fontWeight: FontWeight.normal),
                ),
                const SizedBox(height: 8),
                _buildSummaryRow(
                  label: 'Delivery Fee',
                  value: 'FREE',
                  valueStyle: const TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                  labelStyle: const TextStyle(fontWeight: FontWeight.normal),
                ),
                const SizedBox(height: 16),
                _buildSummaryRow(
                  label: 'Total Amount',
                  value: '₹${_totalAmount.toStringAsFixed(0)}',
                  labelStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  valueStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageDetails() {
    // If we already have the package loaded, display it directly
    // This avoids unnecessary rebuilds and flickering
    if (!_isPackageLoading && _package != null) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Package image/icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.restaurant,
              color: AppColors.primary,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),

          // Package details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _package!.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _package!.description,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  '₹${_package!.price.toStringAsFixed(0)} × ${widget.personCount}',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Otherwise, use the BlocBuilder to handle loading states
    return BlocBuilder<PackageCubit, PackageState>(
      builder: (context, state) {
        if (state is PackageLoading || _isPackageLoading) {
          return Center(
            child: Column(
              children: [
                const CircularProgressIndicator(strokeWidth: 2),
                const SizedBox(height: 8),
                Text(
                  'Loading package details...',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        Package? package;

        if (state is PackageDetailLoaded) {
          package = state.package;
          // Update the package and price in the next frame to ensure UI is updated
          if (_package == null || _package!.id != package.id) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                _package = package;
                _updatePriceCalculations();
              });
            });
          }
        }
        if (package == null) {
          return Column(
            children: [
              const Text('Package details not available.'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _loadPackageDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry Loading'),
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Package image/icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.restaurant,
                color: AppColors.primary,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),

            // Package details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    package.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    package.description,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹${package.price.toStringAsFixed(0)} × ${widget.personCount}',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAddressSelectionCard() {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: EnhancedTheme.cardDecoration,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Delivery Address',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            BlocBuilder<UserProfileCubit, UserProfileState>(
              builder: (context, state) {
                if (state is UserProfileLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is UserProfileLoaded &&
                    state.addresses != null) {
                  final addresses = state.addresses!;

                  if (addresses.isEmpty) {
                    return Column(
                      children: [
                        const Text(
                          'No addresses found. Please add an address to continue.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Navigate to add address screen
                            Navigator.pushNamed(context, '/profile');
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add Address'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    );
                  }

                  // If no address is selected yet, select the first one
                  if (_selectedAddressId == null && addresses.isNotEmpty) {
                    // Use a post-frame callback to avoid setState during build
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() {
                        _selectedAddressId = addresses.first.id;
                      });
                    });
                  }

                  return Column(
                    children: [
                      ...addresses
                          .map((address) => _buildAddressItem(address))
                          .toList(),
                      const SizedBox(height: 16),
                      TextButton.icon(
                        onPressed: () {
                          // Navigate to add new address
                          Navigator.pushNamed(context, '/profile');
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add New Address'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                        ),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      const Text(
                        'Could not load addresses. Please try again.',
                        style: TextStyle(color: AppColors.error),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadUserAddresses,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressItem(Address address) {
    final isSelected = _selectedAddressId == address.id;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedAddressId = address.id;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
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
                setState(() {
                  _selectedAddressId = value;
                });
              },
              activeColor: AppColors.primary,
            ),
            const SizedBox(width: 12),
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

  Widget _buildDeliveryInstructionsCard() {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: EnhancedTheme.cardDecoration,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Delivery Instructions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Add any special instructions for the delivery person',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _deliveryInstructions,
              onChanged: (value) {
                setState(() {
                  _deliveryInstructions = value;
                });
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
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
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

  Widget _buildPaymentMethodCard() {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: EnhancedTheme.cardDecoration,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // UPI option
            _buildPaymentOption(
              title: 'UPI Payment',
              subtitle: 'Pay using any UPI app',
              icon: Icons.account_balance,
              value: PaymentMethod.upi,
            ),

            // Credit card option
            _buildPaymentOption(
              title: 'Credit Card',
              subtitle: 'Pay using credit card',
              icon: Icons.credit_card,
              value: PaymentMethod.creditCard,
            ),

            // Debit card option
            _buildPaymentOption(
              title: 'Debit Card',
              subtitle: 'Pay using debit card',
              icon: Icons.credit_card,
              value: PaymentMethod.debitCard,
            ),

            // // Net banking option
            // _buildPaymentOption(
            //   title: 'Net Banking',
            //   subtitle: 'Pay using net banking',
            //   icon: Icons.account_balance_wallet,
            //   value: PaymentMethod.netBanking,
            // ),
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
      onTap: () {
        setState(() {
          _selectedPaymentMethod = value;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
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
            const SizedBox(width: 12),
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
                  setState(() {
                    _selectedPaymentMethod = newValue;
                  });
                }
              },
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActionBar() {
    final canProceed = _canProceed();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Amount',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '₹${_totalAmount.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: canProceed ? _placeOrder : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: Colors.grey.shade300,
                foregroundColor: Colors.white,
                disabledForegroundColor: Colors.grey.shade500,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text('Place Order'),
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceed() {
    return _selectedAddressId != null &&
        !_isLoading &&
        !_isPackageLoading &&
        _package != null &&
        _totalAmount > 0;
  }

  Widget _buildSummaryRow({
    required String label,
    required String value,
    TextStyle? labelStyle,
    TextStyle? valueStyle,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: labelStyle ?? TextStyle(color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: valueStyle ?? const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
