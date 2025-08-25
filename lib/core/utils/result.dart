import '../errors/failures.dart';

/// A generic result type for handling success and failure cases
sealed class Result<T> {
  const Result();
}

/// Success result containing data
class Success<T> extends Result<T> {
  final T data;
  
  const Success(this.data);
}

/// Error result containing failure information
class Error<T> extends Result<T> {
  final Failure failure;
  
  const Error(this.failure);
}

/// Extension methods for Result
extension ResultExtension<T> on Result<T> {
  /// Returns true if the result is a success
  bool get isSuccess => this is Success<T>;
  
  /// Returns true if the result is an error
  bool get isError => this is Error<T>;
  
  /// Gets the data if success, null otherwise
  T? get dataOrNull => switch (this) {
    Success<T> success => success.data,
    Error<T> _ => null,
  };
  
  /// Gets the failure if error, null otherwise
  Failure? get failureOrNull => switch (this) {
    Success<T> _ => null,
    Error<T> error => error.failure,
  };
  
  /// Transforms the success data using the provided function
  Result<R> map<R>(R Function(T) transform) => switch (this) {
    Success<T> success => Success(transform(success.data)),
    Error<T> error => Error(error.failure),
  };
  
  /// Handles both success and error cases
  R fold<R>(
    R Function(Failure) onError,
    R Function(T) onSuccess,
  ) => switch (this) {
    Success<T> success => onSuccess(success.data),
    Error<T> error => onError(error.failure),
  };
}
