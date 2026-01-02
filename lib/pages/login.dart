import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:house_rent_app_002/pages/signup.dart';
import '../services/api_repository.dart';
import 'homePage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool passwordVisible = true;
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  final ApiRepository apiRepository = ApiRepository();


  Future<void> validateForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      try {
        final response = await apiRepository.login(
          phoneController.text.trim(),
          passwordController.text.trim(),
        );

        // للتشخيص: اطبحي الاستجابة في الكونسول
        print("Response from Server: $response");

        if (response['success'] == true) {
          print("Login Success! Moving to Home...");
          Get.offAll(() => const HomePage());
        } else {
          // إذا فشل السيرفر، اعرضي الرسالة القادمة منه
          Get.snackbar('Login Failed', response['message'] ?? 'Invalid credentials');
        }
      } catch (e) {
        print("Detailed Error: $e");
        Get.snackbar('Error', 'Connection failed: $e', backgroundColor: Colors.red, colorText: Colors.white);
      } finally {
        if (mounted) setState(() => isLoading = false);
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.teal, elevation: 0),
      body: Center( // أضفنا Center لضبط العناصر في منتصف الشاشة
        child: SingleChildScrollView( // لتجنب مشاكل ظهور الكيبورد على الشاشات الصغيرة
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline, size: 80, color: Colors.teal),
                const SizedBox(height: 20),
                const Text(
                  "Welcome Back",
                  style: TextStyle(fontSize: 28, color: Colors.teal, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),

                // حقل رقم الهاتف
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: "Phone Number",
                    hintText: "09xxxxxxxx",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Phone number is required";
                    if (value.length != 10) return "Must be 10 digits";
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // حقل كلمة المرور
                TextFormField(
                  controller: passwordController,
                  obscureText: passwordVisible,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => passwordVisible = !passwordVisible),
                      icon: Icon(passwordVisible ? Icons.visibility_off : Icons.visibility),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Password is required";
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                // زر تسجيل الدخول
                MaterialButton(
                  onPressed: isLoading ? null : validateForm,
                  color: Colors.teal,
                  textColor: Colors.white,
                  minWidth: double.infinity,
                  height: 55,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("LOGIN", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),

                const SizedBox(height: 20),

                TextButton(
                  onPressed: () => Get.to(() => const SignUpPage()),
                  child: const Text("Don't have an account? Sign Up", style: TextStyle(color: Colors.teal)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}