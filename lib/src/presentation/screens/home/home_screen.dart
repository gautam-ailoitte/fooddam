// lib/src/presentation/screens/home/home_screen.dart - Updated to include banner carousel
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/route/app_router.dart';
import 'package:foodam/core/theme/enhanced_app_them.dart';
import 'package:foodam/src/domain/entities/address_entity.dart';
import 'package:foodam/src/domain/entities/order_entity.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';
import 'package:foodam/src/domain/entities/user_entity.dart';
import 'package:foodam/src/presentation/cubits/auth_cubit/auth_cubit_cubit.dart';
import 'package:foodam/src/presentation/cubits/auth_cubit/auth_cubit_state.dart';
import 'package:foodam/src/presentation/cubits/banner/banner_cubits.dart';
import 'package:foodam/src/presentation/cubits/banner/banner_state.dart';
import 'package:foodam/src/presentation/cubits/pacakge_cubits/pacakage_cubit.dart';
import 'package:foodam/src/presentation/cubits/pacakge_cubits/pacakage_state.dart';
import 'package:foodam/src/presentation/cubits/subscription/subscription/subscription_details_cubit.dart';
import 'package:foodam/src/presentation/cubits/subscription/subscription/subscription_details_state.dart';
import 'package:foodam/src/presentation/cubits/today_meal_cubit/today_meal_cubit_cubit.dart';
import 'package:foodam/src/presentation/cubits/user_profile/user_profile_cubit.dart';
import 'package:foodam/src/presentation/cubits/user_profile/user_profile_state.dart';
import 'package:foodam/src/presentation/widgets/active_plan_card.dart';
import 'package:foodam/src/presentation/widgets/banner_carousel_widget.dart';
import 'package:foodam/src/presentation/widgets/createPlanCta_widget.dart';
import 'package:foodam/src/presentation/widgets/pacakage_card_compact.dart';

import '../../cubits/orders/orders_cubit.dart';
import '../../cubits/orders/orders_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // Variables to track selected address and delivery availability
  Address? _selectedAddress;
  bool _isDeliveryAvailable = true; // Default to true until we check
  final ScrollController _scrollController = ScrollController();
  bool _showTitle = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _setupScrollListener();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.offset > 100 && !_showTitle) {
        setState(() {
          _showTitle = true;
        });
      } else if (_scrollController.offset <= 100 && _showTitle) {
        setState(() {
          _showTitle = false;
        });
      }
    });
  }

  void _loadData() {
    // Load active subscriptions
    context.read<SubscriptionCubit>().loadActiveSubscriptions();

    // Load today's meals
    context.read<TodayMealCubit>().loadTodayMeals();

    // Load packages for carousel
    context.read<PackageCubit>().loadAllPackages();

    // Load all orders data for today and upcoming
    context.read<OrdersCubit>().loadAllOrders();

    // Load banners
    context.read<BannerCubit>().loadBanners();

    // Load user details - this will get addresses as well
    context.read<UserProfileCubit>().getUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // Get screen dimensions for responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return BlocListener<UserProfileCubit, UserProfileState>(
      listener: (context, state) {
        if (state is UserProfileLoaded) {
          _initializeAddressFromState(state);
        }
      },
      child: Scaffold(
        body: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            _loadData();
            await Future.delayed(const Duration(milliseconds: 300));
          },
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Enhanced app bar with compact location selector
              _buildAppBar(isTablet),

              // Main content
              SliverToBoxAdapter(
                child: BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, authState) {
                    if (authState is AuthAuthenticated) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Welcome message with animation
                          _buildWelcomeSection(authState.user),

                          // Banner carousel section
                          _buildBannerSection(),

                          // Compact delivery availability section
                          _buildDeliveryAvailabilitySection(),

                          // Only show if delivery is available
                          if (_selectedAddress == null ||
                              _isDeliveryAvailable) ...[
                            // Today's meals section
                            // _buildTodayMealsSection(context),

                            // Enhanced responsive package carousel
                            _buildPackagesCarousel(isTablet),

                            // Active subscriptions section
                            _buildSubscriptionsSection(isTablet),
                          ],

                          // Empty space at bottom to avoid FAB overlap
                          const SizedBox(height: 80),
                        ],
                      );
                    } else {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Loading your meals...',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: _buildFloatingActionButton(),
      ),
    );
  }

  // Banner section with carousel
  Widget _buildBannerSection() {
    return BlocBuilder<BannerCubit, BannerState>(
      builder: (context, state) {
        if (state is BannerLoaded && state.hasBanners) {
          // Use 'home' category banners if available, otherwise use all banners
          // final banners = state.hasBannersForCategory('home')
          // ? state.getBannersForCategory('home')
          // : state.banners;

          final banners = state.banners;

          // Only return if we have banners to show
          if (banners.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: BannerCarousel(
                banners: banners,
                height: 160,
                onTap: () {
                  // Handle banner tap - could open a specific screen or URL
                  // For now, we'll just show a simple message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Banner promotion tapped'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
            );
          }
        }

        // Don't show anything if there are no banners or we're still loading
        return SizedBox.shrink();
      },
    );
  }

  // This method initializes the address from a loaded UserProfile state
  void _initializeAddressFromState(UserProfileLoaded state) {
    final addresses = state.addresses;
    if (addresses != null && addresses.isNotEmpty) {
      // Check if we need to update the selected address
      if (_selectedAddress == null ||
          !addresses.any((addr) => addr.id == _selectedAddress!.id)) {
        setState(() {
          _selectedAddress = addresses.first;
          _checkDeliveryAvailability(_selectedAddress!);
        });
      }
    }
  }

  Widget _buildAppBar(bool isTablet) {
    return SliverAppBar(
      expandedHeight: 90, // Reduced height
      pinned: true,
      elevation: 0,
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.primary,
      title: AnimatedOpacity(
        opacity: _showTitle ? 1.0 : 0.0,
        duration: Duration(milliseconds: 200),
        child: Text(
          'TiffinHub',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -20,
                child: Icon(
                  Icons.restaurant,
                  size: 90, // Reduced icon size
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
              Positioned(
                left: 16,
                top: MediaQuery.of(context).padding.top + 16,
                child: AnimatedOpacity(
                  opacity: _showTitle ? 0.0 : 1.0,
                  duration: Duration(milliseconds: 200),
                  child: Text(
                    'TiffinHub',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        // Only keeping the notifications icon
        IconButton(
          icon: Stack(
            children: [
              Icon(Icons.notifications_outlined),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: BoxConstraints(minWidth: 9, minHeight: 9),
                ),
              ),
            ],
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Notifications coming soon!')),
            );
          },
          tooltip: 'Notifications',
        ),
        SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(
          50,
        ), // Slightly increased for better spacing
        child: Container(
          height: 40,
          margin: EdgeInsets.fromLTRB(16, 0, 16, 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                _showAddressBottomSheet(context);
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: AppColors.primary, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child:
                          _selectedAddress != null
                              ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Delivering to',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    _formatAddress(_selectedAddress!),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                      fontSize: 12,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ],
                              )
                              : Text(
                                'Add delivery address',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                    ),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.primary,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAddressBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      backgroundColor: Colors.white,
      builder: (context) => _buildAddressBottomSheet(context),
    );
  }

  Widget _buildAddressBottomSheet(BuildContext context) {
    return BlocBuilder<UserProfileCubit, UserProfileState>(
      builder: (context, state) {
        if (state is UserProfileLoaded && state.addresses != null) {
          final addresses = state.addresses!;

          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select Delivery Address',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Styled close button
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(height: 24, thickness: 1),

                // Handle both empty and non-empty address lists
                Flexible(
                  child:
                      addresses.isEmpty
                          ? _buildEmptyAddressList()
                          : ListView.builder(
                            shrinkWrap: true,
                            itemCount: addresses.length,
                            itemBuilder:
                                (context, index) => _buildAddressListItem(
                                  context,
                                  addresses[index],
                                ),
                          ),
                ),

                // Add new address button - always shown
                const SizedBox(height: 16),
                _buildAddNewAddressButton(context),

                // Bottom padding to account for notch/home indicator
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            ),
          );
        } else if (state is UserProfileLoading) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Loading Addresses...',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                SizedBox(height: 20),
              ],
            ),
          );
        }

        // Fallback UI for other states
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Please wait while we load your addresses'),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Trigger a refresh of profile data
                  context.read<UserProfileCubit>().getUserProfile();
                },
                child: Text('Refresh'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyAddressList() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 24),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.location_off,
            size: 40,
            color: Colors.grey.shade400,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'No addresses found',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'Add an address to get food delivered to your doorstep',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, height: 1.5),
          ),
        ),
        SizedBox(height: 24),
      ],
    );
  }

  Widget _buildAddressListItem(BuildContext context, Address address) {
    bool isSelected = _isSelectedAddress(address);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.grey.shade200,
          width: isSelected ? 2 : 1,
        ),
        color: isSelected ? AppColors.primary.withOpacity(0.05) : Colors.white,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(11),
          onTap: () {
            _selectAddress(address);
            Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? AppColors.primary.withOpacity(0.1)
                            : Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.location_on,
                    color: isSelected ? AppColors.primary : Colors.grey,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        address.street,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color:
                              isSelected
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '${address.city}, ${address.state} ${address.zipCode}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check, color: Colors.white, size: 16),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddNewAddressButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pop(context);
        // Navigate to add address screen - use profile route for now
        Navigator.pushNamed(context, AppRouter.profileRoute);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        elevation: 0,
        side: BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: EdgeInsets.symmetric(vertical: 12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add, size: 18),
          SizedBox(width: 8),
          Text(
            'Add New Address',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _selectAddress(Address address) {
    setState(() {
      _selectedAddress = address;
      _checkDeliveryAvailability(address);
    });
  }

  bool _isSelectedAddress(Address address) {
    if (_selectedAddress == null) return false;
    return _selectedAddress!.id == address.id;
  }

  void _checkDeliveryAvailability(Address address) {
    // In a real implementation, this would make an API call
    // For demo purposes, let's use a more consistent approach
    // instead of random availability - use the address zipcode

    setState(() {
      // Simple rule: postal codes starting with even numbers are available
      final zipCode = address.zipCode;
      if (zipCode.isNotEmpty) {
        final firstDigit = int.tryParse(zipCode[0]) ?? 0;
        _isDeliveryAvailable = firstDigit % 2 == 0;
      } else {
        _isDeliveryAvailable = true; // Default to available if no zipcode
      }
    });
  }

  Widget _buildDeliveryAvailabilitySection() {
    if (_selectedAddress == null) {
      // No address selected - show a compact prompt to select an address
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Select a delivery address to see meal availability',
                style: TextStyle(fontSize: 12, color: Colors.blue.shade800),
              ),
            ),
          ],
        ),
      );
    }

    // Address is selected - show availability
    if (_isDeliveryAvailable) {
      // Delivery is available - show a compact positive message
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'We deliver to your location!',
                style: TextStyle(fontSize: 12, color: Colors.green.shade800),
              ),
            ),
          ],
        ),
      );
    } else {
      // Delivery is not available - compact unavailable UI
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.location_off, color: Colors.red, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'We don\'t deliver to your location yet',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.red.shade800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'We\'re expanding our service areas. Please try another address or check back soon!',
              style: TextStyle(fontSize: 12, color: Colors.red.shade800),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _showAddressBottomSheet(context);
                },
                icon: Icon(Icons.location_searching, size: 16),
                label: Text('Change Address'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildTodayMealsSection(BuildContext context) {
    return BlocBuilder<OrdersCubit, OrdersState>(
      builder: (context, state) {
        if (state is OrdersDataLoaded && state.hasTodayOrders) {
          return Container(
            margin: EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with View All button
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.marginMedium,
                    vertical: AppDimensions.marginSmall,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Today\'s Meals',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRouter.ordersRoute);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(
                            horizontal: AppDimensions.marginSmall,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text('View All'),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward, size: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Meal Type Chips
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.marginMedium,
                  ),
                  child: Row(
                    children: [
                      _buildMealTypeChip(
                        context,
                        'Breakfast',
                        state.breakfastCount,
                        Icons.free_breakfast,
                        Colors.orange,
                      ),
                      SizedBox(width: 8),
                      _buildMealTypeChip(
                        context,
                        'Lunch',
                        state.lunchCount,
                        Icons.lunch_dining,
                        AppColors.accent,
                      ),
                      SizedBox(width: 8),
                      _buildMealTypeChip(
                        context,
                        'Dinner',
                        state.dinnerCount,
                        Icons.dinner_dining,
                        Colors.purple,
                      ),
                    ],
                  ),
                ),

                // Upcoming deliveries notification
                if (state.hasUpcomingDeliveries) ...[
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppDimensions.marginMedium,
                      AppDimensions.marginSmall,
                      AppDimensions.marginMedium,
                      0,
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.warning.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.delivery_dining,
                            size: 20,
                            color: AppColors.warning,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Next delivery in approx. ${state.upcomingDeliveriesToday.first.minutesUntilDelivery} minutes',
                              style: TextStyle(
                                color: AppColors.warning,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                // Horizontal meal carousel
                SizedBox(height: 16),
                SizedBox(
                  height: 150,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.marginMedium,
                    ),
                    itemCount: state.todayOrders.length,
                    itemBuilder: (context, index) {
                      final order = state.todayOrders[index];
                      return _buildTodayMealCard(context, order);
                    },
                  ),
                ),
              ],
            ),
          );
        }
        return SizedBox.shrink(); // Don't show anything if no meals today
      },
    );
  }

  // Individual meal card for the horizontal carousel
  Widget _buildTodayMealCard(BuildContext context, Order order) {
    final isUpcoming = order.status == OrderStatus.coming;
    final mealType = order.mealType;
    final accentColor = _getMealTypeColor(mealType);

    return Container(
      width: 200,
      margin: EdgeInsets.only(right: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(context, AppRouter.ordersRoute);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Meal type and status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _getMealTypeIcon(mealType),
                            size: 12,
                            color: accentColor,
                          ),
                          SizedBox(width: 4),
                          Text(
                            mealType,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: accentColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color:
                            isUpcoming
                                ? AppColors.warning.withOpacity(0.1)
                                : AppColors.success.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isUpcoming ? Icons.schedule : Icons.check_circle,
                        size: 12,
                        color:
                            isUpcoming ? AppColors.warning : AppColors.success,
                      ),
                    ),
                  ],
                ),

                // Meal name
                SizedBox(height: 8),
                Text(
                  order.meal.name,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                Spacer(),

                // Delivery status
                Row(
                  children: [
                    Icon(
                      isUpcoming
                          ? Icons.access_time
                          : Icons.check_circle_outline,
                      size: 14,
                      color: isUpcoming ? AppColors.warning : AppColors.success,
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        isUpcoming
                            ? 'Arriving in ${order.minutesUntilDelivery} min'
                            : 'Delivered',
                        style: TextStyle(
                          fontSize: 11,
                          color:
                              isUpcoming
                                  ? AppColors.warning
                                  : AppColors.success,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to get meal type color
  Color _getMealTypeColor(String timing) {
    switch (timing.toLowerCase()) {
      case 'breakfast':
        return Colors.orange;
      case 'lunch':
        return AppColors.accent;
      case 'dinner':
        return Colors.purple;
      default:
        return AppColors.primary;
    }
  }

  // Helper method to get meal type icon
  IconData _getMealTypeIcon(String timing) {
    switch (timing.toLowerCase()) {
      case 'breakfast':
        return Icons.free_breakfast;
      case 'lunch':
        return Icons.lunch_dining;
      case 'dinner':
        return Icons.dinner_dining;
      default:
        return Icons.restaurant;
    }
  }

  Widget _buildMealTypeChip(
    BuildContext context,
    String type,
    int count,
    IconData icon,
    Color color,
  ) {
    if (count == 0) {
      return SizedBox.shrink();
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          SizedBox(width: 4),
          Text(
            '$type ($count)',
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _formatAddress(Address address) {
    final street = address.street.trim();
    final city = address.city.trim();

    if (street.isEmpty && city.isEmpty) {
      return "${address.state} ${address.zipCode}";
    } else if (street.isEmpty) {
      return "$city, ${address.state} ${address.zipCode}";
    } else if (city.isEmpty) {
      return "$street, ${address.state} ${address.zipCode}";
    }

    return "$street, $city";
  }

  Widget _buildWelcomeSection(User user) {
    final greeting = _getGreeting();
    final displayName = user.firstName ?? 'there';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '$greeting, ',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                displayName,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const Text(
                '!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          AnimatedContainer(
            duration: Duration(milliseconds: 500),
            margin: const EdgeInsets.only(top: 6),
            child: Text(
              'Welcome to TiffinHub, your personalized meal subscription app.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackagesCarousel(bool isTablet) {
    return BlocBuilder<PackageCubit, PackageState>(
      builder: (context, state) {
        if (state is PackageLoading) {
          return _buildSectionLoading('Popular Packages');
        } else if (state is PackageError) {
          return _buildSectionError(
            'Popular Packages',
            state.message,
            () => context.read<PackageCubit>().loadAllPackages(),
          );
        } else if (state is PackageLoaded && state.hasPackages) {
          // Get screen dimensions for responsive sizing
          final screenWidth = MediaQuery.of(context).size.width;
          final cardWidth =
              isTablet
                  ? screenWidth *
                      0.4 // 40% of screen width on tablets
                  : screenWidth * 0.75; // 75% of screen width on phones

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.marginMedium,
                  vertical: AppDimensions.marginSmall,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Popular Packages',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRouter.packagesRoute);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimensions.marginSmall,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text('See All'),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward, size: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 210, // Slightly reduced height to avoid overflow
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.marginMedium,
                  ),
                  itemCount:
                      state.packages.length > 5
                          ? 5
                          : state.packages.length, // Limit to 5 items
                  itemBuilder: (context, index) {
                    return Container(
                      width: cardWidth,
                      margin: EdgeInsets.only(
                        right: AppDimensions.marginMedium,
                      ),
                      child: PackageCardCompact(
                        package: state.packages[index],
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            AppRouter.packageDetailRoute,
                            arguments: state.packages[index],
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 8),
            ],
          );
        }

        return Container(); // Don't show anything if there are no packages or in other states
      },
    );
  }

  Widget _buildEmptyMealsSection() {
    return _buildSectionCard(
      title: 'Today\'s Meals',
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.restaurant, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'No meals scheduled for today',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Subscribe to a meal plan to get delicious meals delivered to your doorstep',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRouter.packagesRoute);
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text('Browse Meal Plans'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionsSection(bool isTablet) {
    return BlocBuilder<SubscriptionCubit, SubscriptionState>(
      builder: (context, state) {
        if (state is SubscriptionLoading) {
          return _buildSectionLoading('Your Subscriptions');
        } else if (state is SubscriptionError) {
          return _buildSectionError(
            'Your Subscriptions',
            state.message,
            () => context.read<SubscriptionCubit>().loadActiveSubscriptions(),
          );
        } else if (state is SubscriptionLoaded) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Your Subscriptions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (state.hasActiveSubscriptions ||
                        state.hasPausedSubscriptions)
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            AppRouter.subscriptionsRoute,
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        child: Row(
                          children: [
                            Text('See All'),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward, size: 16),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              // Active subscriptions section
              if (state.hasActiveSubscriptions) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children:
                        state.activeSubscriptions
                            .map((subscription) {
                              return ActivePlanCard(
                                subscription: subscription,
                                onTap: () {
                                  _navigateToSubscriptionDetail(
                                    context,
                                    subscription,
                                  );
                                },
                              );
                            })
                            .take(isTablet ? 3 : 2) // Show more on tablets
                            .toList(),
                  ),
                ),
              ] else ...[
                // No active subscriptions - show CTA
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CreatePlanCTA(
                    onTap: () {
                      Navigator.pushNamed(context, AppRouter.packagesRoute);
                    },
                  ),
                ),
              ],

              // Paused subscriptions section - display differently based on device size
              if (state.hasPausedSubscriptions) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'Paused Subscriptions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.warning,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children:
                        state.pausedSubscriptions
                            .map((subscription) {
                              return ActivePlanCard(
                                subscription: subscription,
                                onTap: () {
                                  _navigateToSubscriptionDetail(
                                    context,
                                    subscription,
                                  );
                                },
                              );
                            })
                            .take(
                              1,
                            ) // Always show just 1 paused subscription on home screen
                            .toList(),
                  ),
                ),
              ],
            ],
          );
        }

        return Container();
      },
    );
  }

  void _navigateToSubscriptionDetail(
    BuildContext context,
    Subscription subscription,
  ) async {
    await Navigator.of(
      context,
    ).pushNamed(AppRouter.subscriptionDetailRoute, arguments: subscription);
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              elevation: 0,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                decoration: EnhancedTheme.cardDecoration,
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLoading(String title) {
    return _buildSectionCard(
      title: title,
      child: Container(
        height: 150,
        padding: EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Loading...',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionError(
    String title,
    String message,
    VoidCallback onRetry,
  ) {
    return _buildSectionCard(
      title: title,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                color: AppColors.error,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Error loading data',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppColors.primary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ElevatedButton.icon(
        onPressed: () {
          // change the tab of the navigation bar to packages
          // and navigate to the packages screen

          // This is a workaround since we don't have direct access to the navigation bar

          Navigator.pushNamed(context, AppRouter.packagesRoute);
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Explore Plans',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.white.withOpacity(0.3), width: 1),
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }
}
