import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:house_rent_app_002/services/services/storage_service.dart';
import 'services/network_service.dart';
import 'pages/login.dart';
import 'pages/homePage.dart';

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
}