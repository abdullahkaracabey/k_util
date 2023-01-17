import 'package:k_util/api/password_auth_api.dart';
import 'package:k_util/managers/base_auth_manager.dart';
import 'package:k_util/models/app_error.dart';
import 'package:k_util/models/base_model.dart';

mixin PasswordAuth<T extends BaseModel> on BaseAuthManager<T> {
  Future<void> signInPassword(String username, String password) async {
    await callRequest(() => _signInPassword(username, password));
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
        message: "authApi should be BaseSocialMediaAuthApi");
  }

  Future<void> signUpPassword(String username, String password) async {
    if (authApi is BasePasswordAuthApi) {
      var result = await (authApi as BasePasswordAuthApi)
          .signUpWithPassword(username, password);
      _handleAfterLogin(result);
      return;
    }
    throw const AppException(
        message: "authApi should be BaseSocialMediaAuthApi");
  }

  void _handleAfterLogin(Map<String, dynamic> result) {
    user = createUser(result);
    appManager.prepareAppAfterLogin();
  }
}
