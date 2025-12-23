import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'services/network_service.dart';
import 'pages/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    print('🚀 Starting House Rent App...');

    // Initialize network service
    print('🔌 Initializing NetworkService...');
    NetworkService().initialize();

    return GetMaterialApp(
      title: 'House Rent App',
      theme: ThemeData(
        primaryColor: Colors.teal,
        appBarTheme: const AppBarTheme(
          color: Colors.teal,
        ),
      ),
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}