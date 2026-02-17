class GeneralException implements Exception {
  final String message;

  const GeneralException({required this.message});
}

class ServerException implements Exception {
  final String message;

  const ServerException({required this.message});
}

class StatusCodeException implements Exception {
  final String message;

  const StatusCodeException({required this.message});
}

class EmptyException implements Exception {
  final String message;

  const EmptyException({required this.message});
}

class CacheException implements Exception {
  final String message;

  const CacheException({required this.message});
}

class NetworkException implements Exception {
  final String message;

  const NetworkException({required this.message});
}

class ConflictException implements Exception {
  final String message;
  final Map<String, dynamic>? serverData;

  const ConflictException({required this.message, this.serverData});
}
