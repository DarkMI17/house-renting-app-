import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/api_repository..dart';
import 'login.dart';

class UserInfoPage extends StatefulWidget {
  const UserInfoPage({super.key});

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  final ApiRepository apiRepository = ApiRepository();
  Map<String, dynamic>? userData;
  bool isLoading = false;
  bool isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => isLoading = true);

    try {
      userData = await apiRepository.getStoredUser();

      if (userData == null) {
        final response = await apiRepository.getProfile();
        if (response['success'] == true) {
          userData = response['data']['user'];
          await apiRepository.updateStoredUser(userData!);
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load user data',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _logout() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => isLoggingOut = true);

    try {
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );

      final response = await apiRepository.logout();
      Get.back();

      if (response['success'] == true) {
        Get.snackbar(
          'Success',
          response['message'] ?? 'Logged out successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );

        await Future.delayed(const Duration(milliseconds: 1500));
        Get.offAll(() => const LoginPage());
      } else {
        Get.snackbar(
          'Error',
          response['message'] ?? 'Logout failed',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      if (Get.isDialogOpen == true) Get.back();

      Get.snackbar(
        'Error',
        'Logout failed: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => isLoggingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.teal,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Personal Information',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildInfoRow('Name', '${userData?['first_name'] ?? 'N/A'} ${userData?['last_name'] ?? ''}'),
                    const SizedBox(height: 15),

                    _buildInfoRow('Phone', userData?['phone'] ?? 'N/A'),
                    const SizedBox(height: 15),

                    _buildInfoRow('Role', userData?['role'] ?? 'N/A'),
                    const SizedBox(height: 15),

                    _buildInfoRow('Status', userData?['status'] ?? 'N/A'),
                    const SizedBox(height: 15),

                    _buildInfoRow('Date of Birth', userData?['dob'] ?? 'N/A'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'Account Actions',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 15),

            Card(
              elevation: 3,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.edit, color: Colors.teal),
                    title: const Text('Edit Profile'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {},
                  ),
                  const Divider(height: 0),
                  ListTile(
                    leading: const Icon(Icons.security, color: Colors.teal),
                    title: const Text('Change Password'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {},
                  ),
                  const Divider(height: 0),
                  ListTile(
                    leading: const Icon(Icons.history, color: Colors.teal),
                    title: const Text('Booking History'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: MaterialButton(
                onPressed: isLoggingOut ? null : _logout,
                color: Colors.red,
                textColor: Colors.white,
                height: 50,
                child: isLoggingOut
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
                    Text('Logging out...'),
                  ],
                )
                    : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 10),
                    Text('Logout'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}