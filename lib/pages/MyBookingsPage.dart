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
}*/
// /*import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../services/api_repository.dart';
//
// class MyBookingsPage extends StatefulWidget {
//   const MyBookingsPage({super.key});
//
//   @override
//   State<MyBookingsPage> createState() => _MyBookingsPageState();
// }
//
// class _MyBookingsPageState extends State<MyBookingsPage> {
//   final ApiRepository apiRepository = ApiRepository();
//   List<dynamic> myBookings = [];
//   bool isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchMyBookings();
//   }
//
//   Future<void> _fetchMyBookings() async {
//     final data = await apiRepository.fetchUserReservations();
//     setState(() {
//       myBookings = data;
//       isLoading = false;
//     });
//   }
//
//   // دالة الحذف (Cancel)
//   void _cancelBooking(int id) async {
//     bool confirm = await Get.dialog(
//       AlertDialog(
//         title: const Text("Cancel Booking"),
//         content: const Text("Are you sure you want to cancel this booking?"),
//         actions: [
//           TextButton(onPressed: () => Get.back(result: false), child: const Text("No")),
//           TextButton(onPressed: () => Get.back(result: true), child: const Text("Yes, Cancel", style: TextStyle(color: Colors.red))),
//         ],
//       ),
//     );
//
//     if (confirm) {
//       final success = await apiRepository.removeUserReservation(id);
//       if (success) {
//         Get.snackbar("Success", "Booking cancelled successfully");
//         _fetchMyBookings();
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     Color _getStatusColor(String? status) {
//       switch (status?.toLowerCase()) {
//         case 'approved':
//           return Colors.green;
//         case 'cancelled':
//           return Colors.red;
//         case 'pending':
//           return Colors.orange;
//         case 'modified_pending':
//           return Colors.blue;
//         default:
//           return Colors.grey;
//       }
//     }
//     return Scaffold(
//       appBar: AppBar(title: const Text("My Bookings"), backgroundColor: Colors.teal),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : myBookings.isEmpty
//           ? const Center(child: Text("You have no bookings yet"))
//           : ListView.builder(
//         itemCount: myBookings.length,
//         itemBuilder: (context, index) {
//           final booking = myBookings[index];
//           return Card(
//             margin: const EdgeInsets.all(10),
//             child: ListTile(
//               title: Text(
//                 "Apartment ID: ${booking['apartment_id']}",
//                 style: const TextStyle(fontWeight: FontWeight.bold),
//               ),
//               // هنا نضع التعديل الجديد (الترجمة الملونة للحالة)
//               subtitle: Padding(
//                 padding: const EdgeInsets.only(top: 8.0),
//                 child: RichText(
//                   text: TextSpan(
//                     style: const TextStyle(color: Colors.black87, fontSize: 14),
//                     children: [
//                       TextSpan(text: "From: ${booking['start_date']} To: ${booking['end_date']}\n"),
//                       const TextSpan(
//                           text: "Status: ",
//                           style: TextStyle(fontWeight: FontWeight.bold, height: 1.5)
//                       ),
//                       TextSpan(
//                         text: "${booking['status']}".toUpperCase(),
//                         style: TextStyle(
//                           color: _getStatusColor(booking['status']), // استدعاء دالة الألوان
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               isThreeLine: true,
//               trailing: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // زر التعديل
//                   IconButton(
//                     icon: const Icon(Icons.edit, color: Colors.blue),
//                     onPressed: () => _editBookingDates(
//                       booking['id'],
//                       booking['start_date'],
//                       booking['end_date'],
//                     ),
//                   ),
//                   // زر الحذف (الإلغاء)
//                   IconButton(
//                     icon: const Icon(Icons.delete, color: Colors.red),
//                     onPressed: () => _cancelBooking(booking['id']),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//   void _editBookingDates(int id, String currentStart, String currentEnd) async {
//     // 1. اختيار التاريخ الجديد (مثال مبسط)
//     DateTimeRange? newRange = await showDateRangePicker(
//       context: context,
//       initialDateRange: DateTimeRange(
//         start: DateTime.parse(currentStart),
//         end: DateTime.parse(currentEnd),
//       ),
//       firstDate: DateTime.now(),
//       lastDate: DateTime.now().add(const Duration(days: 365)),
//     );
//
//     if (newRange != null) {
//       setState(() => isLoading = true);
//       final result = await apiRepository.modifyReservationDates(
//         id,
//         newRange.start.toIso8601String().split('T')[0],
//         newRange.end.toIso8601String().split('T')[0],
//       );
//
//       if (result['success']) {
//         Get.snackbar("Success", "Booking dates updated");
//         _fetchMyBookings();
//       } else {
//         Get.snackbar("Error", result['message']);
//         setState(() => isLoading = false);
//       }
//     }
//   }
// }*/
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../services/api_repository.dart';
//
// class MyBookingsPage extends StatefulWidget {
//   const MyBookingsPage({super.key});
//
//   @override
//   State<MyBookingsPage> createState() => _MyBookingsPageState();
// }
//
// class _MyBookingsPageState extends State<MyBookingsPage> {
//   final ApiRepository apiRepository = ApiRepository();
//   List<dynamic> myBookings = [];
//   bool isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchMyBookings();
//   }
//
//   Future<void> _fetchMyBookings() async {
//     final data = await apiRepository.fetchUserReservations();
//     setState(() {
//       myBookings = data;
//       isLoading = false;
//     });
//   }
//
//   // دالة الحذف (Cancel) مع تعديل الألوان لتناسب الثيم
//   void _cancelBooking(int id) async {
//     final colorScheme = Theme.of(context).colorScheme;
//
//     bool confirm = await Get.dialog(
//       AlertDialog(
//         backgroundColor: colorScheme.surface,
//         title: Text("Cancel Booking", style: TextStyle(color: colorScheme.primary)),
//         content: const Text("Are you sure you want to cancel this booking?"),
//         actions: [
//           TextButton(onPressed: () => Get.back(result: false), child: Text("No", style: TextStyle(color: colorScheme.secondary))),
//           TextButton(
//               onPressed: () => Get.back(result: true),
//               child: const Text("Yes, Cancel", style: TextStyle(color: Colors.red))
//           ),
//         ],
//       ),
//     );
//
//     if (confirm) {
//       final success = await apiRepository.removeUserReservation(id);
//       if (success) {
//         Get.snackbar("Success", "Booking cancelled successfully",
//             backgroundColor: colorScheme.primary, colorText: Colors.white);
//         _fetchMyBookings();
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // جلب الثيم الموحد
//     final colorScheme = Theme.of(context).colorScheme;
//
//     // دالة الألوان للحالات (Statuses)
//     Color _getStatusColor(String? status) {
//       switch (status?.toLowerCase()) {
//         case 'approved':
//           return Colors.green;
//         case 'cancelled':
//           return colorScheme.error; // استخدام لون الخطأ من الثيم
//         case 'pending':
//           return Colors.orange;
//         case 'modified_pending':
//           return colorScheme.primary; // استخدام الفيروزي للحالة المعلقة المعدلة
//         default:
//           return Colors.grey;
//       }
//     }
//
//     return Scaffold(
//       backgroundColor: colorScheme.surface, // خلفية بيج
//       appBar: AppBar(
//         title: const Text("My Bookings", style: TextStyle(fontWeight: FontWeight.bold)),
//         backgroundColor: colorScheme.primary, // فيروزي
//         foregroundColor: Colors.white,
//         centerTitle: true,
//         elevation: 0,
//       ),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
//           : myBookings.isEmpty
//           ? const Center(child: Text("You have no bookings yet"))
//           : ListView.builder(
//         itemCount: myBookings.length,
//         itemBuilder: (context, index) {
//           final booking = myBookings[index];
//           return Card(
//             elevation: 2,
//             margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//             color: Colors.white, // كرت أبيض نظيف
//             child: ListTile(
//               contentPadding: const EdgeInsets.all(15),
//               title: Text(
//                 "Apartment ID: ${booking['apartment_id']}",
//                 style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.secondary), // عنابي
//               ),
//               subtitle: Padding(
//                 padding: const EdgeInsets.only(top: 8.0),
//                 child: RichText(
//                   text: TextSpan(
//                     style: const TextStyle(color: Colors.black87, fontSize: 14),
//                     children: [
//                       TextSpan(text: "From: ${booking['start_date']} To: ${booking['end_date']}\n"),
//                       const TextSpan(
//                           text: "Status: ",
//                           style: TextStyle(fontWeight: FontWeight.bold, height: 2.0)
//                       ),
//                       TextSpan(
//                         text: "${booking['status']}".toUpperCase(),
//                         style: TextStyle(
//                           color: _getStatusColor(booking['status']),
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               trailing: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       // زر التعديل (أزرق خفيف أو لون ثانوي)
//                       IconButton(
//                         icon: Icon(Icons.edit, color: colorScheme.primary),
//                         onPressed: () => _editBookingDates(
//                           booking['id'],
//                           booking['start_date'],
//                           booking['end_date'],
//                         ),
//                       ),
//                       // زر الحذف
//                       IconButton(
//                         icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
//                         onPressed: () => _cancelBooking(booking['id']),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   void _editBookingDates(int id, String currentStart, String currentEnd) async {
//     final colorScheme = Theme.of(context).colorScheme;
//
//     DateTimeRange? newRange = await showDateRangePicker(
//       context: context,
//       initialDateRange: DateTimeRange(
//         start: DateTime.parse(currentStart),
//         end: DateTime.parse(currentEnd),
//       ),
//       firstDate: DateTime.now(),
//       lastDate: DateTime.now().add(const Duration(days: 365)),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: colorScheme, // ضمان ظهور منقي التاريخ بألوانك
//           ),
//           child: child!,
//         );
//       },
//     );
//
//     if (newRange != null) {
//       setState(() => isLoading = true);
//       final result = await apiRepository.modifyReservationDates(
//         id,
//         newRange.start.toIso8601String().split('T')[0],
//         newRange.end.toIso8601String().split('T')[0],
//       );
//
//       if (result['success']) {
//         Get.snackbar("Success", "Booking dates updated",
//             backgroundColor: colorScheme.primary, colorText: Colors.white);
//         _fetchMyBookings();
//       } else {
//         Get.snackbar("Error", result['message'], backgroundColor: Colors.red, colorText: Colors.white);
//         setState(() => isLoading = false);
//       }
//     }
//   }
// }

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_repository.dart';
import '../services/services/storage_service.dart';
import 'Apartment.dart';
import 'ApartmentDetailsPage.dart';
import 'review_dialog.dart'; // Make sure you import this

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
    try {
      final data = await apiRepository.fetchUserReservations();
      setState(() {
        myBookings = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print('Error fetching bookings: $e');
    }
  }

  Future<void> _cancelBooking(int id) async {
    final colorScheme = Theme.of(context).colorScheme;

    bool confirm = await Get.dialog(
      AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text("Cancel Booking", style: TextStyle(color: colorScheme.primary)),
        content: const Text("Are you sure you want to cancel this booking?"),
        actions: [
          TextButton(
              onPressed: () => Get.back(result: false),
              child: Text("No", style: TextStyle(color: colorScheme.secondary))
          ),
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
        Get.snackbar(
          "Success",
          "Booking cancelled successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        _fetchMyBookings();
      } else {
        Get.snackbar(
          "Error",
          "Failed to cancel booking",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  // NEW METHOD: Direct review from booking
  // Replace your _rateApartmentFromBooking method with this one:

  void _rateApartmentFromBooking(Map<String, dynamic> booking) async {
    final colorScheme = Theme.of(context).colorScheme;
    final apartmentId = booking['apartment_id'];

    print('Starting review process for apartment ID: $apartmentId');

    try {
      // First check if user is logged in
      final userStr = StorageService.getUser();
      if (userStr == null) {
        Get.snackbar(
          "Error",
          "Please login to leave a review",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final user = jsonDecode(userStr);
      print('User ID: ${user['id']}');

      // Check if user already reviewed this apartment
      print('Fetching reviews for apartment $apartmentId...');
      final reviews = await apiRepository.getApartmentReviews(apartmentId);
      print('Found ${reviews.length} reviews');

      Map<String, dynamic>? userReview;
      for (var review in reviews) {
        print('Review user ID: ${review['user_id']}, Current user ID: ${user['id']}');
        if (review['user_id'] == user['id']) {
          userReview = review;
          print('Found existing review: ${review['id']}');
          break;
        }
      }

      if (userReview != null) {
        // User already reviewed - ask what they want to do
        print('User already has a review. Showing options...');
        final action = await Get.dialog(
          AlertDialog(
            title: const Text("Already Reviewed"),
            content: const Text("You have already reviewed this apartment. What would you like to do?"),
            actions: [
              TextButton(
                onPressed: () {
                  print('User chose to edit review');
                  Get.back(result: 'edit');
                },
                child: const Text("Edit Review"),
              ),
              TextButton(
                onPressed: () {
                  print('User chose to view apartment');
                  Get.back(result: 'view');
                },
                child: const Text("View Apartment"),
              ),
              TextButton(
                onPressed: () {
                  print('User cancelled');
                  Get.back();
                },
                child: const Text("Cancel"),
              ),
            ],
          ),
        );

        if (action == 'edit') {
          _showEditReviewDialog(userReview);
        } else if (action == 'view') {
          _navigateToApartment(apartmentId);
        }
        return;
      }

      print('No existing review found. Showing review dialog...');
      // User hasn't reviewed yet - show review dialog
      Get.dialog(
        ReviewDialog(
          apartmentId: apartmentId,
          onSubmit: (rating, comment) async {
            print('Submitting review - Rating: $rating, Comment: $comment');

            // Show loading
            Get.dialog(
              const Center(
                child: CircularProgressIndicator(),
              ),
              barrierDismissible: false,
            );

            try {
              final result = await apiRepository.addReview(
                apartmentId,
                rating,
                comment,
              );

              Get.back(); // Close loading dialog

              print('Review API response: $result');

              if (result['success'] == true) {
                Get.snackbar(
                  "Success",
                  "Review added successfully!",
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 3),
                );
                Get.back(); // Close review dialog

                // Refresh bookings to update UI
                _fetchMyBookings();
              } else {
                Get.snackbar(
                  "Error",
                  result['message'] ?? 'Failed to add review. Please try again.',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 3),
                );
              }
            } catch (e) {
              Get.back(); // Close loading dialog
              print('Exception during review submission: $e');
              Get.snackbar(
                "Error",
                "An error occurred: ${e.toString()}",
                backgroundColor: Colors.red,
                colorText: Colors.white,
                duration: const Duration(seconds: 3),
              );
            }
          },
        ),
        barrierDismissible: false,
      );

    } catch (e) {
      print('Error in _rateApartmentFromBooking: $e');
      Get.snackbar(
        "Error",
        "Could not load review options: ${e.toString()}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _showEditReviewDialog(Map<String, dynamic> review) {
    Get.dialog(
      ReviewDialog(
        apartmentId: review['apartment_id'],
        onSubmit: (rating, comment) async {
          final result = await apiRepository.updateReview(
            review['id'],
            rating,
            comment,
          );

          if (result['success'] == true) {
            Get.snackbar(
              "Success",
              "Review updated successfully!",
              backgroundColor: Colors.green,
              colorText: Colors.white,
              duration: const Duration(seconds: 2),
            );
            Get.back(); // Close dialog
          } else {
            Get.snackbar(
              "Error",
              result['message'] ?? 'Failed to update review',
              backgroundColor: Colors.red,
              colorText: Colors.white,
              duration: const Duration(seconds: 3),
            );
          }
        },
        initialRating: review['rating'],
        initialComment: review['comment']?.toString(),
        isEditMode: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Color _getStatusColor(String? status) {
      switch (status?.toLowerCase()) {
        case 'approved':
        case 'confirmed':
          return Colors.green;
        case 'cancelled':
          return Colors.redAccent;
        case 'pending':
          return Colors.orange;
        case 'modified_pending':
          return Colors.blue;
        default:
          return Colors.grey;
      }
    }

    IconData _getStatusIcon(String? status) {
      switch (status?.toLowerCase()) {
        case 'approved':
        case 'confirmed':
          return Icons.check_circle;
        case 'cancelled':
          return Icons.cancel;
        case 'pending':
          return Icons.access_time;
        case 'modified_pending':
          return Icons.edit_calendar;
        default:
          return Icons.help;
      }
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text("My Bookings", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchMyBookings,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(
          color: colorScheme.primary,
        ),
      )
          : myBookings.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 20),
            Text(
              "No Bookings Yet",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "You haven't made any reservations yet.",
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Get.back(); // Go back to apartments list
              },
              icon: const Icon(Icons.search),
              label: const Text("Browse Apartments"),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _fetchMyBookings,
        color: colorScheme.primary,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 10),
          itemCount: myBookings.length,
          itemBuilder: (context, index) {
            final booking = myBookings[index];
            final status = booking['status']?.toString() ?? 'unknown';
            final isApprovedOrConfirmed =
                status.toLowerCase() == 'approved' ||
                    status.toLowerCase() == 'confirmed';

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(
                    color: colorScheme.primary.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Booking ID and Status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _getStatusIcon(status),
                                color: _getStatusColor(status),
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Booking #${booking['id']}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: TextStyle(
                                color: _getStatusColor(status),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Dates
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_month,
                            size: 16,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "${booking['start_date']} → ${booking['end_date']}",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Apartment Info
                      Row(
                        children: [
                          Icon(
                            Icons.apartment,
                            size: 16,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Apartment ID: ${booking['apartment_id']}",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Action Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Rate Button (only for approved/confirmed bookings)
                          if (isApprovedOrConfirmed)
                            ElevatedButton.icon(
                              onPressed: () => _rateApartmentFromBooking(booking),
                              icon: const Icon(Icons.star, size: 16),
                              label: const Text("Rate & Review"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber[700],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),

                          if (isApprovedOrConfirmed) const SizedBox(width: 8),
                          //
                          // // View Details Button
                          // OutlinedButton.icon(
                          //   onPressed: () => _navigateToApartment(booking['apartment_id']),
                          //   icon: Icon(
                          //     Icons.visibility,
                          //     size: 16,
                          //     color: colorScheme.primary,
                          //   ),
                          //   label: Text(
                          //     "View Details",
                          //     style: TextStyle(
                          //       color: colorScheme.primary,
                          //     ),
                          //   ),
                          //   style: OutlinedButton.styleFrom(
                          //     side: BorderSide(color: colorScheme.primary),
                          //     padding: const EdgeInsets.symmetric(
                          //       horizontal: 12,
                          //       vertical: 6,
                          //     ),
                          //     shape: RoundedRectangleBorder(
                          //       borderRadius: BorderRadius.circular(8),
                          //     ),
                          //   ),
                          // ),

                          const SizedBox(width: 8),

                          // Edit Button
                          if (status.toLowerCase() == 'pending' ||
                              status.toLowerCase() == 'modified_pending')
                            OutlinedButton.icon(
                              onPressed: () => _editBookingDates(
                                booking['id'],
                                booking['start_date'],
                                booking['end_date'],
                              ),
                              icon: Icon(
                                Icons.edit,
                                size: 16,
                                color: Colors.blue,
                              ),
                              label: Text(
                                "Edit",
                                style: TextStyle(
                                  color: Colors.blue,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.blue),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),

                          if (status.toLowerCase() == 'pending' ||
                              status.toLowerCase() == 'modified_pending')
                            const SizedBox(width: 8),

                          // Cancel Button
                          if (status.toLowerCase() != 'cancelled')
                            OutlinedButton.icon(
                              onPressed: () => _cancelBooking(booking['id']),
                              icon: const Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.red,
                              ),
                              label: const Text(
                                "Cancel",
                                style: TextStyle(color: Colors.red),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.red),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
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
            colorScheme: colorScheme,
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
        Get.snackbar(
          "Success",
          "Booking dates updated successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        _fetchMyBookings();
      } else {
        Get.snackbar(
          "Error",
          result['message'] ?? 'Failed to update booking',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _navigateToApartment(int apartmentId) async {
    try {
      final response = await apiRepository.getApartments();

      if (response.data is List) {
        final apartments = response.data as List;
        final apartmentData = apartments.firstWhere(
              (apt) => apt['id'] == apartmentId,
          orElse: () => null,
        );

        if (apartmentData != null) {
          final apartment = Apartment.fromJson(apartmentData);
          final avgRating = (apartmentData['average_rating'] ?? 0).toDouble();
          final reviewCount = (apartmentData['review_count'] ?? 0).toInt();

          Get.to(() => ApartmentDetailsPage(
            apartment: apartment,
            initialAverageRating: avgRating,
            initialReviewCount: reviewCount,
            //showAddReviewButton: false, // NEW: Disable review button in details
          ));
        } else {
          Get.snackbar(
            "Info",
            "Apartment details not found",
            backgroundColor: Colors.blue,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      print('Error navigating to apartment: $e');
      Get.snackbar(
        "Error",
        "Could not load apartment details",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}