/*
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
}*/


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Added for better image handling
import '../services/api_repository.dart';
import '../services/config.dart';
import '../services/services/storage_service.dart'; // Added for user check
import 'Apartment.dart';
import 'review_dialog.dart'; // Added for review functionality

class ApartmentDetailsPage extends StatefulWidget {
  final Apartment apartment;
  final double initialAverageRating;
  final int initialReviewCount;

  const ApartmentDetailsPage({
    super.key,
    required this.apartment,
    this.initialAverageRating = 0.0,
    this.initialReviewCount = 0,
  });

  @override
  State<ApartmentDetailsPage> createState() => _ApartmentDetailsPageState();
}

class _ApartmentDetailsPageState extends State<ApartmentDetailsPage> {
  final ApiRepository _apiRepository = ApiRepository();
  DateTimeRange? _selectedDateRange;
  bool _isBooking = false;
  int _currentImageIndex = 0;

  // Review state - From ApartmentDetailsPage.dart
  double _averageRating = 0.0;
  int _reviewCount = 0;
  List<dynamic> _reviews = [];
  bool _loadingReviews = false;
  Map<String, dynamic>? _currentUserReview;

  @override
  void initState() {
    super.initState();
    // Initialize with passed values
    _averageRating = widget.initialAverageRating;
    _reviewCount = widget.initialReviewCount;
    _loadReviewsAndUserData();
  }

  // ============== REVIEW LOGIC (EXACT NAMES) ==============

  Future<void> _loadReviewsAndUserData() async {
    await _fetchReviews();
    await _checkUserReview();
  }

  Future<void> _fetchReviews() async {
    setState(() => _loadingReviews = true);
    try {
      final reviews = await _apiRepository.getApartmentReviews(widget.apartment.id);
      if (reviews.isNotEmpty) {
        final totalRating = reviews.fold<double>(0, (sum, review) => sum + (review['rating'] ?? 0).toDouble());
        _averageRating = totalRating / reviews.length;
        _reviewCount = reviews.length;
      } else {
        _averageRating = 0.0;
        _reviewCount = 0;
      }
      setState(() {
        _reviews = reviews;
        _loadingReviews = false;
      });
    } catch (e) {
      setState(() => _loadingReviews = false);
      print('Error fetching reviews: $e');
    }
  }

  Future<void> _checkUserReview() async {
    try {
      final userStr = StorageService.getUser();
      if (userStr != null) {
        final user = jsonDecode(userStr);
        for (var review in _reviews) {
          if (review['user_id'] == user['id']) {
            setState(() => _currentUserReview = review);
            break;
          }
        }
      }
    } catch (e) {
      print('Error checking user review: $e');
    }
  }

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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(apt, colorScheme),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          apt.title ?? "No Title",
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.secondary),
                        ),
                      ),
                      Text("${apt.price.toStringAsFixed(0)} SYP",
                          style: TextStyle(
                              fontSize: 20,
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Location
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

                  // Features Grid
                  _buildFeaturesGrid(apt, colorScheme),
                  const SizedBox(height: 30),

                  // Description
                  Text("Description",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.secondary)),
                  const SizedBox(height: 10),
                  Text(apt.description ?? "No description provided.",
                      style: TextStyle(color: Colors.grey[800], height: 1.5, fontSize: 15)),
                  const SizedBox(height: 30),

                  // RATINGS & REVIEWS SECTION - Integrated here
                  _buildRatingsSection(colorScheme),
                  const SizedBox(height: 30),

                  // Reservation Period
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
      backgroundColor: colorScheme.primary,
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
                return CachedNetworkImage(
                  imageUrl: _formatImageUrl(apt.images[index]),
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, size: 60, color: Colors.grey),
                  ),
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
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentImageIndex == index ? Colors.white : Colors.white54,
                      ),
                    ),
                  ),
                ),
              ),

            // Rating overlay on image
            if (_averageRating > 0)
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 6),
                      Text(_averageRating.toStringAsFixed(1),
                          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 4),
                      Text("($_reviewCount)",
                          style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Get.back(),
      ),
    );
  }

  // ============== FEATURES AND UI HELPERS ==============

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
        Icon(icon, color: colorScheme.primary, size: 28),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_selectedDateRange == null ? "Select Dates" : "Selected Period",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(_selectedDateRange == null
                      ? "Pick check-in and check-out dates"
                      : "${_selectedDateRange!.start.toString().split(' ')[0]} to ${_selectedDateRange!.end.toString().split(' ')[0]}",
                      style: const TextStyle(fontSize: 13, color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(width: 10),
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
            backgroundColor: colorScheme.primary,
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

  // ============== REVIEWS UI SECTION (EXACT LOGIC) ==============

  Widget _buildRatingsSection(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Ratings & Reviews", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.secondary)),
        const SizedBox(height: 15),
        Row(
          children: [
            _buildRatingStars(_averageRating, size: 28),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_averageRating > 0 ? _averageRating.toStringAsFixed(1) : "No rating",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _averageRating > 0 ? colorScheme.primary : Colors.grey[500])),
                Text("$_reviewCount ${_reviewCount == 1 ? 'review' : 'reviews'}",
                    style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (_currentUserReview == null && _reviews.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            child: ElevatedButton(
              onPressed: () => _showAddReviewDialog(),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary.withOpacity(0.1),
                foregroundColor: colorScheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: colorScheme.primary)),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Icon(Icons.star_border), SizedBox(width: 10), Text("Write a Review")],
              ),
            ),
          ),
        if (_loadingReviews)
          const Center(child: CircularProgressIndicator())
        else if (_reviews.isEmpty)
          Center(child: Text("No reviews yet", style: TextStyle(color: Colors.grey[400])))
        else
          Column(
            children: [
              if (_currentUserReview != null) _buildReviewCard(_currentUserReview!, colorScheme, isUsersReview: true),
              ..._reviews.where((review) => review['user_id'] != (_currentUserReview?['user_id'])).map(
                    (review) => _buildReviewCard(review, colorScheme),
              ).toList(),
            ],
          ),
      ],
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review, ColorScheme colorScheme, {bool isUsersReview = false}) {
    final user = review['user'] ?? {};
    final userName = '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'.trim();

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isUsersReview ? BorderSide(color: colorScheme.primary.withOpacity(0.3), width: 1.5) : BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(userName.isNotEmpty ? userName : "Anonymous", style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.secondary)),
                if (isUsersReview)
                  Row(
                    children: [
                      IconButton(icon: Icon(Icons.edit, size: 18, color: colorScheme.primary), onPressed: () => _showEditReviewDialog(review)),
                      IconButton(icon: const Icon(Icons.delete, size: 18, color: Colors.red), onPressed: () => _deleteReview(review['id'])),
                    ],
                  ),
              ],
            ),
            _buildRatingStars((review['rating'] ?? 0).toDouble(), size: 16),
            const SizedBox(height: 10),
            if (review['comment'] != null) Text(review['comment'].toString(), style: const TextStyle(color: Colors.grey, height: 1.5)),
            const SizedBox(height: 10),
            Text(_formatReviewDate(review['created_at'] ?? ''), style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingStars(double rating, {double size = 24}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < rating.floor()) return Icon(Icons.star, color: Colors.amber, size: size);
        if (index < rating.ceil()) return Icon(Icons.star_half, color: Colors.amber, size: size);
        return Icon(Icons.star_border, color: Colors.grey[300], size: size);
      }),
    );
  }

  String _formatReviewDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final difference = DateTime.now().difference(date);
      if (difference.inMinutes < 60) return '${difference.inMinutes} min ago';
      if (difference.inHours < 24) return '${difference.inHours} hours ago';
      return '${difference.inDays} days ago';
    } catch (e) { return dateString; }
  }

  // ============== REVIEW ACTIONS (EXACT NAMES) ==============

  void _showAddReviewDialog() {
    Get.dialog(ReviewDialog(
      apartmentId: widget.apartment.id,
      onSubmit: (rating, comment) async {
        final result = await _apiRepository.addReview(widget.apartment.id, rating, comment);
        if (result['success'] == true) {
          Get.snackbar("Success", "Review added!", backgroundColor: Colors.green, colorText: Colors.white);
          await _loadReviewsAndUserData();
        }
      },
    ));
  }

  void _showEditReviewDialog(Map<String, dynamic> review) {
    Get.dialog(ReviewDialog(
      apartmentId: widget.apartment.id,
      onSubmit: (rating, comment) async {
        final result = await _apiRepository.updateReview(review['id'], rating, comment);
        if (result['success'] == true) {
          Get.snackbar("Success", "Review updated!", backgroundColor: Colors.green, colorText: Colors.white);
          await _loadReviewsAndUserData();
        }
      },
      initialRating: review['rating'],
      initialComment: review['comment']?.toString(),
      isEditMode: true,
    ));
  }

  Future<void> _deleteReview(int reviewId) async {
    final confirm = await Get.dialog(AlertDialog(
      title: const Text("Delete Review"),
      content: const Text("Are you sure?"),
      actions: [
        TextButton(onPressed: () => Get.back(result: false), child: const Text("Cancel")),
        TextButton(onPressed: () => Get.back(result: true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
      ],
    ));
    if (confirm == true) {
      final result = await _apiRepository.deleteReview(reviewId);
      if (result['success'] == true) {
        Get.snackbar("Success", "Deleted!", backgroundColor: Colors.green, colorText: Colors.white);
        await _loadReviewsAndUserData();
      }
    }
  }

  // ============== BOOKING METHODS ==============

  Future<void> _selectBookingDates() async {
    final colorScheme = Theme.of(context).colorScheme;
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _selectedDateRange,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(data: Theme.of(context).copyWith(colorScheme: colorScheme), child: child!),
    );
    if (picked != null) setState(() => _selectedDateRange = picked);
  }

  Future<void> _handleBooking() async {
    if (_selectedDateRange == null) return;
    setState(() => _isBooking = true);
    final result = await _apiRepository.sendBookingRequest(widget.apartment.id, _selectedDateRange!);
    setState(() => _isBooking = false);
    if (result['success'] == true || result.containsKey('booking')) {
      Get.snackbar("Success", "Booking request sent!", backgroundColor: Colors.green, colorText: Colors.white);
    } else {
      Get.defaultDialog(
        title: "Booking Failed",
        middleText: result['message'] ?? "Not available",
        textConfirm: "Change Date",
        onConfirm: () { Get.back(); _selectBookingDates(); },
      );
    }
  }
}