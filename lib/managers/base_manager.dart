import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:k_util/managers/base_auth_manager.dart';
import 'package:k_util/models/app_error.dart';

typedef RequestCall<T> = Future<T> Function();

abstract class BaseManager<S> extends AsyncNotifier<S> {
  BaseAuthManager? get authManager;

  Future<T> callRequest<T>(RequestCall<T> function) async {
    try {
      return await function();
    } catch (e) {
      if (e is AppException) {
        if (e.code == AppException.kUnAuthorized) {
          authManager?.logout();
        }
      }

      rethrow;
    }
  }
}
