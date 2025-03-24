// lib/features/profile/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/route/app_router.dart';
import 'package:foodam/core/widgets/app_loading.dart';
import 'package:foodam/core/widgets/error_display_wideget.dart';
import 'package:foodam/core/widgets/primary_button.dart';
import 'package:foodam/src/domain/entities/user_entity.dart';
import 'package:foodam/src/presentation/cubits/auth_cubit/auth_cubit_cubit.dart';
import 'package:foodam/src/presentation/cubits/user_profile/user_profile_cubit.dart';
import 'package:foodam/src/presentation/cubits/user_profile/user_profile_state.dart';
import 'package:foodam/src/presentation/widgets/profile_scrren_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  void _loadUserProfile() {
    context.read<UserProfileCubit>().getUserProfile();
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _updateProfile(User updatedUser) {
    context.read<UserProfileCubit>().updateUserDetails(updatedUser);
    setState(() {
      _isEditing = false;
    });
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Log Out'),
        content: Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text('Log Out'),
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthCubit>().logout();
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRouter.loginRoute,
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        actions: [
          BlocBuilder<UserProfileCubit, UserProfileState>(
            builder: (context, state) {
              if (state is UserProfileLoaded) {
                return IconButton(
                  icon: Icon(_isEditing ? Icons.close : Icons.edit),
                  onPressed: _toggleEditMode,
                );
              }
              return SizedBox.shrink();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadUserProfile();
          await Future.delayed(Duration(milliseconds: 300));
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(AppDimensions.marginLarge),
            child: BlocBuilder<UserProfileCubit, UserProfileState>(
              builder: (context, state) {
                if (state is UserProfileLoading) {
                  return AppLoading(message: 'Loading profile...');
                } else if (state is UserProfileError) {
                  return ErrorDisplayWidget(
                    message: state.message,
                    onRetry: _loadUserProfile,
                  );
                } else if (state is UserProfileLoaded) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile card
                      _isEditing
                          ? EditProfileForm(
                              user: state.user,
                              onSave: _updateProfile,
                              onCancel: _toggleEditMode,
                            )
                          : ProfileHeader(user: state.user),
                      SizedBox(height: AppDimensions.marginLarge),

                      // Addresses section
                      _buildAddressesSection(context, state),
                      SizedBox(height: AppDimensions.marginLarge),

                      // App preferences section
                      _buildPreferencesSection(context),
                      SizedBox(height: AppDimensions.marginLarge),

                      // Logout button
                      PrimaryButton(
                        text: 'Log Out',
                        onPressed: _logout,
                        icon: Icons.logout,
                      ),
                    ],
                  );
                }
                return Center(
                  child: Text('Please log in to view your profile'),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddressesSection(BuildContext context, UserProfileLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Saved Addresses',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            TextButton.icon(
              icon: Icon(Icons.add),
              label: Text('Add New'),
              onPressed: () {
                // Navigation to add address screen would be implemented here
              },
            ),
          ],
        ),
        SizedBox(height: AppDimensions.marginMedium),
        if (state.addresses == null || state.addresses!.isEmpty)
          Card(
            child: Padding(
              padding: EdgeInsets.all(AppDimensions.marginLarge),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.location_off,
                      size: 48,
                      color: AppColors.textSecondary.withOpacity(0.5),
                    ),
                    SizedBox(height: AppDimensions.marginMedium),
                    Text(
                      'No Addresses Found',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: AppDimensions.marginSmall),
                    Text(
                      'Add your first delivery address to get started',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...state.addresses!.map(
            (address) => AddressListItem(
              address: address,
              onEdit: () {
                // Navigation to edit address screen would be implemented here
              },
              onDelete: () {
                // Confirmation dialog for address deletion would be shown here
              },
            ),
          ),
      ],
    );
  }

  Widget _buildPreferencesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preferences',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        SizedBox(height: AppDimensions.marginMedium),
        Card(
          child: Column(
            children: [
              _buildPreferenceItem(
                context,
                'Notifications',
                'Manage notification settings',
                Icons.notifications_outlined,
                () {
                  // Navigation to notification settings would be implemented here
                },
              ),
              Divider(),
              _buildPreferenceItem(
                context,
                'Payment Methods',
                'Manage your payment methods',
                Icons.payment_outlined,
                () {
                  // Navigation to payment methods would be implemented here
                },
              ),
              Divider(),
              _buildPreferenceItem(
                context,
                'Dark Mode',
                'Toggle dark theme',
                Icons.dark_mode_outlined,
                () {
                  // Dark mode toggle would be implemented here
                },
                trailing: Switch(
                  value: false, // Would be connected to theme state
                  onChanged: (value) {
                    // Theme change would be handled here
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreferenceItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing ?? Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}