// lib/src/domain/entities/address_entity.dart
import 'package:equatable/equatable.dart';

class Address extends Equatable {
  final String id;
  final String street;
  final String city;
  final String state;
  final String zipCode;
  final double? latitude;
  final double? longitude;

  const Address({
    required this.id,
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
    this.latitude,
    this.longitude,
  });

  @override
  List<Object?> get props => [
        id,
        street,
        city,
        state,
        zipCode,
        latitude,
        longitude,
      ];
}
