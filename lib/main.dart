/*
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'pages/AppTheme.dart';
import 'pages/homePage.dart';
import 'services/services/storage_service.dart';

// This function must be a top-level function (outside any class)
// to handle background messages.
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  // 1. Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. Set up Background Handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 4. Initialize Local Storage
  await StorageService.init();

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // 5. Request Permissions (Crucial for iOS and Android 13+)
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');

  // 6. Get FCM Token
  String? token = await messaging.getToken();
  print("---------- COPY THIS TOKEN ----------");
  print(token);
  print("-------------------------------------");

  // 7. Foreground Message Listener
  // This triggers when the app is open and in use.
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('✅ New message received in Foreground!');

    if (message.notification != null) {
      print('Notification Title: ${message.notification!.title}');
      print('Notification Body: ${message.notification!.body}');

      // Show a GetX Snackbar to confirm it's working
      Get.snackbar(
        message.notification!.title ?? "New Notification",
        message.notification!.body ?? "",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.teal,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
        icon: const Icon(Icons.notifications_active, color: Colors.white),
      );
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tootie Rent App',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}*/
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // 1. إضافة الاستيراد
import 'firebase_options.dart';
import 'pages/AppTheme.dart';
import 'pages/homePage.dart';
import 'services/services/storage_service.dart';

// 2. تعريف قناة الإشعارات للأندرويد (خارج أي كلاس)
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  description: 'This channel is used for important notifications.', // description
  importance: Importance.max,
  playSound: true,
);

// 3. تعريف المحرك الرئيسي للإشعارات المحلية
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 4. إعداد القناة داخل الأندرويد لضمان ظهور الإشعار المنبثق والصوت
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // 5. إعداد إعدادات التهيئة للإشعارات المحلية
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  await StorageService.init();

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(alert: true, badge: true, sound: true);

  String? token = await messaging.getToken();
  print("FCM Token: $token");

  // 6. تعديل مستمع الرسائل في الـ Foreground
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      // إظهار الإشعار في القائمة العلوية يدوياً
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            icon: android.smallIcon,
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
          ),
        ),
      );

      // اختيارياً: إبقاء الـ Snackbar إذا كنتِ تحبينه
      Get.snackbar(notification.title!, notification.body!,
          snackPosition: SnackPosition.TOP, backgroundColor: Colors.teal, colorText: Colors.white);
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tootie Rent App',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}