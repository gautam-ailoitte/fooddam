// lib/src/presentation/screens/profile/address_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/service/map_service.dart';
import 'package:foodam/core/widgets/primary_button.dart';
import 'package:foodam/src/domain/entities/address_entity.dart';
import 'package:foodam/src/presentation/cubits/user_profile/user_profile_cubit.dart';
import 'package:foodam/src/presentation/cubits/user_profile/user_profile_state.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AddAddressScreen extends StatefulWidget {
  final Address? address; // For editing existing address

  const AddAddressScreen({this.address, super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mapsService = MapsService();
  final _searchResults = <Map<String, dynamic>>[];

  // Form controllers
  late TextEditingController _streetController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _zipCodeController;
  late TextEditingController _searchController;

  // Map variables
  GoogleMapController? _mapController;
  LatLng _selectedPosition = const LatLng(
    12.9716,
    77.5946,
  ); // Default to Bangalore
  bool _isLoading = false;
  bool _isLocationLoading = false;
  bool _isSearching = false;
  bool _showSearchResults = false;
  Set<Marker> _markers = {};
  Timer? _debounce;
  bool _hasLoadedInitialLocation = false;
  bool _isMapCreated = false;

  @override
  void initState() {
    super.initState();
    _streetController = TextEditingController(
      text: widget.address?.street ?? '',
    );
    _cityController = TextEditingController(text: widget.address?.city ?? '');
    _stateController = TextEditingController(text: widget.address?.state ?? '');
    _zipCodeController = TextEditingController(
      text: widget.address?.zipCode ?? '',
    );
    _searchController = TextEditingController();

    // Initialize map position from address if editing
    if (widget.address?.latitude != null && widget.address?.longitude != null) {
      _selectedPosition = LatLng(
        widget.address!.latitude!,
        widget.address!.longitude!,
      );
      _hasLoadedInitialLocation = true;
    }

    // Add initial marker
    _updateMarker();

    // Listen for search queries
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _searchController.dispose();
    _mapController?.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // Debounce search to avoid too many requests
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), () {
      if (_searchController.text.length > 2) {
        _searchPlaces(_searchController.text);
      } else {
        setState(() {
          _searchResults.clear();
          _showSearchResults = false;
        });
      }
    });
  }

  Future<void> _searchPlaces(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _showSearchResults = true;
    });

    try {
      final results = await _mapsService.searchPlaces(query);

      setState(() {
        _searchResults.clear();
        _searchResults.addAll(results);
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      _showErrorSnackBar(
        'Error searching for places. Please try a different query.',
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    if (_isLocationLoading) return; // Prevent multiple simultaneous requests

    setState(() {
      _isLocationLoading = true;
    });

    try {
      // First check if location services are enabled
      final isEnabled = await _mapsService.isLocationServiceEnabled();
      if (!isEnabled) {
        _showErrorSnackBar(
          'Location services are disabled. Please enable them in your device settings.',
        );
        setState(() {
          _isLocationLoading = false;
        });
        return;
      }

      final position = await _mapsService.getCurrentLocation();

      if (position != null) {
        setState(() {
          _selectedPosition = position;
          _hasLoadedInitialLocation = true;
        });

        // Update map and get address
        _updateMapPosition();
        await _getAddressFromLatLng();

        // Show success message
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Current location found')));
      } else {
        _showErrorSnackBar(
          'Could not get current location. Using default location instead.',
        );
      }
    } catch (e) {
      _showErrorSnackBar('Error getting location. Please try again.');
    } finally {
      setState(() {
        _isLocationLoading = false;
      });
    }
  }

  void _updateMapPosition() {
    if (_mapController != null && _isMapCreated) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _selectedPosition, zoom: 16.0),
        ),
      );

      _updateMarker();
    }
  }

  void _updateMarker() {
    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('selected_location'),
          position: _selectedPosition,
          draggable: true,
          onDragEnd: (newPosition) {
            setState(() {
              _selectedPosition = newPosition;
            });
            _getAddressFromLatLng();
          },
        ),
      };
    });
  }

  Future<void> _getAddressFromLatLng() async {
    try {
      final addressMap = await _mapsService.getAddressFromLatLng(
        _selectedPosition,
      );

      if (addressMap.isNotEmpty) {
        setState(() {
          _streetController.text = addressMap['street'] ?? '';
          _cityController.text = addressMap['city'] ?? '';
          _stateController.text = addressMap['state'] ?? '';
          _zipCodeController.text = addressMap['zipCode'] ?? '';
        });
      }
    } catch (e) {
      _showErrorSnackBar(
        'Error getting address details. Please fill in the fields manually.',
      );
    }
  }

  void _selectSearchResult(Map<String, dynamic> result) {
    final position = result['position'] as LatLng;
    final address = result['address'] as Map<String, String>;

    setState(() {
      _selectedPosition = position;
      _streetController.text = address['street'] ?? '';
      _cityController.text = address['city'] ?? '';
      _stateController.text = address['state'] ?? '';
      _zipCodeController.text = address['zipCode'] ?? '';
      _showSearchResults = false;
      _searchController.text = '';
    });

    _updateMapPosition();
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
        latitude: _selectedPosition.latitude,
        longitude: _selectedPosition.longitude,
        country: widget.address?.country ?? 'India', // Default country
      );

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
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    setState(() {
      _isMapCreated = true;
    });

    // If we haven't loaded initial location yet
    if (!_hasLoadedInitialLocation) {
      _getCurrentLocation();
    } else {
      _updateMapPosition();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            Navigator.pop(context);
          } else if (state is UserProfileError) {
            setState(() {
              _isLoading = false;
            });
            _showErrorSnackBar(state.message);
          }
        },
        child: Column(
          children: [
            // Map section
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _selectedPosition,
                      zoom: 16.0,
                    ),
                    markers: _markers,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: kIsWeb ? true : false,
                    mapToolbarEnabled: true,
                    compassEnabled: true,
                    onMapCreated: _onMapCreated,
                    onTap: (position) {
                      setState(() {
                        _selectedPosition = position;
                        _showSearchResults = false;
                      });
                      _updateMarker();
                      _getAddressFromLatLng();
                    },
                  ),
                  // Search bar
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      children: [
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              children: [
                                Icon(Icons.search, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    decoration: const InputDecoration(
                                      hintText: 'Search for location',
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 15,
                                      ),
                                    ),
                                  ),
                                ),
                                if (_searchController.text.isNotEmpty)
                                  IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      setState(() {
                                        _searchController.clear();
                                        _showSearchResults = false;
                                      });
                                    },
                                  ),
                                Container(
                                  height: 30,
                                  width: 1,
                                  color: Colors.grey.withOpacity(0.5),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                ),
                                IconButton(
                                  icon:
                                      _isLocationLoading
                                          ? SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    AppColors.primary,
                                                  ),
                                            ),
                                          )
                                          : Icon(
                                            Icons.my_location,
                                            color: AppColors.primary,
                                          ),
                                  onPressed:
                                      _isLocationLoading
                                          ? null
                                          : _getCurrentLocation,
                                  tooltip: 'Get current location',
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Search results
                        if (_showSearchResults)
                          Card(
                            elevation: 4,
                            margin: const EdgeInsets.only(top: 4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Container(
                              constraints: const BoxConstraints(maxHeight: 200),
                              child:
                                  _isSearching
                                      ? const Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: CircularProgressIndicator(),
                                        ),
                                      )
                                      : _searchResults.isEmpty
                                      ? const ListTile(
                                        title: Text('No results found'),
                                        leading: Icon(Icons.info_outline),
                                      )
                                      : ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: _searchResults.length,
                                        itemBuilder: (context, index) {
                                          final result = _searchResults[index];
                                          return ListTile(
                                            title: Text(
                                              result['description']
                                                      as String? ??
                                                  'Unknown location',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            leading: const Icon(
                                              Icons.location_on_outlined,
                                            ),
                                            onTap:
                                                () =>
                                                    _selectSearchResult(result),
                                          );
                                        },
                                      ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Floating action button for refresh
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: FloatingActionButton(
                      heroTag: "refreshAddress",
                      onPressed: _getAddressFromLatLng,
                      child: const Icon(Icons.refresh),
                      tooltip: 'Refresh address',
                      backgroundColor: AppColors.primary,
                    ),
                  ),
                  // Instructions overlay
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[800] : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.touch_app, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'Tap or drag pin',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Address form
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[900] : Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppDimensions.marginMedium),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppDimensions.marginMedium),
                        const Text(
                          'Address Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.marginMedium),
                        TextFormField(
                          controller: _streetController,
                          decoration: const InputDecoration(
                            labelText: 'Street Address',
                            prefixIcon: Icon(Icons.home),
                            hintText:
                                'Enter your street address, building name, etc.',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter street address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppDimensions.marginSmall),
                        TextFormField(
                          controller: _cityController,
                          decoration: const InputDecoration(
                            labelText: 'City',
                            prefixIcon: Icon(Icons.location_city),
                            hintText: 'Enter your city',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter city';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppDimensions.marginSmall),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _stateController,
                                decoration: const InputDecoration(
                                  labelText: 'State',
                                  prefixIcon: Icon(Icons.map),
                                  hintText: 'Enter state',
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter state';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: AppDimensions.marginSmall),
                            Expanded(
                              child: TextFormField(
                                controller: _zipCodeController,
                                decoration: const InputDecoration(
                                  labelText: 'ZIP Code',
                                  prefixIcon: Icon(Icons.pin),
                                  hintText: 'Enter ZIP code',
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter ZIP code';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.marginLarge),
                        PrimaryButton(
                          text:
                              widget.address == null
                                  ? 'Save Address'
                                  : 'Update Address',
                          onPressed: _saveAddress,
                          isLoading: _isLoading,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
