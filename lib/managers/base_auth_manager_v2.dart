import 'package:k_scaffold/models/models.dart';

/// Base authentication state for Riverpod code generation compatibility.
/// Extend this in your app-specific auth state.
abstract class BaseAuthStateV2<U extends BaseModel> {
  final U? user;
  final bool isLoading;
  final String? error;

  const BaseAuthStateV2({
    this.user,
    this.isLoading = false,
    this.error,
  });

  bool get isAuthenticated => user != null;

  /// Clone state with new user. Override in your auth state.
  BaseAuthStateV2<U> cloneWithUser(U? user);

  /// Clean state on logout. Override in your auth state.
  BaseAuthStateV2<U> cleanState();
}

/// Base authentication manager interface for Riverpod code generation.
/// Use @riverpod annotation and extend the generated _$YourAuthManager class.
///
/// Usage:
/// ```dart
/// @riverpod
/// class AuthManager extends _$AuthManager {
///   @override
///   AuthState build() {
///     // Initialize auth state
///     return AuthState(user: null);
///   }
///
///   Future<void> login(String email, String password) async {
///     // Implementation
///   }
/// }
/// ```
abstract class BaseAuthManagerV2<U extends BaseModel,
    S extends BaseAuthStateV2<U>> {
  /// Get current user from state
  U? get user;

  /// Get authentication token
  String? get authToken;

  /// Update user in local storage
  Future<void> updateUserLocally(U? user);

  /// Create user object from JSON data
  U createUser(Map<String, dynamic> data);

  /// Logout user
  Future<void> logout();

  /// Delete user account
  Future<void> deleteAccount();

  /// Update FCM messaging token
  Future<void> updateMessagingToken(String token);
}
