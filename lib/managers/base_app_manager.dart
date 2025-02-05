import 'package:app_version_update/app_version_update.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:k_util/managers/base_auth_manager.dart';
import 'package:k_util/managers/firebase_notification_manager.dart';
import 'package:k_util/models/app_error.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:universal_io/io.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  debugPrint('Handling a background message ${message.messageId}');
}

class BaseAppState {
  final String? version;
  final bool? needsUpdate;
  final String? appName;

  BaseAppState({this.appName, this.version, this.needsUpdate});

  BaseAppState copyWith({String? appName, String? version, bool? needsUpdate}) {
    return BaseAppState(
        appName: appName ?? this.appName,
        version: version ?? this.version,
        needsUpdate: needsUpdate ?? this.needsUpdate);
  }
}

abstract class BaseAppManager<T extends BaseAppState> extends AsyncNotifier<T> {
  BaseFirebaseNotificationManager get firebaseNotificationManager;
  BaseAuthManager? get authManager;

  Future<void> initialize(
      {required FireBaseBackgroundHandler onBackgroundMessage,
      required OnNotificationResponse onNotificationResponse,
      required OnNotificationTokenUpdate onNotificationTokenUpdate,
      String? androidNotificationIconNativePath}) async {
    if (!kIsWeb) {
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

      // Isolate.current.addErrorListener(RawReceivePort((pair) async {
      //   if (!FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled) {
      //     return;
      //   }
      //   final List<dynamic> errorAndStacktrace = pair;
      //   await FirebaseCrashlytics.instance.recordError(
      //     errorAndStacktrace.first,
      //     errorAndStacktrace.last,
      //   );
      // }).sendPort);

      await firebaseNotificationManager.initializeFireBaseMessaging(
          androidNotificationIconNativePath: androidNotificationIconNativePath,
          onNotificationResponse: onNotificationResponse,
          onNotificationTokenUpdate: onNotificationTokenUpdate,
          onBackgroundMessage: _firebaseMessagingBackgroundHandler);
    }

    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    if(kIsWeb){
      await update((state) {
        return state.copyWith(
            version: packageInfo.version,
            needsUpdate: false) as T;
      });
      return;
    }
    final updateAvailability = await AppVersionUpdate.checkForUpdates();

    await update((state) {
      return state.copyWith(
          version: packageInfo.version,
          needsUpdate: updateAvailability.canUpdate??false) as T;
    });
  }

  Future<void> prepareAppAfterLogin();

  Locale get currentLocale => Locale(Platform.localeName.substring(0, 2));

  void onLogout() {
    authManager?.logout();
  }
}
