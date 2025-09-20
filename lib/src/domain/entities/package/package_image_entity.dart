// lib/src/domain/entities/package_image_entity.dart
//
import 'package:equatable/equatable.dart';

class PackageImage extends Equatable {
final String id;
final String url;
final String key;
final String fileName;

const PackageImage({
required this.id,
required this.url,
required this.key,
required this.fileName,
});

@override
List<Object?> get props => [id, url, key, fileName];

bool get hasValidUrl => url.isNotEmpty;
}
