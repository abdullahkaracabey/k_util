import 'package:k_util/api/base_auth_api.dart';
import 'package:k_util/managers/base_app_manager.dart';
import 'package:k_util/managers/base_manager.dart';
import 'package:k_util/managers/preferences_manager.dart';
import 'package:k_util/models/models.dart';

abstract class BaseAuthManager<T extends BaseModel> extends BaseManager {
  BaseAppManager get appManager;
  BasePreferencesManager<T> get preferencesManager;
  BaseAuthApi get authApi;
  String? get authToken;
  T? _user;

  T? get user => _user;
  set user(T? u) {
    _user = u;
    notifyListeners();
  }

  T createUser(Map<String, dynamic> data);
  @override
  Future<void> prepare() async {
    _user = await preferencesManager.getUser();
  }

  Future<void> logout() async {
    authApi.logout();
    preferencesManager.clear();
    appManager.onLogout();
    _user = null;
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    await authApi.deleteAccount();
    await logout();
  }

  Future<void> updateMessagingToken(String token) async {
    var currentToken = await preferencesManager.getMessagingToken();

    if (currentToken == null || currentToken != token) {
      preferencesManager.setMessagingToken(token);
    }
  }
}
