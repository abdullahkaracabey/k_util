import 'dart:isolate';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:k_util/managers/base_auth_manager.dart';
import 'package:k_util/managers/firebase_notification_manager.dart';
import 'package:k_util/models/app_error.dart';
import 'package:universal_io/io.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  debugPrint('Handling a background message ${message.messageId}');
}

abstract class BaseAppManager<T> extends AsyncNotifier<T> {
  BaseFirebaseNotificationManager get firebaseNotificationManager;
  BaseAuthManager? get authManager;

  Future<String> appVersion();

  Future<void> initialize(
      {required FireBaseBackgroundHandler onBackgroundMessage,
      required OnNotificationResponse onNotificationResponse,
      String? androidNotificationIconNativePath}) async {
    FlutterError.onError = (errorDetails) {
      if (!FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled) {
        return;
      }
      if (errorDetails.exception is AppException) {
        return;
      }
      FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
    };
    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      if (!FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled) {
        return false;
      }
      if (error is AppException == false) {
        FirebaseCrashlytics.instance.recordError(
          error,
          stack,
        );
      }
      return true;
    };

    Isolate.current.addErrorListener(RawReceivePort((pair) async {
      if (!FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled) {
        return;
      }
      final List<dynamic> errorAndStacktrace = pair;
      await FirebaseCrashlytics.instance.recordError(
        errorAndStacktrace.first,
        errorAndStacktrace.last,
      );
    }).sendPort);

    await firebaseNotificationManager.initializeFireBaseMessaging(
        androidNotificationIconNativePath: androidNotificationIconNativePath,
        onNotificationResponse: onNotificationResponse,
        onBackgroundMessage: _firebaseMessagingBackgroundHandler);
  }

  void prepareAppAfterLogin();

  Locale get currentLocale => Locale(Platform.localeName.substring(0, 2));

  void onLogout() {
    authManager?.logout();
  }
}
