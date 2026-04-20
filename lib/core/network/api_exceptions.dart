class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException({required this.message, this.statusCode});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class NetworkException extends ApiException {
  const NetworkException({super.message = 'Network error occurred'});
}

class TimeoutException extends ApiException {
  const TimeoutException({super.message = 'Request timed out'});
}
