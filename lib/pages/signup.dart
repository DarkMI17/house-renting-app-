import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_repository..dart';
import 'login.dart';

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
  final TextEditingController dobController = TextEditingController();

  String role = 'tenant';
  File? idImage;
  bool passwordVisible = true;
  bool confirmPasswordVisible = true;
  bool isLoading = false;

  final _formKey = GlobalKey<FormState>();
  final ApiRepository apiRepository = ApiRepository();
  final ImagePicker _picker = ImagePicker();

  // Password validation states
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

  Future<void> pickIdImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        setState(() {
          idImage = File(image.path);
        });

        // Check file size
        final fileSize = await idImage!.length();
        if (fileSize > 4 * 1024 * 1024) {
          Get.snackbar(
            'Warning',
            'Image is too large. Max size is 4MB.',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> validateForm() async {
    if (_formKey.currentState!.validate()) {
      if (idImage == null) {
        Get.snackbar(
          'Error',
          'Please upload an ID image',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return;
      }

      // Validate password strength
      if (!(hasLower && hasUpper && hasNumber && hasSpecial && has8Chars)) {
        Get.snackbar(
          'Error',
          'Password must meet all requirements',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return;
      }

      // Check if passwords match
      if (passwordController.text != confirmPasswordController.text) {
        Get.snackbar(
          'Error',
          'Passwords do not match',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return;
      }

      setState(() => isLoading = true);

      try {
        final response = await apiRepository.register(
          phone: phoneController.text.trim(),
          password: passwordController.text.trim(),
          passwordConfirmation: confirmPasswordController.text.trim(), // Add this!
          firstName: firstNameController.text.trim(),
          lastName: lastNameController.text.trim(),
          dob: dobController.text.trim(),
          role: role,
          idImage: idImage!,
        );

        setState(() => isLoading = false);

        if (response['success'] == true) {
          Get.snackbar(
            'Success',
            'Registration successful',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );

          // Navigate to home page after short delay
          await Future.delayed(const Duration(milliseconds: 1500));
          // Get.offAll(() => HomePage()); // Uncomment when you have HomePage
        } else {
          String errorMessage = response['message'] ?? 'Registration failed';

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
            duration: const Duration(seconds: 5),
          );
        }
      } catch (e) {
        setState(() => isLoading = false);
        Get.snackbar(
          'Error',
          'An error occurred. Please try again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign Up"),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Form(
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

              // First Name
              TextFormField(
                controller: firstNameController,
                decoration: InputDecoration(
                  labelText: "First Name",
                  hintText: "Enter your first name",
                  border: const OutlineInputBorder(),
                  prefix: Container(
                    margin: const EdgeInsets.only(right: 10),
                    child: const Icon(Icons.person),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "First name is required";
                  }
                  if (value.length > 50) {
                    return "First name must be less than 50 characters";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Last Name
              TextFormField(
                controller: lastNameController,
                decoration: InputDecoration(
                  labelText: "Last Name",
                  hintText: "Enter your last name",
                  border: const OutlineInputBorder(),
                  prefix: Container(
                    margin: const EdgeInsets.only(right: 10),
                    child: const Icon(Icons.person_outline),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Last name is required";
                  }
                  if (value.length > 50) {
                    return "Last name must be less than 50 characters";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Phone
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Phone Number",
                  hintText: "0912345678",
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
              const SizedBox(height: 20),

              // Date of Birth
              TextFormField(
                controller: dobController,
                decoration: InputDecoration(
                  labelText: "Date of Birth",
                  hintText: "YYYY-MM-DD (e.g., 1990-01-01)",
                  border: const OutlineInputBorder(),
                  prefix: Container(
                    margin: const EdgeInsets.only(right: 10),
                    child: const Icon(Icons.calendar_today),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Date of birth is required";
                  }
                  // Validate date format
                  if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
                    return "Use YYYY-MM-DD format";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Role Dropdown
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
                onChanged: (value) {
                  setState(() {
                    role = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please select a role";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Password
              TextFormField(
                controller: passwordController,
                obscureText: passwordVisible,
                onChanged: checkPassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter a strong password',
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Password is required";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Password Strength Indicator
              if (passwordController.text.isNotEmpty) ...[
                LinearProgressIndicator(
                  value: passwordStrength,
                  backgroundColor: Colors.grey.shade300,
                  color: passwordStrength < 0.4
                      ? Colors.red
                      : passwordStrength < 0.8
                      ? Colors.orange
                      : Colors.green,
                ),
                const SizedBox(height: 10),
                _buildPasswordRule('Lowercase letter (a-z)', hasLower),
                _buildPasswordRule('Uppercase letter (A-Z)', hasUpper),
                _buildPasswordRule('Number (0-9)', hasNumber),
                _buildPasswordRule('Special character (@\$!%*#?&)', hasSpecial),
                _buildPasswordRule('At least 8 characters', has8Chars),
                const SizedBox(height: 20),
              ],

              // Confirm Password
              TextFormField(
                controller: confirmPasswordController,
                obscureText: confirmPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  hintText: 'Re-enter your password',
                  border: const OutlineInputBorder(),
                  prefix: Container(
                    margin: const EdgeInsets.only(right: 10),
                    child: const Icon(Icons.password),
                  ),
                  suffix: IconButton(
                    onPressed: () {
                      setState(() {
                        confirmPasswordVisible = !confirmPasswordVisible;
                      });
                    },
                    icon: Icon(
                      confirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please confirm your password";
                  }
                  if (value != passwordController.text) {
                    return "Passwords do not match";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // ID Image Upload
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
                    Text(idImage == null ? 'Upload ID Image' : 'Image Selected ✅'),
                  ],
                ),
              ),
              if (idImage != null) ...[
                const SizedBox(height: 10),
                Text(
                  'Selected: ${idImage!.path.split('/').last}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 20),

              // Register Button
              MaterialButton(
                onPressed: isLoading ? null : validateForm,
                color: Colors.teal,
                textColor: Colors.white,
                minWidth: double.infinity,
                height: 50,
                child: isLoading
                    ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text('Registering...'),
                  ],
                )
                    : const Text('Register'),
              ),
              const SizedBox(height: 10),

              // Login Link
              TextButton(
                onPressed: isLoading
                    ? null
                    : () {
                  Get.to(() => const LoginPage());
                },
                child: const Text(
                  "Already have an account? Sign in",
                  style: TextStyle(color: Colors.teal),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordRule(String text, bool isValid) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Icon(
              isValid ? Icons.check_circle : Icons.circle,
              size: 16,
              color: isValid ? Colors.green : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: isValid ? Colors.green : Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        )
     );
    }
}
