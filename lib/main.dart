import 'dart:io';
import 'package:Glowzel/firebase_options.dart';
import 'package:Glowzel/module/authentication/repository/auth_repository.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'app/bloc/app_bloc_observer.dart';
import 'app/my_app.dart';
import 'config/environment.dart';
import 'core/initializer/init_app.dart';
import 'core/network/my_http_overrides.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('Background message received: ${message.messageId}');

  if (message.notification != null || message.data.isNotEmpty) {
    await _showNotification(message);
  }
}

Future<void> _showNotification(RemoteMessage message) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'default_channel',
    'Default',
    channelDescription: 'Default channel for notifications',
    importance: Importance.max,
    priority: Priority.high,
  );

  const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

  const NotificationDetails platformDetails =
  NotificationDetails(android: androidDetails, iOS: iosDetails);

  await flutterLocalNotificationsPlugin.show(
    message.hashCode,
    message.notification?.title ?? message.data['title'] ?? 'Notification',
    message.notification?.body ?? message.data['body'] ?? '',
    platformDetails,
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  Bloc.observer = AppBlocObserver();
  HttpOverrides.global = MyHttpOverrides();

  if (Platform.isAndroid) {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  } else if (Platform.isIOS) {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  if (Platform.isAndroid || Platform.isIOS) {
    final status = await Permission.camera.request();
    if (status != PermissionStatus.granted) {
      debugPrint("Camera permission denied");
    }
  }

  await initApp(Environment.fromEnv(AppEnv.dev));

  await _initLocalNotifications();

  _initFirebaseMessaging();

  runApp(const GlowzelApp());
}

Future<void> _initLocalNotifications() async {
  const AndroidInitializationSettings androidSettings =
  AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();
  const InitializationSettings initSettings =
  InitializationSettings(android: androidSettings, iOS: iosSettings);

  await flutterLocalNotificationsPlugin.initialize(initSettings);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint('Foreground message received: ${message.notification?.title}');
    if (message.notification != null || message.data.isNotEmpty) {
      _showNotification(message);
    }
  });
}

void _initFirebaseMessaging() {
  final authRepository = GetIt.I<AuthRepository>();

  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    debugPrint("FCM refreshed token: $newToken");
    await authRepository.updateDeviceToken(newToken);
  });
}
