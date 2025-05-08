// lib/src/presentation/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/route/app_router.dart';
import 'package:foodam/core/theme/theme_provider.dart';
import 'package:foodam/core/widgets/app_loading.dart';
import 'package:foodam/core/widgets/error_display_wideget.dart';
import 'package:foodam/src/domain/entities/address_entity.dart';
import 'package:foodam/src/domain/entities/user_entity.dart';
import 'package:foodam/src/presentation/cubits/auth_cubit/auth_cubit_cubit.dart';
import 'package:foodam/src/presentation/cubits/user_profile/user_profile_cubit.dart';
import 'package:foodam/src/presentation/cubits/user_profile/user_profile_state.dart';
import 'package:foodam/src/presentation/widgets/profile_scrren_widget.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
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

  void _showChangeEmailDialog([bool isAddingEmail = false]) {
    final TextEditingController emailController = TextEditingController();
    bool isUpdating = false;

    showDialog(
      context: context,
      builder:
          (dialogContext) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: Text(isAddingEmail ? 'Add Email' : 'Change Email'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText:
                              isAddingEmail ? 'Email Address' : 'New Email',
                          hintText:
                              isAddingEmail
                                  ? 'Enter your email address'
                                  : 'Enter your new email address',
                        ),
                        keyboardType: TextInputType.emailAddress,
                        enabled: !isUpdating,
                      ),
                      if (isUpdating)
                        const Padding(
                          padding: EdgeInsets.only(top: 16.0),
                          child: LinearProgressIndicator(),
                        ),
                    ],
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  actions: [
                    TextButton(
                      onPressed:
                          isUpdating
                              ? null
                              : () => Navigator.pop(dialogContext),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed:
                          isUpdating
                              ? null
                              : () async {
                                final newEmail = emailController.text.trim();
                                if (newEmail.isNotEmpty) {
                                  setState(() => isUpdating = true);

                                  // Listen for state changes
                                  context
                                      .read<UserProfileCubit>()
                                      .updateUserEmail(newEmail);

                                  // Wait a bit for the operation to complete
                                  await Future.delayed(
                                    const Duration(seconds: 1),
                                  );

                                  if (mounted) {
                                    Navigator.pop(dialogContext);
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please enter a valid email',
                                      ),
                                    ),
                                  );
                                }
                              },
                      child: Text(
                        isUpdating
                            ? 'Updating...'
                            : isAddingEmail
                            ? 'Add'
                            : 'Update',
                      ),
                    ),
                  ],
                ),
          ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder:
          (context) => AlertDialog(
            title: const Text('Log Out'),
            content: const Text('Are you sure you want to log out?'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: Theme.of(context).cardColor,
            elevation: 8,
            actions: [
              TextButton(
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Log Out'),
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      body: BlocConsumer<UserProfileCubit, UserProfileState>(
        listener: (context, state) {
          // Handle one-time actions
          if (state is UserProfileUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          } else if (state is UserProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is UserProfileInitial) {
            _loadUserProfile();
            return const Center(child: AppLoading(message: 'Initializing...'));
          }

          if (state is UserProfileLoading) {
            return const Center(
              child: AppLoading(message: 'Loading profile...'),
            );
          }

          if (state is UserProfileError) {
            return Center(
              child: ErrorDisplayWidget(
                message: state.message,
                onRetry: _loadUserProfile,
              ),
            );
          }

          // Handle loaded states (including updating)
          if (state is UserProfileLoaded ||
              state is UserProfileUpdating ||
              state is UserProfileUpdateSuccess) {
            User user;
            List<Address>? addresses;
            bool isUpdating = false;
            String? updatingField;

            if (state is UserProfileLoaded) {
              user = state.user;
              addresses = state.addresses;
            } else if (state is UserProfileUpdating) {
              user = state.user;
              addresses = state.addresses;
              isUpdating = true;
              updatingField = state.field;
            } else if (state is UserProfileUpdateSuccess) {
              user = state.user;
              addresses = state.addresses;
            } else {
              // This shouldn't happen, but handling it for completeness
              return const Center(child: Text('Unknown state'));
            }

            return _buildProfileContent(
              context,
              user,
              addresses,
              isDarkMode,
              isUpdating,
              updatingField,
            );
          }

          return const Center(
            child: Text('Please log in to view your profile'),
          );
        },
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () {
      //     final currentUser =
      //         (context.read<AuthCubit>().state as AuthAuthenticated).user;
      //     Navigator.of(context).push(
      //       MaterialPageRoute(
      //         builder: (_) => ProfileCompletionScreen(user: currentUser),
      //       ),
      //     );
      //   },
      //   backgroundColor: AppColors.accent,
      //   label: const Text('Complete Profile'),
      //   icon: const Icon(Icons.person_add),
      // ),
    );
  }

  Widget _buildProfileContent(
    BuildContext context,
    User user,
    List<Address>? addresses,
    bool isDarkMode,
    bool isUpdating,
    String? updatingField,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        _loadUserProfile();
        await Future.delayed(const Duration(milliseconds: 300));
      },
      child: Stack(
        children: [
          CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              _buildProfileAppBar(context, user, isDarkMode),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Personal Information
                      if (_isEditing)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          margin: const EdgeInsets.only(bottom: 16),
                          child: EditProfileForm(
                            user: user,
                            onSave: _updateProfile,
                            onCancel: _toggleEditMode,
                          ),
                        )
                      else
                        _buildPersonalInfoCard(context, user, isDarkMode),

                      const SizedBox(height: 16),

                      // Addresses section
                      _buildAddressesSection(
                        context,
                        user,
                        addresses,
                        isDarkMode,
                      ),

                      const SizedBox(height: 24),

                      // Logout button
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ElevatedButton.icon(
                          onPressed: _logout,
                          icon: const Icon(Icons.logout),
                          label: const Text('Log Out'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isDarkMode
                                    ? Colors.redAccent.shade200
                                    : Colors.redAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: isDarkMode ? 0 : 2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Show loading overlay when updating
          if (isUpdating)
            Container(
              color: Colors.black12,
              child: Center(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 8),
                        Text('Updating ${updatingField ?? 'profile'}...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileAppBar(BuildContext context, User user, bool isDarkMode) {
    final displayName = user.fullName ?? 'User';
    final initials = _getInitials(displayName);

    return SliverAppBar(
      automaticallyImplyLeading: false,
      expandedHeight: 200,
      pinned: true,
      stretch: true,
      backgroundColor: isDarkMode ? AppColors.primaryDark : AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors:
                  isDarkMode
                      ? [
                        AppColors.primaryDark,
                        AppColors.primary.withOpacity(0.7),
                      ]
                      : [AppColors.primary, AppColors.primaryLight],
            ),
          ),
          child: Stack(
            children: [
              // Background patterns
              Positioned(
                right: -50,
                top: -30,
                child: Container(
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                left: -30,
                bottom: -20,
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              // User profile content
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 2, width: double.infinity),
                      // Profile avatar
                      Hero(
                        tag: 'profile-avatar',
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 38,
                            backgroundColor: AppColors.accentLight,
                            child: Text(
                              initials,
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // User name
                      Text(
                        displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        collapseMode: CollapseMode.parallax,
      ),
      actions: [
        IconButton(
          icon: Icon(_isEditing ? Icons.close : Icons.edit),
          color: Colors.white,
          onPressed: _toggleEditMode,
          tooltip: _isEditing ? 'Cancel' : 'Edit Profile',
        ),
      ],
    );
  }

  Widget _buildPersonalInfoCard(
    BuildContext context,
    User user,
    bool isDarkMode,
  ) {
    final hasEmail = user.email.isNotEmpty;

    return Card(
      elevation: isDarkMode ? 1 : 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        isDarkMode
                            ? AppColors.primaryDark.withOpacity(0.1)
                            : AppColors.primaryLighter,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person,
                    color:
                        isDarkMode ? AppColors.primaryLight : AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Personal Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  onPressed: _toggleEditMode,
                  tooltip: 'Edit',
                  color: AppColors.primary,
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(
              'Name',
              user.fullName ?? 'Not set',
              Icons.badge_outlined,
            ),

            if (hasEmail)
              _buildInfoRow(
                'Email',
                user.email,
                Icons.email_outlined,
                isVerified: user.isEmailVerified,
              )
            else
              _buildActionRow(
                'Email',
                'Add email address',
                Icons.email_outlined,
                onTap: () => _showChangeEmailDialog(true),
              ),

            // Only show phone if it exists
            if (user.phone != null && user.phone!.isNotEmpty)
              _buildInfoRow(
                'Phone',
                user.phone!,
                Icons.phone_outlined,
                isVerified: user.isPhoneVerified,
              ),

            // Change email button - only show if user has email
            if (hasEmail)
              Padding(
                padding: const EdgeInsets.only(left: 0, bottom: 16),
                child: TextButton.icon(
                  onPressed: () => _showChangeEmailDialog(),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Change Email'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),

            if (user.dietaryPreferences != null &&
                user.dietaryPreferences!.isNotEmpty)
              _buildInfoRow(
                'Dietary',
                user.dietaryPreferences!.join(', '),
                Icons.restaurant_outlined,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon, {
    bool? isVerified,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 15))),
          // Only show verification status if provided
          if (isVerified != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color:
                    isVerified
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isVerified ? Icons.verified : Icons.warning_amber_rounded,
                    size: 16,
                    color: isVerified ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isVerified ? 'Verified' : 'Unverified',
                    style: TextStyle(
                      fontSize: 12,
                      color: isVerified ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionRow(
    String label,
    String actionText,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.grey),
            const SizedBox(width: 8),
            SizedBox(
              width: 80,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Text(
                    actionText,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.add_circle_outline,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressesSection(
    BuildContext context,
    User user,
    List<Address>? addresses,
    bool isDarkMode,
  ) {
    return Card(
      elevation: isDarkMode ? 1 : 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        isDarkMode
                            ? AppColors.accentDark.withOpacity(0.1)
                            : AppColors.accentLighter,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.location_on,
                    color:
                        isDarkMode ? AppColors.accentLight : AppColors.accent,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Addresses',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushNamed(AppRouter.addAddressRoute);
                    // Navigation to add address screen would be implemented here
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add New'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isDarkMode ? AppColors.accentDark : AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            if (addresses == null)
              // Show loading state for addresses
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (addresses.isEmpty)
              _buildEmptyAddressState(context, isDarkMode)
            else
              ...addresses.map(
                (address) => _buildAddressCard(context, address, isDarkMode),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyAddressState(BuildContext context, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.location_off,
            size: 56,
            color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Saved Addresses',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first delivery address to get started',
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).pushNamed(AppRouter.addAddressRoute);
            },
            icon: const Icon(Icons.add_location_alt_outlined),
            label: const Text('Add Your First Address'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              side: BorderSide(color: AppColors.accent),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(
    BuildContext context,
    dynamic address,
    bool isDarkMode,
  ) {
    // Get screen width to determine layout
    final screenWidth = MediaQuery.of(context).size.width;
    final useCompactLayout = screenWidth < 360; // Threshold for compact layout

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isDarkMode ? Colors.grey[850] : Colors.grey[100],
        border: Border.all(
          color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Address content
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.home_outlined,
                color: isDarkMode ? AppColors.accentLight : AppColors.accent,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      address.street,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${address.city}, ${address.state} ${address.zipCode}',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                      ),
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Action buttons - different layouts based on screen width
          useCompactLayout
              ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pushNamed(
                              AppRouter.addAddressRoute,
                              arguments: address,
                            );
                          },
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Edit'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor:
                                isDarkMode
                                    ? Colors.grey[300]
                                    : Colors.grey[700],
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            minimumSize: const Size(0, 36),
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              )
              : Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        AppRouter.addAddressRoute,
                        arguments: address,
                      );
                    },
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit'),
                    style: TextButton.styleFrom(
                      foregroundColor:
                          isDarkMode ? Colors.grey[300] : Colors.grey[700],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '';

    final nameParts = name.split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    } else if (nameParts.length == 1) {
      return name.substring(0, 1).toUpperCase();
    }

    return '';
  }
}
