import 'package:app_version_update/app_version_update.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:k_scaffold/managers/base_auth_manager.dart';
import 'package:k_scaffold/managers/firebase_notification_manager.dart';
import 'package:k_scaffold/models/app_error.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:store_redirect/store_redirect.dart';
import 'package:universal_io/io.dart';
import 'package:url_launcher/url_launcher.dart';

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
  final String? storeUrl;

  BaseAppState({this.appName, this.version, this.needsUpdate, this.storeUrl});

  BaseAppState copyWith(
      {String? appName, String? version, bool? needsUpdate, String? storeUrl}) {
    return BaseAppState(
        appName: appName ?? this.appName,
        version: version ?? this.version,
        needsUpdate: needsUpdate ?? this.needsUpdate,
        storeUrl: storeUrl ?? this.storeUrl);
  }
}

abstract class BaseAppManager<T extends BaseAppState> extends AsyncNotifier<T> {
  /// Mağaza sürümünün geçerli bir sürüm numarası olup olmadığını kontrol eder.
  static final RegExp _versionPattern = RegExp(r'^\d+(\.\d+)*$');

  BaseFirebaseNotificationManager get firebaseNotificationManager;
  BaseAuthManager? get authManager;

  /// App Store'daki sayısal uygulama id'si. Null ise bundle id ile arama
  /// yapılır; uygulama o bundle id ile bulunamazsa sürüm kontrolü başarısız
  /// olur.
  String? get appleAppId => null;

  /// App Store aramasının yapılacağı ülke. Null verilirse paket 'us'
  /// mağazasına bakar ve yalnızca TR'de yayınlanan uygulamalar bulunamaz.
  String? get storeCountry => 'tr';

  /// Uygulamanın mağaza sayfasını açar. Sürüm kontrolünden dönen url her zaman
  /// doğru mağaza/ülke sayfasını gösterdiği için önce o denenir, olmazsa
  /// store_redirect eklentisine düşülür.
  Future<void> openStore() async {
    final storeUrl = state.value?.storeUrl;

    if (storeUrl != null && storeUrl.isNotEmpty) {
      try {
        final opened = await launchUrl(Uri.parse(storeUrl),
            mode: LaunchMode.externalApplication);
        if (opened) return;
      } catch (error) {
        debugPrint("openStore url error: $error");
      }
    }

    try {
      await StoreRedirect.redirect(iOSAppId: appleAppId);
    } catch (error) {
      // iOS tarafı app id boş olduğunda hata fırlatıyor.
      debugPrint("openStore redirect error: $error");
    }
  }

  /// Play Store sürümü mağaza sayfasının html'inden kazınarak bulunuyor ve bu
  /// zaman zaman sürüm olmayan bir sayı döndürebiliyor. Zorunlu güncellemede
  /// hatalı bir sürüm tüm kullanıcıları uygulamanın dışında bırakacağı için
  /// düz noktalı sayı olmayan ya da bir major sürümden fazla ileride görünen
  /// değerler "güncelleme yok" olarak kabul edilir.
  bool isPlausibleStoreVersion(String? storeVersion, String? localVersion) {
    if (storeVersion == null || localVersion == null) return false;
    if (!_versionPattern.hasMatch(storeVersion)) return false;

    final storeMajor = int.tryParse(storeVersion.split('.').first);
    final localMajor =
        int.tryParse(localVersion.split('+').first.split('.').first);

    if (storeMajor == null || localMajor == null) return false;

    return storeMajor <= localMajor + 1;
  }

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
    }

    await firebaseNotificationManager.initializeFireBaseMessaging(
        androidNotificationIconNativePath: androidNotificationIconNativePath,
        onNotificationResponse: onNotificationResponse,
        onNotificationTokenUpdate: onNotificationTokenUpdate,
        onBackgroundMessage: _firebaseMessagingBackgroundHandler);

    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    if (kIsWeb) {
      await update((state) {
        return state.copyWith(version: packageInfo.version, needsUpdate: false)
            as T;
      });
      return;
    }

    AppVersionUpdate.checkForUpdates(
      appleId: appleAppId,
      country: storeCountry,
    ).then((updateAvailability) {
      final needsUpdate = (updateAvailability.canUpdate ?? false) &&
          isPlausibleStoreVersion(
              updateAvailability.storeVersion, packageInfo.version);

      update((state) {
        return state.copyWith(
            version: packageInfo.version,
            storeUrl: updateAvailability.storeUrl,
            needsUpdate: needsUpdate) as T;
      });
    }).catchError((error) {
      debugPrint("AppVersionUpdate error: $error");

      update((state) {
        return state.copyWith(version: packageInfo.version, needsUpdate: false)
            as T;
      });
    });
  }

  Future<void> prepareAppAfterLogin({bool isSilentLogin = false});

  Locale get currentLocale => Locale(Platform.localeName.substring(0, 2));

  void onLogout() {
    authManager?.logout();
  }
}
