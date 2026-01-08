/*import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:house_rent_app_002/pages/ApartmentListPage.dart';
import 'package:house_rent_app_002/services/services/storage_service.dart';
import 'services/network_service.dart';
import 'pages/login.dart';
import 'pages/homePage.dart';
import 'pages/ApartmentDetailsPage.dart';
import 'pages/AppTheme.dart';
/*
void main() async {
  // 1. ضمان تهيئة أدوات فلاتر قبل أي كود برمجي
  WidgetsFlutterBinding.ensureInitialized();

  // 2. تشغيل المخزن (SharedPreferences)
  await StorageService.init();

  // 3. تشغيل محرك الشبكة (Dio)
  NetworkService().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // نستخدم GetMaterialApp بدلاً من MaterialApp لدعم نظام التوكن والـ GetX
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'House Renting App',
      theme: ThemeData(primarySwatch: Colors.blue),
      // فحص التوكن: إذا موجود نذهب للرئيسية، إذا لا نذهب للوجن
      home: StorageService.getToken() != null
          ? const HomePage()
          : const LoginPage(),
    );
  }
}*/

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      // التعديل هنا: استدعاء كلاس AppTheme بدلاً من ThemeData القديم
      theme: AppTheme.light(),

      // إذا كنتِ تريدين دعم الوضع الداكن مستقبلاً
      darkTheme: AppTheme.dark(),

      // لإجبار التطبيق على البدء بالثيم الفاتح (الفيروزي والبيج)
      themeMode: ThemeMode.light,

      home: const HomePage(),
    );
  }
}
*/
/*
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'pages/AppTheme.dart';
import 'pages/homePage.dart';
import 'services/services/storage_service.dart';

void main() async {
  // 1. ضمان تهيئة أدوات فلاتر
  WidgetsFlutterBinding.ensureInitialized();

  // 2. تشغيل الفايربيز باستخدام الإعدادات المولدة
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. تهيئة مخزن البيانات المحلي (SharedPreferences)
  await StorageService.init();

  // 4. إعدادات الإشعارات وجلب التوكن
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // طلب الإذن (ضروري لإظهار التنبيه للمستخدم)
  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // استخراج الـ Token وطباعته في الـ Console
  String? token = await messaging.getToken();
  print("---------- COPY THIS TOKEN ----------");
  print(token);
  print("-------------------------------------");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tootie Rent App',

      // استخدام الثيمات التي صممناها (الفيروزي والعنابي)
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),

      // نغيرها لـ system ليتمكن المستخدم من التبديل يدوياً من الإعدادات
      themeMode: ThemeMode.system,

      home: const HomePage(),
    );
  }
}*/
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
}