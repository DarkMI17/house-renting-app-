import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Add this import
import 'signup.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController phoneControll = TextEditingController();
  final TextEditingController passwordControll = TextEditingController();
  bool visible = true;
  final _formKey = GlobalKey<FormState>();

  void validateForm() {
    if (_formKey.currentState!.validate()) {
      // Form is valid, perform login action
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login Successful!')),
      );
      // You can add your login logic here
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
                    controller: phoneControll,
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
                      if (phoneControll.text.isEmpty) {
                        return "this field is empty";
                      }
                      if (phoneControll.text.length != 10) {
                        return "Phone number must be 10 digits";
                      }
                      // Optional: Add phone format validation
                      if (!phoneControll.text.startsWith("09")) {
                        return "Phone number should start with 09";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 40),

                  // Password field
                  TextFormField(
                    controller: passwordControll,
                    decoration: InputDecoration(
                      labelText: "password",
                      hintText: "enter password",
                      border: const OutlineInputBorder(),
                      prefix: Container(
                        margin: const EdgeInsets.only(right: 10),
                        child: const Icon(Icons.password),
                      ),
                      suffix: IconButton(
                        onPressed: () {
                          setState(() {
                            visible = !visible;
                          });
                        },
                        icon: Icon(
                          visible ? Icons.visibility_off : Icons.visibility,
                        ),
                      ),
                    ),
                    obscureText: visible,
                    validator: (value) {
                      if (passwordControll.text.isEmpty) {
                        return "the password field is empty";
                      }
                      if (passwordControll.text.length < 3) {
                        return "the password must be at least three characters long";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Login button
                  MaterialButton(
                    onPressed: validateForm,
                    color: Colors.teal,
                    textColor: Colors.white,
                    minWidth: double.infinity,
                    height: 50,
                    child: const Text("Login"),
                  ),

                  const SizedBox(height: 20),

                  // Sign up option - CHANGED TO GET.NAVIGATION
                  TextButton(
                    onPressed: () {
                      // Changed from Navigator.push to Get.to
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
