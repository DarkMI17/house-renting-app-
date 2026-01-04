import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
    final data = await apiRepository.fetchUserReservations();
    setState(() {
      myBookings = data;
      isLoading = false;
    });
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

    if (confirm) {
      final success = await apiRepository.removeUserReservation(id);
      if (success) {
        Get.snackbar("Success", "Booking cancelled successfully");
        _fetchMyBookings();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Color _getStatusColor(String? status) {
      switch (status?.toLowerCase()) {
        case 'approved':
          return Colors.green;
        case 'cancelled':
          return Colors.red;
        case 'pending':
          return Colors.orange;
        case 'modified_pending':
          return Colors.blue;
        default:
          return Colors.grey;
      }
    }
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
          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              title: Text(
                "Apartment ID: ${booking['apartment_id']}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              // هنا نضع التعديل الجديد (الترجمة الملونة للحالة)
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black87, fontSize: 14),
                    children: [
                      TextSpan(text: "From: ${booking['start_date']} To: ${booking['end_date']}\n"),
                      const TextSpan(
                          text: "Status: ",
                          style: TextStyle(fontWeight: FontWeight.bold, height: 1.5)
                      ),
                      TextSpan(
                        text: "${booking['status']}".toUpperCase(),
                        style: TextStyle(
                          color: _getStatusColor(booking['status']), // استدعاء دالة الألوان
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              isThreeLine: true,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // زر التعديل
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _editBookingDates(
                      booking['id'],
                      booking['start_date'],
                      booking['end_date'],
                    ),
                  ),
                  // زر الحذف (الإلغاء)
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
    // 1. اختيار التاريخ الجديد (مثال مبسط)
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
}