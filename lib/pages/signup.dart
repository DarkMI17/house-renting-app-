import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_repository..dart'; // تأكدي من صحة المسار
import 'login.dart';
import 'homePage.dart';
import '../services/config.dart'; // تأكدي من أن المسار يؤدي إلى المجلد الصحيح
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  String role = 'tenant';
  File? idImage;
  File? avatarFile; // متغير الصورة الشخصية
  bool passwordVisible = true;
  bool confirmPasswordVisible = true;
  bool isLoading = false;

  final _formKey = GlobalKey<FormState>();
  final ApiRepository apiRepository = ApiRepository();
  final ImagePicker _picker = ImagePicker();

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

  double get passwordStrength {
    int validCount = 0;
    if (hasLower) validCount++;
    if (hasUpper) validCount++;
    if (hasNumber) validCount++;
    if (hasSpecial) validCount++;
    if (has8Chars) validCount++;
    return validCount / 5;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2005),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> pickIdImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (image != null) setState(() => idImage = File(image.path));
  }

  Future<void> validateForm() async {
    if (_formKey.currentState!.validate()) {
      if (idImage == null) {
        Get.snackbar('Error', 'Please upload an ID image', backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      setState(() => isLoading = true);

      try {
        final response = await apiRepository.register(
          phone: phoneController.text.trim(),
          password: passwordController.text.trim(),
          passwordConfirmation: confirmPasswordController.text.trim(),
          first_name: firstNameController.text.trim(),
          last_name: lastNameController.text.trim(),
          dob: _dobController.text.trim(),
          role: role,
          idImage: idImage!,
          avatar: avatarFile, // تم تمرير الصورة الشخصية هنا
        );

        if (response['success'] == true) {
          Get.snackbar('Account Created',response['message'], backgroundColor: Colors.green, colorText: Colors.white);
          Get.offAll(() => const LoginPage());
        } else {
          Get.snackbar('Error', response['message'] ?? 'Registration failed', backgroundColor: Colors.red, colorText: Colors.white);
        }
      } catch (e) {
        Get.snackbar('Error', 'An error occurred', backgroundColor: Colors.red, colorText: Colors.white);
      } finally {
        if (mounted) setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up"), backgroundColor: Colors.teal),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),

              // ودجت اختيار الصورة الشخصية
              GestureDetector(
                onTap: () async {
                  final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
                  if (image != null) setState(() => avatarFile = File(image.path));
                },
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.teal.withOpacity(0.1),
                  backgroundImage: avatarFile != null ? FileImage(avatarFile!) : null,
                  child: avatarFile == null
                      ? const Icon(Icons.add_a_photo, size: 35, color: Colors.teal)
                      : null,
                ),
              ),
              const SizedBox(height: 10),
              const Text("Profile Picture (Optional)", style: TextStyle(color: Colors.grey, fontSize: 12)),

              const SizedBox(height: 20),
              _buildTextField(firstNameController, "First Name", Icons.person),
              const SizedBox(height: 20),
              _buildTextField(lastNameController, "Last Name", Icons.person_outline),
              const SizedBox(height: 20),

              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: "Phone Number", border: OutlineInputBorder(), prefixIcon: Icon(Icons.phone)),
                validator: (v) => (v == null || v.length != 10) ? "Must be 10 digits" : null,
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _dobController,
                readOnly: true,
                onTap: () => _selectDate(context),
                decoration: const InputDecoration(labelText: 'Date of Birth', prefixIcon: Icon(Icons.calendar_today, color: Colors.teal), border: OutlineInputBorder()),
                validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 20),

              DropdownButtonFormField(
                initialValue: role,
                decoration: const InputDecoration(labelText: 'Role', border: OutlineInputBorder(), prefixIcon: Icon(Icons.work)),
                items: const [
                  DropdownMenuItem(value: 'tenant', child: Text('Tenant')),
                  DropdownMenuItem(value: 'owner', child: Text('Owner')),
                ],
                onChanged: (v) => setState(() => role = v!),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: passwordController,
                obscureText: passwordVisible,
                onChanged: checkPassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(passwordVisible ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => passwordVisible = !passwordVisible),
                  ),
                ),
                validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
              ),
              const SizedBox(height: 15),

              if (passwordController.text.isNotEmpty) ...[
                LinearProgressIndicator(value: passwordStrength, backgroundColor: Colors.grey.shade300, color: passwordStrength < 0.8 ? Colors.orange : Colors.green),
                const SizedBox(height: 20),
              ],

              TextFormField(
                controller: confirmPasswordController,
                obscureText: confirmPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(confirmPasswordVisible ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => confirmPasswordVisible = !confirmPasswordVisible),
                  ),
                ),
                validator: (v) => v != passwordController.text ? "Passwords do not match" : null,
              ),
              const SizedBox(height: 20),

              MaterialButton(
                onPressed: isLoading ? null : pickIdImage,
                color: idImage == null ? Colors.teal : Colors.green,
                textColor: Colors.white,
                minWidth: double.infinity,
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(idImage == null ? Icons.upload : Icons.check),
                    const SizedBox(width: 10),
                    Text(idImage == null ? 'Upload ID Image' : 'ID Image Selected '),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              MaterialButton(
                onPressed: isLoading ? null : validateForm,
                color: Colors.teal,
                textColor: Colors.white,
                minWidth: double.infinity,
                height: 55,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('REGISTER', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), prefixIcon: Icon(icon)),
      validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
    );
  }
}