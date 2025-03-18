// lib/src/presentation/widgets/home/user_profile_header.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/src/domain/entities/user_entity.dart';

class UserProfileHeader extends StatelessWidget {
  final User user;

  const UserProfileHeader({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // User avatar
        CircleAvatar(
          radius: 30,
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Text(
            _getInitials(user.firstName, user.lastName),
            style: TextStyle(
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
                'Hello, ${user.firstName}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'What would you like to eat today?',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getInitials(String firstName, String lastName) {
    String firstInitial = firstName.isNotEmpty ? firstName[0] : '';
    String lastInitial = lastName.isNotEmpty ? lastName[0] : '';
    return (firstInitial + lastInitial).toUpperCase();
  }
}