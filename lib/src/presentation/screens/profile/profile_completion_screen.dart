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
  bool _showAllAddresses = false;
  static const int _initialAddressCount = 2;

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

    // Load user profile and addresses from cubit (single source of truth)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProfileCubit>().getUserProfile();
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  String _trimSafely(String? input) => input?.trim() ?? '';

  void _selectAddress(Address address) {
    setState(() {
      _selectedAddress = address;
    });
  }

  void _autoSelectAddress(List<Address>? addresses) {
    if (addresses == null || addresses.isEmpty) return;

    // Auto-select first address if none selected, or newest if just added
    if (_selectedAddress == null) {
      setState(() {
        _selectedAddress = addresses.first;
      });
    } else {
      // If we have more addresses than before, select the newest (last) one
      final newestAddress = addresses.last;
      if (_selectedAddress?.id != newestAddress.id) {
        setState(() {
          _selectedAddress = newestAddress;
        });
      }
    }
  }

  void _saveProfile() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedAddress == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a delivery address'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Create updated user with trimmed text data
      final updatedUser = User(
        id: widget.user.id,
        email: widget.user.email,
        firstName: _trimSafely(_firstNameController.text),
        lastName: _trimSafely(_lastNameController.text),
        phone: widget.user.phone,
        role: widget.user.role,
        addresses: widget.user.addresses,
        dietaryPreferences: widget.user.dietaryPreferences,
        allergies: widget.user.allergies,
        isEmailVerified: widget.user.isEmailVerified,
        isPhoneVerified: widget.user.isPhoneVerified,
      );

      // Update user profile
      context.read<UserProfileCubit>().updateUserDetails(updatedUser);
    }
  }

  void _addAddress() async {
    final result = await Navigator.of(
      context,
    ).pushNamed(AppRouter.addAddressRoute);

    // Optional: Show feedback that address will be auto-selected
    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New address will be selected automatically'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _toggleShowAllAddresses() {
    setState(() {
      _showAllAddresses = !_showAllAddresses;
    });
  }

  List<Address> _getDisplayedAddresses(List<Address> addresses) {
    if (_showAllAddresses || addresses.length <= _initialAddressCount) {
      return addresses;
    }
    return addresses.take(_initialAddressCount).toList();
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
      body: MultiBlocListener(
        listeners: [
          BlocListener<UserProfileCubit, UserProfileState>(
            listener: (context, state) {
              // Auto-select address after successful operations
              if (state is UserProfileLoaded) {
                _autoSelectAddress(state.addresses);
              } else if (state is UserProfileUpdateSuccess) {
                if (state.message.contains('Address added')) {
                  // Auto-select newest address after addition
                  _autoSelectAddress(state.addresses);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (state.message.contains('Profile updated')) {
                  // Navigate to main screen after profile update
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.of(
                    context,
                  ).pushReplacementNamed(AppRouter.mainRoute);
                }
              } else if (state is UserProfileError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<UserProfileCubit, UserProfileState>(
          builder: (context, state) {
            if (state is UserProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is UserProfileError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error Loading Profile',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<UserProfileCubit>().getUserProfile();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            // Get addresses from state
            List<Address>? addresses;
            if (state is UserProfileLoaded) {
              addresses = state.addresses;
            } else if (state is UserProfileUpdating) {
              addresses = state.addresses;
            } else if (state is UserProfileUpdateSuccess) {
              addresses = state.addresses;
            }

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
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      'Personal Information',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: AppDimensions.marginMedium,
                                    ),

                                    // First & Last Name fields
                                    _buildNameFields(context),

                                    const SizedBox(
                                      height: AppDimensions.marginLarge,
                                    ),

                                    // Address section
                                    Text(
                                      'Delivery Address',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: AppDimensions.marginMedium,
                                    ),

                                    _buildAddressSection(addresses),

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
      ),
    );
  }

  Widget _buildProfileImageSection() {
    return Container(
      color: AppColors.primary,
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
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
                  boxShadow: const [
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
                    child: const Icon(
                      Icons.person,
                      size: 70,
                      color: Colors.white,
                    ),
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
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
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
                    child: const Icon(
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
        final trimmed = _trimSafely(value);
        if (trimmed.isEmpty) {
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
        final trimmed = _trimSafely(value);
        if (trimmed.isEmpty) {
          return 'Please enter your last name';
        }
        return null;
      },
    );
  }

  Widget _buildAddressSection(List<Address>? addresses) {
    if (addresses == null || addresses.isEmpty) {
      // No addresses - show empty state with nice visuals
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 30),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(Icons.location_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
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
    }

    // Show address selection cards with progressive disclosure
    final displayedAddresses = _getDisplayedAddresses(addresses);

    return Column(
      children: [
        // Address cards
        ...displayedAddresses.map((address) {
          final isSelected = _selectedAddress?.id == address.id;

          return Card(
            key: ValueKey(address.id), // Use address ID as unique key
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isSelected ? AppColors.primary : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
            ),
            elevation: isSelected ? 2 : 0,
            child: InkWell(
              onTap: () => _selectAddress(address),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
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
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            address.street,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
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
                        if (value != null) _selectAddress(value);
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        }),

        // Show more/less button
        if (addresses.length > _initialAddressCount)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextButton.icon(
              onPressed: _toggleShowAllAddresses,
              icon: Icon(
                _showAllAddresses ? Icons.expand_less : Icons.expand_more,
                color: AppColors.primary,
              ),
              label: Text(
                _showAllAddresses
                    ? 'Show Less'
                    : 'Show ${addresses.length - _initialAddressCount} More',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ),
      ],
    );
  }
}
