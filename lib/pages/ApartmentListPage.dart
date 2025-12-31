import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_repository..dart';
import '../services/config.dart';
import 'apartment.dart'; // Add this import
import 'apartment_detail.dart'; // Add this import

class ApartmentListPage extends StatefulWidget {
  const ApartmentListPage({super.key});

  @override
  State<ApartmentListPage> createState() => _ApartmentListPageState();
}

class _ApartmentListPageState extends State<ApartmentListPage> {
  final TextEditingController _searchController = TextEditingController();
  final ApiRepository _apiRepository = ApiRepository();

  // Filters
  String _selectedSort = 'Price: Low to High';
  int? _selectedProvinceId;
  int? _selectedCityId;

  // Data
  List<dynamic> _apartments = [];
  List<dynamic> _filteredApartments = [];
  List<dynamic> _provinces = [];
  List<dynamic> _filteredCities = [];

  // Loading states
  bool _isLoading = true;
  bool _isLoadingCities = false;
  String? _errorMessage;

  // Pagination
  int _currentPage = 1;
  bool _hasMorePages = true;

  final List<String> sortOptions = ['Price: Low to High', 'Price: High to Low', 'Rooms'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
    _searchController.addListener(_applyLocalFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _currentPage = 1;
    });
    try {
      // Fetch both apartments and provinces simultaneously
      await Future.wait([
        _fetchApartmentsFromApi(),
        _fetchProvinces(),
      ]);
    } catch (e) {
      setState(() => _errorMessage = 'Failed to load data');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchProvinces() async {
    final response = await _apiRepository.getProvinces();
    if (response['success'] == true) {
      setState(() {
        _provinces = List<dynamic>.from(response['data'] ?? []);
      });
    }
  }

  Future<void> _fetchApartmentsFromApi() async {
    try {
      final response = await _apiRepository.getApartments(
        provinceId: _selectedProvinceId,
        cityId: _selectedCityId,
        page: _currentPage,
      );

      if (response['success'] == true) {
        final dynamic apiPayload = response['data'];
        List<dynamic> extractedList = [];

        if (apiPayload is Map<String, dynamic>) {
          // Your API returns: {'status': true, 'message': '...', 'data': {paginator}}
          // The 'data' key contains ANOTHER Map with pagination info
          if (apiPayload.containsKey('data') && apiPayload['data'] is Map) {
            final innerData = apiPayload['data'] as Map<String, dynamic>;

            // Now extract the apartments list from the paginator
            if (innerData.containsKey('data') && innerData['data'] is List) {
              extractedList = innerData['data'];

              // Update pagination
              if (innerData.containsKey('current_page')) {
                _hasMorePages = innerData['next_page_url'] != null;
              }
            }
          }
        }

        setState(() {
          if (_currentPage == 1) {
            _apartments = List<dynamic>.from(extractedList);
          } else {
            _apartments.addAll(List<dynamic>.from(extractedList));
          }

          _applyLocalFilters();
          _errorMessage = null;
        });
      } else {
        setState(() => _errorMessage = response['message'] ?? 'Failed to load data');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Connection error: $e');
    }
  }

  Future<void> _loadCities(int provinceId) async {
    setState(() => _isLoadingCities = true);
    final response = await _apiRepository.getCities(provinceId);
    if (response['success'] == true) {
      setState(() {
        _filteredCities = List<dynamic>.from(response['data'] ?? []);
        _isLoadingCities = false;
      });
    }
  }

  void _applyLocalFilters() {
    setState(() {
      List<dynamic> result = List.from(_apartments);

      // 1. Text Search
      final query = _searchController.text.toLowerCase();
      if (query.isNotEmpty) {
        result = result.where((apt) {
          final title = (apt['title'] ?? '').toString().toLowerCase();
          final address = (apt['address_details'] ?? '').toString().toLowerCase();
          return title.contains(query) || address.contains(query);
        }).toList();
      }

      // 2. Sorting
      if (_selectedSort == 'Price: Low to High') {
        result.sort((a, b) => (a['price'] ?? 0).compareTo(b['price'] ?? 0));
      } else if (_selectedSort == 'Price: High to Low') {
        result.sort((a, b) => (b['price'] ?? 0).compareTo(a['price'] ?? 0));
      } else if (_selectedSort == 'Rooms') {
        result.sort((a, b) => (b['number_of_rooms'] ?? 0).compareTo(a['number_of_rooms'] ?? 0));
      }

      _filteredApartments = result;
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedProvinceId = null;
      _selectedCityId = null;
      _searchController.clear();
      _currentPage = 1;
      _apartments = [];
      _filteredApartments = [];
      _isLoading = true;
    });
    // Don't call _fetchApartmentsFromApi() here, call _loadInitialData()
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Find Your Home"),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchAndFilterHeader(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
                : _filteredApartments.isEmpty
                ? _buildEmptyState()
                : _buildApartmentList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterHeader() {
    return Container(
      color: Colors.teal,
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Search by title or address...",
              prefixIcon: const Icon(Icons.search),
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildTransparentDropdown(
                  hint: "Province",
                  value: _selectedProvinceId,
                  items: _provinces,
                  onChanged: (val) {
                    setState(() {
                      _selectedProvinceId = val;
                      _selectedCityId = null;
                      _currentPage = 1;
                    });
                    if (val != null) _loadCities(val);
                    _fetchApartmentsFromApi();
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTransparentDropdown(
                  hint: "Sort",
                  value: _selectedSort,
                  items: sortOptions.map((e) => {'id': e, 'name': e}).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedSort = val.toString();
                      _applyLocalFilters();
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransparentDropdown({
    required String hint,
    required dynamic value,
    required List<dynamic> items,
    required Function(dynamic) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<dynamic>(
          value: value,
          hint: Text(hint, style: const TextStyle(color: Colors.white, fontSize: 13)),
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
          dropdownColor: Colors.teal.shade700,
          style: const TextStyle(color: Colors.white),
          items: [
            DropdownMenuItem(value: null, child: Text("All $hint")),
            ...items.map((item) => DropdownMenuItem(
              value: item['id'],
              child: Text(item['name'] ?? ''),
            )),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildApartmentList() {
    return RefreshIndicator(
      onRefresh: _loadInitialData,
      child: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: _filteredApartments.length + (_hasMorePages ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _filteredApartments.length) {
            // This triggers when user reaches bottom and hasMorePages is true
            _currentPage++;
            _fetchApartmentsFromApi();
            return const Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final apt = _filteredApartments[index];
          return _buildPropertyCard(apt);
        },
      ),
    );
  }

  Widget _buildPropertyCard(dynamic apt) {
    // 1. Check if apt is actually a Map and not null
    if (apt == null || apt is! Map) {
      print("DEBUG: Invalid apartment data: $apt");
      return Container(height: 0); // Return invisible container
    }

    // 2. Safely cast to Map
    final Map<dynamic, dynamic> apartment = apt;

    // 3. Debug the apartment structure
    print("DEBUG Apartment keys: ${apartment.keys}");
    print("DEBUG Apartment data: $apartment");

    // 4. Safe Image URL logic
    String getImageUrl() {
      try {
        if (apartment['images'] != null) {
          if (apartment['images'] is List && (apartment['images'] as List).isNotEmpty) {
            dynamic firstImage = apartment['images'][0];
            if (firstImage != null) {
              String path = firstImage.toString();
              print("DEBUG: Image path: $path");
              print("DEBUG: Generated URL: ${ApiConfig.getImageUrl(path)}");
              return ApiConfig.getImageUrl(path);
            }
          } else if (apartment['images'] is String) {
            String path = apartment['images'];
            print("DEBUG: Single image path: $path");
            return ApiConfig.getImageUrl(path);
          }
        }
      } catch (e) {
        print("DEBUG: Image URL error: $e");
      }
      print("DEBUG: Using placeholder image");
      return "https://via.placeholder.com/150";
    }

    // 5. Get city and province names safely
    String getLocation() {
      String city = '';
      String province = '';

      if (apartment['city'] is Map) {
        city = (apartment['city'] as Map)['name']?.toString() ?? '';
      } else if (apartment['city'] is String) {
        city = apartment['city'];
      }

      if (apartment['province'] is Map) {
        province = (apartment['province'] as Map)['name']?.toString() ?? '';
      } else if (apartment['province'] is String) {
        province = apartment['province'];
      }

      if (city.isEmpty && province.isEmpty) {
        return apartment['address_details']?.toString() ?? 'Location not specified';
      } else if (city.isNotEmpty && province.isNotEmpty) {
        return "$city, $province";
      } else {
        return city.isNotEmpty ? city : province;
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        onTap: () {
          try {
            final apartmentModel = Apartment.fromDynamicMap(apartment);
            Get.to(() => ApartmentDetailPage(apartment: apartmentModel));
          } catch (e) {
            print("Error converting apartment: $e");
            print("Full error: ${e.toString()}");
            Get.snackbar(
              'Error',
              'Could not load apartment details',
              duration: Duration(seconds: 2),
            );
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                getImageUrl(),
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 180,
                    color: Colors.grey[200],
                    child: Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  print("DEBUG: Image load error: $error");
                  return Container(
                    height: 180,
                    color: Colors.grey[200],
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_not_supported, size: 50, color: Colors.grey[400]),
                          SizedBox(height: 8),
                          Text("No image", style: TextStyle(color: Colors.grey[500])),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Price
                      Text(
                        "\$${apartment['price']?.toString() ?? '0'}/mo",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      // Status
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade50,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          (apartment['status']?.toString() ?? 'Available').toUpperCase(),
                          style: const TextStyle(
                            color: Colors.teal,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  // Title
                  Text(
                    apartment['title']?.toString() ?? 'No Title Available',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  // Location
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          getLocation(),
                          style: const TextStyle(color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  // Features
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _infoIcon(
                        Icons.bed,
                        "${apartment['number_of_rooms']?.toString() ?? '0'} Rooms",
                      ),
                      _infoIcon(
                        Icons.bathtub,
                        "${apartment['number_of_bathrooms']?.toString() ?? '0'} Bath",
                      ),
                      _infoIcon(
                        Icons.square_foot,
                        "${apartment['area']?.toString() ?? '0'} m²",
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoIcon(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.teal),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  // Widget _infoIcon(IconData icon, String label) {
  //   return Row(
  //     children: [
  //       Icon(icon, size: 16, color: Colors.teal),
  //       const SizedBox(width: 4),
  //       Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
  //     ],
  //   );
  // }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.home_work_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 10),
          const Text("No properties found",
              style: TextStyle(color: Colors.grey, fontSize: 18)),
          TextButton(
              onPressed: () {
                _clearFilters();
                _loadInitialData();
              },
              child: const Text("Clear Filters & Refresh")
          ),
        ],
      ),
    );
  }
}