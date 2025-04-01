// lib/src/data/model/address_model.dart
import 'package:foodam/src/domain/entities/address_entity.dart';

class AddressModel {
  final String id;
  final String street;
  final String city;
  final String state;
  final String zipCode;
  final double? latitude;
  final double? longitude;
  final String? country;

  AddressModel({
    required this.id,
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
    this.latitude,
    this.longitude,
    this.country,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'],
      street: json['street'],
      city: json['city'],
      state: json['state'],
      zipCode: json['zipCode'],
      latitude: json['coordinates']?['latitude'],
      longitude: json['coordinates']?['longitude'],
      country: json['country'],
    );
  }

Map<String, dynamic> toJson() {
  final Map<String, dynamic> data = {
    'street': street,
    'city': city,
    'state': state,
    'zipCode': zipCode,
    'coordinates': {
      'latitude': latitude ?? 0,
      'longitude': longitude ?? 0,
    },
    // IMPORTANT: Always include country - even if null, use empty string
    'country': country ?? 'India',  // Default to India if not specified
  };
  
  // Only include id if it's not empty
  if (id.isNotEmpty) data['id'] = id;

  return data;
}
  // Mapper to convert model to entity
  Address toEntity() {
    return Address(
      id: id,
      street: street,
      city: city,
      state: state,
      zipCode: zipCode,
      latitude: latitude,
      longitude: longitude,
      country: country,
    );
  }

  // Mapper to convert entity to model
  factory AddressModel.fromEntity(Address entity) {
    return AddressModel(
      id: entity.id,
      street: entity.street,
      city: entity.city,
      state: entity.state,
      zipCode: entity.zipCode,
      latitude: entity.latitude,
      longitude: entity.longitude,
      country: entity.country,
    );
  }
}
