import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:house_rent_app_002/pages/ApartmentListPage.dart';
import '../services/api_repository..dart';

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

  Future<void> _logout() async {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back(); // Close dialog
              Get.back(); // Close drawer

              // Show loading
              Get.dialog(
                const Center(
                  child: CircularProgressIndicator(),
                ),
                barrierDismissible: false,
              );

              try {
                final response = await _apiRepository.logout();

                Get.back(); // Close loading

                if (response['success'] == true) {
                  // Navigate to login page
                  Get.offAll(() => const LoginPage());
                } else {
                  Get.snackbar(
                    'Error',
                    'Logout failed: ${response['message']}',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                }
              } catch (e) {
                Get.back(); // Close loading
                Get.snackbar(
                  'Error',
                  'Logout error: $e',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
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
          decoration: InputDecoration(
            hintText: 'Search properties...',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear, color: Colors.white),
              onPressed: () {
                setState(() {
                  _showSearch = false;
                  _searchController.clear();
                });
              },
            ),
          ),
          style: const TextStyle(color: Colors.white),
          onSubmitted: (value) {
            print('Searching for: $value');
          },
        )
            : const Text("Welcome to House Rent!"),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) _searchController.clear();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Handle notifications
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.teal,
              ),
              child: InkWell(
                onTap: () {
                  Get.back(); // Close drawer
                  Get.to(() => const UserInfoPage()); // Navigate to user info
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 10),
                    FutureBuilder<Map<String, dynamic>>(
                      future: _apiRepository.getUser(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Loading...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                              SizedBox(height: 5),
                              SizedBox(
                                width: 100,
                                height: 8,
                                child: LinearProgressIndicator(
                                  backgroundColor: Colors.white54,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                            ],
                          );
                        }

                        if (snapshot.hasError) {
                          return Text(
                            'Error: ${snapshot.error}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          );
                        }

                        if (snapshot.hasData) {
                          final response = snapshot.data!;

                          if (response['success'] == true && response['user'] != null) {
                            final user = response['user'];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  user['phone']?.toString() ?? 'No phone number',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            );
                          } else {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'No user data',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Get.back(); // Close drawer
                                    Get.to(() => const LoginPage());
                                  },
                                  child: const Text(
                                    'Login',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            );
                          }
                        }

                        return const Text(
                          'No user data',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.teal),
              title: const Text('Home'),
              onTap: () {
                Get.back(); // Close drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.search, color: Colors.teal),
              title: const Text('Browse Properties'),
              onTap: () {
                Get.back(); // Close drawer
                Get.to(() => const ApartmentListPage());
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite_border, color: Colors.teal),
              title: const Text('Favorites'),
              onTap: () {
                Get.back(); // Close drawer
                // Navigate to favorites page
              },
            ),
            ListTile(
              leading: const Icon(Icons.message, color: Colors.teal),
              title: const Text('Messages'),
              onTap: () {
                Get.back(); // Close drawer
                // Navigate to messages page
              },
            ),
            ListTile(
              leading: const Icon(Icons.list_alt, color: Colors.teal),
              title: const Text('My Listings'),
              onTap: () {
                Get.back(); // Close drawer
                // Navigate to listings page
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.teal),
              title: const Text('Settings'),
              onTap: () {
                Get.back(); // Close drawer
                // Navigate to settings page
              },
            ),
            ListTile(
              leading: const Icon(Icons.help, color: Colors.teal),
              title: const Text('Help & Support'),
              onTap: () {
                Get.back(); // Close drawer
                // Navigate to help page
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.teal),
              title: const Text('Logout'),
              onTap: () {
                _logout();
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    "Find Your Perfect Home",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Discover thousands of rental properties across multiple states. "
                        "From cozy apartments to luxurious villas, we have something for everyone. "
                        "Our platform makes finding and renting your dream home easy and secure.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: MaterialButton(
                          onPressed: () {
                            Get.to(() => const ApartmentListPage());
                          },
                          color: Colors.teal,
                          textColor: Colors.white,
                          height: 50,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.explore),
                              SizedBox(width: 10),
                              Text(
                                "Explore Properties",
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      MaterialButton(
                        onPressed: () {
                          Get.to(() => const AddPropertyPage());
                        },
                        color: Colors.white,
                        textColor: Colors.teal,
                        height: 50,
                        child: const Row(
                          children: [
                            Icon(Icons.add),
                            SizedBox(width: 5),
                            Text("List Property"),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Featured Properties",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Handpicked properties just for you",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 300,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildPropertyCard(
                          "Modern Apartment",
                          "Los Angeles, CA",
                          "\$1,200/month",
                          Icons.apartment,
                        ),
                        _buildPropertyCard(
                          "Luxury Villa",
                          "Miami, FL",
                          "\$2,500/month",
                          Icons.villa,
                        ),
                        _buildPropertyCard(
                          "City Studio",
                          "New York, NY",
                          "\$1,800/month",
                          Icons.king_bed,
                        ),
                        _buildPropertyCard(
                          "Family House",
                          "Houston, TX",
                          "\$1,500/month",
                          Icons.house,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyCard(String title, String location, String price, IconData icon) {
    return Container(
      width: 250,
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Center(
              child: Icon(icon, size: 60, color: Colors.teal),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        location,
                        style: const TextStyle(color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      price,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    MaterialButton(
                      onPressed: () {
                        Get.to(() => const ApartmentListPage());
                      },
                      color: Colors.teal,
                      textColor: Colors.white,
                      minWidth: 80,
                      height: 35,
                      child: const Text("View"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}