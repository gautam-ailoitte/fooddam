// lib/src/presentation/screens/profile/address_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/widgets/primary_button.dart';
import 'package:foodam/src/domain/entities/address_entity.dart';
import 'package:foodam/src/presentation/cubits/user_profile/user_profile_cubit.dart';
import 'package:foodam/src/presentation/cubits/user_profile/user_profile_state.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../widgets/custom_google_map.dart';

class AddAddressScreen extends StatefulWidget {
  final Address? address; // For editing existing address

  const AddAddressScreen({this.address, super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late DraggableScrollableController _sheetController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Form controllers
  late TextEditingController _streetController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _zipCodeController;
  late TextEditingController _countryController;

  bool _isLoading = false;
  bool _isMapLoading = false;
  bool _isAutoFilling = false; // Track when we're auto-filling from map
  bool _userHasModifiedForm = false; // Track if user has manually edited
  double _currentSheetSize = 0.4; // Track current sheet position

  // Map related
  late LatLng _selectedLocation;
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();

    // Initialize sheet controller
    _sheetController = DraggableScrollableController();

    // Initialize animation controller for fade effects
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();

    // Initialize form controllers
    _streetController = TextEditingController(
      text: widget.address?.street ?? '',
    );
    _cityController = TextEditingController(text: widget.address?.city ?? '');
    _stateController = TextEditingController(text: widget.address?.state ?? '');
    _zipCodeController = TextEditingController(
      text: widget.address?.zipCode ?? '',
    );
    _countryController = TextEditingController(
      text: widget.address?.country ?? 'India',
    );

    // Initialize map location
    if (widget.address?.latitude != null && widget.address?.longitude != null) {
      _latitude = widget.address!.latitude;
      _longitude = widget.address!.longitude;
      _selectedLocation = LatLng(_latitude!, _longitude!);
    } else {
      // Default location (e.g., center of India)
      _selectedLocation = const LatLng(20.5937, 78.9629);
    }

    print(
      'DEBUG: AddAddressScreen initialized with location: ${_selectedLocation.latitude}, ${_selectedLocation.longitude}',
    );

    // Add listeners to detect manual edits
    _streetController.addListener(_onFormFieldChanged);
    _cityController.addListener(_onFormFieldChanged);
    _stateController.addListener(_onFormFieldChanged);
    _zipCodeController.addListener(_onFormFieldChanged);
    _countryController.addListener(_onFormFieldChanged);
  }

  void _onFormFieldChanged() {
    if (!_isAutoFilling) {
      _userHasModifiedForm = true;
      print('DEBUG: User has manually modified the form');

      // Auto-expand sheet when user starts typing
      if (_currentSheetSize < 0.4) {
        _sheetController.animateTo(
          0.4,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  void dispose() {
    _sheetController.dispose();
    _fadeController.dispose();

    _streetController.removeListener(_onFormFieldChanged);
    _cityController.removeListener(_onFormFieldChanged);
    _stateController.removeListener(_onFormFieldChanged);
    _zipCodeController.removeListener(_onFormFieldChanged);
    _countryController.removeListener(_onFormFieldChanged);

    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _parseAddressFromLatLng(LatLng location) async {
    print(
      'DEBUG: _parseAddressFromLatLng called with location: ${location.latitude}, ${location.longitude}',
    );

    if (_userHasModifiedForm) {
      print('DEBUG: User has modified form, showing dialog');
      // Ask user if they want to override their manual changes
      bool? shouldOverride = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Update Address?'),
            content: const Text(
              'You have manually edited the address. Do you want to replace it with the location from the map?',
            ),
            actions: [
              TextButton(
                child: const Text('Keep My Edits'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: const Text('Use Map Location'),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          );
        },
      );

      print('DEBUG: Dialog result: $shouldOverride');

      if (shouldOverride != true) {
        // User wants to keep their edits, just update coordinates
        setState(() {
          _latitude = location.latitude;
          _longitude = location.longitude;
        });
        return;
      }
    }

    setState(() {
      _isMapLoading = true;
      _isAutoFilling = true;
    });

    try {
      print('DEBUG: Starting reverse geocoding');
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      print('DEBUG: Received ${placemarks.length} placemarks');

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        print(
          'DEBUG: First placemark data: street=${place.street}, locality=${place.locality}, administrativeArea=${place.administrativeArea}, postalCode=${place.postalCode}, country=${place.country}',
        );

        setState(() {
          // Update form fields
          _streetController.text = [
            place.street,
            place.subLocality,
            place.subThoroughfare,
            place.thoroughfare,
          ].where((s) => s != null && s.isNotEmpty).join(', ');

          _cityController.text = place.locality ?? '';
          _stateController.text = place.administrativeArea ?? '';
          _zipCodeController.text = place.postalCode ?? '';
          _countryController.text = place.country ?? 'India';

          // Update coordinates
          _latitude = location.latitude;
          _longitude = location.longitude;

          print(
            'DEBUG: Form fields updated - street: ${_streetController.text}, city: ${_cityController.text}, state: ${_stateController.text}, zip: ${_zipCodeController.text}, country: ${_countryController.text}',
          );
        });

        // Provide haptic feedback
        HapticFeedback.lightImpact();
      }
    } catch (e) {
      print('DEBUG: Error in reverse geocoding: $e');
      _showErrorSnackBar(
        'Failed to get address details. Please enter manually.',
      );
    } finally {
      setState(() {
        _isMapLoading = false;
        _isAutoFilling = false;
      });
    }
  }

  void _handleLocationChange(LatLng location, String? address) {
    print(
      'DEBUG: _handleLocationChange called with location: ${location.latitude}, ${location.longitude}, address: $address',
    );

    setState(() {
      _selectedLocation = location;
      _latitude = location.latitude;
      _longitude = location.longitude;
    });

    print('DEBUG: Location state updated, now parsing address');

    if (address != null) {
      print('DEBUG: Parsing from search result');
      // If we have a formatted address from search, try to parse it
      _parseAddressFromSearchResult(address);
    } else {
      print('DEBUG: Reverse geocoding coordinates');
      // Otherwise, reverse geocode the coordinates
      _parseAddressFromLatLng(location);
    }
  }

  void _parseAddressFromSearchResult(String address) async {
    print('DEBUG: _parseAddressFromSearchResult called with address: $address');

    if (_userHasModifiedForm) {
      print('DEBUG: User has modified form, showing dialog');
      // Ask user if they want to override their manual changes
      bool? shouldOverride = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Update Address?'),
            content: const Text(
              'You have manually edited the address. Do you want to replace it with the searched location?',
            ),
            actions: [
              TextButton(
                child: const Text('Keep My Edits'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: const Text('Use Searched Address'),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          );
        },
      );

      print('DEBUG: Dialog result: $shouldOverride');

      if (shouldOverride != true) {
        return; // User wants to keep their edits
      }
    }

    print('DEBUG: Starting to parse address: $address');
    _isAutoFilling = true;

    // Basic parsing of address string
    List<String> parts = address.split(',').map((e) => e.trim()).toList();
    print('DEBUG: Address parts: $parts');

    if (parts.isNotEmpty) {
      setState(() {
        print('DEBUG: Setting street to: ${parts[0]}');
        _streetController.text = parts[0];

        if (parts.length > 1) {
          print('DEBUG: Setting city to: ${parts[1]}');
          _cityController.text = parts[1];
        }

        if (parts.length > 2) {
          // Check if the part contains numbers (likely postal code)
          if (RegExp(r'\d').hasMatch(parts[parts.length - 1])) {
            String zipCode = parts[parts.length - 1].replaceAll(
              RegExp(r'[^\d]'),
              '',
            );
            print('DEBUG: Setting zipCode to: $zipCode');
            _zipCodeController.text = zipCode;

            String country = parts[parts.length - 2] ?? 'India';
            print('DEBUG: Setting country to: $country');
            _countryController.text = country;
          } else {
            String country = parts[parts.length - 1] ?? 'India';
            print('DEBUG: Setting country to: $country');
            _countryController.text = country;
          }
        }

        // For state, you might need to extract from the address or use geocoding
        if (parts.length > 3) {
          print('DEBUG: Setting state to: ${parts[2]}');
          _stateController.text = parts[2];
        }
      });
    }

    _isAutoFilling = false;
    print('DEBUG: Finished parsing address');
  }

  void _saveAddress() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      final address = Address(
        id: widget.address?.id ?? '', // Empty ID for new address
        street: _streetController.text,
        city: _cityController.text,
        state: _stateController.text,
        zipCode: _zipCodeController.text,
        country: _countryController.text,
        latitude: _latitude,
        longitude: _longitude,
      );

      print('DEBUG: Saving address with coordinates: $_latitude, $_longitude');

      if (widget.address == null) {
        // Add new address
        context.read<UserProfileCubit>().addAddress(address);
      } else {
        // Update existing address
        context.read<UserProfileCubit>().updateAddress(address);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildLocationStatusChip() {
    if (_latitude != null && _longitude != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_on, size: 16, color: Colors.green[700]),
            const SizedBox(width: 6),
            Text(
              'Location Set',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.green[700],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_off, size: 16, color: Colors.orange[700]),
          const SizedBox(width: 6),
          Text(
            'Select Location',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.orange[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDragHandle() {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.only(top: 8, bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildSheetHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.marginLarge,
      ),
      child: Column(
        children: [
          Center(child: _buildDragHandle()),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Address Details',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Select location on map or enter details manually',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.marginMedium),
              _buildLocationStatusChip(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.marginLarge),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Street Address
            TextFormField(
              controller: _streetController,
              decoration: InputDecoration(
                labelText: 'Street Address',
                prefixIcon: const Icon(Icons.home_outlined),
                hintText: 'Enter your street address, building name, etc.',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter street address';
                }
                return null;
              },
              maxLines: 2,
            ),
            const SizedBox(height: AppDimensions.marginMedium),

            // City
            TextFormField(
              controller: _cityController,
              decoration: InputDecoration(
                labelText: 'City',
                prefixIcon: const Icon(Icons.location_city_outlined),
                hintText: 'Enter your city',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter city';
                }
                return null;
              },
            ),
            const SizedBox(height: AppDimensions.marginMedium),

            // State and ZIP Code row
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _stateController,
                    decoration: InputDecoration(
                      labelText: 'State',
                      prefixIcon: const Icon(Icons.map_outlined),
                      hintText: 'Enter state',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter state';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: AppDimensions.marginMedium),
                Expanded(
                  child: TextFormField(
                    controller: _zipCodeController,
                    decoration: InputDecoration(
                      labelText: 'ZIP Code',
                      prefixIcon: const Icon(Icons.pin_outlined),
                      hintText: 'Enter ZIP code',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter ZIP code';
                      }
                      if (!RegExp(r'^[0-9]{5,6}$').hasMatch(value)) {
                        return 'Please enter valid ZIP code';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.marginMedium),

            // Country
            TextFormField(
              controller: _countryController,
              decoration: InputDecoration(
                labelText: 'Country',
                prefixIcon: const Icon(Icons.flag_outlined),
                hintText: 'Enter country',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter country';
                }
                return null;
              },
            ),

            const SizedBox(height: AppDimensions.marginExtraLarge),

            // Save Button
            PrimaryButton(
              text: widget.address == null ? 'Save Address' : 'Update Address',
              onPressed: _saveAddress,
              isLoading: _isLoading,
            ),

            const SizedBox(height: AppDimensions.marginMedium),

            // Helper text
            Center(
              child: Text(
                'Map location helps us deliver accurately',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ),

            // Extra padding for bottom sheet
            const SizedBox(height: AppDimensions.marginExtraLarge),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.address == null ? 'Add New Address' : 'Edit Address',
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocListener<UserProfileCubit, UserProfileState>(
        listener: (context, state) {
          if (state is UserProfileUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
            Navigator.pop(context);
          } else if (state is UserProfileError) {
            setState(() {
              _isLoading = false;
            });
            _showErrorSnackBar(state.message);
          }
        },
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Stack(
            children: [
              // Full-screen map background
              Positioned.fill(
                child: Stack(
                  children: [
                    SimpleGoogleMapsWidget(
                      initialLocation: _selectedLocation,
                      onLocationChanged: _handleLocationChange,
                      isMarkerDraggable: true,
                      showSearchBar: true,
                    ),
                    // Map loading overlay
                    if (_isMapLoading)
                      Container(
                        color: Colors.black.withOpacity(0.3),
                        child: const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Draggable bottom sheet
              DraggableScrollableSheet(
                controller: _sheetController,
                initialChildSize: 0.4,
                minChildSize: 0.39,
                maxChildSize: 0.72,
                snap: true,
                snapSizes: const [0.4, 0.7],
                builder: (context, scrollController) {
                  return NotificationListener<DraggableScrollableNotification>(
                    onNotification: (notification) {
                      setState(() {
                        _currentSheetSize = notification.extent;
                      });

                      // Haptic feedback on snap positions
                      if ((notification.extent - 0.2).abs() < 0.01 ||
                          (notification.extent - 0.4).abs() < 0.01 ||
                          (notification.extent - 0.9).abs() < 0.01) {
                        HapticFeedback.lightImpact();
                      }

                      return false;
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, -5),
                          ),
                        ],
                      ),
                      child: ListView(
                        controller: scrollController,
                        children: [
                          _buildSheetHeader(),
                          const SizedBox(height: AppDimensions.marginMedium),
                          _buildFormFields(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
