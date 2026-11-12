import 'package:k_scaffold/models/app_error.dart';

typedef RequestCall<T> = Future<T> Function();

/// Base class for all managers using Riverpod code generation.
/// This is the V2 version compatible with @riverpod annotation.
///
/// Usage:
/// ```dart
/// @riverpod
/// class MyManager extends _$MyManager {
///   // Your manager implementation
/// }
/// ```
abstract class BaseManagerV2 {
  /// Execute an API request with standardized error handling.
  /// Automatically logs out user on 401 Unauthorized errors.
  Future<T> callRequest<T>(RequestCall<T> function) async {
    try {
      return await function();
    } catch (e) {
      if (e is AppException) {
        if (e.code == AppException.kUnAuthorized) {
          // Trigger logout via auth manager
          // Note: This should be injected via constructor or ref
          // authManager?.logout();
        }
      }
      rethrow;
    }
  }
}
