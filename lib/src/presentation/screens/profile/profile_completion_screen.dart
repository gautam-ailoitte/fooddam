// lib/src/presentation/screens/auth/profile_completion_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/route/app_router.dart';
import 'package:foodam/core/widgets/primary_button.dart';
import 'package:foodam/src/domain/entities/user_entity.dart';
import 'package:foodam/src/presentation/cubits/user_profile/user_profile_cubit.dart';
import 'package:foodam/src/presentation/cubits/user_profile/user_profile_state.dart';

class ProfileCompletionScreen extends StatefulWidget {
  final User user;
  
  const ProfileCompletionScreen({
    required this.user,
    Key? key,
  }) : super(key: key);

  @override
  State<ProfileCompletionScreen> createState() => _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  final _allergiesController = TextEditingController();
  final _dietaryPrefsController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing user data if available
    _firstNameController = TextEditingController(text: widget.user.firstName ?? '');
    _lastNameController = TextEditingController(text: widget.user.lastName ?? '');
    _phoneController = TextEditingController(text: widget.user.phone ?? '');
    
    if (widget.user.allergies != null && widget.user.allergies!.isNotEmpty) {
      _allergiesController.text = widget.user.allergies!.join(', ');
    }
    
    if (widget.user.dietaryPreferences != null && widget.user.dietaryPreferences!.isNotEmpty) {
      _dietaryPrefsController.text = widget.user.dietaryPreferences!.join(', ');
    }
  }
  
  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _allergiesController.dispose();
    _dietaryPrefsController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState?.validate() ?? false) {
      // Create updated user with new information
      final updatedUser = User(
        id: widget.user.id,
        email: widget.user.email,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        phone: _phoneController.text,
        role: widget.user.role,
        addresses: widget.user.addresses,
        allergies: _allergiesController.text.isEmpty 
            ? null 
            : _allergiesController.text.split(',').map((e) => e.trim()).toList(),
        dietaryPreferences: _dietaryPrefsController.text.isEmpty 
            ? null 
            : _dietaryPrefsController.text.split(',').map((e) => e.trim()).toList(),
      );
      
      // Update user profile
      context.read<UserProfileCubit>().updateUserDetails(updatedUser);
    }
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            
            // Navigate to main screen
            Navigator.of(context).pushReplacementNamed(AppRouter.mainRoute);
          } else if (state is UserProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
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
                    const SizedBox(height: AppDimensions.marginMedium),
                    
                    // Allergies
                    TextFormField(
                      controller: _allergiesController,
                      decoration: const InputDecoration(
                        labelText: 'Allergies (comma separated)',
                        prefixIcon: Icon(Icons.warning_amber),
                        hintText: 'e.g. Nuts, Dairy, Gluten',
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppDimensions.marginMedium),
                    
                    // Dietary Preferences
                    TextFormField(
                      controller: _dietaryPrefsController,
                      decoration: const InputDecoration(
                        labelText: 'Dietary Preferences (comma separated)',
                        prefixIcon: Icon(Icons.restaurant_menu),
                        hintText: 'e.g. Vegetarian, Low Carb, Keto',
                      ),
                      textInputAction: TextInputAction.done,
                    ),
                    
                    const SizedBox(height: AppDimensions.marginExtraLarge),
                    PrimaryButton(
                      text: 'Save & Continue',
                      onPressed: _saveProfile,
                      isLoading: state is UserProfileUpdating,
                    ),
                    const SizedBox(height: AppDimensions.marginMedium),
                    TextButton(
                      onPressed: state is UserProfileUpdating ? null : () {
                        Navigator.of(context).pushReplacementNamed(AppRouter.mainRoute);
                      },
                      child: const Text('Skip for now'),
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
}