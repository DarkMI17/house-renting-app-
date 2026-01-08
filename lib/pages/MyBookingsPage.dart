/*import 'package:flutter/material.dart';
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
}*/
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

  // دالة الحذف (Cancel) مع تعديل الألوان لتناسب الثيم
  void _cancelBooking(int id) async {
    final colorScheme = Theme.of(context).colorScheme;

    bool confirm = await Get.dialog(
      AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text("Cancel Booking", style: TextStyle(color: colorScheme.primary)),
        content: const Text("Are you sure you want to cancel this booking?"),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: Text("No", style: TextStyle(color: colorScheme.secondary))),
          TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text("Yes, Cancel", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );

    if (confirm) {
      final success = await apiRepository.removeUserReservation(id);
      if (success) {
        Get.snackbar("Success", "Booking cancelled successfully",
            backgroundColor: colorScheme.primary, colorText: Colors.white);
        _fetchMyBookings();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // جلب الثيم الموحد
    final colorScheme = Theme.of(context).colorScheme;

    // دالة الألوان للحالات (Statuses)
    Color _getStatusColor(String? status) {
      switch (status?.toLowerCase()) {
        case 'approved':
          return Colors.green;
        case 'cancelled':
          return colorScheme.error; // استخدام لون الخطأ من الثيم
        case 'pending':
          return Colors.orange;
        case 'modified_pending':
          return colorScheme.primary; // استخدام الفيروزي للحالة المعلقة المعدلة
        default:
          return Colors.grey;
      }
    }

    return Scaffold(
      backgroundColor: colorScheme.surface, // خلفية بيج
      appBar: AppBar(
        title: const Text("My Bookings", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: colorScheme.primary, // فيروزي
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
          : myBookings.isEmpty
          ? const Center(child: Text("You have no bookings yet"))
          : ListView.builder(
        itemCount: myBookings.length,
        itemBuilder: (context, index) {
          final booking = myBookings[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            color: Colors.white, // كرت أبيض نظيف
            child: ListTile(
              contentPadding: const EdgeInsets.all(15),
              title: Text(
                "Apartment ID: ${booking['apartment_id']}",
                style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.secondary), // عنابي
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black87, fontSize: 14),
                    children: [
                      TextSpan(text: "From: ${booking['start_date']} To: ${booking['end_date']}\n"),
                      const TextSpan(
                          text: "Status: ",
                          style: TextStyle(fontWeight: FontWeight.bold, height: 2.0)
                      ),
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
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // زر التعديل (أزرق خفيف أو لون ثانوي)
                      IconButton(
                        icon: Icon(Icons.edit, color: colorScheme.primary),
                        onPressed: () => _editBookingDates(
                          booking['id'],
                          booking['start_date'],
                          booking['end_date'],
                        ),
                      ),
                      // زر الحذف
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () => _cancelBooking(booking['id']),
                      ),
                    ],
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
    final colorScheme = Theme.of(context).colorScheme;

    DateTimeRange? newRange = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(
        start: DateTime.parse(currentStart),
        end: DateTime.parse(currentEnd),
      ),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: colorScheme, // ضمان ظهور منقي التاريخ بألوانك
          ),
          child: child!,
        );
      },
    );

    if (newRange != null) {
      setState(() => isLoading = true);
      final result = await apiRepository.modifyReservationDates(
        id,
        newRange.start.toIso8601String().split('T')[0],
        newRange.end.toIso8601String().split('T')[0],
      );

      if (result['success']) {
        Get.snackbar("Success", "Booking dates updated",
            backgroundColor: colorScheme.primary, colorText: Colors.white);
        _fetchMyBookings();
      } else {
        Get.snackbar("Error", result['message'], backgroundColor: Colors.red, colorText: Colors.white);
        setState(() => isLoading = false);
      }
    }
  }
}