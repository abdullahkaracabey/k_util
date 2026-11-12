import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:k_scaffold/models/base_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Storage türü - hassas veri için Secure, normal veri için SharedPreferences
enum StorageType {
  /// Güvenli depolama (Keychain/Android KeyStore) - app silinse bile kalır
  secure,

  /// Normal depolama (SharedPreferences) - app silinince temizlenir
  shared,
}

abstract class BasePreferencesManager<T extends BaseModel> {
  final _kUser = "user";
  final _kLanguageCode = "language_code";
  final _kMessagingToken = "messaging_token";

  FlutterSecureStorage? _secureStorage;
  SharedPreferences? _sharedPreferences;

  T createUser(Map<String, dynamic> data);

  /// Secure Storage instance (Keychain/Android KeyStore)
  Future<FlutterSecureStorage> secureStorage() async {
    AndroidOptions getAndroidOptions() => const AndroidOptions(
          encryptedSharedPreferences: true,
        );
    _secureStorage ??= FlutterSecureStorage(aOptions: getAndroidOptions());

    return _secureStorage!;
  }

  /// SharedPreferences instance (app silinince temizlenir)
  Future<SharedPreferences> sharedPreferences() async {
    _sharedPreferences ??= await SharedPreferences.getInstance();
    return _sharedPreferences!;
  }

  /// Geriye uyumluluk için - SecureStorage döner
  @Deprecated('Use secureStorage() or sharedPreferences() instead')
  Future<FlutterSecureStorage> preferences() async {
    return secureStorage();
  }

  /// Tüm verileri temizle (hem secure hem shared)
  Future<void> clear() async {
    final secure = await secureStorage();
    await secure.deleteAll();

    final shared = await sharedPreferences();
    await shared.clear();
  }

  /// Sadece SharedPreferences'ı temizle (app silinince zaten temizlenir)
  Future<void> clearSharedOnly() async {
    final shared = await sharedPreferences();
    await shared.clear();
  }

  /// Sadece SecureStorage'ı temizle (hassas veriler)
  Future<void> clearSecureOnly() async {
    final secure = await secureStorage();
    await secure.deleteAll();
  }

  /// User hassas veri - SecureStorage'da saklanır
  Future<void> setUser(T user) async {
    try {
      var pref = await secureStorage();
      await pref.write(
          key: _kUser, value: jsonEncode(user.toJson(ignoreDates: true)));
    } catch (e) {
      debugPrint('Error setting user: $e');
    }
  }

  Future<T?> getUser() async {
    var pref = await secureStorage();
    try {
      var userAsString = await pref.read(key: _kUser);

      if (userAsString != null && userAsString.isNotEmpty) {
        var map = jsonDecode(userAsString) as Map<String, dynamic>;
        return createUser(map);
      }
    } catch (e) {
      debugPrint('Error getting user: $e');
    }

    return null;
  }

  /// Language tercihi - SharedPreferences (app silinince resetlenir)
  Future<void> setLanguage(String type) async {
    await putString(_kLanguageCode, type);
  }

  Future<String?> getLanguage() async {
    return await getString(_kLanguageCode);
  }

  /// Messaging token - SecureStorage (güvenlik için)
  Future<void> setMessagingToken(String value) async {
    await putString(_kMessagingToken, value, storageType: StorageType.secure);
  }

  Future<String?> getMessagingToken() async {
    return await getString(_kMessagingToken, storageType: StorageType.secure);
  }

  /// String kaydetme - storage türü seçilebilir
  Future<void> putString(String name, String value,
      {StorageType storageType = StorageType.secure}) async {
    if (storageType == StorageType.secure) {
      final secure = await secureStorage();
      await secure.write(key: name, value: value);
    } else {
      final shared = await sharedPreferences();
      await shared.setString(name, value);
    }
  }

  /// String okuma - storage türü seçilebilir
  Future<String?> getString(String name,
      {StorageType storageType = StorageType.secure}) async {
    try {
      if (storageType == StorageType.secure) {
        final secure = await secureStorage();
        return await secure.read(key: name);
      } else {
        final shared = await sharedPreferences();
        return shared.getString(name);
      }
    } catch (e) {
      debugPrint('Error getting string: $e');
    }

    return null;
  }

  /// Int kaydetme - storage türü seçilebilir
  Future<void> putInt(String name, int value,
      {StorageType storageType = StorageType.secure}) async {
    if (storageType == StorageType.secure) {
      final secure = await secureStorage();
      await secure.write(key: name, value: value.toString());
    } else {
      final shared = await sharedPreferences();
      await shared.setInt(name, value);
    }
  }

  /// Int okuma - storage türü seçilebilir
  Future<int?> getInt(String name,
      {StorageType storageType = StorageType.secure}) async {
    try {
      if (storageType == StorageType.secure) {
        final secure = await secureStorage();
        var value = await secure.read(key: name);
        if (value != null && value.isNotEmpty) {
          return int.parse(value);
        }
      } else {
        final shared = await sharedPreferences();
        return shared.getInt(name);
      }
    } catch (e) {
      debugPrint('Error getting int: $e');
    }

    return null;
  }

  /// Bool kaydetme - storage türü seçilebilir
  Future<void> putBool(String name, bool value,
      {StorageType storageType = StorageType.secure}) async {
    if (storageType == StorageType.secure) {
      final secure = await secureStorage();
      await secure.write(key: name, value: value.toString());
    } else {
      final shared = await sharedPreferences();
      await shared.setBool(name, value);
    }
  }

  /// Bool okuma - storage türü seçilebilir
  Future<bool?> getBool(String name,
      {StorageType storageType = StorageType.secure}) async {
    try {
      if (storageType == StorageType.secure) {
        final secure = await secureStorage();
        var value = await secure.read(key: name);
        if (value != null && value.isNotEmpty) {
          return value.toLowerCase() == "true";
        }
      } else {
        final shared = await sharedPreferences();
        return shared.getBool(name);
      }
    } catch (e) {
      debugPrint('Error getting bool: $e');
    }

    return null;
  }

  /// Map kaydetme - storage türü seçilebilir
  Future<void> putMap(String name, Map<String, dynamic> value,
      {StorageType storageType = StorageType.secure}) async {
    final jsonString = jsonEncode(value);
    if (storageType == StorageType.secure) {
      final secure = await secureStorage();
      await secure.write(key: name, value: jsonString);
    } else {
      final shared = await sharedPreferences();
      await shared.setString(name, jsonString);
    }
  }

  /// Map okuma - storage türü seçilebilir
  Future<Map<String, dynamic>?> getMap(String name,
      {StorageType storageType = StorageType.secure}) async {
    try {
      String? value;
      if (storageType == StorageType.secure) {
        final secure = await secureStorage();
        value = await secure.read(key: name);
      } else {
        final shared = await sharedPreferences();
        value = shared.getString(name);
      }

      if (value != null && value.isNotEmpty) {
        return jsonDecode(value) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('Error getting map: $e');
    }

    return null;
  }

  /// Belirli bir key'i sil - storage türü seçilebilir
  Future<void> remove(String name,
      {StorageType storageType = StorageType.secure}) async {
    if (storageType == StorageType.secure) {
      final secure = await secureStorage();
      await secure.delete(key: name);
    } else {
      final shared = await sharedPreferences();
      await shared.remove(name);
    }
  }

  /// Tüm verileri sil - her iki storage'dan da
  Future<void> removeAll() async {
    await clear();
  }
}
