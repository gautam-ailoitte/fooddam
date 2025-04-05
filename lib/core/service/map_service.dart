// lib/core/service/maps_service.dart
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:foodam/core/service/logger_service.dart';

class MapsService {
  final LoggerService _logger = LoggerService();

  // Get current location with proper error handling
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

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        // desiredAccuracy: LocationAccuracy.high,
        // locationSettings: AndroidSettings(
        //     accuracy: LocationAccuracy.high,
        //     distanceFilter: 10,
        //     forceLocationManager: true,
        //   ),
        locationSettings: WebSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );

      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      _logger.e('Error getting location', error: e, tag: 'MapsService');
      return null;
    }
  }

  // Get address details from coordinates
  Future<Map<String, String>> getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        // Format street address
        String street = place.street ?? '';
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          street += ', ${place.subLocality}';
        }

        return {
          'street': street,
          'city': place.locality ?? '',
          'state': place.administrativeArea ?? '',
          'zipCode': place.postalCode ?? '',
          'country': place.country ?? 'India', // Default to India
        };
      }

      return {};
    } catch (e) {
      _logger.e(
        'Error getting address from coordinates',
        error: e,
        tag: 'MapsService',
      );
      return {};
    }
  }

  // Search for places (basic implementation)
  // In a real app, this would use Places API with proper autocomplete
  Future<List<Map<String, dynamic>>> searchPlaces(String query) async {
    try {
      if (query.isEmpty) return [];

      // Simple geocoding search - in a real app, use Places API
      List<Location> locations = await locationFromAddress(query);

      List<Map<String, dynamic>> results = [];

      for (var location in locations) {
        final position = LatLng(location.latitude, location.longitude);
        final address = await getAddressFromLatLng(position);

        results.add({
          'position': position,
          'address': address,
          'description':
              '${address['street']}, ${address['city']}, ${address['state']}',
        });
      }

      return results;
    } catch (e) {
      _logger.e('Error searching places', error: e, tag: 'MapsService');
      return [];
    }
  }
}
