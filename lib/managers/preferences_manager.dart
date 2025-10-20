import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:k_util/models/base_model.dart';

abstract class BasePreferencesManager<T extends BaseModel> {
  final _kUser = "user";
  final _kLanguageCode = "language_code";
  final _kMessagingToken = "messaging_token";

  FlutterSecureStorage? _pref;

  T createUser(Map<String, dynamic> data);

  Future<FlutterSecureStorage> preferences() async {
    AndroidOptions getAndroidOptions() => const AndroidOptions(
          encryptedSharedPreferences: true,
        );
    _pref ??= FlutterSecureStorage(aOptions: getAndroidOptions());

    return _pref!;
  }

  Future<void> clear() async {
    var pref = await preferences();
    await pref.deleteAll();
  }

  Future<void> setUser(T user) async {
    try {
      var pref = await preferences();
      await pref.write(
          key: _kUser, value: jsonEncode(user.toJson(ignoreDates: true)));
    } catch (e) {
      // debugPrint(e.toString());
    }
  }

  Future<T?> getUser() async {
    var pref = await preferences();
    try {
      var userAsString = await pref.read(key: _kUser);

      if (userAsString != null && userAsString.isNotEmpty) {
        var map = jsonDecode(userAsString) as Map<String, dynamic>;
        return createUser(map);
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    return null;
  }

  Future<void> setLanguage(String type) async {
    await putString(_kLanguageCode, type);
  }

  Future<String?> getLanguage() async {
    return await getString(_kLanguageCode);
  }

  Future<void> setMessagingToken(String value) async {
    await putString(_kMessagingToken, value);
  }

  Future<String?> getMessagingToken() async {
    return await getString(_kMessagingToken);
  }

  Future<void> putString(String name, value) async {
    var pref = await preferences();
    await pref.write(key: name, value: value);
  }

  Future<String?> getString(String name) async {
    var pref = await preferences();
    try {
      return await pref.read(key: name);
    } catch (e) {
      debugPrint(e.toString());
    }

    return null;
  }

  Future<void> putInt(String name, int value) async {
    var pref = await preferences();
    await pref.write(key: name, value: value.toString());
  }

  Future<int?> getInt(String name) async {
    var pref = await preferences();
    try {
      var value = await pref.read(key: name);
      if (value != null && value.isNotEmpty) {
        return int.parse(value);
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    return null;
  }

  Future<void> putBool(String name, bool value) async {
    var pref = await preferences();
    await pref.write(key: name, value: value.toString());
  }

  Future<bool?> getBool(String name) async {
    var pref = await preferences();
    try {
      var value = await pref.read(key: name);
      if (value != null && value.isNotEmpty) {
        return value.toLowerCase() == "true";
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    return null;
  }

  Future<void> putMap(String name, Map<String, dynamic> value) async {
    var pref = await preferences();
    await pref.write(key: name, value: jsonEncode(value));
  }

  Future<Map<String, dynamic>?> getMap(String name) async {
    var pref = await preferences();
    try {
      var value = await pref.read(key: name);
      if (value != null && value.isNotEmpty) {
        return jsonDecode(value) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    return null;
  }

  Future<void> remove(String name) async {
    var pref = await preferences();
    await pref.delete(key: name);
  }

  Future<void> removeAll() async {
    var pref = await preferences();
    await pref.deleteAll();
  }
}
