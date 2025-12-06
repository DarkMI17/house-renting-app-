import 'dart:io';
import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4f6fa),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 10,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Create Account',
                    style:
                    TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Secure registration',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),

                  input('Phone', phone, Icons.phone),
                  input('First Name', firstName, Icons.person),
                  input('Last Name', lastName, Icons.person_outline),
                  input('Date of Birth', dob, Icons.calendar_today),

                  DropdownButtonFormField(
                    value: role,
                    decoration: inputDecoration('Role', Icons.work),
                    items: const [
                      DropdownMenuItem(value: 'tenant', child: Text('Tenant')),
                      DropdownMenuItem(value: 'owner', child: Text('Owner')),
                    ],
                    onChanged: (v) => setState(() => role = v!),
                  ),

                  const SizedBox(height: 15),

                  TextField(
                    controller: password,
                    obscureText: true,
                    onChanged: checkPassword,
                    decoration: inputDecoration('Password', Icons.lock),
                  ),

                  const SizedBox(height: 10),

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

                  const SizedBox(height: 15),

                  ElevatedButton.icon(
                    onPressed: pickImage,
                    icon: const Icon(Icons.image),
                    label: Text(
                        idImage == null ? 'Upload ID Image' : 'Image Selected ✅'),
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    onPressed: () {},
                    child: const Text('Register',
                        style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
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

  InputDecoration inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget input(String label, TextEditingController c, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        decoration: inputDecoration(label, icon),
      ),
    );
  }
}
