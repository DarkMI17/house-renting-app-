import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:house_rent_app_002/ApartmentListPage.dart';
import 'appartment.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;

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
                  // Handle search
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
                  const Text(
                    'John Doe',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'john.doe@example.com',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.teal),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.search, color: Colors.teal),
              title: const Text('Browse Properties'),
              onTap: () {
                // Navigate to browse page
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite_border, color: Colors.teal),
              title: const Text('Favorites'),
              onTap: () {
                // Navigate to favorites page
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.message, color: Colors.teal),
              title: const Text('Messages'),
              onTap: () {
                // Navigate to messages page
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.list_alt, color: Colors.teal),
              title: const Text('My Listings'),
              onTap: () {
                // Navigate to listings page
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.teal),
              title: const Text('Settings'),
              onTap: () {
                // Navigate to settings page
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.help, color: Colors.teal),
              title: const Text('Help & Support'),
              onTap: () {
                // Navigate to help page
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.teal),
              title: const Text('Logout'),
              onTap: () {
                // Handle logout
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section with Description
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
                             Get.to(ApartmentListPage());
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

            // Quick Stats
            // Padding(
            //   padding: const EdgeInsets.all(20),
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       const Text(
            //         "Why Choose Us?",
            //         style: TextStyle(
            //           fontSize: 22,
            //           fontWeight: FontWeight.bold,
            //           color: Colors.teal,
            //         ),
            //       ),
            //       const SizedBox(height: 15),
            //       Row(
            //         mainAxisAlignment: MainAxisAlignment.spaceAround,
            //         children: [
            //           _buildStatItem(Icons.home, "5,000+", "Properties"),
            //           _buildStatItem(Icons.location_city, "50+", "Cities"),
            //           _buildStatItem(Icons.map, "10+", "States"),
            //         ],
            //       ),
            //       const SizedBox(height: 10),
            //       Row(
            //         mainAxisAlignment: MainAxisAlignment.spaceAround,
            //         children: [
            //           _buildStatItem(Icons.verified_user, "Verified", "Listings"),
            //           _buildStatItem(Icons.support_agent, "24/7", "Support"),
            //           _buildStatItem(Icons.star, "4.8", "Rating"),
            //         ],
            //       ),
            //     ],
            //   ),
            // ),

            // Featured Properties
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

            // Browse by State
            // Padding(
            //   padding: const EdgeInsets.all(20),
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       const Text(
            //         "Browse by State",
            //         style: TextStyle(
            //           fontSize: 22,
            //           fontWeight: FontWeight.bold,
            //           color: Colors.teal,
            //         ),
            //       ),
            //       const SizedBox(height: 15),
            //       GridView.count(
            //         shrinkWrap: true,
            //         physics: const NeverScrollableScrollPhysics(),
            //         crossAxisCount: 2,
            //         childAspectRatio: 2.5,
            //         crossAxisSpacing: 10,
            //         mainAxisSpacing: 10,
            //         children: [
            //           _buildStateCard("California", Icons.beach_access),
            //           _buildStateCard("Texas", Icons.landscape),
            //           _buildStateCard("New York", Icons.apartment),
            //           _buildStateCard("Florida", Icons.beach_access),
            //           _buildStateCard("Washington", Icons.cloud),
            //           _buildStateCard("Illinois", Icons.location_city),
            //         ],
            //       ),
            //     ],
            //   ),
            // ),

            // Bottom CTA
            // Container(
            //   margin: const EdgeInsets.all(20),
            //   padding: const EdgeInsets.all(25),
            //   decoration: BoxDecoration(
            //     color: Colors.teal,
            //     borderRadius: BorderRadius.circular(15),
            //   ),
            //   child: Column(
            //     children: [
            //       const Text(
            //         "Ready to Find Your Dream Home?",
            //         style: TextStyle(
            //           fontSize: 22,
            //           fontWeight: FontWeight.bold,
            //           color: Colors.white,
            //           // textAlign: TextAlign.center,
            //         ),
            //       ),
            //       const SizedBox(height: 10),
            //       const Text(
            //         "Join thousands of satisfied renters who found their perfect home through our platform.",
            //         style: TextStyle(
            //           color: Colors.white70,
            //           fontSize: 16,
            //           // textAlign: TextAlign.center,
            //         ),
            //       ),
            //       const SizedBox(height: 20),
            //       MaterialButton(
            //         onPressed: () {
            //           // Start searching
            //         },
            //         color: Colors.white,
            //         textColor: Colors.teal,
            //         minWidth: double.infinity,
            //         height: 50,
            //         child: const Text(
            //           "Start Searching Now",
            //           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.teal, size: 30),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
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
                        // View property details
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

  Widget _buildStateCard(String state, IconData icon) {
    return Card(
      color: Colors.teal.withOpacity(0.05),
      child: ListTile(
        leading: Icon(icon, color: Colors.teal),
        title: Text(
          state,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.teal),
        onTap: () {
          // Navigate to state properties
        },
      ),
    );
  }
}
