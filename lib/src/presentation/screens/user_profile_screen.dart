// lib/src/presentation/screens/profile/user_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/layout/app_scaffold.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/widgets/app_button.dart';
import 'package:foodam/core/widgets/app_card.dart';
import 'package:foodam/core/widgets/app_loading.dart';
import 'package:foodam/core/widgets/app_section_header.dart';
import 'package:foodam/src/domain/entities/dish_entity.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';
import 'package:foodam/src/domain/entities/user_entity.dart';
import 'package:foodam/src/presentation/cubits/auth/auth_cubit.dart';
import 'package:foodam/src/presentation/cubits/auth/auth_state.dart';
import 'package:foodam/src/presentation/cubits/susbcription/subscription_cubit.dart';
import 'package:foodam/src/presentation/cubits/susbcription/susbcription_state.dart';
import 'package:foodam/src/presentation/screens/auth/login_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    context.read<SubscriptionCubit>().getSubscriptionHistory();
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthCubit>().logout();
            },
            child: const Text('Logout', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'My Profile',
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is Unauthenticated) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: AppLoading());
          } else if (state is Authenticated) {
            return _buildProfileContent(state.user);
          } else {
            return const Center(
              child: Text('Failed to load profile. Please try again later.'),
            );
          }
        },
      ),
    );
  }

  Widget _buildProfileContent(User user) {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Profile Information Card
          _buildProfileCard(user),
          AppSpacing.vLg,
          
          // Address Information
          AppSectionHeader(title: 'Delivery Address'),
          AppSpacing.vSm,
          _buildAddressCard(user.address),
          AppSpacing.vLg,
          
          // Dietary Preferences
          if (user.dietaryPreferences != null && user.dietaryPreferences!.isNotEmpty) ...[
            AppSectionHeader(title: 'Dietary Preferences'),
            AppSpacing.vSm,
            _buildPreferencesCard(user),
            AppSpacing.vLg,
          ],
          
          // Subscription History
          AppSectionHeader(title: 'Subscription History'),
          AppSpacing.vSm,
          _buildSubscriptionHistory(),
          AppSpacing.vLg,
          
          // Logout Button
          AppButton(
            label: 'Logout',
            onPressed: _logout,
            buttonType: AppButtonType.outline,
            backgroundColor: AppColors.error.withOpacity(0.1),
            textColor: AppColors.error,
          ),
        ],
      ),
    );
  }
  
  Widget _buildProfileCard(User user) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar placeholder
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  _getInitials(user.firstName, user.lastName),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    AppSpacing.vXs,
                    Text(
                      user.email,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    AppSpacing.vXs,
                    Text(
                      user.phone,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              // Edit Button
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // TODO: Navigate to edit profile screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Edit profile feature coming soon')),
                  );
                },
              ),
            ],
          ),
          AppSpacing.vMd,
          const Divider(),
          AppSpacing.vSm,
          
          // Member since
          Text(
            'Member since: ${_formatDate(user.createdAt)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAddressCard(address) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  address.fullAddress,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                onPressed: () {
                  // TODO: Navigate to edit address screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Edit address feature coming soon')),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildPreferencesCard(User user) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (user.dietaryPreferences ?? []).map((pref) {
              return Chip(
                label: Text(
                  pref.toString().split('.').last,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
                backgroundColor: _getPreferenceColor(pref),
              );
            }).toList(),
          ),
          
          if (user.allergies != null && user.allergies!.isNotEmpty) ...[
            AppSpacing.vMd,
            const Divider(),
            AppSpacing.vSm,
            const Text(
              'Allergies:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            AppSpacing.vXs,
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (user.allergies ?? []).map((allergy) {
                return Chip(
                  label: Text(
                    allergy,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: AppColors.error,
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildSubscriptionHistory() {
    return BlocBuilder<SubscriptionCubit, SubscriptionState>(
      builder: (context, state) {
        if (state is SubscriptionLoading) {
          return const SizedBox(
            height: 100,
            child: Center(child: AppLoading()),
          );
        } else if (state is SubscriptionHistoryLoaded) {
          if (state.subscriptions.isEmpty) {
            return const AppCard(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No subscription history yet'),
              ),
            );
          }
          
          return Column(
            children: state.subscriptions.take(5).map((subscription) {
              return AppCard(
                margin: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_getDurationName(subscription.duration)} Plan',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        _buildStatusBadge(subscription.status),
                      ],
                    ),
                    AppSpacing.vXs,
                    Text(
                      '${_formatDate(subscription.startDate)} - ${_formatDate(subscription.endDate)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    AppSpacing.vSm,
                    Text(
                      'Total: ₹${subscription.totalPrice.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        } else {
          return const AppCard(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Failed to load subscription history'),
            ),
          );
        }
      },
    );
  }
  
  Widget _buildStatusBadge(SubscriptionStatus status) {
    Color color;
    String text;
    
    switch (status) {
      case SubscriptionStatus.active:
        color = AppColors.success;
        text = 'Active';
        break;
      case SubscriptionStatus.paused:
        color = AppColors.warning;
        text = 'Paused';
        break;
      case SubscriptionStatus.cancelled:
        color = AppColors.error;
        text = 'Cancelled';
        break;
      case SubscriptionStatus.expired:
        color = AppColors.textSecondary;
        text = 'Expired';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  Color _getPreferenceColor(preference) {
    switch (preference) {
      case DietaryPreference.vegetarian:
        return AppColors.vegetarian;
      case DietaryPreference.nonVegetarian:
        return AppColors.nonVegetarian;
      case DietaryPreference.vegan:
        return Colors.green.shade700;
      case DietaryPreference.glutenFree:
        return Colors.orange;
      case DietaryPreference.dairyFree:
        return Colors.blue;
      case DietaryPreference.nutFree:
        return Colors.brown;
      case DietaryPreference.pescatarian:
        return Colors.cyan;
      case DietaryPreference.keto:
        return Colors.purple;
      case DietaryPreference.paleo:
        return Colors.amber.shade700;
      default:
        return AppColors.textSecondary;
    }
  }
  
  String _getInitials(String firstName, String lastName) {
    String firstInitial = firstName.isNotEmpty ? firstName[0] : '';
    String lastInitial = lastName.isNotEmpty ? lastName[0] : '';
    return (firstInitial + lastInitial).toUpperCase();
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
  
  String _getDurationName(SubscriptionDuration duration) {
    switch (duration) {
      case SubscriptionDuration.sevenDays:
        return 'Weekly';
      case SubscriptionDuration.fourteenDays:
        return 'Bi-Weekly';
      case SubscriptionDuration.twentyEightDays:
        return 'Monthly';
      case SubscriptionDuration.monthly:
        return 'Monthly';
      case SubscriptionDuration.quarterly:
        return 'Quarterly';
      case SubscriptionDuration.halfYearly:
        return 'Half Yearly';
      case SubscriptionDuration.yearly:
        return 'Yearly';
      }
  }
}