// lib/src/presentation/screens/profile/address_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/widgets/primary_button.dart';
import 'package:foodam/src/domain/entities/address_entity.dart';
import 'package:foodam/src/presentation/cubits/user_profile/user_profile_cubit.dart';
import 'package:foodam/src/presentation/cubits/user_profile/user_profile_state.dart';

class AddAddressScreen extends StatefulWidget {
  final Address? address; // For editing existing address

  const AddAddressScreen({this.address, super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  late TextEditingController _streetController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _zipCodeController;
  late TextEditingController _countryController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _streetController = TextEditingController(
      text: widget.address?.street ?? '',
    );
    _cityController = TextEditingController(text: widget.address?.city ?? '');
    _stateController = TextEditingController(text: widget.address?.state ?? '');
    _zipCodeController = TextEditingController(
      text: widget.address?.zipCode ?? '',
    );
    _countryController = TextEditingController(
      text: widget.address?.country ?? 'India',
    );
  }

  @override
  void dispose() {
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  void _saveAddress() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      final address = Address(
        id: widget.address?.id ?? '', // Empty ID for new address
        street: _streetController.text,
        city: _cityController.text,
        state: _stateController.text,
        zipCode: _zipCodeController.text,
        country: _countryController.text,
        // Default coordinates - for now using null
        latitude: null,
        longitude: null,
      );

      if (widget.address == null) {
        // Add new address
        context.read<UserProfileCubit>().addAddress(address);
      } else {
        // Update existing address
        context.read<UserProfileCubit>().updateAddress(address);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.address == null ? 'Add New Address' : 'Edit Address',
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocListener<UserProfileCubit, UserProfileState>(
        listener: (context, state) {
          if (state is UserProfileUpdateSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            Navigator.pop(context);
          } else if (state is UserProfileError) {
            setState(() {
              _isLoading = false;
            });
            _showErrorSnackBar(state.message);
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.marginLarge),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Address Details',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppDimensions.marginSmall),
                Text(
                  'Please fill in your complete address details below',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: AppDimensions.marginLarge),

                TextFormField(
                  controller: _streetController,
                  decoration: const InputDecoration(
                    labelText: 'Street Address',
                    prefixIcon: Icon(Icons.home),
                    hintText: 'Enter your street address, building name, etc.',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter street address';
                    }
                    return null;
                  },
                  maxLines: 2,
                ),
                const SizedBox(height: AppDimensions.marginMedium),

                TextFormField(
                  controller: _cityController,
                  decoration: const InputDecoration(
                    labelText: 'City',
                    prefixIcon: Icon(Icons.location_city),
                    hintText: 'Enter your city',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter city';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.marginMedium),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _stateController,
                        decoration: const InputDecoration(
                          labelText: 'State',
                          prefixIcon: Icon(Icons.map),
                          hintText: 'Enter state',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter state';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: AppDimensions.marginMedium),
                    Expanded(
                      child: TextFormField(
                        controller: _zipCodeController,
                        decoration: const InputDecoration(
                          labelText: 'ZIP Code',
                          prefixIcon: Icon(Icons.pin),
                          hintText: 'Enter ZIP code',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter ZIP code';
                          }
                          if (!RegExp(r'^[0-9]{5,6}$').hasMatch(value)) {
                            return 'Please enter valid ZIP code';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.marginMedium),

                TextFormField(
                  controller: _countryController,
                  decoration: const InputDecoration(
                    labelText: 'Country',
                    prefixIcon: Icon(Icons.flag),
                    hintText: 'Enter country',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter country';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppDimensions.marginExtraLarge),

                PrimaryButton(
                  text:
                      widget.address == null
                          ? 'Save Address'
                          : 'Update Address',
                  onPressed: _saveAddress,
                  isLoading: _isLoading,
                ),

                const SizedBox(height: AppDimensions.marginMedium),

                // Optional helper text
                Center(
                  child: Text(
                    'You can update your address anytime from profile',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
