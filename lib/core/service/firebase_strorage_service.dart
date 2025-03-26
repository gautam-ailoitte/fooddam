// lib/core/service/firebase_storage_service.dart

import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

/// Service for handling file uploads to Firebase Storage
class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload a file to Firebase Storage
  /// 
  /// Returns the download URL for the uploaded file
  Future<String> uploadFile({
    required dynamic file, // File or Uint8List
    required String folder,
    String? customFileName,
  }) async {
    try {
      // Generate a unique filename if not provided
      final fileName = customFileName ?? '${DateTime.now().millisecondsSinceEpoch}-${path.basename(file is File ? file.path : 'file')}';
      final destination = '$folder/$fileName';
      
      Reference ref = _storage.ref().child(destination);
      UploadTask? uploadTask;
      
      // Handle different file types
      if (kIsWeb) {
        // Web platform uses Uint8List for file upload
        if (file is Uint8List) {
          uploadTask = ref.putData(file);
        } else {
          throw ArgumentError('For web, file must be Uint8List');
        }
      } else {
        // Mobile platforms use File
        if (file is File) {
          uploadTask = ref.putFile(file);
        } else if (file is Uint8List) {
          uploadTask = ref.putData(file);
        } else {
          throw ArgumentError('File must be either File or Uint8List');
        }
      }
      
      // Wait for the upload to complete
      final snapshot = await uploadTask;
      
      // Get the download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading file: $e');
      rethrow;
    }
  }

  /// Delete a file from Firebase Storage by URL
  Future<void> deleteFileByUrl(String fileUrl) async {
    try {
      // Extract the path from the URL
      final ref = _storage.refFromURL(fileUrl);
      await ref.delete();
    } catch (e) {
      debugPrint('Error deleting file: $e');
      rethrow;
    }
  }

  /// Get a download URL for a file in Firebase Storage by path
  Future<String?> getDownloadUrl(String storagePath) async {
    try {
      final ref = _storage.ref().child(storagePath);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error getting download URL: $e');
      return null;
    }
  }
}