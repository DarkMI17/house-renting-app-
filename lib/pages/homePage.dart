import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_repository..dart'; // تأكدي من عدد النقاط في المسار
import 'ApartmentListPage.dart';
import 'AddPropertyPage.dart';
import 'UserInfoPage.dart';
import 'login.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final ApiRepository _apiRepository = ApiRepository();
  bool _showSearch = false;

  // --- دالة تسجيل الخروج المصححة ---
  Future<void> _logout() async {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Get.back(); // إغلاق الحوار

              // تنفيذ تسجيل الخروج (مسح التوكن والبيانات)
              await _apiRepository.logout();

              // العودة لصفحة تسجيل الدخول ومسح كل الصفحات السابقة
              Get.offAll(() => const LoginPage());
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _showSearch
            ? TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search properties...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: const TextStyle(color: Colors.white),
        )
            : const Text("House Rent"),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            onPressed: () => setState(() {
              _showSearch = !_showSearch;
              if (!_showSearch) _searchController.clear();
            }),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.teal),
              child: InkWell(
                onTap: () {
                  Get.back();
                  Get.to(() => const UserInfoPage());
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 40, color: Colors.teal),
                    ),
                    const SizedBox(height: 10),
                    // --- تحديث الـ FutureBuilder ليناسب الـ Repository الجديد ---
                    FutureBuilder<Map<String, dynamic>?>(
                      future: _apiRepository.getStoredUser(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Text("Loading...", style: TextStyle(color: Colors.white));
                        }

                        final user = snapshot.data;
                        if (user != null) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${user['first_name'] ?? 'User'} ${user['last_name'] ?? ''}',
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                user['phone'] ?? '',
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          );
                        }
                        return const Text("Guest User", style: TextStyle(color: Colors.white));
                      },
                    ),
                  ],
                ),
              ),
            ),
            _buildDrawerItem(Icons.home, 'Home', () => Get.back()),
            _buildDrawerItem(Icons.search, 'Browse', () => Get.to(() => const ApartmentListPage())),
            _buildDrawerItem(Icons.add_box, 'Add Property', () => Get.to(() => const AddPropertyPage())),
            const Divider(),
            _buildDrawerItem(Icons.logout, 'Logout', () => _logout()),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // الهيدر الترحيبي
            _buildHeader(),
            // العقارات المميزة
            _buildFeaturedSection(),
          ],
        ),
      ),
    );
  }

  // --- Widgets مساعدة لتنظيف الـ Build ---
  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.teal),
      title: Text(title),
      onTap: onTap,
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.teal.withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        children: [
          const Text("Find Your Perfect Home", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Get.to(() => const ApartmentListPage()),
                  icon: const Icon(Icons.explore),
                  label: const Text("Explore"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Get.to(() => const AddPropertyPage()),
                  icon: const Icon(Icons.add),
                  label: const Text("List Property"),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.teal),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildFeaturedSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Featured Properties", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          SizedBox(
            height: 280,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildPropertyCard("Modern Flat", "Dubai", "\$1,500", Icons.apartment),
                _buildPropertyCard("Cozy Villa", "Riyadh", "\$3,000", Icons.villa),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyCard(String title, String loc, String price, IconData icon) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Column(
        children: [
          Expanded(child: Icon(icon, size: 50, color: Colors.teal)),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(loc, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 5),
                Text(price, style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
      ),
    );
  }
}