/*import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_repository.dart';
import 'login.dart';
import 'homePage.dart';
import '../services/config.dart'; // تأكدي من أن المسار يؤدي إلى المجلد الصحيح
import 'AppTheme.dart';
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
      appBar: AppBar(title: const Text("Sign Up"), backgroundColor: Theme.of(context).colorScheme.secondary),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),


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
}*/
/*
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_repository.dart';
import 'login.dart';
import '../services/config.dart';
import 'AppTheme.dart';

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
  File? avatarFile;
  bool passwordVisible = true;
  bool confirmPasswordVisible = true;
  bool isLoading = false;

  final _formKey = GlobalKey<FormState>();
  final ApiRepository apiRepository = ApiRepository();
  final ImagePicker _picker = ImagePicker();

  // متغيرات قوة كلمة المرور
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
        Get.snackbar(
            'Error',
            'Please upload an ID image',
            backgroundColor: Get.theme.colorScheme.error, // توحيد اللون
            colorText: Get.theme.colorScheme.onError
        );
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
          Get.snackbar('Success', response['message'], backgroundColor: Colors.green, colorText: Colors.white);
          Get.offAll(() => const LoginPage());
        } else {
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign Up"),
        backgroundColor: colorScheme.primary, // فيروزي
        foregroundColor: colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),

              // صورة البروفايل
              GestureDetector(
                onTap: () async {
                  final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
                  if (image != null) setState(() => avatarFile = File(image.path));
                },
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: colorScheme.primary.withOpacity(0.1),
                  backgroundImage: avatarFile != null ? FileImage(avatarFile!) : null,
                  child: avatarFile == null
                      ? Icon(Icons.add_a_photo, size: 35, color: colorScheme.primary)
                      : null,
                ),
              ),
              const SizedBox(height: 10),
              Text("Profile Picture (Optional)", style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontSize: 12)),

              const SizedBox(height: 20),
              _buildTextField(firstNameController, "First Name", Icons.person, colorScheme),
              const SizedBox(height: 20),
              _buildTextField(lastNameController, "Last Name", Icons.person_outline, colorScheme),
              const SizedBox(height: 20),

              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                    labelText: "Phone Number",
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone, color: colorScheme.primary)
                ),
                validator: (v) => (v == null || v.length != 10) ? "Must be 10 digits" : null,
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _dobController,
                readOnly: true,
                onTap: () => _selectDate(context),
                decoration: InputDecoration(
                    labelText: 'Date of Birth',
                    prefixIcon: Icon(Icons.calendar_today, color: colorScheme.primary),
                    border: const OutlineInputBorder()
                ),
                validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 20),

              DropdownButtonFormField(
                value: role,
                decoration: InputDecoration(
                    labelText: 'Role',
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(Icons.work, color: colorScheme.primary)
                ),
                items: const [
                  DropdownMenuItem(value: 'tenant', child: Text('Tenant')),
                  DropdownMenuItem(value: 'owner', child: Text('Owner')),
                ],
                onChanged: (v) => setState(() => role = v.toString()),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: passwordController,
                obscureText: passwordVisible,
                onChanged: checkPassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock, color: colorScheme.primary),
                  suffixIcon: IconButton(
                    icon: Icon(passwordVisible ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => passwordVisible = !passwordVisible),
                  ),
                ),
                validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
              ),
              const SizedBox(height: 15),

              if (passwordController.text.isNotEmpty) ...[
                LinearProgressIndicator(
                    value: passwordStrength,
                    backgroundColor: colorScheme.surface,
                    color: passwordStrength < 0.8 ? Colors.orange : Colors.green
                ),
                const SizedBox(height: 20),
              ],

              TextFormField(
                controller: confirmPasswordController,
                obscureText: confirmPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline, color: colorScheme.primary),
                  suffixIcon: IconButton(
                    icon: Icon(confirmPasswordVisible ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => confirmPasswordVisible = !confirmPasswordVisible),
                  ),
                ),
                validator: (v) => v != passwordController.text ? "Passwords do not match" : null,
              ),
              const SizedBox(height: 20),

              // زر رفع الهوية
              MaterialButton(
                onPressed: isLoading ? null : pickIdImage,
                color: idImage == null ? colorScheme.secondary : Colors.green, // عنابي أو أخضر
                textColor: Colors.white,
                minWidth: double.infinity,
                height: 50,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(idImage == null ? Icons.upload : Icons.check),
                    const SizedBox(width: 10),
                    Text(idImage == null ? 'Upload ID Image' : 'ID Image Selected'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // زر التسجيل النهائي
              MaterialButton(
                onPressed: isLoading ? null : validateForm,
                color: colorScheme.primary, // فيروزي
                textColor: Colors.white,
                minWidth: double.infinity,
                height: 55,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

  // تعديل دالة الحقول لتقبل الألوان
  Widget _buildTextField(TextEditingController controller, String label, IconData icon, ColorScheme colorScheme) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: Icon(icon, color: colorScheme.primary)
      ),
      validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
    );
  }
}*/
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
          Get.snackbar('Success', response['message'], backgroundColor: Colors.green, colorText: Colors.white);
          Get.offAll(() => const LoginPage());
        } else {
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