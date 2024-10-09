import 'package:flutter/material.dart';
import 'package:k_util/api/base_auth_api.dart';
import 'package:k_util/managers/base_app_manager.dart';
import 'package:k_util/managers/base_manager.dart';
import 'package:k_util/managers/preferences_manager.dart';
import 'package:k_util/models/models.dart';

abstract class BaseAuthState<U extends BaseModel> {
  final U? user;

  BaseAuthState({this.user});

  BaseAuthState cloneWithUser(U? u);
  BaseAuthState cleanState();
}

abstract class BaseAuthManager<U extends BaseModel, S extends BaseAuthState>
    extends BaseManager<S> {
  BaseAppManager? get appManager;
  BasePreferencesManager<U> get preferencesManager;
  BaseAuthApi get authApi;

  U? get user {
    debugPrint("user from base_auth_manager.dart get user method");
    return state.value?.user as U?;
  }

  String? get authToken;

  set user(U? u) {
    updateUser(u);
  }

  Future<void> updateUser(U? u) async {
    await update((state) async {
      if (u != null) {
        await preferencesManager.setUser(u!);
      } else {
        preferencesManager.clear();
      }
      return state.cloneWithUser(u) as S;
    });
  }

  U createUser(Map<String, dynamic> data);

  Future<void> logout() async {
    authApi.logout();
    preferencesManager.clear();

    await update((state) => state.cleanState() as S);
  }

  Future<void> deleteAccount();

  Future<void> updateMessagingToken(String token) async {
    var currentToken = await preferencesManager.getMessagingToken();

    if (currentToken == null || currentToken != token) {
      preferencesManager.setMessagingToken(token);
    }
  }
}
