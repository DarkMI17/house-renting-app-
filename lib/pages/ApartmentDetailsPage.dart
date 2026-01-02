import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/network_service.dart';

class ApartmentDetailsPage extends StatefulWidget {
  final int apartmentId;
  const ApartmentDetailsPage({super.key, required this.apartmentId});

  @override
  State<ApartmentDetailsPage> createState() => _ApartmentDetailsPageState();
}

class _ApartmentDetailsPageState extends State<ApartmentDetailsPage> {
  Map<String, dynamic>? _details;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadApartmentDetails();
  }

  Future<void> _loadApartmentDetails() async {
    try {
      final response = await NetworkService().get('/apartments/${widget.apartmentId}');
      setState(() {
        _details = response.data['data'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      Get.snackbar("Error", "Could not load apartment details");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.teal)));
    if (_details == null) return const Scaffold(body: Center(child: Text("Data not found")));

    final List<dynamic> images = _details!['images'] ?? [];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: images.isNotEmpty
                  ? PageView.builder(
                itemCount: images.length,
                itemBuilder: (context, index) => Image.network(images[index], fit: BoxFit.cover),
              )
                  : Container(color: Colors.teal.shade100, child: const Icon(Icons.apartment, size: 100, color: Colors.teal)),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(_details!['title'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      ),
                      Text("\$${_details!['price']}", style: const TextStyle(fontSize: 22, color: Colors.teal, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 5),
                      Text("${_details!['city']['name']}, ${_details!['province']['name']}", style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const Divider(height: 30),
                  const Text("Specifications", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 4,
                    children: [
                      _buildFeatureItem(Icons.king_bed, "${_details!['number_of_rooms']} Rooms"),
                      _buildFeatureItem(Icons.bathtub, "${_details!['number_of_bathrooms']} Baths"),
                      _buildFeatureItem(Icons.square_foot, "${_details!['area']} m²"),
                      _buildFeatureItem(Icons.elevator, _details!['has_elevator'] ? "Elevator" : "No Elevator"),
                      _buildFeatureItem(Icons.balcony, _details!['has_balcony'] ? "Balcony" : "No Balcony"),
                    ],
                  ),
                  const Divider(height: 30),
                  const Text("Description", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(_details!['description'] ?? "No description provided.", style: const TextStyle(height: 1.5, color: Colors.black87)),
                  const SizedBox(height: 100), // مساحة للزر السفلي
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 5)],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _details!['booking_status'] == 'available' ? Colors.teal : Colors.grey,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: _details!['booking_status'] == 'available' ? () {
            // منطق فتح صفحة الحجز
          } : null,
          child: Text(
            _details!['booking_status'] == 'available' ? "Book Now" : "Currently Booked",
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.teal),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
/*
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_repository.dart';
import '../services/config.dart';

class ApartmentDetailsPage extends StatefulWidget {
  final int apartmentId; // ⬅️ متوافق مع ApartmentListPage
  const ApartmentDetailsPage({super.key, required this.apartmentId});

  @override
  State<ApartmentDetailsPage> createState() => _ApartmentDetailsPageState();
}

class _ApartmentDetailsPageState extends State<ApartmentDetailsPage> {
  final ApiRepository _apiRepository = ApiRepository();

  Map<String, dynamic>? _details;
  bool _loading = true;
  bool _booking = false;
  DateTimeRange? _range;
  int _imageIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    try {
      final res = await _apiRepository.getApartmentDetails(widget.apartmentId);
      _details = res['data'];
    } catch (e) {
      Get.snackbar("Error", "Failed to load apartment");
    }
    setState(() => _loading = false);
  }

  String _img(String path) {
    if (path.startsWith('http')) return path;
    return "${ApiConfig.imageBaseUrl}$path";
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_details == null) {
      return const Scaffold(
        body: Center(child: Text("No data found")),
      );
    }

    final images = _details!['images'] ?? [];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: images.isEmpty
                  ? _placeholder()
                  : PageView.builder(
                itemCount: images.length,
                onPageChanged: (i) => setState(() => _imageIndex = i),
                itemBuilder: (_, i) => Image.network(
                  _img(images[i]),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholder(),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _details!['title'] ?? '',
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        "\$${_details!['price']}",
                        style: const TextStyle(
                            fontSize: 22,
                            color: Colors.teal,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 5),
                      Text(
                        "${_details!['city']?['name']}, ${_details!['province']?['name']}",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const Divider(height: 30),

                  _spec(Icons.king_bed,
                      "${_details!['number_of_rooms']} Rooms"),
                  _spec(Icons.bathtub,
                      "${_details!['number_of_bathrooms']} Baths"),
                  _spec(Icons.square_foot, "${_details!['area']} m²"),
                  _spec(Icons.elevator,
                      _details!['has_elevator'] == 1 ? "Elevator" : "No Elevator"),
                  _spec(Icons.balcony,
                      _details!['has_balcony'] == 1 ? "Balcony" : "No Balcony"),

                  const Divider(height: 30),
                  const Text("Description",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(_details!['description'] ?? ''),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _bottom(),
    );
  }

  Widget _spec(IconData i, String t) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Icon(i, color: Colors.teal),
        const SizedBox(width: 10),
        Text(t),
      ],
    ),
  );

  Widget _bottom() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          minimumSize: const Size(double.infinity, 50),
        ),
        onPressed: _range == null || _booking ? null : _book,
        child: _booking
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text("BOOK NOW"),
      ),
    );
  }

  Future<void> _book() async {
    setState(() => _booking = true);

    final res = await _apiRepository.sendBookingRequest(
        widget.apartmentId, _range!);

    setState(() => _booking = false);

    Get.snackbar(
      res['success'] ? "Success" : "Error",
      res['message'],
    );
  }

  Widget _placeholder() => Container(
    color: Colors.grey[300],
    child: const Icon(Icons.image_not_supported, size: 50),
  );
}

*/










