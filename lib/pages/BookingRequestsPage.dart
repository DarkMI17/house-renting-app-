/*import 'package:flutter/material.dart';
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
}*/
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

    Get.snackbar(
      isApprove ? "Approved" : "Rejected",
      result['message'],
      backgroundColor: isApprove ? Colors.green : Colors.red,
      colorText: Colors.white,
    );
    _fetchRequests();
  }

  @override
  Widget build(BuildContext context) {
    // جلب نظام الألوان من الثيم
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface, // اللون البيج للخلفية
      appBar: AppBar(
        title: const Text("Booking Requests", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: colorScheme.primary, // الفيروزي للـ AppBar
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
          : requests.isEmpty
          ? _buildEmptyState(colorScheme)
          : ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 10),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final req = requests[index];
          return _buildRequestCard(req, colorScheme);
        },
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 80, color: colorScheme.secondary.withOpacity(0.3)),
          const SizedBox(height: 15),
          const Text("No pending requests", style: TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildRequestCard(dynamic req, ColorScheme colorScheme) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black26,
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.apartment, color: colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Apartment: ${req['apartment']['title']}",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: colorScheme.secondary), // العنابي للعنوان
                  ),
                ),
              ],
            ),
            const Divider(height: 25),
            _infoRow(Icons.person, "Tenant", "${req['tenant']['first_name']} ${req['tenant']['last_name']}"),
            const SizedBox(height: 8),
            _infoRow(Icons.phone, "Phone", "${req['tenant']['phone']}"),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.orange[700]),
                const SizedBox(width: 8),
                Text("Status: ", style: const TextStyle(fontWeight: FontWeight.w500)),
                Text("${req['status']}", style: TextStyle(color: Colors.orange[800], fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => _handleAction(req['id'], false),
                  child: const Text("Reject"),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary, // الفيروزي للقبول
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  onPressed: () => _handleAction(req['id'], true),
                  child: const Text("Approve"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text("$label: ", style: const TextStyle(fontWeight: FontWeight.w500)),
        Text(value, style: TextStyle(color: Colors.grey[800])),
      ],
    );
  }
}