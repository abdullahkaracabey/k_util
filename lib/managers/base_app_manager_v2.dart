/// Base application state for Riverpod code generation compatibility.
class BaseAppStateV2 {
  final String? version;
  final bool? needsUpdate;
  final String? appName;

  const BaseAppStateV2({
    this.appName,
    this.version,
    this.needsUpdate,
  });

  BaseAppStateV2 copyWith({
    String? appName,
    String? version,
    bool? needsUpdate,
  }) {
    return BaseAppStateV2(
      appName: appName ?? this.appName,
      version: version ?? this.version,
      needsUpdate: needsUpdate ?? this.needsUpdate,
    );
  }
}

/// Base application manager interface for Riverpod code generation.
/// Use @riverpod annotation and extend the generated _$YourAppManager class.
///
/// Usage:
/// ```dart
/// @Riverpod(keepAlive: true)
/// class AppManager extends _$AppManager {
///   @override
///   Future<AppState> build(AppConfig config) async {
///     // Initialize Firebase, Crashlytics, Analytics, etc.
///     return AppState();
///   }
/// }
/// ```
///
/// Key Responsibilities:
/// - Firebase initialization
/// - Crashlytics setup
/// - Analytics configuration
/// - Remote Config
/// - App version checking
/// - Push notification setup
abstract class BaseAppManagerV2 {
  // This is now just an interface
  // The actual implementation uses @riverpod and build() method
}
