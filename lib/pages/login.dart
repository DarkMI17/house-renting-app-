import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:house_rent_app_002/pages/signup.dart';
import '../services/api_repository..dart';
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

      final response = await apiRepository.login(
        phoneController.text.trim(),
        passwordController.text.trim(),
      );

      setState(() => isLoading = false);

      if (response['success'] == true) {
        // Navigate to home page
        Get.offAll(() => HomePage()); // Replace with your home page
        Get.snackbar(
          'Success',
          response['message'] ?? 'Login successful',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        // Show error message
        String errorMessage = response['message'] ?? 'Login failed';

        // Show validation errors if any
        if (response['errors'] != null) {
          final errors = response['errors'];
          if (errors is Map) {
            errorMessage = '';
            errors.forEach((key, value) {
              if (value is List) {
                errorMessage += '${value.join(', ')}\n';
              } else {
                errorMessage += '$value\n';
              }
            });
          }
        }

        Get.snackbar(
          'Error',
          errorMessage,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  const Text(
                    "Login",
                    style: TextStyle(
                      fontSize: 35,
                      color: Colors.teal,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Phone number field
                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: "Phone Number",
                      hintText: "enter phone number",
                      border: const OutlineInputBorder(),
                      prefix: Container(
                        margin: const EdgeInsets.only(right: 10),
                        child: const Icon(Icons.phone),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Phone number is required";
                      }
                      if (value.length != 10) {
                        return "Phone number must be 10 digits";
                      }
                      if (!value.startsWith("09")) {
                        return "Phone number should start with 09";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 40),

                  // Password field
                  TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: "Password",
                      hintText: "enter password",
                      border: const OutlineInputBorder(),
                      prefix: Container(
                        margin: const EdgeInsets.only(right: 10),
                        child: const Icon(Icons.password),
                      ),
                      suffix: IconButton(
                        onPressed: () {
                          setState(() {
                            passwordVisible = !passwordVisible;
                          });
                        },
                        icon: Icon(
                          passwordVisible ? Icons.visibility_off : Icons.visibility,
                        ),
                      ),
                    ),
                    obscureText: passwordVisible,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Password is required";
                      }
                      if (value.length < 8) {
                        return "Password must be at least 8 characters";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Login button
                  MaterialButton(
                    onPressed: isLoading ? null : validateForm,
                    color: Colors.teal,
                    textColor: Colors.white,
                    minWidth: double.infinity,
                    height: 50,
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Login"),
                  ),

                  const SizedBox(height: 20),

                  // Sign up option
                  TextButton(
                    onPressed: () {
                      Get.to(() => const SignUpPage());
                    },
                    child: const Text(
                      "Don't have an account? Sign Up",
                      style: TextStyle(color: Colors.teal),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}