// lib/src/domain/entities/uploaded_file_entity.dart
import 'package:equatable/equatable.dart';

class UploadedFile extends Equatable {
  final String? fileName;
  final String? fileUrl;
  final String? folder;
  final int? size;
  final String? key;
  final List<String>? categories;
  final DateTime? uploadedAt;
  final String? id;

  const UploadedFile({
    this.fileName,
    this.fileUrl,
    this.folder,
    this.size,
    this.key,
    this.categories,
    this.uploadedAt,
    this.id,
  });

  @override
  List<Object?> get props => [
    fileName,
    fileUrl,
    folder,
    size,
    key,
    categories,
    uploadedAt,
    id,
  ];

  /// Helper getter for display name
  String get displayName => fileName ?? 'Unknown File';

  /// Helper getter to check if file has valid URL
  bool get hasValidUrl => fileUrl != null && fileUrl!.isNotEmpty;

  /// Helper getter for file size in KB
  double? get sizeInKB => size != null ? size! / 1024 : null;

  /// Helper getter for file size in MB
  double? get sizeInMB => size != null ? size! / (1024 * 1024) : null;

  /// Helper getter for formatted file size
  String get formattedSize {
    if (size == null) return 'Unknown size';

    final sizeInMB = this.sizeInMB!;
    if (sizeInMB >= 1) {
      return '${sizeInMB.toStringAsFixed(1)} MB';
    } else {
      final sizeInKB = this.sizeInKB!;
      return '${sizeInKB.toStringAsFixed(0)} KB';
    }
  }

  /// Helper getter for file extension
  String? get fileExtension {
    if (fileName == null) return null;

    final parts = fileName!.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : null;
  }

  /// Helper to check if file is an image
  bool get isImage {
    final ext = fileExtension;
    if (ext == null) return false;

    const imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'];
    return imageExtensions.contains(ext);
  }

  /// Copy with new values
  UploadedFile copyWith({
    String? fileName,
    String? fileUrl,
    String? folder,
    int? size,
    String? key,
    List<String>? categories,
    DateTime? uploadedAt,
    String? id,
  }) {
    return UploadedFile(
      fileName: fileName ?? this.fileName,
      fileUrl: fileUrl ?? this.fileUrl,
      folder: folder ?? this.folder,
      size: size ?? this.size,
      key: key ?? this.key,
      categories: categories ?? this.categories,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      id: id ?? this.id,
    );
  }
}

// lib/src/domain/entities/file_upload_response_entity.dart

class FileUploadResponse extends Equatable {
  final String? status;
  final String? message;
  final List<UploadedFile>? data;

  const FileUploadResponse({this.status, this.message, this.data});

  @override
  List<Object?> get props => [status, message, data];

  /// Helper to check if upload was successful
  bool get isSuccess => status?.toLowerCase() == 'success';

  /// Helper to get the first uploaded file
  UploadedFile? get firstFile => data?.isNotEmpty == true ? data!.first : null;

  /// Helper to get all file URLs
  List<String> get fileUrls {
    if (data == null) return [];
    return data!
        .where((file) => file.fileUrl != null)
        .map((file) => file.fileUrl!)
        .toList();
  }

  /// Helper to get the first file URL
  String? get firstFileUrl => firstFile?.fileUrl;

  /// Helper getter for display message
  String get displayMessage => message ?? 'Upload completed';

  /// Copy with new values
  FileUploadResponse copyWith({
    String? status,
    String? message,
    List<UploadedFile>? data,
  }) {
    return FileUploadResponse(
      status: status ?? this.status,
      message: message ?? this.message,
      data: data ?? this.data,
    );
  }
}
