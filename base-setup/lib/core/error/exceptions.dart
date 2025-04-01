/// Exception from remote server in Data Layer
class ServerException implements Exception {
  String message;

  ServerException({required this.message, });
}

/// CacheException from cache in Data Layer
class CacheException implements Exception {}