/*import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_repository.dart';
import 'ApartmentDetailsPage.dart';
import '../services/config.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'Apartment.dart';
class ApartmentListPage extends StatefulWidget {
  const ApartmentListPage({super.key});

  @override
  State<ApartmentListPage> createState() => _ApartmentListPageState();
}

class _ApartmentListPageState extends State<ApartmentListPage> {
  final ApiRepository _apiRepository = ApiRepository();
  List<dynamic> _apartments = [];
  bool _isLoading = true;

  double? _maxPrice;
  int? _minRooms;
  bool _hasElevator = false;

  @override
  void initState() {
    super.initState();
    _fetchApartments();
  }

  Future<void> _fetchApartments() async {
    setState(() => _isLoading = true);
    try {
      Map<String, dynamic> filters = {};
      if (_maxPrice != null) filters['max_price'] = _maxPrice;
      if (_minRooms != null) filters['min_rooms'] = _minRooms;
      if (_hasElevator) filters['has_elevator'] = 1;

      final response = await _apiRepository.getApartments(filters: filters);

      setState(() {
// هيكلية Laravel Paginate: response.data['data']['data']
        _apartments = response.data['data']['data'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print("Error Detail: $e"); // لطباعة الخطأ في الكونسول ومعرفة السبب
      Get.snackbar("Error", "Failed to load apartments");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Browse Apartments"),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : _apartments.isEmpty
          ? const Center(child: Text("No apartments found matching your criteria."))
          : ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: _apartments.length,
        itemBuilder: (context, index) {
          final item = _apartments[index];
          return _buildApartmentCard(item);
        },
      ),
    );
  }

  Widget _buildApartmentCard(dynamic item) {

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.only(bottom: 15),
      child: InkWell(
        onTap: () {
          Apartment apartmentModel = Apartment.fromJson(item);
          Get.to(() =>ApartmentDetailsPage(apartment: apartmentModel));
        },
        child: Column(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  child: _buildApartmentImage(item),
                ),
                if (item['is_booked'] == true)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Text(
                        "Booked",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
              ],
            ),
            ListTile(
              title: Text(item['title'] ?? "No Title",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                  "${item['city']?['name'] ?? ''}, ${item['province']?['name'] ?? ''}"),
              trailing: Text("\$${item['price']}",
                  style: const TextStyle(
                      color: Colors.teal,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildApartmentImage(dynamic item) {
    if (item['images'] != null &&
        item['images'] is List &&
        item['images'].isNotEmpty) {

      String img = item['images'][0];

// لو مسار نسبي
/*if (img.startsWith('/')) {
        img = "${ApiConfig.imageBaseUrl}$img";
      }
*/
      print("IMAGE URL => $img");

      return CachedNetworkImage(
        imageUrl: img,

        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,

// أثناء التحميل
        placeholder: (context, url) => Container(
          height: 180,
          color: Colors.grey[300],
          child: const Center(child: CircularProgressIndicator()),
        ),

// عند الخطأ
        errorWidget: (context, url, error) => _placeholder(),
      );
    }

    return _placeholder();
  }


  Widget _networkImage(String url) {
    print("IMAGE URL => $url"); // 🔥 مهم للتأكد

    return  Image.network(
      url,
      height: 180,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }


  Widget _placeholder() {
    return Container(
      height: 180,
      color: Colors.grey[300],
      child: const Icon(Icons.image_not_supported, size: 40),
    );
  }


  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Filter Results",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(
                decoration: const InputDecoration(
                    labelText: "Max Price", prefixIcon: Icon(Icons.attach_money)),
                keyboardType: TextInputType.number,
                onChanged: (val) => _maxPrice = double.tryParse(val),
              ),
              SwitchListTile(
                title: const Text("Has Elevator"),
                value: _hasElevator,
                activeColor: Colors.teal,
                onChanged: (val) => setModalState(() => _hasElevator = val),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    minimumSize: const Size(double.infinity, 45)),
                onPressed: () {
                  Navigator.pop(context);
                  _fetchApartments();
                },
                child:
                const Text("Apply Filters", style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
*/
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_repository.dart';
import 'ApartmentDetailsPage.dart';
import '../services/config.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'Apartment.dart';

class ApartmentListPage extends StatefulWidget {
  const ApartmentListPage({super.key});

  @override
  State<ApartmentListPage> createState() => _ApartmentListPageState();
}

class _ApartmentListPageState extends State<ApartmentListPage> {
  final ApiRepository _apiRepository = ApiRepository();
  List<dynamic> _apartments = [];
  bool _isLoading = true;

  String? _priceRange;
  bool _hasElevator = false;
  int? _minRooms;
  bool _hasBalcony = false;
  int? _selectedProvinceId;
  int? _selectedCityId;

  List<dynamic> _provinces = [];
  List<dynamic> _cities = [];
  bool _loadingProvinces = true;

  @override
  void initState() {
    super.initState();
    _fetchApartments();
    _fetchProvinces();
  }

  Future<void> _fetchProvinces() async {
    try {
      final result = await _apiRepository.getProvinces();
      if (result['success'] == true && result['data'] is List) {
        setState(() {
          _provinces = result['data'];
          _loadingProvinces = false;
        });
      } else {
        setState(() => _loadingProvinces = false);
        print('Error fetching provinces: ${result['message']}');
        Get.snackbar("Error", "Failed to load provinces");
      }
    } catch (e) {
      setState(() => _loadingProvinces = false);
      print('Error fetching provinces: $e');
      Get.snackbar("Error", "Failed to load provinces");
    }
  }

  Future<void> _fetchCities(int provinceId) async {
    try {
      final result = await _apiRepository.getCities(provinceId);
      if (result['success'] == true && result['data'] is List) {
        setState(() {
          _cities = result['data'];
          _selectedCityId = null;
        });
      } else {
        print('Error fetching cities: ${result['message']}');
        setState(() => _cities = []);
        Get.snackbar("Info", "No cities found for this province");
      }
    } catch (e) {
      print('Error fetching cities: $e');
      setState(() => _cities = []);
    }
  }

  Future<void> _fetchApartments() async {
    setState(() => _isLoading = true);
    try {
      Map<String, dynamic> filters = {};

      if (_priceRange != null) {
        if (_priceRange == 'under_100') {
          filters['max_price'] = 100;
        } else if (_priceRange == 'under_1000') {
          filters['max_price'] = 1000;
        } else if (_priceRange == 'under_10000') {
          filters['max_price'] = 10000;
        }
      }

      if (_hasElevator) filters['has_elevator'] = 1;
      if (_minRooms != null) filters['min_rooms'] = _minRooms;
      if (_hasBalcony) filters['has_balcony'] = 1;
      if (_selectedProvinceId != null) filters['province_id'] = _selectedProvinceId;
      if (_selectedCityId != null) filters['city_id'] = _selectedCityId;

      final response = await _apiRepository.getApartments(filters: filters);

      List<dynamic> apartmentsList = [];
      if (response.data is List) {
        apartmentsList = response.data;
      } else if (response.data is Map) {
        if (response.data['data'] is List) {
          apartmentsList = response.data['data'];
        } else if (response.data['data']?['data'] is List) {
          apartmentsList = response.data['data']['data'];
        }
      }

      setState(() {
        _apartments = apartmentsList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error: $e');
      Get.snackbar("Error", "Failed to load apartments");
    }
  }

  void _resetFilters() {
    setState(() {
      _priceRange = null;
      _hasElevator = false;
      _minRooms = null;
      _hasBalcony = false;
      _selectedProvinceId = null;
      _selectedCityId = null;
      _cities = [];
    });
    _fetchApartments();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text("Browse Apartments", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: _showFilterSheet,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetFilters,
            tooltip: 'Reset Filters',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
          : _apartments.isEmpty
          ? SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          // تم إصلاح الخطأ هنا: تم إزالة Alignment(Center) واستبدالها بـ child: Center
          height: MediaQuery.of(context).size.height * 0.7,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 60, color: colorScheme.primary.withOpacity(0.5)),
                const SizedBox(height: 15),
                const Text("No apartments found"),
                const SizedBox(height: 5),
                Text("Try adjusting your filters", style: TextStyle(color: Colors.grey[600])),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _resetFilters,
                  icon: Icon(Icons.refresh, color: colorScheme.primary),
                  label: Text("Reset Filters", style: TextStyle(color: colorScheme.primary)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        itemCount: _apartments.length,
        itemBuilder: (context, index) {
          final item = _apartments[index];
          return _buildApartmentCard(item, colorScheme);
        },
      ),
    );
  }

  Widget _buildApartmentCard(dynamic item, ColorScheme colorScheme) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.only(bottom: 20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Apartment apartmentModel = Apartment.fromJson(item);
          Get.to(() => ApartmentDetailsPage(apartment: apartmentModel));
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                _buildApartmentImage(item),
                if (item['is_booked'] == true)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        "BOOKED",
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item['title'] ?? "No Title",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.secondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "${item['price']} SYP",
                        style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: colorScheme.primary.withOpacity(0.7)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          "${item['city']?['name'] ?? ''}, ${item['province']?['name'] ?? ''}",
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
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

  Widget _buildApartmentImage(dynamic item) {
    String img = "";
    if (item['images'] != null && item['images'] is List && item['images'].isNotEmpty) {
      img = item['images'][0].toString();
      if (!img.startsWith('http')) {
        img = "${ApiConfig.imageBaseUrl}$img";
      }
    }

    return CachedNetworkImage(
      imageUrl: img,
      height: 200,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        height: 200,
        color: Colors.grey[200],
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      errorWidget: (context, url, error) => Container(
        height: 200,
        color: Colors.grey[300],
        child: const Icon(Icons.apartment, size: 50, color: Colors.grey),
      ),
    );
  }

  void _showFilterSheet() {
    final colorScheme = Theme.of(context).colorScheme;
    final TextEditingController minRoomsController = TextEditingController(
      text: _minRooms?.toString() ?? '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      backgroundColor: colorScheme.surface,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Filter Results", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorScheme.primary)),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, color: colorScheme.secondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Text("Price Range", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: colorScheme.secondary)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildPriceChip('All Prices', null, colorScheme, setModalState),
                      _buildPriceChip('Under 100 SYP', 'under_100', colorScheme, setModalState),
                      _buildPriceChip('Under 1,000 SYP', 'under_1000', colorScheme, setModalState),
                      _buildPriceChip('Under 10,000 SYP', 'under_10000', colorScheme, setModalState),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: minRoomsController,
                    decoration: InputDecoration(
                      labelText: "Minimum Rooms",
                      prefixIcon: Icon(Icons.king_bed, color: colorScheme.secondary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      if (val.isEmpty) {
                        _minRooms = null;
                      } else {
                        _minRooms = int.tryParse(val);
                      }
                    },
                  ),
                  const SizedBox(height: 15),
                  if (_loadingProvinces)
                    const Center(child: CircularProgressIndicator())
                  else
                    DropdownButtonFormField<int?>(
                      decoration: InputDecoration(
                        labelText: "Province",
                        prefixIcon: Icon(Icons.location_city, color: colorScheme.secondary),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      value: _selectedProvinceId,
                      items: [
                        DropdownMenuItem<int?>(
                          value: null,
                          child: Text("All Provinces", style: TextStyle(color: Colors.grey[600])),
                        ),
                        ..._provinces.map((province) {
                          return DropdownMenuItem<int?>(
                            value: int.tryParse(province['id']?.toString() ?? '0'),
                            child: Text(province['name']?.toString() ?? 'Unknown'),
                          );
                        }).toList(),
                      ],
                      onChanged: (value) {
                        setModalState(() {
                          _selectedProvinceId = value;
                          if (value != null) {
                            _fetchCities(value);
                          } else {
                            _cities = [];
                            _selectedCityId = null;
                          }
                        });
                      },
                    ),
                  const SizedBox(height: 15),
                  if (_selectedProvinceId != null)
                    DropdownButtonFormField<int?>(
                      decoration: InputDecoration(
                        labelText: "City",
                        prefixIcon: Icon(Icons.location_on, color: colorScheme.secondary),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      value: _selectedCityId,
                      items: [
                        DropdownMenuItem<int?>(
                          value: null,
                          child: Text("All Cities", style: TextStyle(color: Colors.grey[600])),
                        ),
                        ..._cities.map((city) {
                          return DropdownMenuItem<int?>(
                            value: int.tryParse(city['id']?.toString() ?? '0'),
                            child: Text(city['name']?.toString() ?? 'Unknown'),
                          );
                        }).toList(),
                      ],
                      onChanged: (value) {
                        setModalState(() => _selectedCityId = value);
                      },
                    ),
                  if (_selectedProvinceId != null) const SizedBox(height: 15),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Has Elevator", style: TextStyle(fontWeight: FontWeight.w500)),
                    value: _hasElevator,
                    onChanged: (val) => setModalState(() => _hasElevator = val),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Has Balcony", style: TextStyle(fontWeight: FontWeight.w500)),
                    value: _hasBalcony,
                    onChanged: (val) => setModalState(() => _hasBalcony = val),
                  ),
                  const SizedBox(height: 25),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 55),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            setModalState(() {
                              _resetFilters();
                              minRoomsController.clear();
                            });
                            Navigator.pop(context);
                          },
                          child: Text("Reset All"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 55),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            _fetchApartments();
                          },
                          child: const Text("Apply Filters"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceChip(String label, String? value, ColorScheme colorScheme, StateSetter setModalState) {
    bool isSelected = _priceRange == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setModalState(() {
          _priceRange = selected ? value : null;
        });
      },
      selectedColor: colorScheme.primary,
    );
  }
}

extension on Map<String, dynamic> {
  get data => null;
}
