/// Base exception for data layer operations.
abstract class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

/// Thrown when a database operation fails.
class DatabaseException extends AppException {
  const DatabaseException([super.message = 'Database operation failed']);
}

/// Thrown when a requested entity is not found.
class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Entity not found']);
}

/// Thrown when input validation fails in the data layer.
class ValidationException extends AppException {
  const ValidationException([super.message = 'Validation failed']);
}
