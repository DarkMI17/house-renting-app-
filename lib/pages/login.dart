
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
    final colorScheme = Get.theme.colorScheme;
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      try {
        final response = await apiRepository.login(
          phoneController.text.trim(),
          passwordController.text.trim(),
        );

        // إذا نجح الدخول (الحساب مفعل)
        if (response['success'] == true) {
          Get.offAll(() => const HomePage());
        } else {
          // إذا رجع نجاح false (مثلاً كلمة مرور خطأ)
          Get.snackbar(
            'Login Failed',
            response['message'] ?? 'Check your credentials',
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
        }
      } catch (e) {
        // هنا يتم التقاط أخطاء السيرفر مثل 403 (Pending/Rejected)
        // الـ ApiRepository الخاص بك يعيد الرسالة القادمة من السيرفر في الـ catch
        Get.snackbar(
          'Account Status',
          'Your account is pending admin approval or invalid credentials.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
      } finally {
        if (mounted) setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(backgroundColor: colorScheme.primary, elevation: 0),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline, size: 80, color: colorScheme.primary),
                const SizedBox(height: 20),
                Text(
                  "Welcome Back",
                  style: TextStyle(fontSize: 28, color: colorScheme.primary, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),

                // حقل رقم الهاتف
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: "Phone Number",
                    hintText: "09xxxxxxxx",
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone, color: colorScheme.primary),
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
                    prefixIcon: Icon(Icons.lock, color: colorScheme.primary),
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
                  color: colorScheme.primary,
                  textColor: colorScheme.onPrimary,
                  minWidth: double.infinity,
                  height: 55,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: isLoading
                      ? CircularProgressIndicator(color: colorScheme.onPrimary)
                      : const Text("LOGIN", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),

                const SizedBox(height: 20),

                // التعديل هنا: جعل نص "Sign Up" يتبع لون الثيم الفيروزي
                TextButton(
                  onPressed: () => Get.to(() => const SignUpPage()),
                  child: Text(
                      "Don't have an account? Sign Up",
                      style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}