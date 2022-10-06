import 'package:k_util/api/base_auth_api.dart';
import 'package:k_util/managers/base_app_manager.dart';
import 'package:k_util/managers/base_manager.dart';
import 'package:k_util/managers/preferences_manager.dart';
import 'package:k_util/models/models.dart';

abstract class BaseAuthManager<T extends BaseModel> extends BaseManager {
  BaseAppManager get appManager;
  BasePreferencesManager<T> get preferencesManager;
  BaseAuthApi get authApi;
  T? _user;

  T? get user => _user;
  set user(T? u) => _user = u;

  T createUser(Map<String, dynamic> data);
  @override
  Future<void> prepare() async {
    _user = await preferencesManager.getUser();
  }

  Future<void> logout() async {
    await authApi.logout();
    await preferencesManager.clear();
    appManager.onLogout();
  }

  Future<void> updateMessagingToken(String token) async {
    var currentToken = await preferencesManager.getMessagingToken();

    if (currentToken == null || currentToken != token) {
      preferencesManager.setMessagingToken(token);
    }
  }
}
