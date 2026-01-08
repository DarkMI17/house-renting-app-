import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_repository.dart';
import 'AddPropertyPage.dart';
import 'login.dart';
import '../services/config.dart';
import 'MyPropertiesPage.dart';
import 'BookingRequestsPage.dart';
import 'MyBookingsPage.dart';
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

  //
  Future<void> _loadUserData() async {
    if (!mounted) return;

    setState(() => isLoading = true);

    try {
      // 1. Fetch fresh data from Server directly to get full profile (names, avatar)
      final response = await apiRepository.getProfile();

      if (mounted) {
        setState(() {
          // Handle different API response structures (wrapped in 'user' or direct)
          userData = response.containsKey('user') ? response['user'] : response;
        });
      }

      // 2. Update local storage with this fresh full data for future offline use
      if (userData != null) {
        await apiRepository.updateStoredUser(userData!);
      }

    } catch (e) {
      debugPrint("Profile Loading Error: $e");

      // 3. Fallback: If server fails, try to load whatever we have in local storage
      final storedData = await apiRepository.getStoredUser();

      if (mounted) {
        setState(() {
          userData = storedData;
        });

        if (userData == null) {
          Get.snackbar(
            'Sync Error',
            'Failed to load profile from server and no local data found.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Theme.of(context).colorScheme.error,
            colorText: Theme.of(context).colorScheme.onError,
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _logout() async {
    final bool? confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to exit?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => isLoggingOut = true);
    try {
      await apiRepository.logout();
      Get.offAll(() => const LoginPage());
      Get.snackbar('Success', 'Logged out successfully');
    } catch (e) {
      Get.snackbar('Error', 'Logout failed');
    } finally {
      if (mounted) setState(() => isLoggingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        backgroundColor: Theme.of(context).colorScheme.primary, // بيجيب لون Tootie تلقائياً
        foregroundColor: Theme.of(context).colorScheme.onPrimary, // بيخلي النص باللون البيج (الخلفية العكسية)
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Get.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              Get.changeThemeMode(Get.isDarkMode ? ThemeMode.light : ThemeMode.dark);
            },
          ),
        ],



      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userData == null
          ? _buildEmptyState()
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 25),
            _buildInfoCard(),
            const SizedBox(height: 20),
            _buildManagementSection(),
            const SizedBox(height: 20),
            _buildAppSettingsSection(),

            const SizedBox(height: 30),
            _buildLogoutButton(),
          ],
        ),
      ),

    );
  }

  Widget _buildProfileHeader() {
    String? avatarName = userData?['avatar'];

    // 1. استخراج الرابط الأساسي من ApiConfig وحذف كلمة '/api' من نهايته
    // النتيجة ستكون: http://127.0.0.1:8000 (أو الـ IP الخاص بكِ)
    final String baseServerUrl = ApiConfig.baseUrl.replaceAll('/api', '');

    String fullImageUrl = "";
    if (avatarName != null && avatarName.isNotEmpty) {
      if (avatarName.contains('avatars/')) {
        // الروابط ستصبح مثلاً: http://192.168.1.5:8000/storage/avatars/user.jpg
        fullImageUrl = "$baseServerUrl/storage/$avatarName";
      } else {
        fullImageUrl = "$baseServerUrl/uploads/avatars/$avatarName";
      }
    }

    print("DEBUG: Final Image URL -> $fullImageUrl");

    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).colorScheme.secondary, // درجتك 009688
            backgroundImage: (avatarName != null && avatarName != 'default_avatar.png' && fullImageUrl.isNotEmpty)
                ? NetworkImage(fullImageUrl)
                : null,
            child: (avatarName == null || avatarName == 'default_avatar.png')
                ? const Icon(Icons.person, size: 60, color: Colors.white)
                : null,
          ),
          const SizedBox(height: 15),
          Text(
            '${userData?['first_name'] ?? 'User'} ${userData?['last_name'] ?? ''}',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            userData?['role']?.toString().toUpperCase() ?? 'TENANT',
            style: const TextStyle(color: Colors.grey, letterSpacing: 1.2),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildInfoRow(Icons.phone, 'Phone', userData?['phone'] ?? 'N/A'),
            const Divider(),
            _buildInfoRow(Icons.cake, 'Birth Date', userData?['dob'] ?? 'N/A'),
            const Divider(),
            _buildInfoRow(Icons.verified_user, 'Status', userData?['status'] ?? 'Active'),
          ],
        ),
      ),
    );
  }
/*
  Widget _buildManagementSection() {

    bool isOwner = userData?['role']?.toString().toLowerCase() == 'owner';

    if (!isOwner) return const SizedBox.shrink(); // إخفاء القسم للمستأجرين

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Text(
              "Property Management",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)
          ),
        ),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Column(
            children: [
              // الخيار الأول: عرض العقارات
              ListTile(
                leading: const Icon(Icons.home_work, color: Colors.teal),
                title: const Text('My Properties'),
                subtitle: const Text('Edit or delete your listings'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Get.to(() => const MyPropertiesPage());
                },
              ),
              const Divider(height: 1),

              // الخيار الثاني: إضافة عقار جديد
              ListTile(
                leading: const Icon(Icons.add_box, color: Colors.teal),
                title: const Text('Add New Property'),
                trailing: const Icon(Icons.add, size: 20),
                onTap: () {
                  Get.to(() => const AddPropertyPage());
                },
              ),
              const Divider(height: 1),


              ListTile(
                leading: const Icon(Icons.notifications_active, color: Colors.teal),
                title: const Text('Booking Requests'),
                subtitle: const Text('Manage who wants to rent your units'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // تأكدي من استيراد ملف صفحة الطلبات في الأعلى
                  Get.to(() => const BookingRequestsPage());
                },
              ),
            ],
          ),
        ),
      ],
    );
  }*/
  Widget _buildManagementSection() {
    // التحقق من الدور
    String role = userData?['role']?.toString().toLowerCase() ?? 'tenant';
    bool isOwner = role == 'owner';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
              isOwner ? "Property Management" : "My Bookings & Activity",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color:Theme.of(context).colorScheme.secondary)
          ),
        ),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Column(
            children: [
              if (isOwner) ...[
                // --- خيارات المالك فقط ---
                ListTile(
                  leading: Icon(Icons.home_work, color: Theme.of(context).colorScheme.secondary),
                  title: const Text('My Properties'),
                  subtitle: const Text('Manage your listings'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => Get.to(() => const MyPropertiesPage()),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.add_box, color: Theme.of(context).colorScheme.secondary),
                  title: const Text('Add New Property'),
                  trailing: const Icon(Icons.add, size: 20),
                  onTap: () => Get.to(() => const AddPropertyPage()),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.notifications_active, color: Theme.of(context).colorScheme.secondary),
                  title: const Text('Booking Requests'),
                  subtitle: const Text('Manage rental requests'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => Get.to(() => const BookingRequestsPage()),
                ),
              ] else ...[
                // --- خيارات المستأجر فقط (Tenant) ---
                ListTile(
                  leading: Icon(Icons.bookmark_added,color: Theme.of(context).colorScheme.secondary),
                  title: const Text('My Bookings'),
                  subtitle: const Text('View and manage your reservations'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // سنقوم بإنشاء هذه الصفحة الآن
                    Get.to(() => const MyBookingsPage());
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.favorite, color: Colors.pink),
                  title: const Text('Saved Properties'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // خيار إضافي للمستأجر مستقبلاً
                  },
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isLoggingOut ? null : _logout,
        icon: const Icon(Icons.logout),
        label: Text(isLoggingOut ? 'Logging out...' : 'LOGOUT'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.error,
          foregroundColor: Theme.of(context).colorScheme.onError,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: colorScheme.secondary, size: 20),
          const SizedBox(width: 15),

          // 1. النص الثابت (مثل Phone:)
          Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),

          const SizedBox(width: 10), // مسافة بسيطة بين العنوان والقيمة

          // 2. الحل السحري هنا: نضع القيمة داخل Expanded
          // لكي لا تخرج عن حدود الشاشة وتسبب الـ overflow
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end, // يجعل النص يذهب لليمين
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis, // إذا كان النص طويلاً جداً يضع نقاط (...) بدل أن يكسر التصميم
              maxLines: 1, // يحافظ على جمال السطر الواحد
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.grey),
          const SizedBox(height: 10),
          const Text("Profile data not available"),
          TextButton(onPressed: _loadUserData, child: const Text("Retry")),
        ],
      ),
    );
  }
  // --- ضيف هذه الدالة في نهاية الكلاس ---
  Widget _buildAppSettingsSection() {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            "App Settings",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.secondary
            ),
          ),
        ),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            leading: Icon(
                Get.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: colorScheme.secondary
            ),
            title: const Text('Dark Mode Appearance'),
            trailing: Switch(
              value: Get.isDarkMode,
              activeColor: colorScheme.primary,
              onChanged: (val) {
                Get.changeThemeMode(Get.isDarkMode ? ThemeMode.light : ThemeMode.dark);
              },
            ),
          ),
        ),
      ],
    );
  }
}