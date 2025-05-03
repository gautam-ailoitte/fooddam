// lib/features/profile/widgets/profile_header.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/src/domain/entities/user_entity.dart';

class ProfileHeader extends StatelessWidget {
  final User user;

  const ProfileHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final hasName = user.firstName != null || user.lastName != null;
    final displayName =
        hasName
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
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),

            // User email
            Text(
              user.email,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
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
        Icon(icon, color: AppColors.primary),
        SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
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

// lib/src/presentation/widgets/profile_screen_widget.dart

class EditProfileForm extends StatefulWidget {
  final User user;
  final Function(User) onSave;
  final VoidCallback? onCancel;

  const EditProfileForm({
    super.key,
    required this.user,
    required this.onSave,
    this.onCancel,
  });

  @override
  State<EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<EditProfileForm> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  bool _hasExistingEmail = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.user.firstName);
    _lastNameController = TextEditingController(text: widget.user.lastName);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phone);
    _hasExistingEmail = widget.user.email.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // First Name
          TextFormField(
            controller: _firstNameController,
            decoration: const InputDecoration(
              labelText: 'First Name',
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 16),

          // Last Name
          TextFormField(
            controller: _lastNameController,
            decoration: const InputDecoration(
              labelText: 'Last Name',
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 16),

          // Email - disabled if already exists
          TextFormField(
            controller: _emailController,
            enabled: !_hasExistingEmail, // Disable if email exists
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: const Icon(Icons.email),
              suffixIcon:
                  _hasExistingEmail
                      ? IconButton(
                        icon: const Icon(Icons.info_outline),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Email cannot be changed from here. Use email change option in settings.',
                              ),
                            ),
                          );
                        },
                      )
                      : null,
            ),
          ),
          const SizedBox(height: 16),

          // Phone
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Phone',
              prefixIcon: Icon(Icons.phone),
            ),
          ),
          const SizedBox(height: 24),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (widget.onCancel != null)
                TextButton(
                  onPressed: widget.onCancel,
                  child: const Text('Cancel'),
                ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  final updatedUser = User(
                    id: widget.user.id,
                    email:
                        _emailController
                            .text, // This won't be updated if field is disabled
                    firstName: _firstNameController.text,
                    lastName: _lastNameController.text,
                    phone: _phoneController.text,
                    role: widget.user.role,
                    isEmailVerified: widget.user.isEmailVerified,
                    isPhoneVerified: widget.user.isPhoneVerified,
                    dietaryPreferences: widget.user.dietaryPreferences,
                    allergies: widget.user.allergies,
                  );
                  widget.onSave(updatedUser);
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
