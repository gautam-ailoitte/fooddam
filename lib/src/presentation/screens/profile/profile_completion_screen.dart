// lib/src/presentation/screens/profile/profile_completion_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
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
    _phoneController = TextEditingController(text: widget.user.phone ?? '');
    _emailController = TextEditingController(text: widget.user.email);

    // If user already has addresses, preselect the first one
    if (widget.user.addresses != null && widget.user.addresses!.isNotEmpty) {
      _selectedAddress = widget.user.addresses!.first;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState?.validate() ?? false) {
      // Create updated user with new information
      final updatedUser = User(
        id: widget.user.id,
        email: _emailController.text,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        phone: _phoneController.text,
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
      ),
      body: BlocConsumer<UserProfileCubit, UserProfileState>(
        listener: (context, state) {
          if (state is UserProfileUpdateSuccess) {
            // Show success message
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));

            // Navigate to main screen
            Navigator.of(context).pushReplacementNamed(AppRouter.mainRoute);
          } else if (state is UserProfileError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.marginLarge),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Complete Your Profile',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimensions.marginSmall),
                    Text(
                      'Please provide your details to enhance your food experience',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimensions.marginExtraLarge),

                    // First Name
                    TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        labelText: 'First Name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your first name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppDimensions.marginMedium),

                    // Last Name
                    TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        labelText: 'Last Name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your last name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppDimensions.marginMedium),

                    // Email - Read only since it's already provided
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      // readOnly: true,
                      // enabled: false,
                    ),
                    const SizedBox(height: AppDimensions.marginMedium),

                    // Phone
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        if (value.length < 10) {
                          return 'Please enter a valid phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppDimensions.marginLarge),

                    // Address section
                    _buildAddressSection(),

                    const SizedBox(height: AppDimensions.marginExtraLarge),
                    PrimaryButton(
                      text: 'Save & Continue',
                      onPressed: _saveProfile,
                      isLoading: state is UserProfileUpdating,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddressSection() {
    // Get addresses from user or from UserProfileCubit if available
    final addresses =
        context.read<UserProfileCubit>().state is UserProfileLoaded
            ? (context.read<UserProfileCubit>().state as UserProfileLoaded)
                .addresses
            : widget.user.addresses;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Delivery Address',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppDimensions.marginSmall),

        if (addresses == null || addresses.isEmpty)
          // No addresses - show add address button
          OutlinedButton.icon(
            onPressed: _addAddress,
            icon: const Icon(Icons.add_location_alt),
            label: const Text('Add Delivery Address'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          )
        else
          // Show address selection
          Column(
            children: [
              // Address selector
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: addresses.length,
                  itemBuilder: (context, index) {
                    final address = addresses[index];
                    final _ = _selectedAddress?.id == address.id;

                    return RadioListTile<Address>(
                      title: Text(address.street),
                      subtitle: Text(
                        '${address.city}, ${address.state} ${address.zipCode}',
                      ),
                      value: address,
                      groupValue: _selectedAddress,
                      onChanged: (value) {
                        setState(() {
                          _selectedAddress = value;
                        });
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: AppDimensions.marginSmall),

              // Add another address button
              TextButton.icon(
                onPressed: _addAddress,
                icon: const Icon(Icons.add),
                label: const Text('Add Another Address'),
              ),
            ],
          ),
      ],
    );
  }
}
