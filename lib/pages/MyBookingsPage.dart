import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart'; // المكتبة الجديدة
import '../services/api_repository.dart';

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  final ApiRepository apiRepository = ApiRepository();
  List<dynamic> myBookings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMyBookings();
  }

  Future<void> _fetchMyBookings() async {
    setState(() => isLoading = true);
    final data = await apiRepository.fetchUserReservations();
    setState(() {
      myBookings = data;
      isLoading = false;
    });
  }

  // --- دالة إظهار نافذة التقييم ---
  void _showReviewDialog(int apartmentId) {
    final TextEditingController _commentController = TextEditingController();
    double _currentRating = 3.0;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Rate Your Stay", textAlign: TextAlign.center),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("How would you rate this apartment?"),
              const SizedBox(height: 15),
              RatingBar.builder(
                initialRating: 3,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                onRatingUpdate: (rating) => _currentRating = rating,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _commentController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Write your feedback here...",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            onPressed: () async {
              final result = await apiRepository.addReview(
                apartmentId,
                _currentRating,
                _commentController.text,
              );
              Get.back();
              Get.snackbar(
                result['success'] ? "Success" : "Note",
                result['message'],
                backgroundColor: result['success'] ? Colors.green : Colors.orange,
                colorText: Colors.white,
              );
            },
            child: const Text("Submit Review"),
          ),
        ],
      ),
    );
  }

  // دالة الحذف (Cancel)
  void _cancelBooking(int id) async {
    bool confirm = await Get.dialog(
      AlertDialog(
        title: const Text("Cancel Booking"),
        content: const Text("Are you sure you want to cancel this booking?"),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text("No")),
          TextButton(onPressed: () => Get.back(result: true), child: const Text("Yes, Cancel", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      final success = await apiRepository.removeUserReservation(id);
      if (success) {
        Get.snackbar("Success", "Booking cancelled successfully");
        _fetchMyBookings();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Bookings"), backgroundColor: Colors.teal),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : myBookings.isEmpty
          ? const Center(child: Text("You have no bookings yet"))
          : ListView.builder(
        itemCount: myBookings.length,
        itemBuilder: (context, index) {
          final booking = myBookings[index];

          // --- منطق شروط الأزرار ---
          final bool isApproved = booking['status'].toString().toLowerCase() == 'approved';
          DateTime endDate = DateTime.parse(booking['end_date']);
          final bool isExpired = DateTime.now().isAfter(endDate);

          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              title: Text(
                "Apartment ID: ${booking['apartment_id']}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black87, fontSize: 14),
                    children: [
                      TextSpan(text: "From: ${booking['start_date']} To: ${booking['end_date']}\n"),
                      const TextSpan(text: "Status: ", style: TextStyle(fontWeight: FontWeight.bold, height: 1.5)),
                      TextSpan(
                        text: "${booking['status']}".toUpperCase(),
                        style: TextStyle(
                          color: _getStatusColor(booking['status']),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. زر التقييم (يظهر فقط إذا تم قبول الحجز وانتهت مدته)
                  if (isApproved && isExpired)
                    IconButton(
                      icon: const Icon(Icons.rate_review, color: Colors.orange),
                      onPressed: () => _showReviewDialog(booking['apartment_id']),
                    ),

                  // 2. زر التعديل (يظهر إذا كان الحجز لم ينتهِ بعد)
                  if (!isExpired)
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _editBookingDates(
                        booking['id'],
                        booking['start_date'],
                        booking['end_date'],
                      ),
                    ),

                  // 3. زر الحذف
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _cancelBooking(booking['id']),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _editBookingDates(int id, String currentStart, String currentEnd) async {
    DateTimeRange? newRange = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(
        start: DateTime.parse(currentStart),
        end: DateTime.parse(currentEnd),
      ),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (newRange != null) {
      setState(() => isLoading = true);
      final result = await apiRepository.modifyReservationDates(
        id,
        newRange.start.toIso8601String().split('T')[0],
        newRange.end.toIso8601String().split('T')[0],
      );

      if (result['success']) {
        Get.snackbar("Success", "Booking dates updated");
        _fetchMyBookings();
      } else {
        Get.snackbar("Error", result['message']);
        setState(() => isLoading = false);
      }
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved': return Colors.green;
      case 'cancelled': return Colors.red;
      case 'pending': return Colors.orange;
      case 'modified_pending': return Colors.blue;
      default: return Colors.grey;
    }
  }
}