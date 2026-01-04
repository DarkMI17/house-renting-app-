import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_repository.dart';

class MyPropertiesPage extends StatefulWidget {
  const MyPropertiesPage({super.key});

  @override
  State<MyPropertiesPage> createState() => _MyPropertiesPageState();
}

class _MyPropertiesPageState extends State<MyPropertiesPage> {
  final ApiRepository apiRepository = ApiRepository();

  // استخدام مسمى myUnits بدلاً من الاسم المحظور
  List<dynamic> myUnits = [];
  bool isLoading = true;
  String serverMessage = "";

  @override
  void initState() {
    super.initState();
    _loadOwnerUnits();
  }

  Future<void> _loadOwnerUnits() async {
    try {
      final response = await apiRepository.getMyApartmentData();

      setState(() {
        if (response['status'] == true && response['data'] != null) {
          // في Laravel Pagination: البيانات الفعلية تكون داخل data['data']
          myUnits = response['data']['data'] ?? [];
          serverMessage = response['message'] ?? "";
        } else {
          myUnits = [];
          serverMessage = response['message'] ?? "No units found";
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        serverMessage = "An unexpected error occurred";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Rental Units"),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : myUnits.isEmpty
          ? _buildNoContentState()
          : RefreshIndicator(
        onRefresh: _loadOwnerUnits,
        child: ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: myUnits.length,
          itemBuilder: (context, index) {
            final unit = myUnits[index];
            return _unitCard(unit);
          },
        ),
      ),
    );
  }

  Widget _buildNoContentState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inventory_2_outlined, size: 70, color: Colors.grey),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              serverMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ),
          TextButton(
            onPressed: _loadOwnerUnits,
            child: const Text("Refresh", style: TextStyle(color: Colors.teal)),
          )
        ],
      ),
    );
  }

  Widget _unitCard(Map<String, dynamic> unit) {
    // منطق الألوان حسب admin_status
    Color adminStatusColor;
    switch (unit['admin_status']) {
      case 'approved': adminStatusColor = Colors.green; break;
      case 'pending': adminStatusColor = Colors.orange; break;
      case 'rejected': adminStatusColor = Colors.red; break;
      default: adminStatusColor = Colors.grey;
    }

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            _unitImageThumbnail(unit['images']),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    unit['title'] ?? 'No Title',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    "${unit['city']['name']}, ${unit['province']['name']}",
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _badge(unit['admin_status'].toString().toUpperCase(), adminStatusColor),
                      if (unit['is_booked'] == true) ...[
                        const SizedBox(width: 5),
                        _badge("BOOKED", Colors.blueGrey),
                      ]
                    ],
                  ),
                ],
              ),
            ),
            Text(
              "\$${unit['price']}",
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 17),
            ),
          ],
        ),
      ),
    );
  }

  Widget _unitImageThumbnail(dynamic images) {
    return Container(
      width: 75,
      height: 75,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.apartment_rounded, color: Colors.teal, size: 35),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color, width: 1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold),
      ),
    );
  }
}