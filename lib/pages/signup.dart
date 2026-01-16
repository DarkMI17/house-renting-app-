
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_repository.dart';
import 'login.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // ... (نفس المتغيرات والكونترولرز بدون تغيير)
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  String role = 'tenant';
  File? idImage;
  File? avatarFile;
  bool passwordVisible = true;
  bool confirmPasswordVisible = true;
  bool isLoading = false;

  final _formKey = GlobalKey<FormState>();
  final ApiRepository apiRepository = ApiRepository();
  final ImagePicker _picker = ImagePicker();

  bool hasLower = false, hasUpper = false, hasNumber = false, hasSpecial = false, has8Chars = false;

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
        Get.snackbar('Error', 'Please upload an ID image',
            backgroundColor: Get.theme.colorScheme.error,
            colorText: Get.theme.colorScheme.onError);
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
          avatar: avatarFile,
        );

        if (response['success'] == true) {
          // عرض رسالة واضحة للمستخدم
          Get.snackbar(
            'Registration Successful',
            'Your account is created. Please wait for admin approval before you can login.',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 4), // وقت كافٍ للقراءة
          );

          // تأخير بسيط للانتقال لصفحة تسجيل الدخول لكي يرى الرسالة
          Future.delayed(const Duration(seconds: 2), () {
            Get.offAll(() => const LoginPage());
          });
        }else {
          Get.snackbar('Error', response['message'] ?? 'Registration failed', backgroundColor: Get.theme.colorScheme.error, colorText: Colors.white);
        }
      } catch (e) {
        Get.snackbar('Error', 'An error occurred', backgroundColor: Get.theme.colorScheme.error, colorText: Colors.white);
      } finally {
        if (mounted) setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // جلب الألوان من الثيم
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Account"),
        centerTitle: true,
        backgroundColor: colorScheme.primary, // فيروزي
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // صورة البروفايل بتنسيق دائري فيروزي
              GestureDetector(
                onTap: () async {
                  final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
                  if (image != null) setState(() => avatarFile = File(image.path));
                },
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 55,
                      backgroundColor: colorScheme.primary.withOpacity(0.1),
                      backgroundImage: avatarFile != null ? FileImage(avatarFile!) : null,
                      child: avatarFile == null
                          ? Icon(Icons.person, size: 55, color: colorScheme.primary)
                          : null,
                    ),
                    PositionRectangle(colorScheme: colorScheme),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              _buildTextField(firstNameController, "First Name", Icons.person, colorScheme),
              const SizedBox(height: 15),
              _buildTextField(lastNameController, "Last Name", Icons.person_outline, colorScheme),
              const SizedBox(height: 15),

              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                    labelText: "Phone Number",
                    prefixIcon: Icon(Icons.phone, color: colorScheme.primary)
                ),
                validator: (v) => (v == null || v.length != 10) ? "Must be 10 digits" : null,
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _dobController,
                readOnly: true,
                onTap: () => _selectDate(context),
                decoration: InputDecoration(
                  labelText: 'Date of Birth',
                  prefixIcon: Icon(Icons.calendar_today, color: colorScheme.primary),
                ),
                validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 15),

              DropdownButtonFormField(
                value: role,
                decoration: InputDecoration(
                    labelText: 'Role',
                    prefixIcon: Icon(Icons.supervised_user_circle, color: colorScheme.primary)
                ),
                items: const [
                  DropdownMenuItem(value: 'tenant', child: Text('Tenant')),
                  DropdownMenuItem(value: 'owner', child: Text('Owner')),
                ],
                onChanged: (v) => setState(() => role = v.toString()),
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: passwordController,
                obscureText: passwordVisible,
                onChanged: checkPassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock, color: colorScheme.primary),
                  suffixIcon: IconButton(
                    icon: Icon(passwordVisible ? Icons.visibility_off : Icons.visibility, color: colorScheme.primary),
                    onPressed: () => setState(() => passwordVisible = !passwordVisible),
                  ),
                ),
                validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
              ),

              if (passwordController.text.isNotEmpty) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: LinearProgressIndicator(
                      value: passwordStrength,
                      minHeight: 6,
                      backgroundColor: Colors.grey[200],
                      color: passwordStrength < 0.6 ? Colors.red : (passwordStrength < 0.9 ? Colors.orange : Colors.green)
                  ),
                ),
              ],
              const SizedBox(height: 15),

              TextFormField(
                controller: confirmPasswordController,
                obscureText: confirmPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: Icon(Icons.lock_reset, color: colorScheme.primary),
                  suffixIcon: IconButton(
                    icon: Icon(confirmPasswordVisible ? Icons.visibility_off : Icons.visibility, color: colorScheme.primary),
                    onPressed: () => setState(() => confirmPasswordVisible = !confirmPasswordVisible),
                  ),
                ),
                validator: (v) => v != passwordController.text ? "Passwords do not match" : null,
              ),
              const SizedBox(height: 25),

              // زر رفع الهوية باللون العنابي (Secondary)
              MaterialButton(
                onPressed: isLoading ? null : pickIdImage,
                color: idImage == null ? colorScheme.secondary : Colors.green,
                textColor: Colors.white,
                minWidth: double.infinity,
                height: 50,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(idImage == null ? Icons.assignment_ind : Icons.check_circle),
                    const SizedBox(width: 10),
                    Text(idImage == null ? 'Upload ID Image' : 'ID Selected Successfully'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // زر التسجيل النهائي باللون الفيروزي (Primary)
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoading ? null : validateForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('REGISTER', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, ColorScheme colorScheme) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: colorScheme.primary)
      ),
      validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
    );
  }
}

// ويدجت صغيرة لإضافة علامة + على صورة البروفايل
class PositionRectangle extends StatelessWidget {
  const PositionRectangle({super.key, required this.colorScheme});
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: colorScheme.primary, shape: BoxShape.circle),
        child: const Icon(Icons.add, color: Colors.white, size: 20),
      ),
    );
  }
}