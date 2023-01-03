import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:k_util/managers/base_auth_manager.dart';
import 'package:k_util/managers/firebase_notification_manager.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  debugPrint('Handling a background message ${message.messageId}');
}

abstract class BaseAppManager extends ChangeNotifier {
  bool _initialized = false;
  bool _isSplashScreenSeen = false;
  bool _isLoginComplete = false;

  bool get isSplashScreenSeen => _isSplashScreenSeen;
  set isSplashScreenSeen(bool isSeen) {
    _isSplashScreenSeen= isSeen;
    notifyListeners();
  }
  bool get isInitialized => _initialized;
  bool get isLoginComplete => _isLoginComplete;

  BaseFirebaseNotificationManager get firebaseNotificationManager;
  BaseAuthManager get authManager;

  Future<String> appVersion();

  Future<void> initialize({dynamic options}) async {
    await firebaseNotificationManager.initializeFireBaseMessaging(
        onBackgroundMessage: _firebaseMessagingBackgroundHandler);
    await authManager.prepare();
    _initialized = true;

    if (authManager.user != null) {
      _isLoginComplete = true;
    }
  }

  void prepareAppAfterLogin() {
    _isLoginComplete = true;
  }

  Locale get currentLocale => Locale(Platform.localeName.substring(0, 2));

  void onLogout() {
    _isLoginComplete = false;
    notifyListeners();
  }
}
