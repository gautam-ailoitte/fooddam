// lib/src/presentation/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/route/app_router.dart';
import 'package:foodam/core/theme/theme_provider.dart';
import 'package:foodam/core/widgets/app_loading.dart';
import 'package:foodam/core/widgets/error_display_wideget.dart';
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

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  bool _isEditing = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
    // Get the ThemeProvider to check dark mode status
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      body: BlocBuilder<UserProfileCubit, UserProfileState>(
        builder: (context, state) {
          if (state is UserProfileLoading) {
            return const Center(
              child: AppLoading(message: 'Loading profile...'),
            );
          } else if (state is UserProfileError) {
            return Center(
              child: ErrorDisplayWidget(
                message: state.message,
                onRetry: _loadUserProfile,
              ),
            );
          } else if (state is UserProfileLoaded) {
            return _buildProfileContent(context, state, isDarkMode);
          }

          return const Center(
            child: Text('Please log in to view your profile'),
          );
        },
      ),
    );
  }

  Widget _buildProfileContent(
    BuildContext context,
    UserProfileLoaded state,
    bool isDarkMode,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        _loadUserProfile();
        await Future.delayed(const Duration(milliseconds: 300));
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Custom App Bar with profile header
          _buildProfileAppBar(context, state.user, isDarkMode),

          // Tab Bar
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor:
                    isDarkMode ? Colors.grey[400] : Colors.grey[600],
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                indicatorSize: TabBarIndicatorSize.label,
                tabs: const [Tab(text: 'Profile'), Tab(text: 'Preferences')],
              ),
            ),
          ),

          // Tab Views
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildProfileTab(context, state, isDarkMode),
                _buildPreferencesTab(context, isDarkMode),
              ],
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

                      // // User email
                      // Text(
                      //   email,
                      //   style: TextStyle(
                      //     color: Colors.white.withOpacity(0.9),
                      //     fontSize: 14,
                      //   ),
                      // ),
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

  Widget _buildProfileTab(
    BuildContext context,
    UserProfileLoaded state,
    bool isDarkMode,
  ) {
    return SingleChildScrollView(
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
                user: state.user,
                onSave: _updateProfile,
                onCancel: _toggleEditMode,
              ),
            )
          else
            _buildPersonalInfoCard(context, state.user, isDarkMode),

          const SizedBox(height: 16),

          // Addresses section
          _buildAddressesSection(context, state, isDarkMode),

          const SizedBox(height: 16),
          _buildVerificationSection(context, state.user, isDarkMode),

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
                    isDarkMode ? Colors.redAccent.shade200 : Colors.redAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: isDarkMode ? 0 : 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoCard(
    BuildContext context,
    User user,
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
            _buildInfoRow(
              'Email',
              user.email,
              Icons.email_outlined,
              isVerified: user.isEmailVerified,
            ),
            _buildInfoRow(
              'Phone',
              user.phone ?? 'Not set',
              Icons.phone_outlined,
              isVerified: user.phone != null ? user.isPhoneVerified : null,
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

  Widget _buildVerificationSection(
    BuildContext context,
    User user,
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
                            ? Colors.blueAccent.withOpacity(0.1)
                            : Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.verified_user,
                    color: isDarkMode ? Colors.blueAccent : Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Account Verification',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),

            // Email verification status
            _buildVerificationItem(
              context,
              'Email Address',
              user.email,
              user.isEmailVerified,
              Icons.email,
              isDarkMode,
              onVerify: () {
                // TODO: Implement email verification request
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Verification email sent')),
                );
              },
            ),

            const SizedBox(height: 16),

            // Phone verification status
            _buildVerificationItem(
              context,
              'Phone Number',
              user.phone ?? 'Not set',
              user.phone != null ? user.isPhoneVerified : false,
              Icons.phone,
              isDarkMode,
              onVerify:
                  user.phone == null
                      ? null
                      : () {
                        // TODO: Implement phone verification request
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Verification SMS sent'),
                          ),
                        );
                      },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationItem(
    BuildContext context,
    String title,
    String value,
    bool isVerified,
    IconData icon,
    bool isDarkMode, {
    VoidCallback? onVerify,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isDarkMode ? Colors.grey[850] : Colors.grey[100],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                ),
              ),
              const Spacer(),
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
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 15)),
          if (!isVerified && onVerify != null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onVerify,
                icon: const Icon(Icons.verified_outlined, size: 16),
                label: const Text('Verify Now'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddressesSection(
    BuildContext context,
    UserProfileLoaded state,
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
            if (state.addresses == null || state.addresses!.isEmpty)
              _buildEmptyAddressState(context, isDarkMode)
            else
              ...state.addresses!.map(
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
              // Navigation to add address screen would be implemented here
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
                            // Edit action implementation
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
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Delete action implementation
                          },
                          icon: const Icon(Icons.delete_outline, size: 16),
                          label: const Text('Delete'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.redAccent,
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
                      Navigator.pop(context);
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
                  TextButton.icon(
                    onPressed: () {
                      // Delete action implementation
                    },
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Delete'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.redAccent,
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

  Widget _buildPreferencesTab(BuildContext context, bool isDarkMode) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App Preferences Card
          _buildPreferencesCard(
            context,
            'App Preferences',
            Icons.settings,
            isDarkMode,
            [
              _buildPreferenceSwitch(
                'Dark Mode',
                'Enable dark theme',
                Icons.dark_mode,
                isDarkMode,
                isDarkMode,
                (value) {
                  // Get the ThemeProvider and toggle the theme
                  final themeProvider = Provider.of<ThemeProvider>(
                    context,
                    listen: false,
                  );
                  themeProvider.toggleTheme();
                },
              ),
              _buildPreferenceSwitch(
                'Notifications',
                'Enable push notifications',
                Icons.notifications,
                isDarkMode,
                true, // This would be dynamic based on user preference
                (value) {
                  // Handle notification toggle
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Account Settings Card
          _buildPreferencesCard(
            context,
            'Account Settings',
            Icons.person_pin,
            isDarkMode,
            [
              _buildPreferenceItem(
                'Payment Methods',
                'Manage your payment options',
                Icons.payment,
                isDarkMode,
                () {
                  // Navigate to payment methods screen
                },
              ),
              _buildPreferenceItem(
                'Dietary Preferences',
                'Set your food preferences',
                Icons.restaurant_menu,
                isDarkMode,
                () {
                  // Navigate to dietary preferences screen
                },
              ),
              _buildPreferenceItem(
                'Change Password',
                'Update your account password',
                Icons.lock_outline,
                isDarkMode,
                () {
                  // Navigate to change password screen
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Privacy & Security Card
          _buildPreferencesCard(
            context,
            'Privacy & Security',
            Icons.security,
            isDarkMode,
            [
              _buildPreferenceItem(
                'Privacy Policy',
                'Read our privacy policy',
                Icons.privacy_tip,
                isDarkMode,
                () {
                  // Navigate to privacy policy screen
                },
              ),
              _buildPreferenceItem(
                'Terms of Service',
                'Read our terms of service',
                Icons.description,
                isDarkMode,
                () {
                  // Navigate to terms of service screen
                },
              ),
              _buildPreferenceItem(
                'Delete Account',
                'Permanently delete your account',
                Icons.delete_forever,
                isDarkMode,
                () {
                  // Show delete account confirmation
                },
                textColor: Colors.redAccent,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Support Card
          _buildPreferencesCard(
            context,
            'Support',
            Icons.support_agent,
            isDarkMode,
            [
              _buildPreferenceItem(
                'Help Center',
                'Get help with your orders',
                Icons.help_outline,
                isDarkMode,
                () {
                  // Navigate to help center
                },
              ),
              _buildPreferenceItem(
                'Contact Support',
                'Reach out to our support team',
                Icons.contact_support,
                isDarkMode,
                () {
                  // Navigate to contact support
                },
              ),
              _buildPreferenceItem(
                'App Version',
                '1.0.0 (Build 123)',
                Icons.info_outline,
                isDarkMode,
                () {
                  // Show app version info
                },
                isClickable: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesCard(
    BuildContext context,
    String title,
    IconData icon,
    bool isDarkMode,
    List<Widget> children,
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
                            ? AppColors.primaryDark.withOpacity(0.1)
                            : AppColors.primaryLighter,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color:
                        isDarkMode ? AppColors.primaryLight : AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildPreferenceItem(
    String title,
    String subtitle,
    IconData icon,
    bool isDarkMode,
    VoidCallback? onTap, {
    Widget? trailing,
    Color? textColor,
    bool isClickable = true,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: textColor ?? (isDarkMode ? Colors.white70 : Colors.grey[700]),
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w500, color: textColor),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
        ),
      ),
      trailing:
          trailing ??
          (isClickable
              ? Icon(
                Icons.chevron_right,
                color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                size: 20,
              )
              : null),
      onTap: isClickable ? onTap : null,
    );
  }

  Widget _buildPreferenceSwitch(
    String title,
    String subtitle,
    IconData icon,
    bool isDarkMode,
    bool value,
    Function(bool) onChanged,
  ) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isDarkMode ? Colors.white70 : Colors.grey[700],
          size: 20,
        ),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
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

// Helper class for SliverPersistentHeader
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDarkMode ? Colors.grey[900] : Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
