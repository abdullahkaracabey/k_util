# k_util

`k_util` is a comprehensive "core" utility and management package designed for Flutter projects. It gathers Riverpod-based state management, Firebase services, authentication infrastructure, and frequently used helper tools under a single roof.

## Features

-   **State Management**: Core structures integrated with Riverpod (`BaseAppManager`, `AsyncNotifier`).
-   **Authentication**: Ready-to-use Auth infrastructure (`BaseAuthManager`, `BaseAuthApi`).
-   **Firebase Integration**:
    -   Cloud Messaging (FCM) management.
    -   Crashlytics error catching.
    -   Analytics.
-   **Network Layer**: Dio-based configuration.
-   **Utilities**:
    -   `DeviceUtility` (Screen size, platform check).
    -   `DateUtility` (Date formatting).
    -   `StringExtensions` (Text processing).

## Installation

Add this packet to your project as a git dependency or path dependency (until published on pub.dev).

**Via Git:**

```yaml
dependencies:
  k_util:
    git:
      url: https://github.com/abdullahkaracabey/k_util.git
      ref: main
```

**Via Path (Local Development):**

```yaml
dependencies:
  k_util:
    path: ../path/to/k_util
```

## Usage

### 1. Initialization

You can initialize basic services using the `BaseAppManager` structure at the entry point of your application (`main.dart`).

```dart
import 'package:k_util/k_util.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase and other services
  await Firebase.initializeApp();
  
  runApp(const ProviderScope(child: MyApp()));
}
```

### 2. BaseAppManager Usage

Create your application's main state manager by deriving from `BaseAppManager`. This class manages version control, notification management, and user session state.

```dart
class AppManager extends BaseAppManager<AppState> {
  @override
  BaseFirebaseNotificationManager get firebaseNotificationManager => NotificationManager();

  @override
  BaseAuthManager? get authManager => AuthManager();

  @override
  Future<AppState> build() async {
    // Initial state loading
    return AppState();
  }
  
  // ...
}
```

### 3. Extensions

**Context Extensions:**
```dart
context.height; // Screen height
context.width;  // Screen width
context.push(MyPage()); // Navigation
```

**String Extensions:**
```dart
"example@email.com".isValidEmail; // true
"2023-10-10".toDate(); // DateTime object
```

## Dependencies

This package uses and exports the following core libraries:
-   `flutter_riverpod`
-   `go_router`
-   `dio`
-   `firebase_core` & `firebase_messaging` & `firebase_auth`

## License

MIT
