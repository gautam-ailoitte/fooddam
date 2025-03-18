// lib/src/presentation/widgets/common/app_bottom_navigation.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/src/presentation/screens/home_screen.dart';
import 'package:foodam/src/presentation/screens/meal_selection_screen.dart';
import 'package:foodam/src/presentation/screens/user_profile_screen.dart';

enum AppTab { home, menu, profile }

class AppBottomNavigation extends StatelessWidget {
  final AppTab currentTab;
  final ValueChanged<AppTab> onSelectTab;

  const AppBottomNavigation({
    super.key,
    required this.currentTab,
    required this.onSelectTab,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            spreadRadius: 1,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTabItem(
                context,
                AppTab.home,
                Icons.home,
                'Home',
              ),
              _buildTabItem(
                context,
                AppTab.menu,
                Icons.restaurant_menu,
                'Menu',
              ),
              _buildTabItem(
                context,
                AppTab.profile,
                Icons.person,
                'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(
    BuildContext context,
    AppTab tab,
    IconData icon,
    String title,
  ) {
    final isSelected = currentTab == tab;
    final color = isSelected ? AppColors.primary : AppColors.textSecondary;

    return InkWell(
      onTap: () => onSelectTab(tab),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

// Main app scaffold with bottom navigation
class MainScaffold extends StatefulWidget {
  final int initialIndex;

  const MainScaffold({
    Key? key,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  late AppTab _currentTab;
  final List<Widget> _screens = [
    const HomeScreen(),
    const MealSelectionScreen(),
    const UserProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentTab = AppTab.values[widget.initialIndex];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentTab.index],
      bottomNavigationBar: AppBottomNavigation(
        currentTab: _currentTab,
        onSelectTab: _onSelectTab,
      ),
    );
  }

  void _onSelectTab(AppTab tab) {
    // If we're already on the tab, don't rebuild
    if (tab == _currentTab) return;

    setState(() {
      _currentTab = tab;
    });
  }
}