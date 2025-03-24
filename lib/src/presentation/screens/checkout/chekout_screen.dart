import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/theme/enhanced_app_them.dart';
import 'package:foodam/src/domain/entities/address_entity.dart';
import 'package:foodam/src/domain/entities/meal_slot_entity.dart';
import 'package:foodam/src/domain/entities/pacakge_entity.dart';
import 'package:foodam/src/domain/entities/payment_entity.dart';
import 'package:foodam/src/presentation/cubits/subscription/create_subcription/create_subcription_cubit.dart';
import 'package:foodam/src/presentation/cubits/subscription/create_subcription/create_subcription_state.dart';
import 'package:foodam/src/presentation/cubits/user_profile/user_profile_cubit.dart';
import 'package:foodam/src/presentation/cubits/user_profile/user_profile_state.dart';

class CheckoutScreen extends StatefulWidget {
  final String packageId;
  final List<MealSlot> mealSlots;
  final int personCount;
  final DateTime startDate;
  final int durationDays;

  const CheckoutScreen({
    Key? key,
    required this.packageId,
    required this.mealSlots,
    required this.personCount,
    required this.startDate,
    required this.durationDays,
  }) : super(key: key);

  @override
  _EnhancedCheckoutScreenState createState() => _EnhancedCheckoutScreenState();
}

class _EnhancedCheckoutScreenState extends State<CheckoutScreen> {
  String? _selectedAddressId;
  String? _deliveryInstructions;
  PaymentMethod _selectedPaymentMethod = PaymentMethod.upi;
  bool _isLoading = false;
  Package? _package;
  
  @override
  void initState() {
    super.initState();
    _loadUserAddresses();
  }
  
  void _loadUserAddresses() {
    context.read<UserProfileCubit>().getUserProfile();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: BlocListener<CreateSubscriptionCubit, CreateSubscriptionState>(
        listener: (context, state) {
          if (state is CreateSubscriptionLoading) {
            setState(() {
              _isLoading = true;
            });
          } else if (state is CreateSubscriptionSuccess) {
            setState(() {
              _isLoading = false;
            });
            
            // Navigate to confirmation screen
            Navigator.of(context).pushNamed(
              '/confirmation',
              arguments: state.subscription,
            );
          } else if (state is CreateSubscriptionError) {
            setState(() {
              _isLoading = false;
            });
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Stack(
          children: [
            // Main content
            SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order summary
                  _buildOrderSummaryCard(),
                  SizedBox(height: 16),
                  
                  // Address selection
                  _buildAddressSelectionCard(),
                  SizedBox(height: 16),
                  
                  // Delivery instructions
                  _buildDeliveryInstructionsCard(),
                  SizedBox(height: 16),
                  
                  // Payment method
                  _buildPaymentMethodCard(),
                  SizedBox(height: 80), // Space for bottom bar
                ],
              ),
            ),
            
            // Loading overlay
            if (_isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
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
    );
  }

  Widget _buildOrderSummaryCard() {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: EnhancedTheme.cardDecoration,
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            
            // Package details
            _buildPackageDetails(),
            
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 16),
            
            // Order details
            Column(
              children: [
                _buildSummaryRow(
                  label: 'Start Date',
                  value: '${widget.startDate.day}/${widget.startDate.month}/${widget.startDate.year}',
                ),
                SizedBox(height: 8),
                _buildSummaryRow(
                  label: 'Duration',
                  value: '${widget.durationDays} days',
                ),
                SizedBox(height: 8),
                _buildSummaryRow(
                  label: 'Selected Meals',
                  value: '${widget.mealSlots.length}',
                ),
                SizedBox(height: 8),
                _buildSummaryRow(
                  label: 'Number of People',
                  value: '${widget.personCount}',
                ),
                SizedBox(height: 16),
                Divider(color: Colors.grey.shade200),
                SizedBox(height: 16),
                
                // Total calculation
                _buildSummaryRow(
                  label: 'Package Price',
                  value: '₹${_calculatePackagePrice().toStringAsFixed(0)}',
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.normal,
                  ),
                  valueStyle: TextStyle(
                    fontWeight: FontWeight.normal,
                  ),
                ),
                SizedBox(height: 8),
                _buildSummaryRow(
                  label: 'Delivery Fee',
                  value: 'FREE',
                  valueStyle: TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.normal,
                  ),
                ),
                SizedBox(height: 16),
                _buildSummaryRow(
                  label: 'Total Amount',
                  value: '₹${_calculateTotalAmount().toStringAsFixed(0)}',
                  labelStyle: TextStyle(
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
    return FutureBuilder<Package?>(
      future: _getPackage(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          );
        }
        
        final package = snapshot.data;
        if (package == null) {
          return Text('Package details not available');
        }
        
        _package = package;
        
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
              child: Icon(
                Icons.restaurant,
                color: AppColors.primary,
                size: 30,
              ),
            ),
            SizedBox(width: 16),
            
            // Package details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    package.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    package.description,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
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
      }
    );
  }

  Widget _buildAddressSelectionCard() {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: EnhancedTheme.cardDecoration,
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Delivery Address',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            
            BlocBuilder<UserProfileCubit, UserProfileState>(
              builder: (context, state) {
                if (state is UserProfileLoading) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (state is UserProfileLoaded && state.addresses != null) {
                  final addresses = state.addresses!;
                  
                  if (addresses.isEmpty) {
                    return Column(
                      children: [
                        Text(
                          'No addresses found. Please add an address to continue.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Navigate to add address screen
                            Navigator.pushNamed(context, '/profile');
                          },
                          icon: Icon(Icons.add),
                          label: Text('Add Address'),
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
                    _selectedAddressId = addresses.first.id;
                  }
                  
                  return Column(
                    children: [
                      ...addresses.map((address) => _buildAddressItem(address)).toList(),
                      SizedBox(height: 16),
                      TextButton.icon(
                        onPressed: () {
                          // Navigate to add new address
                          Navigator.pushNamed(context, '/profile');
                        },
                        icon: Icon(Icons.add),
                        label: Text('Add New Address'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                        ),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      Text(
                        'Could not load addresses. Please try again.',
                        style: TextStyle(
                          color: AppColors.error,
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadUserAddresses,
                        child: Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
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
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.05) : Colors.white,
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
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address.street,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: EnhancedTheme.cardDecoration,
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Delivery Instructions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Add any special instructions for the delivery person',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 16),
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
                  borderSide: BorderSide(
                    color: Colors.grey.shade300,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
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

  Widget _buildPaymentMethodCard() {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: EnhancedTheme.cardDecoration,
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Method',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            
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
            
            // Net banking option
            _buildPaymentOption(
              title: 'Net Banking',
              subtitle: 'Pay using net banking',
              icon: Icons.account_balance_wallet,
              value: PaymentMethod.netBanking,
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
      onTap: () {
        setState(() {
          _selectedPaymentMethod = value;
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.05) : Colors.white,
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
                color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primary : Colors.grey.shade700,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
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
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, -4),
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
                Text(
                  'Total Amount',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '₹${_calculateTotalAmount().toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _canProceed() ? _placeOrder : null,
              child: Text('Place Order'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<Package?> _getPackage() async {
    // In a real app, you would fetch this from a repository
    // For now, we'll return a placeholder
    // This could be replaced with a call to PackageCubit.getPackageById
    
    if (_package != null) {
      return _package;
    }
    
    // Simulate loading from API
    await Future.delayed(Duration(milliseconds: 500));
    
    return Package(
      id: widget.packageId,
      name: 'Weekly Subscription',
      description: 'A delicious meal package for the week',
      price: 2000, // Base price
      slots: [], // We don't need the full slots list for checkout
    );
  }

  double _calculatePackagePrice() {
    if (_package != null) {
      return _package!.price * widget.personCount;
    }
    return 0;
  }

  double _calculateTotalAmount() {
    // Package price * person count + any additional fees
    return _calculatePackagePrice();
  }

  bool _canProceed() {
    return _selectedAddressId != null && !_isLoading;
  }

  void _placeOrder() {
    if (!_canProceed()) return;
    
    final cubit = context.read<CreateSubscriptionCubit>();
    
    // Convert to deprecated MealDistribution objects for the cubit
    @Deprecated('Use MealSlot instead')
    final mealDistributions = widget.mealSlots.map((slot) {
      return MealDistribution(
        day: slot.day,
        mealTime: slot.timing,
        mealId: slot.mealId,
      );
    }).toList();
    
    // Set the address and instructions
    cubit.selectAddress(_selectedAddressId!);
    cubit.setInstructions(_deliveryInstructions);
    
    // Create the subscription
    cubit.createSubscription();
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
          style: valueStyle ?? TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
