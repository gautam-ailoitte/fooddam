
import 'package:foodam/src/domain/entities/address_entity.dart';

class AddressModel extends Address {
  const AddressModel({
    required super.id,
    required super.street,
    required super.city,
    required super.state,
    required super.zipCode,
    required super.latitude,
    required super.longitude,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'],
      street: json['street'],
      city: json['city'],
      state: json['state'],
      zipCode: json['zipCode'],
      latitude: json['coordinates']['latitude'],
      longitude: json['coordinates']['longitude'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'street': street,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'coordinates': {
        'latitude': latitude,
        'longitude': longitude,
      },
    };
  }
}

