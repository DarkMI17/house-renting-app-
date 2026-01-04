import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_repository.dart';

class BookingRequestsPage extends StatefulWidget {
  const BookingRequestsPage({super.key});

  @override
  State<BookingRequestsPage> createState() => _BookingRequestsPageState();
}

class _BookingRequestsPageState extends State<BookingRequestsPage> {
  final ApiRepository apiRepository = ApiRepository();
  List<dynamic> requests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    final data = await apiRepository.getOwnerBookingRequests();
    setState(() {
      requests = data;
      isLoading = false;
    });
  }

  void _handleAction(int id, bool isApprove) async {
    setState(() => isLoading = true);
    final result = isApprove
        ? await apiRepository.approveBooking(id)
        : await apiRepository.rejectBooking(id);

    Get.snackbar(isApprove ? "Approved" : "Rejected", result['message']);
    _fetchRequests(); // تحديث القائمة بعد الإجراء
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Booking Requests"), backgroundColor: Colors.teal),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : requests.isEmpty
          ? const Center(child: Text("No pending requests"))
          : ListView.builder(
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final req = requests[index];
          return Card(
            margin: const EdgeInsets.all(10),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Apartment: ${req['apartment']['title']}",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const Divider(),
                  Text("Tenant: ${req['tenant']['first_name']} ${req['tenant']['last_name']}"),
                  Text("Phone: ${req['tenant']['phone']}"),
                  Text("Status: ${req['status']}", style: const TextStyle(color: Colors.orange)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: () => _handleAction(req['id'], false),
                        child: const Text("Reject", style: TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        onPressed: () => _handleAction(req['id'], true),
                        child: const Text("Approve", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}