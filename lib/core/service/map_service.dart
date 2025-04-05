// lib/core/service/maps_service.dart
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:foodam/core/service/logger_service.dart';
import 'dart:async';

class MapsService {
  final LoggerService _logger = LoggerService();

  // Improved getting current location with better error handling
  Future<LatLng?> getCurrentLocation() async {
    try {
      // Check for location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _logger.w('Location permissions denied', tag: 'MapsService');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _logger.w(
          'Location permissions permanently denied',
          tag: 'MapsService',
        );
        return null;
      }

      // Get current position with appropriate settings based on platform
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
        // Use appropriate settings based on platform
        locationSettings:
            kIsWeb
                ? const LocationSettings(
                  accuracy: LocationAccuracy.high,
                  timeLimit: Duration(seconds: 15),
                )
                : null,
      );

      _logger.i(
        'Got current position: ${position.latitude}, ${position.longitude}',
        tag: 'MapsService',
      );
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      _logger.e('Error getting location', error: e, tag: 'MapsService');

      // For web, fall back to a default location if geolocation fails
      if (kIsWeb) {
        _logger.i(
          'Falling back to default location on web',
          tag: 'MapsService',
        );
        return const LatLng(12.9716, 77.5946); // Default to Bangalore
      }
      return null;
    }
  }

  // Improved address retrieval with better error handling
  Future<Map<String, String>> getAddressFromLatLng(LatLng position) async {
    try {
      _logger.d(
        'Getting address for: ${position.latitude}, ${position.longitude}',
        tag: 'MapsService',
      );
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        // Debug the placemark
        _logger.d('Placemark found: ${place.toString()}', tag: 'MapsService');

        // Format street address with null safety
        String street = place.street ?? '';
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          street += ', ${place.subLocality}';
        }

        return {
          'street': street.isNotEmpty ? street : 'Unknown Street',
          'city':
              place.locality ?? place.subAdministrativeArea ?? 'Unknown City',
          'state': place.administrativeArea ?? 'Unknown State',
          'zipCode': place.postalCode ?? 'Unknown Zipcode',
          'country': place.country ?? 'India', // Default to India
        };
      }

      // If no placemarks, return default values
      _logger.w('No placemarks found for location', tag: 'MapsService');
      return {
        'street': 'Unknown Street',
        'city': 'Unknown City',
        'state': 'Unknown State',
        'zipCode': 'Unknown Zipcode',
        'country': 'India',
      };
    } catch (e) {
      _logger.e(
        'Error getting address from coordinates',
        error: e,
        tag: 'MapsService',
      );

      // Return default values on error
      return {
        'street': 'Unknown Street',
        'city': 'Unknown City',
        'state': 'Unknown State',
        'zipCode': 'Unknown Zipcode',
        'country': 'India',
      };
    }
  }

  // Improved place search with better error handling
  Future<List<Map<String, dynamic>>> searchPlaces(String query) async {
    try {
      if (query.isEmpty) return [];

      _logger.d('Searching places for query: $query', tag: 'MapsService');

      try {
        // Simple geocoding search - in a real app, use Places API
        List<Location> locations = await locationFromAddress(query);
        _logger.d(
          'Found ${locations.length} locations for query',
          tag: 'MapsService',
        );

        List<Map<String, dynamic>> results = [];

        for (var location in locations) {
          final position = LatLng(location.latitude, location.longitude);
          final address = await getAddressFromLatLng(position);

          String description = '';
          if (address['street']!.isNotEmpty &&
              address['street'] != 'Unknown Street') {
            description += address['street']!;
          }
          if (address['city']!.isNotEmpty &&
              address['city'] != 'Unknown City') {
            description +=
                description.isNotEmpty
                    ? ', ${address['city']}'
                    : address['city']!;
          }
          if (address['state']!.isNotEmpty &&
              address['state'] != 'Unknown State') {
            description +=
                description.isNotEmpty
                    ? ', ${address['state']}'
                    : address['state']!;
          }

          // If description is still empty, fallback to query
          if (description.isEmpty) {
            description = query;
          }

          results.add({
            'position': position,
            'address': address,
            'description': description,
          });
        }

        return results;
      } catch (e) {
        // If locationFromAddress fails, try to create a simple search result using the query
        _logger.w(
          'locationFromAddress failed, using fallback search',
          tag: 'MapsService',
        );

        return [
          {
            'position': const LatLng(12.9716, 77.5946), // Default position
            'address': {
              'street': query,
              'city': 'Unknown City',
              'state': 'Unknown State',
              'zipCode': 'Unknown Zipcode',
              'country': 'India',
            },
            'description': query,
          },
        ];
      }
    } catch (e) {
      _logger.e('Error searching places', error: e, tag: 'MapsService');
      return [];
    }
  }

  // Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      _logger.e(
        'Error checking location services',
        error: e,
        tag: 'MapsService',
      );
      return false;
    }
  }
}
