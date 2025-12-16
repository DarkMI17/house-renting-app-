import 'package:flutter/material.dart';
import 'login.dart';
import 'signup.dart';
import 'homePage.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(), // Start with LoginPage
    );
  }
}
