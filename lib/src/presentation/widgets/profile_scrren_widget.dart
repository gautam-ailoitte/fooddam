// lib/features/profile/widgets/profile_header.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/widgets/primary_button.dart';
import 'package:foodam/core/widgets/secondary_button.dart';
import 'package:foodam/src/domain/entities/address_entity.dart';
import 'package:foodam/src/domain/entities/user_entity.dart';

class ProfileHeader extends StatelessWidget {
  final User user;

  const ProfileHeader({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final hasName = user.firstName != null || user.lastName != null;
    final displayName = hasName
        ? '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim()
        : 'User';

    final initials = _getInitials(displayName);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.marginLarge),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primaryLight,
              child: Text(
                initials,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            SizedBox(height: AppDimensions.marginMedium),

            // User name
            Text(
              displayName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),

            // User email
            Text(
              user.email,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppDimensions.marginMedium),
            Divider(),
            SizedBox(height: AppDimensions.marginMedium),

            // User details grid
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoItem(
                  context,
                  'Email',
                  user.email,
                  Icons.email_outlined,
                ),
                _buildInfoItem(
                  context,
                  'Phone',
                  user.phone ?? 'Not set',
                  Icons.phone_outlined,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.primary,
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';

    final nameParts = name.split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    } else if (nameParts.length == 1 && nameParts[0].isNotEmpty) {
      return nameParts[0][0].toUpperCase();
    } else {
      return '?';
    }
  }
}


// lib/src/presentation/widgets/profile_scrren_widget.dart


class EditProfileForm extends StatefulWidget {
  final User user;
  final Function(User) onSave;
  final VoidCallback onCancel;

  const EditProfileForm({
    super.key,
    required this.user,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<EditProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    // Handle potentially null values safely
    _firstNameController = TextEditingController(text: widget.user.firstName ?? '');
    _lastNameController = TextEditingController(text: widget.user.lastName ?? '');
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phone ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      // Create an updated user that preserves ALL existing fields
      // but updates only the ones from the form
      final updatedUser = User(
        id: widget.user.id,
        email: _emailController.text,
        firstName: _firstNameController.text.isEmpty 
            ? null 
            : _firstNameController.text,
        lastName: _lastNameController.text.isEmpty 
            ? null 
            : _lastNameController.text,
        phone: _phoneController.text.isEmpty 
            ? null 
            : _phoneController.text,
        role: widget.user.role,
        // Important: Preserve these fields from the existing user
        addresses: widget.user.addresses,
        dietaryPreferences: widget.user.dietaryPreferences,
        allergies: widget.user.allergies,
        isEmailVerified: widget.user.isEmailVerified,
        isPhoneVerified: widget.user.isPhoneVerified,
      );
      
      widget.onSave(updatedUser);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.marginLarge),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Profile',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppDimensions.marginMedium),
              
              // First name field
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: 'First Name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              SizedBox(height: AppDimensions.marginMedium),
              
              // Last name field
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: 'Last Name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              SizedBox(height: AppDimensions.marginMedium),
              
              // Email field
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              SizedBox(height: AppDimensions.marginMedium),
              
              // Phone field
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: AppDimensions.marginLarge),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      text: 'Cancel',
                      onPressed: widget.onCancel,
                    ),
                  ),
                  SizedBox(width: AppDimensions.marginMedium),
                  Expanded(
                    child: PrimaryButton(
                      text: 'Save',
                      onPressed: _submitForm,
                      icon: Icons.save,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}class AddressListItem extends StatelessWidget {
  final Address address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AddressListItem({
    super.key,
    required this.address,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: AppDimensions.marginMedium),
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.marginMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.location_on,
                  color: AppColors.primary,
                ),
                SizedBox(width: AppDimensions.marginSmall),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        address.street,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${address.city}, ${address.state} ${address.zipCode}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: AppDimensions.marginMedium),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: Icon(Icons.edit, size: 18),
                  label: Text('Edit'),
                  onPressed: onEdit,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
                SizedBox(width: AppDimensions.marginSmall),
                TextButton.icon(
                  icon: Icon(Icons.delete_outline, size: 18),
                  label: Text('Delete'),
                  onPressed: onDelete,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.error,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}