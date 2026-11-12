# k_scaffold Flutter Package Instructions

## Architecture Overview

**k_scaffold** is a reusable Flutter foundation package providing core infrastructure for apps using **Riverpod** state management. It implements a layered architecture with versioned base classes:

- **Managers** ([lib/managers/](lib/managers/)) - Business logic, app/auth lifecycle management, Firebase integration
- **APIs** ([lib/api/](lib/api/)) - Network layer with Dio-based HTTP client + auth abstractions
- **Models** ([lib/models/](lib/models/)) - Data models, view state handling, standardized error types
- **Controllers** ([lib/controllers/](lib/controllers/)) - Standalone UI state controllers (button states, etc.)
- **Extensions** ([lib/extensions/](lib/extensions/)) - Convenience extensions for Context, String, DateTime, GoRouter
- **Widgets** ([lib/widget/](lib/widget/)) - Stateful UI components with integrated loading/error states
- **Services** ([lib/services/](lib/services/)) - Navigation and other app-level services

## Critical Patterns

### Versioned Architecture (V1 vs V2)
The package provides TWO versions of base classes for different Riverpod approaches:

**V1 (legacy)**: Traditional class-based providers
- `BaseAppManager<T>`, `BaseAuthManager<U, S>`, `BaseManager`
- Used with manual provider declarations

**V2 (current)**: Riverpod code generation (`@riverpod` annotation)
- `BaseAppManagerV2`, `BaseAuthManagerV2<U, S>`, `BaseManagerV2`
- Requires `build_runner` and `riverpod_generator`
- **Preferred for new code** - see [lib/managers/base_manager_v2.dart](lib/managers/base_manager_v2.dart)

### Request Error Handling Pattern
All managers and views use `callRequest<T>()` for standardized API calls:

```dart
// In managers (BaseManagerV2)
Future<User> fetchUser() {
  return callRequest(() => api.getUser()); // Auto-handles 401/errors
}

// In views (BaseViewState)
await callRequest(
  () => ref.read(userProvider.notifier).fetchUser(),
  shouldChangeWidgetState: true, // Shows loading state
  alertText: "Loading user..." // Optional dialog
);
```

**Key behavior**: `callRequest()` automatically triggers logout on 401 errors and rethrows exceptions for caller handling.

### API Integration with Dio
All network operations use the `Api` mixin ([lib/mixing/api.dart](lib/mixing/api.dart)):

```dart
class MyApi with Api {
  @override
  String get baseUrl => "https://api.example.com";
  
  @override
  Dio get dio => _dio; // Your configured Dio instance
  
  Future<Map> getData() => getRequest("endpoint"); // Auto-handles errors
}
```

- Response handling: 2xx = success, 401 = `AppException.unAuthorized`, 500 = `AppException.unknownError`
- All auth APIs extend `BaseAuthApi` and implement `fetchUser()`, `logout()`, `updateUser()`

### View State Management
Views extend `BaseViewState<W>` ([lib/models/base_view_state.dart](lib/models/base_view_state.dart)) for consistent state handling:

```dart
class MyView extends ConsumerStatefulWidget { ... }

class _MyViewState extends BaseViewState<MyView> {
  WidgetState currentState; // init, onAction, completed, error
  
  void _loadData() {
    callRequest(() => api.fetchData()); // Auto-manages currentState
  }
}
```

**States**: `init` (idle) → `onAction` (loading) → `completed`/`error`

### Widget State Pattern
For button/widget loading states, use `WidgetStateController` + `ElevatedStateButton`:

```dart
final controller = WidgetStateController();

ElevatedStateButton(
  controller: controller,
  onPressed: () async {
    await performAsyncAction(); // Auto-shows loading
  },
  child: Text("Submit"),
)
```

Controller automatically transitions: `init` → `onAction` → `completed`/`error`

### Authentication Flow (Mixins)
Auth features use mixins for composition ([lib/managers/auth/](lib/managers/auth/)):

```dart
class AuthManager extends BaseAuthManager<User, AuthState>
    with PasswordAuth<User, AuthState>, SocialMediaAuth<User, AuthState> {
  
  @override
  BaseAuthApi get authApi => MyAuthApi();
  
  // PasswordAuth adds: signInPassword(), signUpPassword(), resetPassword()
  // SocialMediaAuth adds: signInWithGoogle(), signInWithApple(), etc.
}
```

After successful login, all auth mixins call `_handleAfterLogin()` → `updateUserLocally()` → `appManager?.prepareAppAfterLogin()`

### Barrel File Export Strategy
**Critical**: Each directory has a barrel file (`managers.dart`, `apis.dart`, etc.) that exports all public APIs. Main entry point [lib/k_scaffold.dart](lib/k_scaffold.dart) re-exports:
1. All external dependencies (flutter_riverpod, dio, firebase_*, go_router, etc.)
2. All internal barrel files

**When adding features**:
1. Create implementation in appropriate directory
2. Add export to directory barrel file (e.g., `lib/api/apis.dart`)
3. `lib/k_scaffold.dart` automatically includes it via barrel re-export

## Development Workflow

### Essential Commands
```bash
flutter analyze                 # Lint/analyze code
flutter test                    # Run unit tests
flutter gen-l10n                # Regenerate localizations from ARB files
dart run build_runner build     # Generate Riverpod providers (V2 only)
dart run build_runner watch     # Auto-generate on file changes
```

### Localization Setup
Configured in [l10n.yaml](l10n.yaml) with output class `KScaffoldLocalizations`:
- ARB files in [lib/l10n/](lib/l10n/) (e.g., `app_en.arb`, `app_tr.arb`)
- Access via `KScaffoldLocalizations.of(context)!.yourKey`
- Run `flutter gen-l10n` after modifying ARB files

### Testing Patterns
- Tests go in [test/](test/) directory
- Mock Riverpod providers using `ProviderContainer` with overrides
- Use `ConsumerStatefulWidget` test wrappers for view state tests

### Firebase Integration
Required managers in [lib/managers/](lib/managers/):
- `FirebaseNotificationManager` - FCM setup, token management, notification handling
- `BaseAppManager` - Firebase initialization via `Firebase.initializeApp()`
- Both integrate with Firebase Analytics, Crashlytics

**Note**: Consumers must configure Firebase in their app (GoogleService-Info.plist, google-services.json)

## Key Extensions

- **Context** ([extensions/context.dart](lib/extensions/context.dart)): `context.height`, `context.width`, `context.heightTransformer()`
- **GoRouter** ([extensions/go_router.dart](lib/extensions/go_router.dart)): `router.currentRoute`, `router.popUntil(path)`
- **String** ([extensions/string.dart](lib/extensions/string.dart)): `"email@example.com".isValidEmail`, `"text".toDate()`

## Common Pitfalls

1. **401 Handling**: `callRequest()` auto-logs out on 401, but auth manager must be properly injected
2. **V1 vs V2**: Don't mix versioned base classes - choose one architecture per app
3. **Barrel Files**: Always update directory barrel file when adding new exports
4. **Localization**: Localization class name is `KScaffoldLocalizations`, not `KUtilLocalizations` (legacy name exists in some files)
5. **AppException Codes**: Use predefined constants (`AppException.kUnAuthorized`, etc.) not magic numbers