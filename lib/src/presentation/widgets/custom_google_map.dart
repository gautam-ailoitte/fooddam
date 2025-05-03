// lib/src/presentation/widgets/simple_google_maps_widget.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SimpleGoogleMapsWidget extends StatefulWidget {
  final LatLng initialLocation;
  final void Function(LatLng)? onLocationChanged;
  final bool isMarkerDraggable;
  final double initialZoom;

  const SimpleGoogleMapsWidget({
    super.key,
    required this.initialLocation,
    this.onLocationChanged,
    this.isMarkerDraggable = true,
    this.initialZoom = 15.0,
  });

  @override
  State<SimpleGoogleMapsWidget> createState() => _SimpleGoogleMapsWidgetState();
}

class _SimpleGoogleMapsWidgetState extends State<SimpleGoogleMapsWidget> {
  GoogleMapController? _mapController;
  late LatLng _currentPosition;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _currentPosition = widget.initialLocation;
  }

  @override
  void dispose() {
    _mapController?.dispose();
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
    }
  }

  Future<void> _getCurrentLocation() async {
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

      setState(() {
        _currentPosition = newPosition;
      });

      // Animate to new position
      await _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(newPosition, 16.0),
      );

      // Notify parent widget
      widget.onLocationChanged?.call(newPosition);
    } catch (e) {
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
  }

  void _onMarkerDragEnd(LatLng newPosition) {
    setState(() {
      _currentPosition = newPosition;
    });
    widget.onLocationChanged?.call(newPosition);
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
            top: 16,
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
