import 'package:k_util/api/password_auth_api.dart';
import 'package:k_util/managers/base_auth_manager.dart';
import 'package:k_util/models/app_error.dart';
import 'package:k_util/models/base_model.dart';

mixin PasswordAuth<U extends BaseModel, S extends BaseAuthState>
    on BaseAuthManager<U, S> {
  Future<bool> isUserExists(String username) async {
    return callRequest(() => _isUserExists(username));
  }

  Future<void> signInPassword(String username, String password) async {
    await callRequest(() => _signInPassword(username, password));
  }

  Future<bool> _isUserExists(String username) async {
    if (authApi is BasePasswordAuthApi) {
      return (authApi as BasePasswordAuthApi).isUserExists(
        username,
      );
    }
    throw const AppException(
        code: AppException.kDeveloperLog,
        message: "authApi should be BasePasswordAuthApi");
  }

  Future<void> _signInPassword(String username, String password) async {
    if (authApi is BasePasswordAuthApi) {
      var result = await (authApi as BasePasswordAuthApi)
          .signInWithPassword(username, password);
      _handleAfterLogin(result);
      return;
    }
    throw const AppException(
        code: AppException.kDeveloperLog,
        message: "authApi should be BasePasswordAuthApi");
  }

  Future<void> signUpPassword(String username, String password) async {
    if (authApi is BasePasswordAuthApi) {
      var result = await (authApi as BasePasswordAuthApi)
          .signUpWithPassword(username, password);
      _handleAfterLogin(result);
      return;
    }
    throw const AppException(message: "authApi should be BasePasswordAuthApi");
  }

  void _handleAfterLogin(Map<String, dynamic> result) {
    final user = createUser(result);

    updateUser(user).then((value) => appManager?.prepareAppAfterLogin());
  }

  Future<void> resetPassword(String email) {
    return (authApi as BasePasswordAuthApi).resetPassword(email);
  }

  Future<void> updatePassword(String newPassword) {
    return (authApi as BasePasswordAuthApi).updatePassword(newPassword);
  }
}
