// lib/src/domain/entities/cloud_kitchen_entity.dart
import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/address_entity.dart';

class CloudKitchen extends Equatable {
  final String? id;
  final String? name;
  final Address? address;

  const CloudKitchen({this.id, this.name, this.address});

  @override
  List<Object?> get props => [id, name, address];

  /// Helper getter for display name
  String get displayName => name ?? 'Unknown Kitchen';

  /// Helper getter for location
  String get location {
    if (address == null) return 'Unknown Location';
    return '${address!.city}, ${address!.state}';
  }

  /// Copy with new values
  CloudKitchen copyWith({String? id, String? name, Address? address}) {
    return CloudKitchen(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
    );
  }
}
