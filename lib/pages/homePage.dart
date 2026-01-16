/*import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_repository.dart';
import 'ApartmentListPage.dart';
import 'AddPropertyPage.dart';
import 'UserInfoPage.dart';
import 'login.dart';
/*
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
}*/
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // --- المنطق (Logic) كما هو بدون تغيير ---
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
    if (user != null && mounted) {
      setState(() {
        userRole = (user['role'] ?? 'tenant').toString().toLowerCase();
      });
    }
  }

  Future<void> _logout() async {
    final colorScheme = Get.theme.colorScheme;
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Logout', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to logout from your account?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await _apiRepository.logout();
              Get.offAll(() => const LoginPage());
            },
            style: ElevatedButton.styleFrom(backgroundColor: colorScheme.error, foregroundColor: Colors.white),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      // تجعل المحتوى يمتد خلف الـ AppBar ليعطي شكلاً متصلاً
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent, // شفاف لدمجه مع الهيدر
        title: _showSearch
            ? Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(15),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Search properties...',
              border: InputBorder.none,
              hintStyle: TextStyle(color: Colors.white70),
            ),
            style: const TextStyle(color: Colors.white),
          ),
        )
            : const Text("House Rent", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
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
      drawer: _buildModernDrawer(colorScheme),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildCreativeHeader(colorScheme),
            _buildCategoriesSection(colorScheme),
            _buildFeaturedSection(colorScheme),
          ],
        ),
      ),
    );
  }

  // --- تصميم الـ Header الجديد مع انحناء وألوان متدرجة ---
  Widget _buildCreativeHeader(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(25, 110, 25, 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Find Your\nPerfect Home",
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, height: 1.2),
          ),
          const SizedBox(height: 25),
          Row(
            children: [
              Expanded(
                child: _actionButton(
                  onPressed: () => Get.to(() => const ApartmentListPage()),
                  icon: Icons.explore_rounded,
                  label: "Explore",
                  isPrimary: false, // الزر الأبيض
                ),
              ),
              if (userRole == 'owner') ...[
                const SizedBox(width: 12),
                Expanded(
                  child: _actionButton(
                    onPressed: () => Get.to(() => const AddPropertyPage()),
                    icon: Icons.add_circle_outline,
                    label: "List Property",
                    isPrimary: true, // الزر العنابي (secondary)
                  ),
                ),
              ],
            ],
          )
        ],
      ),
    );
  }

  // أزرار مخصصة (Custom Buttons)
  Widget _actionButton({required VoidCallback onPressed, required IconData icon, required String label, required bool isPrimary}) {
    final colorScheme = Theme.of(context).colorScheme;
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? colorScheme.secondary : Colors.white,
        foregroundColor: isPrimary ? Colors.black87 : colorScheme.primary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  // --- قسم التصنيفات (إضافة جمالية لملء الفراغ) ---
  Widget _buildCategoriesSection(ColorScheme colorScheme) {
    final categories = [
      {'name': 'All', 'icon': Icons.apps},
      {'name': 'Villas', 'icon': Icons.villa_rounded},
      {'name': 'Flats', 'icon': Icons.apartment_rounded},
      {'name': 'Studios', 'icon': Icons.home_rounded},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 25),
            child: Text("Quick Categories", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: categories.length,
              itemBuilder: (context, index) => Container(
                width: 85,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(categories[index]['icon'] as IconData, color: colorScheme.primary),
                    const SizedBox(height: 5),
                    Text(categories[index]['name'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedSection(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Featured Properties", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              TextButton(onPressed: () => Get.to(() => const ApartmentListPage()), child: Text("See All", style: TextStyle(color: colorScheme.primary))),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 280,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildPropertyCard("Modern Flat", "Dubai, Marina", "\$1,500", Icons.apartment, colorScheme),
                _buildPropertyCard("Cozy Villa", "Riyadh, Al-Olaya", "\$3,000", Icons.villa, colorScheme),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildPropertyCard(String title, String loc, String price, IconData icon, ColorScheme colorScheme) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 20, bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(10),
              width: double.infinity,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, size: 50, color: colorScheme.primary),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: colorScheme.secondary),
                    const SizedBox(width: 4),
                    Text(loc, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 10),
                Text(price, style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
          )
        ],
      ),
    );
  }

  // --- تصميم الـ Drawer المحدث ---
  Widget _buildModernDrawer(ColorScheme colorScheme) {
    return Drawer(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.horizontal(right: Radius.circular(30))),
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: colorScheme.primary),
            child: FutureBuilder<Map<String, dynamic>?>(
              future: _apiRepository.getStoredUser(),
              builder: (context, snapshot) {
                final user = snapshot.data;
                return Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 35, color: Color(0xFF009688)),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${user?['first_name'] ?? 'Guest'}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(user?['phone'] ?? '', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          _drawerItem(Icons.home_outlined, 'Home', () => Get.back(), colorScheme),
          _drawerItem(Icons.search_outlined, 'Browse', () => Get.to(() => const ApartmentListPage()), colorScheme),
          if (userRole == 'owner')
            _drawerItem(Icons.add_box_outlined, 'Add Property', () => Get.to(() => const AddPropertyPage()), colorScheme),
          _drawerItem(Icons.person_outline, 'Profile', () => Get.to(() => const UserInfoPage()), colorScheme),
          const Spacer(),
          const Divider(),
          _drawerItem(Icons.logout_rounded, 'Logout', () => _logout(), colorScheme, isError: true),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap, ColorScheme colorScheme, {bool isError = false}) {
    return ListTile(
      leading: Icon(icon, color: isError ? colorScheme.error : colorScheme.primary),
      title: Text(title, style: TextStyle(color: isError ? colorScheme.error : Colors.black87, fontWeight: FontWeight.w500)),
      onTap: onTap,
    );
  }
}
*/
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
  // --- Logic (Kept exactly as yours) ---
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
    if (user != null && mounted) {
      setState(() {
        userRole = (user['role'] ?? 'tenant').toString().toLowerCase();
      });
    }
  }

  Future<void> _logout() async {
    final colorScheme = Get.theme.colorScheme;
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Logout', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await _apiRepository.logout();
              Get.offAll(() => const LoginPage());
            },
            style: ElevatedButton.styleFrom(backgroundColor: colorScheme.error, foregroundColor: Colors.white),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: _showSearch
            ? Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(15),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Search properties...',
              border: InputBorder.none,
              hintStyle: TextStyle(color: Colors.white70),
            ),
            style: const TextStyle(color: Colors.white),
          ),
        )
            : const Text("DALAL", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
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
      drawer: _buildModernDrawer(colorScheme),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildCreativeHeader(colorScheme),
            _buildCategoriesSection(colorScheme), // The New Professional Section
            _buildFeaturedSection(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildCreativeHeader(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(25, 110, 25, 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Find Your\nDream Space",
            style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white, height: 1.1),
          ),
          const SizedBox(height: 25),
          Row(
            children: [
              Expanded(
                child: _actionButton(
                  onPressed: () => Get.to(() => const ApartmentListPage()),
                  icon: Icons.explore_rounded,
                  label: "Explore",
                  isPrimary: false,
                ),
              ),
              if (userRole == 'owner') ...[
                const SizedBox(width: 12),
                Expanded(
                  child: _actionButton(
                    onPressed: () => Get.to(() => const AddPropertyPage()),
                    icon: Icons.add_business_outlined,
                    label: "List Property",
                    isPrimary: true,
                  ),
                ),
              ],
            ],
          )
        ],
      ),
    );
  }

  Widget _actionButton({required VoidCallback onPressed, required IconData icon, required String label, required bool isPrimary}) {
    final colorScheme = Theme.of(context).colorScheme;
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? colorScheme.secondary : Colors.white,
        foregroundColor: isPrimary ? Colors.black87 : colorScheme.primary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  // --- New Category Section with Real Images ---
  Widget _buildCategoriesSection(ColorScheme colorScheme) {
    final categories = [
      {'name': 'Apartments', 'image': 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?q=80&w=200'},
      {'name': 'Villas', 'image': 'https://images.unsplash.com/photo-1580587767526-d367a8ddbb4d?q=80&w=200'},
      {'name': 'Studios', 'image': 'https://images.unsplash.com/photo-1536376074432-ad717fa57911?q=80&w=200'},
      {'name': 'Offices', 'image': 'https://images.unsplash.com/photo-1497366216548-37526070297c?q=80&w=200'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 25),
            child: Text("Browse by Category", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: categories.length,
              itemBuilder: (context, index) => Container(
                width: 90,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: colorScheme.secondary.withOpacity(0.4), width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 32,
                        backgroundImage: NetworkImage(categories[index]['image']!),
                        backgroundColor: Colors.grey[200],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      categories[index]['name']!,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedSection(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Top Picks", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              TextButton(onPressed: () => Get.to(() => const ApartmentListPage()), child: Text("View All", style: TextStyle(color: colorScheme.primary))),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 280,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildPropertyCard("Modern Flat", "Marina, Dubai", "1,500 SYP", Icons.apartment, colorScheme),
                _buildPropertyCard("Luxury Villa", "Al-Rawda, Damascus", "5,000 SYP", Icons.villa, colorScheme),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildPropertyCard(String title, String loc, String price, IconData icon, ColorScheme colorScheme) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 20, bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(10),
              width: double.infinity,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, size: 50, color: colorScheme.primary),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 14, color: colorScheme.secondary),
                    const SizedBox(width: 4),
                    Text(loc, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 10),
                Text(price, style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 17)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildModernDrawer(ColorScheme colorScheme) {
    return Drawer(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.horizontal(right: Radius.circular(30))),
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: colorScheme.primary),
            child: FutureBuilder<Map<String, dynamic>?>(
              future: _apiRepository.getStoredUser(),
              builder: (context, snapshot) {
                final user = snapshot.data;
                return Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 35, color: Color(0xFF009688)),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${user?['first_name'] ?? 'Guest'}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(user?['phone'] ?? '', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          _drawerItem(Icons.home_outlined, 'Home', () => Get.back(), colorScheme),
          _drawerItem(Icons.search_outlined, 'Browse', () => Get.to(() => const ApartmentListPage()), colorScheme),
          if (userRole == 'owner')
            _drawerItem(Icons.add_box_outlined, 'Add Property', () => Get.to(() => const AddPropertyPage()), colorScheme),
          _drawerItem(Icons.person_outline, 'My Profile', () => Get.to(() => const UserInfoPage()), colorScheme),
          const Spacer(),
          const Divider(),
          _drawerItem(Icons.logout_rounded, 'Logout', () => _logout(), colorScheme, isError: true),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap, ColorScheme colorScheme, {bool isError = false}) {
    return ListTile(
      leading: Icon(icon, color: isError ? colorScheme.error : colorScheme.primary),
      title: Text(title, style: TextStyle(color: isError ? colorScheme.error : Colors.black87, fontWeight: FontWeight.w500)),
      onTap: onTap,
    );
  }
}