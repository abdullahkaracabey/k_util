import 'package:k_util/api/social_media_auth_api.dart';
import 'package:k_util/managers/base_auth_manager.dart';
import 'package:k_util/models/app_error.dart';
import 'package:k_util/models/base_model.dart';

mixin SocialMediaAuth<T extends BaseModel> on BaseAuthManager<T> {
  Future<void> loginWithApple(Map<String, String> params) async {
    callRequest(() async {
      if (authApi is BaseSocialMediaAuthApi) {
        var result =
            await (authApi as BaseSocialMediaAuthApi).loginWithApple(params);
        _handleAfterLogin(result);
      } else {
        throw const AppException(
            code: AppException.kDeveloperLog,
            message: "authApi should be BaseSocialMediaAuthApi");
      }
    });
  }

  Future<void> loginWithFaceBook(String token) async {
    return callRequest(() async {
      if (authApi is BaseSocialMediaAuthApi) {
        var result =
            await (authApi as BaseSocialMediaAuthApi).loginWithFacebook(token);

        if (result != null) {
          _handleAfterLogin(result);
        }
      } else {
        throw const AppException(
            code: AppException.kDeveloperLog,
            message: "authApi should be BaseSocialMediaAuthApi");
      }
    });
  }

  void _handleAfterLogin(Map<String, dynamic> result) {
    user = createUser(result);
    appManager.prepareAppAfterLogin();
  }
}
