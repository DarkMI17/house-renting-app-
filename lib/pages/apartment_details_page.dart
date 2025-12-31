import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_repository..dart';
import '../services/config.dart';
import 'Apartment.dart';

class ApartmentDetailsPage extends StatefulWidget {
  final Apartment apartment; // ✅ التعديل الأساسي: استقبال الموديل وليس dynamic
  const ApartmentDetailsPage({super.key, required this.apartment});

  @override
  State<ApartmentDetailsPage> createState() => _ApartmentDetailsPageState();
}

class _ApartmentDetailsPageState extends State<ApartmentDetailsPage> {
  final ApiRepository _apiRepository = ApiRepository();
  DateTimeRange? _selectedDateRange;
  bool _isBooking = false;
  int _currentImageIndex = 0;

  // دالة تنسيق روابط الصور لتناسب السيرفر
  String _formatImageUrl(String imagePath) {
    if (imagePath.isEmpty) return "https://via.placeholder.com/300";
    if (imagePath.startsWith('http')) return imagePath;
    final String baseUrl = ApiConfig.baseUrl.replaceAll('/api', '');
    String cleanPath = imagePath.startsWith('/') ? imagePath : '/$imagePath';
    return "$baseUrl$cleanPath";
  }
/* replace */
  @override
  Widget build(BuildContext context) {
    final apt = widget.apartment; // تعريف متغير محلي للسهولة

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(apt),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // العنوان والسعر
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(apt.title,
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      ),
                      Text("${apt.price.toStringAsFixed(0)} SYP",
                          style: const TextStyle(fontSize: 20, color: Color(0xFF0B6C5F), fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // العنوان التفصيلي
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(apt.addressDetails, style: const TextStyle(color: Colors.grey)),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Divider(),
                  ),
                  // شبكة الميزات (الغرف، الحمامات، المساحة)
                  _buildFeaturesGrid(apt),
                  const SizedBox(height: 30),
                  // الوصف
                  const Text("Description", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(apt.description,
                      style: TextStyle(color: Colors.grey[800], height: 1.5, fontSize: 15)),
                  const SizedBox(height: 30),
                  // قسم الحجز
                  const Text("Reservation", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildBookingCard(),
                  const SizedBox(height: 120), // مساحة لعدم تداخل المحتوى مع الزر السفلي
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomAction(),
    );
  }

  // الجزء العلوي مع معرض الصور
  Widget _buildSliverAppBar(Apartment apt) {
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      backgroundColor: const Color(0xFF0B6C5F),
      flexibleSpace: FlexibleSpaceBar(
        background: apt.images.isEmpty
            ? Container(color: Colors.grey[300], child: const Icon(Icons.home, size: 100, color: Colors.white))
            : Stack(
          alignment: Alignment.bottomCenter,
          children: [
            PageView.builder(
              itemCount: apt.images.length,
              onPageChanged: (index) => setState(() => _currentImageIndex = index),
              itemBuilder: (context, index) {
                return Image.network(
                  _formatImageUrl(apt.images[index]),
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(color: Colors.grey[200], child: const Icon(Icons.broken_image)),
                );
              },
            ),
            if (apt.images.length > 1)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(apt.images.length, (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8, height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentImageIndex == index ? Colors.white : Colors.white54,
                    ),
                  )),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesGrid(Apartment apt) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _featureItem(Icons.king_bed, "${apt.numberOfRooms} Rooms"),
        _featureItem(Icons.bathtub, "${apt.numberOfBathrooms} Baths"),
        _featureItem(Icons.square_foot, "${apt.area} m²"),
      ],
    );
  }

  Widget _featureItem(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF0B6C5F), size: 28),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildBookingCard() {
    return GestureDetector(
      onTap: _selectBookingDates,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0B6C5F).withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFF0B6C5F).withOpacity(0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month, color: Color(0xFF0B6C5F)),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_selectedDateRange == null ? "Select Dates" : "Selected Period",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(_selectedDateRange == null
                    ? "Pick check-in and check-out"
                    : "${_selectedDateRange!.start.toString().split(' ')[0]} to ${_selectedDateRange!.end.toString().split(' ')[0]}"),
              ],
            ),
            const Spacer(),
            const Icon(Icons.edit, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black12)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0B6C5F),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: (_selectedDateRange == null || _isBooking) ? null : _handleBooking,
          child: _isBooking
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text("BOOK THIS APARTMENT",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ),
    );
  }

  Future<void> _selectBookingDates() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF0B6C5F)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDateRange = picked);
  }

  Future<void> _handleBooking() async {
    setState(() => _isBooking = true);

    // ✅ إرسال الـ ID كـ int بفضل الموديل الجديد
    final result = await _apiRepository.sendBookingRequest(
        widget.apartment.id,
        _selectedDateRange!
    );

    setState(() => _isBooking = false);

    if (result['success']) {
      Get.snackbar("Success", "Booking request sent!",
          backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    } else {
      Get.snackbar("Error", result['message'] ?? "Booking failed",
          backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    }
  }
}