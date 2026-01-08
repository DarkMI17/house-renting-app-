/*import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_repository.dart';
import '../services/config.dart';
import 'Apartment.dart';

class ApartmentDetailsPage extends StatefulWidget {
  final Apartment apartment;
  const ApartmentDetailsPage({super.key, required this.apartment});

  @override
  State<ApartmentDetailsPage> createState() => _ApartmentDetailsPageState();
}

class _ApartmentDetailsPageState extends State<ApartmentDetailsPage> {
  final ApiRepository _apiRepository = ApiRepository();
  DateTimeRange? _selectedDateRange;
  bool _isBooking = false;
  int _currentImageIndex = 0;

  String _formatImageUrl(String imagePath) {
    if (imagePath.isEmpty) return "https://via.placeholder.com/300";
    if (imagePath.startsWith('http')) return imagePath;
    final String baseUrl = ApiConfig.baseUrl.replaceAll('/api', '');
    String cleanPath = imagePath.startsWith('/') ? imagePath : '/$imagePath';
    return "$baseUrl$cleanPath";
  }

  @override
  Widget build(BuildContext context) {
    final apt = widget.apartment;

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
                        child: Text(
                          apt.title ?? "No Title",
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text("${apt.price.toStringAsFixed(0)} SYP",
                          style: const TextStyle(
                              fontSize: 20,
                              color: Color(0xFF0B6C5F),
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 10),
// الموقع (المحافظة والمدينة)
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text("${apt.governorate}, ${apt.city}",
                            style: const TextStyle(color: Colors.grey)),
                      ),
                    ],
                  ),
// تفاصيل العنوان الإضافية إذا وجدت
                  if (apt.addressDetails != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 5, left: 21),
                      child: Text(apt.addressDetails!,
                          style: TextStyle(
                              color: Colors.grey[600], fontSize: 13)),
                    ),
                  const Divider(height: 30),
// شبكة المواصفات
                  _buildFeaturesGrid(apt),
                  const SizedBox(height: 30),
// الوصف
                  const Text("Description",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(apt.description ?? "No description provided.",
                      style: TextStyle(
                          color: Colors.grey[800],
                          height: 1.5,
                          fontSize: 15)),
                  const SizedBox(height: 30),
// قسم اختيار التاريخ
                  const Text("Reservation Period",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildBookingCard(),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomAction(),
    );
  }

  Widget _buildSliverAppBar(Apartment apt) {
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      backgroundColor: const Color(0xFF0B6C5F),
      flexibleSpace: FlexibleSpaceBar(
        background: apt.images.isEmpty
            ? Container(
            color: Colors.grey[300],
            child: const Icon(Icons.home, size: 100, color: Colors.white))
            : Stack(
          alignment: Alignment.bottomCenter,
          children: [
            PageView.builder(
              itemCount: apt.images.length,
              onPageChanged: (index) =>
                  setState(() => _currentImageIndex = index),
              itemBuilder: (context, index) {
                return Image.network(
                  _formatImageUrl(apt.images[index]),
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image)),
                );
              },
            ),
            if (apt.images.length > 1)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                      apt.images.length,
                          (index) => Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentImageIndex == index
                              ? Colors.white
                              : Colors.white54,
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
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      alignment: WrapAlignment.spaceAround,
      children: [
        _featureItem(Icons.king_bed, "${apt.numberOfRooms ?? 0} Rooms"),
        _featureItem(Icons.bathtub, "${apt.numberOfBathrooms ?? 0} Baths"),
        _featureItem(Icons.square_foot, "${apt.space.toStringAsFixed(0)} m²"),
        if (apt.hasElevator) _featureItem(Icons.elevator, "Elevator"),
        if (apt.hasBalcony) _featureItem(Icons.balcony, "Balcony"),
      ],
    );
  }

  Widget _featureItem(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFF0B6C5F), size: 28),
        const SizedBox(height: 5),
        Text(label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
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
                Text(
                    _selectedDateRange == null
                        ? "Select Dates"
                        : "Selected Period",
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
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            disabledBackgroundColor: Colors.grey,
          ),
          onPressed: (_selectedDateRange == null || _isBooking)
              ? null
              : _handleBooking,
          child: _isBooking
              ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2))
              : const Text("BOOK THIS APARTMENT",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
        ),
      ),
    );
  }

  Future<void> _selectBookingDates() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF0B6C5F)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDateRange = picked);
    }
  }

// ===========================
// الدالة الأساسية لحجز الشقة
// ===========================
  Future<void> _handleBooking() async {
    if (_selectedDateRange == null) return;

    setState(() => _isBooking = true);

    final result = await _apiRepository.sendBookingRequest(
      widget.apartment.id,
      _selectedDateRange!,
    );

    setState(() => _isBooking = false);

    if (result['success'] == true || result.containsKey('booking')) {

      Get.snackbar(
        "Success",
        "Booking request sent!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      String errorMsg = result['message'] ?? "This apartment is not available";

      Get.defaultDialog(
        title: "Booking Failed",
        middleText: errorMsg,
        textConfirm: "Change Date",
        confirmTextColor: Colors.white,
        buttonColor: const Color(0xFF0B6C5F),
        onConfirm: () {
          Get.back();
          _selectBookingDates();
        },
      );
    }
  }
}*/
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_repository.dart';
import '../services/config.dart';
import 'Apartment.dart';

class ApartmentDetailsPage extends StatefulWidget {
  final Apartment apartment;
  const ApartmentDetailsPage({super.key, required this.apartment});

  @override
  State<ApartmentDetailsPage> createState() => _ApartmentDetailsPageState();
}

class _ApartmentDetailsPageState extends State<ApartmentDetailsPage> {
  final ApiRepository _apiRepository = ApiRepository();
  DateTimeRange? _selectedDateRange;
  bool _isBooking = false;
  int _currentImageIndex = 0;

  String _formatImageUrl(String imagePath) {
    if (imagePath.isEmpty) return "https://via.placeholder.com/300";
    if (imagePath.startsWith('http')) return imagePath;
    final String baseUrl = ApiConfig.baseUrl.replaceAll('/api', '');
    String cleanPath = imagePath.startsWith('/') ? imagePath : '/$imagePath';
    return "$baseUrl$cleanPath";
  }

  @override
  Widget build(BuildContext context) {
    final apt = widget.apartment;
    final colorScheme = Theme.of(context).colorScheme; // سحب الثيم

    return Scaffold(
      backgroundColor: colorScheme.surface, // استخدام اللون البيج كخلفية
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(apt, colorScheme),
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
                        child: Text(
                          apt.title ?? "No Title",
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.secondary), // العنابي للعنوان
                        ),
                      ),
                      Text("${apt.price.toStringAsFixed(0)} SYP",
                          style: TextStyle(
                              fontSize: 20,
                              color: colorScheme.primary, // الفيروزي للسعر
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // الموقع
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: colorScheme.primary),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text("${apt.governorate}, ${apt.city}",
                            style: const TextStyle(color: Colors.grey)),
                      ),
                    ],
                  ),
                  if (apt.addressDetails != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 5, left: 21),
                      child: Text(apt.addressDetails!,
                          style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    ),
                  const Divider(height: 30),
                  // شبكة المواصفات
                  _buildFeaturesGrid(apt, colorScheme),
                  const SizedBox(height: 30),
                  // الوصف
                  Text("Description",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.secondary)),
                  const SizedBox(height: 10),
                  Text(apt.description ?? "No description provided.",
                      style: TextStyle(color: Colors.grey[800], height: 1.5, fontSize: 15)),
                  const SizedBox(height: 30),
                  // قسم اختيار التاريخ
                  Text("Reservation Period",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.secondary)),
                  const SizedBox(height: 10),
                  _buildBookingCard(colorScheme),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomAction(colorScheme),
    );
  }

  Widget _buildSliverAppBar(Apartment apt, ColorScheme colorScheme) {
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      backgroundColor: colorScheme.primary, // الفيروزي للـ AppBar
      flexibleSpace: FlexibleSpaceBar(
        background: apt.images.isEmpty
            ? Container(
            color: Colors.grey[300],
            child: const Icon(Icons.home, size: 100, color: Colors.white))
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
                  children: List.generate(
                      apt.images.length,
                          (index) => Container(
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

  Widget _buildFeaturesGrid(Apartment apt, ColorScheme colorScheme) {
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      alignment: WrapAlignment.spaceAround,
      children: [
        _featureItem(Icons.king_bed, "${apt.numberOfRooms ?? 0} Rooms", colorScheme),
        _featureItem(Icons.bathtub, "${apt.numberOfBathrooms ?? 0} Baths", colorScheme),
        _featureItem(Icons.square_foot, "${apt.space.toStringAsFixed(0)} m²", colorScheme),
        if (apt.hasElevator) _featureItem(Icons.elevator, "Elevator", colorScheme),
        if (apt.hasBalcony) _featureItem(Icons.balcony, "Balcony", colorScheme),
      ],
    );
  }

  Widget _featureItem(IconData icon, String label, ColorScheme colorScheme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: colorScheme.primary, size: 28), // الفيروزي للأيقونات
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildBookingCard(ColorScheme colorScheme) {
    return GestureDetector(
      onTap: _selectBookingDates,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_month, color: colorScheme.primary),
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
            Icon(Icons.edit, size: 18, color: colorScheme.secondary.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomAction(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: const Border(top: BorderSide(color: Colors.black12)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary, // الفيروزي للزر
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            disabledBackgroundColor: Colors.grey,
          ),
          onPressed: (_selectedDateRange == null || _isBooking) ? null : _handleBooking,
          child: _isBooking
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text("BOOK THIS APARTMENT",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ),
    );
  }

  Future<void> _selectBookingDates() async {
    final colorScheme = Theme.of(context).colorScheme;
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(colorScheme: colorScheme),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDateRange = picked);
    }
  }

  Future<void> _handleBooking() async {
    if (_selectedDateRange == null) return;
    final colorScheme = Theme.of(context).colorScheme;

    setState(() => _isBooking = true);

    final result = await _apiRepository.sendBookingRequest(
      widget.apartment.id,
      _selectedDateRange!,
    );

    setState(() => _isBooking = false);

    if (result['success'] == true || result.containsKey('booking')) {
      Get.snackbar("Success", "Booking request sent!",
          backgroundColor: Colors.green, colorText: Colors.white);
    } else {
      String errorMsg = result['message'] ?? "This apartment is not available";
      Get.defaultDialog(
        title: "Booking Failed",
        middleText: errorMsg,
        textConfirm: "Change Date",
        confirmTextColor: Colors.white,
        buttonColor: colorScheme.primary,
        onConfirm: () {
          Get.back();
          _selectBookingDates();
        },
      );
    }
  }
}