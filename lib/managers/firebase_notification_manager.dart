import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

typedef FireBaseBackgroundHandler = Future<void> Function(
    RemoteMessage message);

abstract class BaseFirebaseNotificationManager extends ChangeNotifier {
  FirebaseMessaging? messaging;

  /// Create a [AndroidNotificationChannel] for heads up notifications
  AndroidNotificationChannel channel;

  /// Initialize the [FlutterLocalNotificationsPlugin] package.
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  void onNotification(RemoteNotification notification);
  void onRemoteMessage(RemoteMessage message);
  void onMessagingToken(String token);

  BaseFirebaseNotificationManager({required this.channel});

  Future<void> initializeFireBaseMessaging(
      {required FireBaseBackgroundHandler onBackgroundMessage}) async {
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

    var initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = const IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: _onSelectNotification);

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    _setupInteractedMessage();
    _requestNotificationPermission();
    _foregroundMessagingConfigure();
    _messagingToken();
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
      debugPrint('Message data: ${message.data}');

      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null) {
        onNotification(notification);

        await messaging!.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

        try {
          var flutterLocalNotificationsPlugin =
              FlutterLocalNotificationsPlugin();
          await flutterLocalNotificationsPlugin.show(
              0, //notification.hashCode,
              notification.title,
              notification.body,
              NotificationDetails(
                  android: android != null
                      ? AndroidNotificationDetails(channel.id, channel.name,
                          channelDescription: channel.description,
                          // sound: RawResourceAndroidNotificationSound('horn'),
                          icon: android.smallIcon)
                      : null,
                  iOS: const IOSNotificationDetails(
                    presentAlert: true,
                    presentSound: true,
                    presentBadge: true,
                    //sound: "horn.caf"
                  )),
              payload: jsonEncode(message.data));
        } catch (e) {
          debugPrint(e.toString());
        }

        messaging!.setForegroundNotificationPresentationOptions(
          alert: false,
          badge: false,
          sound: false,
        );
      }
    });
  }

  Future<void> playNotificationSound() async {
    // AudioCache player = new AudioCache();
    // const alarmAudioPath = "horn.mp3";

    // player.respectSilence = true;
    // player.play(alarmAudioPath);
  }

  Future<void> _requestNotificationPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

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

  _onSelectNotification(String? payload) {
    if (payload == null) return;

    try {
      var data = jsonDecode(payload);
      onRemoteMessage(RemoteMessage.fromMap({"data": data}));
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  _messagingToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();

      if (token != null) {
        onMessagingToken(token);
      }
      debugPrint("Firebase messaging token $token");
    } catch (e) {}
  }
}
