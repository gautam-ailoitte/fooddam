// lib/src/domain/entities/address_entity.dart

import 'package:equatable/equatable.dart';

class Coordinates extends Equatable {
  final double? latitude;
  final double? longitude;

  const Coordinates({
    this.latitude,
    this.longitude,
  });

  @override
  List<Object?> get props => [latitude, longitude];
}

class Address extends Equatable {
  final String street;
  final String city;
  final String state;
  final String zipCode;
  final String country;
  final Coordinates? coordinates;

  const Address({
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
    this.coordinates,
  });

  String get fullAddress {
    return '$street, $city, $state $zipCode, $country';
  }

  @override
  List<Object?> get props => [
    street,
    city,
    state,
    zipCode,
    country,
    coordinates,
  ];
}