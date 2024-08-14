import 'dart:convert' show jsonDecode, jsonEncode;

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

typedef OnNotificationResponse = void Function(NotificationResponse)?;
typedef FireBaseBackgroundHandler = Future<void> Function(
    RemoteMessage message);

abstract class BaseFirebaseNotificationManager {
  FirebaseMessaging? messaging;

  /// Create a [AndroidNotificationChannel] for heads up notifications
  AndroidNotificationChannel channel;

  /// Initialize the [FlutterLocalNotificationsPlugin] package.
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  void onNotification(RemoteMessage notification);
  void onRemoteMessage(RemoteMessage message);
  Future<void> onMessagingToken(String token);

  bool _isInitialized = false;

  BaseFirebaseNotificationManager({required this.channel});

  Future<void> initializeFireBaseMessaging(
      {required FireBaseBackgroundHandler onBackgroundMessage,
      required OnNotificationResponse onNotificationResponse,
      String? androidNotificationIconNativePath}) async {
    if (_isInitialized) return;
    _isInitialized = true;
    debugPrint("initializeFireBaseMessaging");
    FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);
    channel == channel;
    // _channel = const AndroidNotificationChannel(
    //     'notification_channel', // id
    //     'Mesaj Bildirimleri', // title
    //     description: 'Mesaj Bildirimlerinin alındığı kanal', // description
    //     importance: Importance.max,
    //     playSound: true,
    //     // sound: RawResourceAndroidNotificationSound('horn'),
    //     enableVibration: true,
    //     showBadge: true);

    var initializationSettingsAndroid = AndroidInitializationSettings(
        androidNotificationIconNativePath ?? '@mipmap/ic_launcher');
    var initializationSettingsIOS = const DarwinInitializationSettings();
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: onNotificationResponse,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await _setupInteractedMessage();

    _foregroundMessagingConfigure();
    await checkMessagingToken();
  }

  void _foregroundMessagingConfigure() async {
    messaging ??= FirebaseMessaging.instance;

    await messaging!.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: false,
      sound: false,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: $message');

      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      onNotification(message);
      if (notification != null) {
        await messaging!.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

        try {
          var flutterLocalNotificationsPlugin =
              FlutterLocalNotificationsPlugin();

          BigPictureStyleInformation? bigPictureStyleInformation;

          if (android?.imageUrl != null) {
            var response = await Dio().getUri(Uri.parse(android!.imageUrl!));
            debugPrint(response.data);
            // bigPictureStyleInformation = BigPictureStyleInformation(
            //   ByteArrayAndroidBitmap.fromBase64String(response.data),
            //   largeIcon: ByteArrayAndroidBitmap.fromBase64String(response.data),
            // );

            bigPictureStyleInformation = BigPictureStyleInformation(
              FilePathAndroidBitmap(android.imageUrl!),
              contentTitle: notification.title,
              summaryText: notification.body,
            );
          }
          await flutterLocalNotificationsPlugin.show(
              0, //notification.hashCode,
              notification.title,
              notification.body,
              NotificationDetails(
                  android: android != null
                      ? AndroidNotificationDetails(channel.id, channel.name,
                          channelDescription: channel.description,
                          styleInformation: bigPictureStyleInformation,
                          // largeIcon: android.imageUrl != null
                          //     ? DrawableResourceAndroidBitmap('splash')
                          //     : null,
                          // sound: RawResourceAndroidNotificationSound('notification'),
                          icon: android.smallIcon)
                      : null,
                  iOS: const DarwinNotificationDetails(
                    presentAlert: true,
                    presentSound: true,
                    presentBadge: true,
                    //sound: "notification.caf"
                  )),
              payload: jsonEncode(message.data));
        } catch (e) {
          debugPrint(e.toString());
        }

        await messaging!.setForegroundNotificationPresentationOptions(
          alert: false,
          badge: false,
          sound: false,
        );
      }
    });
  }

  Future<bool> requestNotificationPermission() async {
    final result = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    debugPrint("Notification permission granted, $result");

    return result ?? false;
    // FirebaseMessaging messaging = FirebaseMessaging.instance;

    // NotificationSettings settings = await messaging.requestPermission(
    //   alert: true,
    //   announcement: false,
    //   badge: true,
    //   carPlay: false,
    //   criticalAlert: false,
    //   provisional: false,
    //   sound: true,
    // );

    // if (settings.authorizationStatus == AuthorizationStatus.authorized ||
    //     settings.authorizationStatus == AuthorizationStatus.provisional)
    //   _getDeviceFCMToken();
  }

  Future<void> _setupInteractedMessage() async {
    messaging ??= FirebaseMessaging.instance;
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage = await messaging!.getInitialMessage();

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (initialMessage != null) {
      onRemoteMessage(initialMessage);
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(onRemoteMessage);
  }

  void _onSelectNotification(String? payload) {
    if (payload == null) return;

    try {
      var data = jsonDecode(payload);
      onRemoteMessage(RemoteMessage.fromMap({"data": data}));
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> checkMessagingToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();

      if (token != null) {
        await onMessagingToken(token);
      }
      debugPrint("Firebase messaging token $token");
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
