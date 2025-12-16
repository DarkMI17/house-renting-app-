import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Add GetX import
import 'package:house_rent_app_002/login.dart';
import 'package:image_picker/image_picker.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final phone = TextEditingController();
  final password = TextEditingController();
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final dob = TextEditingController();

  String role = 'tenant';
  File? idImage;

  bool hasLower = false;
  bool hasUpper = false;
  bool hasNumber = false;
  bool hasSpecial = false;
  bool has8Chars = false;
  bool passwordVisible = true;

  final _formKey = GlobalKey<FormState>();

  void checkPassword(String value) {
    setState(() {
      hasLower = RegExp(r'[a-z]').hasMatch(value);
      hasUpper = RegExp(r'[A-Z]').hasMatch(value);
      hasNumber = RegExp(r'[0-9]').hasMatch(value);
      hasSpecial = RegExp(r'[@$!%*#?&]').hasMatch(value);
      has8Chars = value.length >= 8;
    });
  }

  double get strength =>
      [hasLower, hasUpper, hasNumber, hasSpecial, has8Chars]
          .where((e) => e)
          .length /
          5;

  Future<void> pickImage() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (img != null) setState(() => idImage = File(img.path));
  }

  void validateForm() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration Successful!')),
      );
      // After successful registration, you can navigate to login or home
      // Get.offAll(() => const LoginPage()); // Uncomment if you want to go to login
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign Up"), // Added title
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    "Sign Up",
                    style: TextStyle(
                      fontSize: 35,
                      color: Colors.teal,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Secure registration",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 30),

                  // Input fields
                  input('First Name', firstName, Icons.person),
                  input('Last Name', lastName, Icons.person_outline),
                  input('Phone', phone, Icons.phone),
                  input('Date of Birth', dob, Icons.calendar_today),

                  // Role dropdown
                  DropdownButtonFormField(
                    value: role,
                    decoration: InputDecoration(
                      labelText: 'Role',
                      border: const OutlineInputBorder(),
                      prefix: Container(
                        margin: const EdgeInsets.only(right: 10),
                        child: const Icon(Icons.work),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'tenant', child: Text('Tenant')),
                      DropdownMenuItem(value: 'owner', child: Text('Owner')),
                    ],
                    onChanged: (v) => setState(() => role = v!),
                  ),

                  const SizedBox(height: 20),

                  // Password field with visibility toggle
                  TextFormField(
                    controller: password,
                    obscureText: passwordVisible,
                    onChanged: checkPassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
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
                  ),

                  const SizedBox(height: 15),

                  // Password strength
                  if (password.text.isNotEmpty) ...[
                    LinearProgressIndicator(
                      value: strength,
                      minHeight: 6,
                      backgroundColor: Colors.grey.shade300,
                      color: strength < 0.4
                          ? Colors.red
                          : strength < 0.7
                              ? Colors.orange
                              : Colors.green,
                    ),
                    const SizedBox(height: 10),
                    rule('Lowercase letter', hasLower),
                    rule('Uppercase letter', hasUpper),
                    rule('Number', hasNumber),
                    rule('Special character', hasSpecial),
                    rule('At least 8 characters', has8Chars),
                    const SizedBox(height: 20),
                  ],

                  // ID Image upload button
                  MaterialButton(
                    onPressed: pickImage,
                    color: Colors.teal,
                    textColor: Colors.white,
                    minWidth: double.infinity,
                    height: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(idImage == null ? Icons.upload : Icons.check),
                        const SizedBox(width: 10),
                        Text(idImage == null ? 'Upload ID Image' : 'Image Selected'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Register button
                  MaterialButton(
                    onPressed: validateForm,
                    color: Colors.teal,
                    textColor: Colors.white,
                    minWidth: double.infinity,
                    height: 50,
                    child: const Text('Register',
                        style: TextStyle(fontSize: 16)),
                  ),
                  
                  // Already have an account - CHANGED TO GET.NAVIGATION
                  TextButton(
                    onPressed: () {
                      // Changed from Navigator.push to Get.to
                      Get.to(() => const LoginPage());
                    },
                    child: const Text(
                      "Already have an account, Sign in",
                      style: TextStyle(color: Colors.teal),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget rule(String text, bool valid) {
    return Row(
      children: [
        Icon(valid ? Icons.check_circle : Icons.close,
            size: 18, color: valid ? Colors.green : Colors.red),
        const SizedBox(width: 6),
        Text(text),
      ],
    );
  }

  Widget input(String label, TextEditingController c, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefix: Container(
            margin: const EdgeInsets.only(right: 10),
            child: Icon(icon),
          ),
        ),
        // Add basic validation
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }
}
