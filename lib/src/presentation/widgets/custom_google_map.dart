// lib/src/presentation/widgets/simple_google_maps_widget.dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/constants/app_constants.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/place_type.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:http/http.dart' as http;

class SimpleGoogleMapsWidget extends StatefulWidget {
  final LatLng initialLocation;
  final void Function(LatLng, String?)? onLocationChanged;
  final bool isMarkerDraggable;
  final double initialZoom;
  final bool showSearchBar;

  const SimpleGoogleMapsWidget({
    super.key,
    required this.initialLocation,
    this.onLocationChanged,
    this.isMarkerDraggable = true,
    this.initialZoom = 15.0,
    this.showSearchBar = true,
  });

  @override
  State<SimpleGoogleMapsWidget> createState() => _SimpleGoogleMapsWidgetState();
}

class _SimpleGoogleMapsWidgetState extends State<SimpleGoogleMapsWidget> {
  GoogleMapController? _mapController;
  late LatLng _currentPosition;
  bool _isLoading = false;
  String? _errorMessage;
  Prediction? _lastPrediction;

  // Search bar controllers
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _currentPosition = widget.initialLocation;
    print(
      'DEBUG: SimpleGoogleMapsWidget initialized with location: ${widget.initialLocation.latitude}, ${widget.initialLocation.longitude}',
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(SimpleGoogleMapsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialLocation != widget.initialLocation &&
        _mapController != null) {
      _currentPosition = widget.initialLocation;
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(widget.initialLocation),
      );
      print(
        'DEBUG: Widget updated with new location: ${widget.initialLocation.latitude}, ${widget.initialLocation.longitude}',
      );
    }
  }

  InputDecoration _getInputDecoration() {
    return InputDecoration(
      hintText: 'Search location',
      prefixIcon: const Icon(Icons.search),
      suffixIcon:
          _searchController.text.isNotEmpty
              ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  _focusNode.unfocus();
                },
              )
              : null,
      border: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  void _updateLocation(LatLng newPosition, {String? address}) {
    print(
      'DEBUG: _updateLocation called with position: ${newPosition.latitude}, ${newPosition.longitude}, address: $address',
    );

    setState(() {
      _currentPosition = newPosition;
    });

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(newPosition, 16.0),
    );

    print('DEBUG: Calling onLocationChanged callback');
    widget.onLocationChanged?.call(newPosition, address);
  }

  Future<void> _getCurrentLocation() async {
    print('DEBUG: Getting current location');
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled';
      }

      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied';
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      LatLng newPosition = LatLng(position.latitude, position.longitude);
      print(
        'DEBUG: Current location obtained: ${position.latitude}, ${position.longitude}',
      );
      _updateLocation(newPosition);
    } catch (e) {
      print('DEBUG: Error getting location: $e');
      setState(() {
        _errorMessage = e.toString();
      });

      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage ?? 'Failed to get location'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    print('DEBUG: Map controller created');
  }

  void _onMarkerDragEnd(LatLng newPosition) {
    print(
      'DEBUG: Marker dragged to: ${newPosition.latitude}, ${newPosition.longitude}',
    );
    _updateLocation(newPosition);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _currentPosition,
            zoom: widget.initialZoom,
          ),
          myLocationEnabled: true,
          myLocationButtonEnabled: false, // We'll use custom button
          mapToolbarEnabled: false,
          zoomControlsEnabled: true,
          markers: {
            Marker(
              markerId: const MarkerId('selected_location'),
              position: _currentPosition,
              draggable: widget.isMarkerDraggable,
              onDragEnd: _onMarkerDragEnd,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueRed,
              ),
              infoWindow: const InfoWindow(title: 'Selected Location'),
            ),
          },
        ),

        // Search bar with improved configuration
        if (widget.showSearchBar)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: GooglePlaceAutoCompleteTextField(
              textEditingController: _searchController,
              googleAPIKey: AppConstants.googleMapKey,
              inputDecoration: _getInputDecoration(),
              debounceTime: 800,
              isLatLngRequired: true,
              focusNode: _focusNode,
              // Changed to PlaceType.address for better results
              placeType: PlaceType.address,
              // Add countries restriction (example for India)
              countries: ["in"], // Add more country codes as needed
              // Optional: Add location bias for better local results
              // You can uncomment and adjust these parameters
              // location: LatLng(_currentPosition.latitude, _currentPosition.longitude),
              // radius: 50000, // 50km radius
              getPlaceDetailWithLatLng: (Prediction prediction) {
                print('DEBUG: getPlaceDetailWithLatLng called');
                print(
                  'DEBUG: getPlaceDetailWithLatLng called with prediction: ${prediction.description}',
                );
                print('DEBUG: Prediction place_id: ${prediction.placeId}');
                print(
                  'DEBUG: Prediction lat: ${prediction.lat}, lng: ${prediction.lng}',
                );

                // Store the prediction data for use in itemClick
                _lastPrediction = prediction;
              },
              itemClick: (Prediction prediction) async {
                print(
                  'DEBUG: itemClick triggered with prediction: ${prediction.description}',
                );
                print('DEBUG: Place ID: ${prediction.placeId}');

                // First update the search field text
                _searchController.text = prediction.description ?? '';
                _searchController.selection = TextSelection.fromPosition(
                  TextPosition(offset: prediction.description?.length ?? 0),
                );

                // Then unfocus the keyboard
                _focusNode.unfocus();

                // Get place details using place_id if available
                if (prediction.placeId != null) {
                  try {
                    // Show loading indicator
                    setState(() {
                      _isLoading = true;
                    });

                    // Use Google Places Details API with more fields
                    final String url =
                        'https://maps.googleapis.com/maps/api/place/details/json?place_id=${prediction.placeId}&fields=geometry,formatted_address,address_components&key=${AppConstants.googleMapKey}';

                    final response = await http.get(Uri.parse(url));

                    if (response.statusCode == 200) {
                      final data = json.decode(response.body);

                      if (data['status'] == 'OK') {
                        final location = data['result']['geometry']['location'];
                        final lat = location['lat'];
                        final lng = location['lng'];

                        print(
                          'DEBUG: Got location from API - lat: $lat, lng: $lng',
                        );

                        // Update location with the selected address
                        _updateLocation(
                          LatLng(lat, lng),
                          address: prediction.description,
                        );
                      } else {
                        print('DEBUG: API Error: ${data['status']}');
                        if (data['status'] == 'REQUEST_DENIED') {
                          print(
                            'DEBUG: Error message: ${data['error_message']}',
                          );
                          // Show error to user
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'API key issue. Please check configuration.',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      }
                    } else {
                      print('DEBUG: HTTP Error: ${response.statusCode}');
                      print('DEBUG: Response body: ${response.body}');
                    }
                  } catch (e) {
                    print('DEBUG: Error getting place details: $e');
                    // Show error to user
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error getting location details'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } finally {
                    if (mounted) {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  }
                } else {
                  print('DEBUG: No place_id in prediction');
                }
              },
              itemBuilder: (context, index, Prediction prediction) {
                return Container(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on),
                      const SizedBox(width: 7),
                      Expanded(child: Text(prediction.description ?? '')),
                    ],
                  ),
                );
              },
              seperatedBuilder: const Divider(),
              isCrossBtnShown: true,
              containerHorizontalPadding: 10,
            ),
          ),

        // Current location button
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            mini: true,
            backgroundColor: Colors.white,
            onPressed: _isLoading ? null : _getCurrentLocation,
            child:
                _isLoading
                    ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    )
                    : Icon(Icons.my_location, color: AppColors.primary),
          ),
        ),

        // Error message (if any)
        if (_errorMessage != null)
          Positioned(
            top: MediaQuery.of(context).padding.top + 80,
            left: 16,
            right: 16,
            child: Card(
              color: Colors.red.shade100,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _errorMessage = null;
                        });
                      },
                      color: Colors.red.shade700,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
