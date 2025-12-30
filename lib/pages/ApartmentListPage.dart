import 'package:flutter/material.dart';

class ApartmentListPage extends StatefulWidget {
  const ApartmentListPage({super.key});

  @override
  State<ApartmentListPage> createState() => _ApartmentListPageState();
}

class _ApartmentListPageState extends State<ApartmentListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  String _selectedSort = 'Price: Low to High';
  String _selectedLocation = 'All';
  List<Map<String, dynamic>> _filteredApartments = [];

  // US Cities/States
  final List<String> locations = [
    'All',
    'New York, NY',
    'Los Angeles, CA',
    'Chicago, IL',
    'Houston, TX',
    'Phoenix, AZ',
    'Philadelphia, PA',
    'San Antonio, TX',
    'San Diego, CA',
    'Dallas, TX',
    'San Jose, CA',
    'Austin, TX',
    'Jacksonville, FL',
    'San Francisco, CA',
    'Columbus, OH',
    'Charlotte, NC',
  ];

  // Sample apartment data for US cities
  final List<Map<String, dynamic>> apartments = [
    {
      'id': 1,
      'title': 'Modern Apartment in Manhattan',
      'location': 'Midtown, Manhattan',
      'city': 'New York, NY',
      'price': 3200,
      'image': 'https://via.placeholder.com/300x200/4DB6AC/FFFFFF?text=NYC+Apt',
      'bedrooms': 2,
      'bathrooms': 1,
      'area': '850 sq ft',
      'type': 'Apartment',
      'rating': 4.5,
      'isFavorite': false,
    },
    {
      'id': 2,
      'title': 'Luxury Villa in Beverly Hills',
      'location': 'Beverly Hills',
      'city': 'Los Angeles, CA',
      'price': 8500,
      'image': 'https://via.placeholder.com/300x200/4DB6AC/FFFFFF?text=LA+Villa',
      'bedrooms': 3,
      'bathrooms': 2,
      'area': '1800 sq ft',
      'type': 'Villa',
      'rating': 4.8,
      'isFavorite': true,
    },
    {
      'id': 3,
      'title': 'City Center Apartment in Chicago',
      'location': 'Downtown Chicago',
      'city': 'Chicago, IL',
      'price': 2200,
      'image': 'https://via.placeholder.com/300x200/4DB6AC/FFFFFF?text=Chicago+Apt',
      'bedrooms': 2,
      'bathrooms': 1,
      'area': '950 sq ft',
      'type': 'Apartment',
      'rating': 4.3,
      'isFavorite': false,
    },
    {
      'id': 4,
      'title': 'Sea View Apartment in San Diego',
      'location': 'La Jolla',
      'city': 'San Diego, CA',
      'price': 2800,
      'image': 'https://via.placeholder.com/300x200/4DB6AC/FFFFFF?text=San+Diego+Apt',
      'bedrooms': 3,
      'bathrooms': 2,
      'area': '1200 sq ft',
      'type': 'Apartment',
      'rating': 4.7,
      'isFavorite': false,
    },
    {
      'id': 5,
      'title': 'Beach House in Miami',
      'location': 'Miami Beach',
      'city': 'Miami, FL',
      'price': 4500,
      'image': 'https://via.placeholder.com/300x200/4DB6AC/FFFFFF?text=Miami+House',
      'bedrooms': 4,
      'bathrooms': 3,
      'area': '2200 sq ft',
      'type': 'House',
      'rating': 4.9,
      'isFavorite': true,
    },
    {
      'id': 6,
      'title': 'Modern Studio in Austin',
      'location': 'Downtown Austin',
      'city': 'Austin, TX',
      'price': 1600,
      'image': 'https://via.placeholder.com/300x200/4DB6AC/FFFFFF?text=Austin+Studio',
      'bedrooms': 1,
      'bathrooms': 1,
      'area': '650 sq ft',
      'type': 'Studio',
      'rating': 4.2,
      'isFavorite': false,
    },
    {
      'id': 7,
      'title': 'Garden Villa in San Francisco',
      'location': 'Pacific Heights',
      'city': 'San Francisco, CA',
      'price': 5200,
      'image': 'https://via.placeholder.com/300x200/4DB6AC/FFFFFF?text=SF+Villa',
      'bedrooms': 5,
      'bathrooms': 4,
      'area': '2800 sq ft',
      'type': 'Villa',
      'rating': 4.8,
      'isFavorite': false,
    },
    {
      'id': 8,
      'title': 'Traditional House in Dallas',
      'location': 'Highland Park',
      'city': 'Dallas, TX',
      'price': 3200,
      'image': 'https://via.placeholder.com/300x200/4DB6AC/FFFFFF?text=Dallas+House',
      'bedrooms': 3,
      'bathrooms': 2,
      'area': '2100 sq ft',
      'type': 'House',
      'rating': 4.4,
      'isFavorite': false,
    },
    {
      'id': 9,
      'title': 'Mountain View Apartment in Denver',
      'location': 'Downtown Denver',
      'city': 'Denver, CO',
      'price': 2100,
      'image': 'https://via.placeholder.com/300x200/4DB6AC/FFFFFF?text=Denver+Apt',
      'bedrooms': 2,
      'bathrooms': 1,
      'area': '980 sq ft',
      'type': 'Apartment',
      'rating': 4.6,
      'isFavorite': false,
    },
    {
      'id': 10,
      'title': 'Riverside Villa in Seattle',
      'location': 'Queen Anne',
      'city': 'Seattle, WA',
      'price': 3800,
      'image': 'https://via.placeholder.com/300x200/4DB6AC/FFFFFF?text=Seattle+Villa',
      'bedrooms': 4,
      'bathrooms': 3,
      'area': '2400 sq ft',
      'type': 'Villa',
      'rating': 4.5,
      'isFavorite': false,
    },
  ];

  final List<String> filters = ['All', 'Apartment', 'House', 'Villa', 'Studio', 'Condo'];
  final List<String> sortOptions = ['Price: Low to High', 'Price: High to Low', 'Rating', 'Bedrooms'];

  @override
  void initState() {
    super.initState();
    _filteredApartments = List.from(apartments);
    _searchController.addListener(_applyAllFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Apply all filters at once
  void _applyAllFilters() {
    print('🔍 Applying all filters...');
    print('   Search: ${_searchController.text}');
    print('   Location: $_selectedLocation');
    print('   Type: $_selectedFilter');

    setState(() {
      // Start with all apartments
      List<Map<String, dynamic>> result = List.from(apartments);

      // Apply search filter
      final searchQuery = _searchController.text.toLowerCase();
      if (searchQuery.isNotEmpty) {
        result = result.where((apartment) {
          return apartment['title'].toLowerCase().contains(searchQuery) ||
              apartment['location'].toLowerCase().contains(searchQuery) ||
              apartment['city'].toLowerCase().contains(searchQuery) ||
              apartment['type'].toLowerCase().contains(searchQuery);
        }).toList();
      }

      // Apply location filter
      if (_selectedLocation != 'All') {
        result = result.where((apt) => apt['city'] == _selectedLocation).toList();
      }

      // Apply type filter
      if (_selectedFilter != 'All') {
        result = result.where((apt) => apt['type'] == _selectedFilter).toList();
      }

      // Apply sorting
      switch (_selectedSort) {
        case 'Price: Low to High':
          result.sort((a, b) => a['price'].compareTo(b['price']));
          break;
        case 'Price: High to Low':
          result.sort((a, b) => b['price'].compareTo(a['price']));
          break;
        case 'Rating':
          result.sort((a, b) => b['rating'].compareTo(a['rating']));
          break;
        case 'Bedrooms':
          result.sort((a, b) => b['bedrooms'].compareTo(a['bedrooms']));
          break;
      }

      _filteredApartments = result;
      print('   Found: ${_filteredApartments.length} properties');
    });
  }

  void _applyFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    _applyAllFilters();
  }

  void _applyLocationFilter(String location) {
    setState(() {
      _selectedLocation = location;
    });
    _applyAllFilters();
  }

  void _applySort(String sort) {
    setState(() {
      _selectedSort = sort;
    });
    _applyAllFilters();
  }

  void _toggleFavorite(int id) {
    setState(() {
      final index = apartments.indexWhere((apt) => apt['id'] == id);
      if (index != -1) {
        apartments[index]['isFavorite'] = !apartments[index]['isFavorite'];
        _applyAllFilters(); // Refresh the list
      }
    });
  }

  void _clearAllFilters() {
    setState(() {
      _searchController.clear();
      _selectedFilter = 'All';
      _selectedSort = 'Price: Low to High';
      _selectedLocation = 'All';
    });
    _applyAllFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("US Properties"),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(15),
            child: TextFormField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Search for properties...",
                hintText: "Enter location, type, or name",
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search, color: Colors.teal),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _applyAllFilters();
                  },
                )
                    : null,
              ),
            ),
          ),

          // Filter, Location, and Sort Rows
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Column(
              children: [
                // Location Filter Row
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.teal),
                    const SizedBox(width: 10),
                    const Text(
                      "Location:",
                      style: TextStyle(
                        color: Colors.teal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.teal),
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.white,
                        ),
                        child: DropdownButton<String>(
                          value: _selectedLocation,
                          isExpanded: true,
                          underline: const SizedBox(),
                          dropdownColor: Colors.white,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                          ),
                          items: locations.map((String location) {
                            return DropdownMenuItem<String>(
                              value: location,
                              child: Text(
                                location,
                                style: const TextStyle(color: Colors.black),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            if (value != null) {
                              _applyLocationFilter(value);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Filter and Sort in one row
                Row(
                  children: [
                    // Filter
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.filter_list, color: Colors.teal, size: 20),
                          const SizedBox(width: 5),
                          const Text(
                            "Type:",
                            style: TextStyle(
                              color: Colors.teal,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Container(
                              height: 40,
                              padding: const EdgeInsets.symmetric(horizontal: 5),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.teal),
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.white,
                              ),
                              child: DropdownButton<String>(
                                value: _selectedFilter,
                                isExpanded: true,
                                underline: const SizedBox(),
                                iconSize: 20,
                                dropdownColor: Colors.white,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                                items: filters.map((String filter) {
                                  return DropdownMenuItem<String>(
                                    value: filter,
                                    child: Text(
                                      filter,
                                      style: const TextStyle(color: Colors.black),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? value) {
                                  if (value != null) {
                                    _applyFilter(value);
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Sort
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.sort, color: Colors.teal, size: 20),
                          const SizedBox(width: 5),
                          const Text(
                            "Sort:",
                            style: TextStyle(
                              color: Colors.teal,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Container(
                              height: 40,
                              padding: const EdgeInsets.symmetric(horizontal: 5),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.teal),
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.white,
                              ),
                              child: DropdownButton<String>(
                                value: _selectedSort,
                                isExpanded: true,
                                underline: const SizedBox(),
                                iconSize: 20,
                                dropdownColor: Colors.white,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                                items: sortOptions.map((String option) {
                                  return DropdownMenuItem<String>(
                                    value: option,
                                    child: Text(
                                      option,
                                      style: const TextStyle(color: Colors.black),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? value) {
                                  if (value != null) {
                                    _applySort(value);
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Results Count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            color: Colors.teal.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${_filteredApartments.length} properties available",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_searchController.text.isNotEmpty || _selectedFilter != 'All' || _selectedLocation != 'All')
                  TextButton(
                    onPressed: _clearAllFilters,
                    child: const Text(
                      "Clear all filters",
                      style: TextStyle(color: Colors.teal),
                    ),
                  ),
              ],
            ),
          ),

          // Location Quick Select (Chips)
          if (_selectedLocation == 'All')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: locations.length - 1, // Exclude 'All'
                itemBuilder: (context, index) {
                  final location = locations[index + 1];
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(
                        location,
                        style: const TextStyle(color: Colors.teal),
                      ),
                      selected: false,
                      selectedColor: Colors.teal,
                      backgroundColor: Colors.teal.withOpacity(0.1),
                      onSelected: (selected) {
                        _applyLocationFilter(location);
                      },
                      labelStyle: const TextStyle(
                        color: Colors.teal,
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
            ),

          // Apartments List
          Expanded(
            child: _filteredApartments.isEmpty
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 60, color: Colors.grey),
                  SizedBox(height: 20),
                  Text(
                    "No properties available",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Try searching with different filters",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: _filteredApartments.length,
              itemBuilder: (context, index) {
                final apartment = _filteredApartments[index];
                return _buildApartmentCard(apartment);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApartmentCard(Map<String, dynamic> apartment) {
    // Format price in USD
    String formatPrice(int price) {
      return '\$${price.toStringAsFixed(0)}/month';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 3,
      child: InkWell(
        onTap: () {
          // Navigate to detail page
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row with image and basic info
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Property Image
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.teal.withOpacity(0.1),
                      image: DecorationImage(
                        image: NetworkImage(apartment['image']),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Property Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                apartment['title'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                apartment['isFavorite']
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: apartment['isFavorite']
                                    ? Colors.red
                                    : Colors.grey,
                                size: 20,
                              ),
                              onPressed: () => _toggleFavorite(apartment['id']),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),

                        // City and Location
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 14, color: Colors.grey),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                '${apartment['location']} - ${apartment['city']}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Property Type and City Badge
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.teal.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                apartment['type'],
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.teal,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                apartment['city'],
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Property Features
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildFeatureItem(Icons.bed, '${apartment['bedrooms']} BR'),
                  _buildFeatureItem(Icons.bathtub, '${apartment['bathrooms']} BA'),
                  _buildFeatureItem(Icons.square_foot, apartment['area']),
                  _buildFeatureItem(Icons.star, '${apartment['rating']}'),
                ],
              ),

              const SizedBox(height: 12),

              // Price and Action Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formatPrice(apartment['price']),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      Text(
                        '\$${apartment['price'].toStringAsFixed(0)} per month',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  MaterialButton(
                    onPressed: () {
                      // Navigate to detail page
                    },
                    color: Colors.teal,
                    textColor: Colors.white,
                    height: 36,
                    child: const Text("View Details"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.teal),
        const SizedBox(height: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}