import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_repository.dart';
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
  String userRole = 'tenant';
  final TextEditingController _searchController = TextEditingController();
  final ApiRepository _apiRepository = ApiRepository();
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final user = await _apiRepository.getStoredUser();

    // هذا السطر سيطبع لكِ في الـ Debug Console شكل البيانات بالضبط
    print("User Data from storage: $user");

    if (user != null && mounted) {
      setState(() {
        // قمنا بتحويل النص إلى أحرف صغيرة (toLowerCase) لنتجنب مشاكل Owner و owner
        userRole = (user['role'] ?? 'tenant').toString().toLowerCase();
      });
      print("Detected Role: $userRole");
    }
  }

  Future<void> _logout() async {
    final colorScheme = Get.theme.colorScheme;
    Get.dialog(
      AlertDialog(
        title: Text('Logout', style: TextStyle(color: colorScheme.primary)),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Get.back();
              await _apiRepository.logout();
              Get.offAll(() => const LoginPage());
            },
            child: Text('Logout', style: TextStyle(color: colorScheme.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
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
            : const Text("House Rent", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
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
        backgroundColor: Get.theme.scaffoldBackgroundColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: colorScheme.primary),
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
                      child: Icon(Icons.person, size: 40, color: Color(0xFF009688)),
                    ),
                    const SizedBox(height: 10),
                    FutureBuilder<Map<String, dynamic>?>(
                      future: _apiRepository.getStoredUser(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Text("Loading...", style: TextStyle(color: Colors.white));
                        }
                        final user = snapshot.data;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${user?['first_name'] ?? 'Guest'} ${user?['last_name'] ?? ''}',
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              user?['phone'] ?? '',
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            _buildDrawerItem(Icons.home, 'Home', () => Get.back(), colorScheme),
            _buildDrawerItem(Icons.search, 'Browse', () => Get.to(() => ApartmentListPage()), colorScheme),

            // --- التعديل الأول: إخفاء من الـ Drawer ---
            if (userRole == 'owner')
              _buildDrawerItem(Icons.add_box, 'Add Property', () => Get.to(() => AddPropertyPage()), colorScheme),

            const Divider(),
            _buildDrawerItem(Icons.logout, 'Logout', () => _logout(), colorScheme, isError: true),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(colorScheme),
            _buildFeaturedSection(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap, ColorScheme colorScheme, {bool isError = false}) {
    return ListTile(
      leading: Icon(icon, color: isError ? colorScheme.error : colorScheme.primary),
      title: Text(title, style: TextStyle(color: isError ? colorScheme.error : Colors.black87)),
      onTap: onTap,
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Text("Find Your Perfect Home",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colorScheme.primary)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Get.to(() => const ApartmentListPage()),
                  icon: const Icon(Icons.explore),
                  label: const Text("Explore"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),


              if (userRole == 'owner') ...[
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Get.to(() => const AddPropertyPage()),
                    icon: const Icon(Icons.add),
                    label: const Text("List Property"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.primary,
                      side: BorderSide(color: colorScheme.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ],
          )
        ],
      ),
    );
  }

  Widget _buildFeaturedSection(ColorScheme colorScheme) {
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
                _buildPropertyCard("Modern Flat", "Dubai", "\$1,500", Icons.apartment, colorScheme),
                _buildPropertyCard("Cozy Villa", "Riyadh", "\$3,000", Icons.villa, colorScheme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyCard(String title, String loc, String price, IconData icon, ColorScheme colorScheme) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 15, bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: colorScheme.primary.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.05),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Icon(icon, size: 60, color: colorScheme.primary),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 12, color: colorScheme.secondary),
                    const SizedBox(width: 4),
                    Text(loc, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(price, style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
          )
        ],
      ),
    );
  }
}