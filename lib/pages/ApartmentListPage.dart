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

  double? _maxPrice;
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
      if (_hasElevator) filters['has_elevator'] = 1;

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
      Get.snackbar("Error", "Failed to load apartments");
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface, // الخلفية البيج
      appBar: AppBar(
        title: const Text("Browse Apartments", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: colorScheme.primary, // الفيروزي
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: _showFilterSheet,
          )
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
          : _apartments.isEmpty
          ? const Center(child: Text("No apartments found matching your criteria."))
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item['title'] ?? "No Title",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.secondary), // العنابي
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        "${item['price']} SYP",
                        style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 16), // الفيروزي
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: colorScheme.primary.withOpacity(0.7)),
                      const SizedBox(width: 4),
                      Text(
                        "${item['city']?['name'] ?? ''}, ${item['province']?['name'] ?? ''}",
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
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
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      backgroundColor: colorScheme.surface,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Filter Results", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorScheme.primary)),
              const SizedBox(height: 25),
              TextField(
                decoration: InputDecoration(
                  labelText: "Max Price",
                  prefixIcon: Icon(Icons.attach_money, color: colorScheme.secondary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: colorScheme.primary), borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.number,
                onChanged: (val) => _maxPrice = double.tryParse(val),
              ),
              const SizedBox(height: 15),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Has Elevator", style: TextStyle(fontWeight: FontWeight.w500)),
                value: _hasElevator,
                activeColor: colorScheme.primary,
                onChanged: (val) => setModalState(() => _hasElevator = val),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _fetchApartments();
                },
                child: const Text("Apply Filters", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      ),
    );
  }
}