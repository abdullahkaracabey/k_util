# K_Util Flutter Package Instructions

## Architecture Overview

This is a Flutter utility package built with **Riverpod** for state management, designed as a reusable foundation for Flutter apps. It follows a layered architecture:

- **Managers** (`lib/managers/`) - Core business logic and app lifecycle management
- **APIs** (`lib/api/`) - Network layer with authentication abstractions  
- **Models** (`lib/models/`) - Data models, state definitions, and error handling
- **Controllers** (`lib/controllers/`) - UI state management (button states, etc.)
- **Extensions** (`lib/extensions/`) - Dart/Flutter extensions for common operations
- **Widgets** (`lib/widget/`) - Reusable UI components with state integration

## Key Patterns

### Manager Pattern
All core functionality extends from base managers in `lib/managers/base_*.dart`:
- `BaseAppManager<T extends BaseAppState>` - App initialization, Firebase, version checking
- `BaseAuthManager` - Authentication flow abstractions
- Managers use Riverpod's `AsyncNotifier<T>` pattern

### State Management
- **View States**: `BaseViewState<W>` provides standard UI state handling (`init`, `onAction`, `completed`, `error`)
- **Widget States**: `WidgetStateController` manages button/widget loading states
- **Request Pattern**: Use `callRequest<T>()` method in views for standardized API calls with error handling

### API Integration
- Use `Api` mixin from `lib/mixing/api.dart` for HTTP operations
- All API calls should extend base auth APIs (`BaseAuthApi`, `PasswordAuthApi`, etc.)
- Standard error handling through `AppException` and `AppError` models

### Export Structure
- Each directory has a barrel file (`*.dart`) that exports all public APIs
- Main entry point `lib/k_util.dart` re-exports everything including external dependencies
- Follow this pattern when adding new components

## Development Workflow

### Package Structure
```bash
# Run package analysis
flutter analyze

# Run tests  
flutter test

# Generate localizations (if modified)
flutter gen-l10n
```

### Dependencies
- **State Management**: flutter_riverpod (primary), get_it (service location)
- **Navigation**: go_router with custom extensions in `lib/extensions/go_router.dart`
- **Firebase**: Full suite (core, messaging, analytics, crashlytics)
- **UI**: Custom state widgets

### Adding New Features
1. Create base classes in appropriate `lib/*/base_*.dart` files
2. Implement concrete classes extending the bases
3. Add exports to the directory's barrel file
4. Update `lib/k_util.dart` if needed for public API

## Testing & Localization

- Tests go in `test/` directory
- Localizations in `lib/l10n/` with ARB files for each language
- Use `KUtilLocalizations.of(context)` for localized strings

## External Dependencies
- Firebase configuration required for notification/analytics managers
- Secure storage for auth token persistence