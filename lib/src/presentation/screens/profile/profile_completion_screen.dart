// lib/src/presentation/screens/profile/profile_completion_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/route/app_router.dart';
import 'package:foodam/core/widgets/primary_button.dart';
import 'package:foodam/src/domain/entities/address_entity.dart';
import 'package:foodam/src/domain/entities/user_entity.dart';
import 'package:foodam/src/presentation/cubits/user_profile/user_profile_cubit.dart';
import 'package:foodam/src/presentation/cubits/user_profile/user_profile_state.dart';

class ProfileCompletionScreen extends StatefulWidget {
  final User user;

  const ProfileCompletionScreen({required this.user, super.key});

  @override
  State<ProfileCompletionScreen> createState() =>
      _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  Address? _selectedAddress;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing user data if available
    _firstNameController = TextEditingController(
      text: widget.user.firstName ?? '',
    );
    _lastNameController = TextEditingController(
      text: widget.user.lastName ?? '',
    );

    // If user already has addresses, preselect the first one
    if (widget.user.addresses != null && widget.user.addresses!.isNotEmpty) {
      _selectedAddress = widget.user.addresses!.first;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedAddress == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add a delivery address')),
        );
        return;
      }

      // Create updated user with new information
      final updatedUser = User(
        id: widget.user.id,
        email: widget.user.email,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: widget.user.phone,
        role: widget.user.role,
        addresses: widget.user.addresses,
        isEmailVerified: widget.user.isEmailVerified,
        isPhoneVerified: widget.user.isPhoneVerified,
      );

      // Update user profile
      context.read<UserProfileCubit>().updateUserDetails(updatedUser);
    }
  }

  void _addAddress() {
    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigating to address form...'),
        duration: Duration(seconds: 1),
      ),
    );

    // Navigate to address screen
    Navigator.of(context).pushNamed(AppRouter.addAddressRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<UserProfileCubit, UserProfileState>(
        listener: (context, state) {
          if (state is UserProfileUpdateSuccess) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );

            // Navigate to main screen
            Navigator.of(context).pushReplacementNamed(AppRouter.mainRoute);
          } else if (state is UserProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Profile image section with curved decoration
                            _buildProfileImageSection(),

                            // Form fields
                            Padding(
                              padding: const EdgeInsets.all(
                                AppDimensions.marginLarge,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    'Personal Information',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    height: AppDimensions.marginMedium,
                                  ),

                                  // First & Last Name fields (side by side on larger screens)
                                  _buildNameFields(context),

                                  const SizedBox(
                                    height: AppDimensions.marginLarge,
                                  ),

                                  // Address section
                                  Text(
                                    'Delivery Address',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    height: AppDimensions.marginMedium,
                                  ),

                                  _buildAddressSection(),

                                  const SizedBox(
                                    height: AppDimensions.marginExtraLarge,
                                  ),

                                  PrimaryButton(
                                    text: 'Save & Continue',
                                    onPressed: _saveProfile,
                                    isLoading: state is UserProfileUpdating,
                                  ),

                                  const SizedBox(height: 80), // Space for FAB
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Fixed position Add Address Button at bottom
                Positioned(
                  // left: 0,
                  right: 0,
                  bottom: 16,
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: ElevatedButton.icon(
                        onPressed: _addAddress,
                        icon: const Icon(Icons.add_location_alt),
                        label: const Text('Add New Address'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          elevation: 4,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          minimumSize: const Size(200, 48),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileImageSection() {
    return Container(
      color: AppColors.primary,
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            'Profile Setup',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              // Profile image placeholder
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 57,
                    backgroundColor: AppColors.primary.withOpacity(0.3),
                    child: Icon(Icons.person, size: 70, color: Colors.white),
                  ),
                ),
              ),

              // Edit button for image
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Image upload will be implemented later'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.accent,
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildNameFields(BuildContext context) {
    // Check if screen width is large enough for side-by-side layout
    final screenWidth = MediaQuery.of(context).size.width;
    final useHorizontalLayout = screenWidth > 600;

    if (useHorizontalLayout) {
      return Row(
        children: [
          Expanded(child: _buildFirstNameField()),
          const SizedBox(width: 16),
          Expanded(child: _buildLastNameField()),
        ],
      );
    } else {
      return Column(
        children: [
          _buildFirstNameField(),
          const SizedBox(height: AppDimensions.marginMedium),
          _buildLastNameField(),
        ],
      );
    }
  }

  Widget _buildFirstNameField() {
    return TextFormField(
      controller: _firstNameController,
      decoration: const InputDecoration(
        labelText: 'First Name',
        hintText: 'Enter your first name',
        prefixIcon: Icon(Icons.person_outline),
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your first name';
        }
        return null;
      },
    );
  }

  Widget _buildLastNameField() {
    return TextFormField(
      controller: _lastNameController,
      decoration: const InputDecoration(
        labelText: 'Last Name',
        hintText: 'Enter your last name',
        prefixIcon: Icon(Icons.person_outline),
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      textInputAction: TextInputAction.done,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your last name';
        }
        return null;
      },
    );
  }

  Widget _buildAddressSection() {
    // Get addresses from user or from UserProfileCubit if available
    List<Address>? addresses;
    if (context.watch<UserProfileCubit>().state is UserProfileLoaded) {
      addresses =
          (context.read<UserProfileCubit>().state as UserProfileLoaded)
              .addresses;
    } else if (widget.user.addresses != null &&
        widget.user.addresses!.isNotEmpty) {
      addresses = widget.user.addresses;
    }

    if (addresses == null || addresses.isEmpty) {
      // No addresses - show empty state with nice visuals
      return Container(
        padding: EdgeInsets.symmetric(vertical: 30),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(Icons.location_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No Addresses Added Yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Add a delivery address to get your meals delivered to your doorstep',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    } else {
      // Show address selection cards
      return Column(
        children: [
          ...addresses.map((address) {
            final isSelected = _selectedAddress?.id == address.id;

            return Card(
              margin: EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
              ),
              elevation: isSelected ? 2 : 0,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedAddress = address;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? AppColors.primary.withOpacity(0.1)
                                  : Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.location_on,
                          color: isSelected ? AppColors.primary : Colors.grey,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              address.street,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '${address.city}, ${address.state} ${address.zipCode}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Radio<Address>(
                        value: address,
                        groupValue: _selectedAddress,
                        activeColor: AppColors.primary,
                        onChanged: (value) {
                          setState(() {
                            _selectedAddress = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      );
    }
  }
}
