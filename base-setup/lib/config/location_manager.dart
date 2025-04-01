import 'dart:async';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as lo;

class LocationManager {
  static final LocationManager _instance = LocationManager._();
  Position? _currentPosition;

  factory LocationManager() {
    return _instance;
  }

  LocationManager._();

  static Future<Position?> get getCurrentPosition async =>
      _instance._currentPosition ?? (await _getCurrentPosition());

  static Future<Position?> _getCurrentPosition() async {
    // Test if location services are enabled.
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      final isEnabled = await _requestForTurnOnLocation();
      if (!isEnabled) {
        return null;
      }
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try requesting permissions again (this is also where Android's shouldShowRequestPermissionRationale returned true. According to Android guidelines your App should show an explanatory UI now.
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return null;
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return _instance._currentPosition ??= await Geolocator.getCurrentPosition();
  }

  static Future<Placemark?> getCurrentLocation() async {
    final position = await getCurrentPosition;
    if (position != null) {
      return (await placemarkFromCoordinates(
              position.latitude, position.longitude))
          .firstOrNull;
    }
    return null;
  }

  static Future<bool> _requestForTurnOnLocation() async {
    return lo.Location().requestService();
  }
}
