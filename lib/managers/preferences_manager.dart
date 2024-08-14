import 'package:flutter/material.dart';
import 'package:k_util/models/base_model.dart';
import 'package:secure_shared_preferences/secure_shared_preferences.dart';
import 'package:universal_io/io.dart';

abstract class BasePreferencesManager<T extends BaseModel> {
  final _kUser = "user";
  final _kLanguageCode = "language_code";
  final _kMessagingToken = "messaging_token";

  SecureSharedPref? _pref;

  T createUser(Map<String, dynamic> data);

  Future<SecureSharedPref> preferences() async {
    _pref ??= await SecureSharedPref.getInstance();
    return _pref!;
  }

  Future<void> clear() async {
    var pref = await preferences();
    await pref.clearAll();
  }

  Future<void> setUser(T user) async {
    try {
      var pref = await preferences();
      await pref.putMap(_kUser, user.toJson(ignoreDates: true),
          isEncrypted: false);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<T?> getUser() async {
    var pref = await preferences();
    try {
      var userAsString =
          await pref.getMap(_kUser, isEncrypted: Platform.isAndroid);

      if (userAsString != null && userAsString.isNotEmpty) {
        var map = userAsString as Map<String, dynamic>;
        return createUser(map);
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    return null;
  }

  Future<void> setLanguage(String type) async {
    await _putString(_kLanguageCode, type);
  }

  Future<String?> getLanguage() async {
    return await _getString(_kLanguageCode);
  }

  Future<void> setMessagingToken(String value) async {
    await _putString(_kMessagingToken, value);
  }

  Future<String?> getMessagingToken() async {
    return await _getString(_kMessagingToken);
  }

  _putString(String name, value) async {
    _pref ??= await SecureSharedPref.getInstance();
    await _pref!.putString(name, value);
  }

  _getString(name) async {
    var pref = await preferences();
    try {
      return await pref.getString(name);
    } catch (e) {
      debugPrint(e.toString());
    }

    return null;
  }
}
