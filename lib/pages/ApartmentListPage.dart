import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_repository..dart';
import 'Apartment.dart';
import 'apartment_details_page.dart';

class ApartmentListPage extends StatefulWidget {
  const ApartmentListPage({super.key});

  @override
  State<ApartmentListPage> createState() => _ApartmentListPageState();
}

class _ApartmentListPageState extends State<ApartmentListPage> {
  final ApiRepository _apiRepository = ApiRepository();
  List<Apartment> _apartments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadApartments();
  }
  /*
  Future<void> _loadApartments() async {
    try {
      setState(() => _isLoading = true);

      // نعتبر أن response هنا هو List<dynamic> مباشرة
      final response = await _apiRepository.getMyProperties();

      if (response is List) {
        print("API Response: $response");
        setState(() {
          _apartments = response.map((json) {
            final Map<String, dynamic> item = Map<String, dynamic>.from(json);

            // تحويل الأنواع بشكل آمن لضمان عدم حدوث خطأ
            item['id'] = int.tryParse(item['id'].toString()) ?? 0;
            item['price'] = double.tryParse(item['price'].toString()) ?? 0.0;

            return Apartment.fromJson(item);
          }).toList();

          _isLoading = false;
        });
      } else {
        // احتياطاً إذا تغير شكل البيانات مستقبلاً ولم تكن Array
        print("Warning: Response is not a List");
        setState(() => _isLoading = false);
      }

    } catch (e) {
      setState(() => _isLoading = false);
      Get.snackbar("Error", "Check data types: $e");
    }
  }
*/
  Future<void> _loadApartments() async {
    try {
      setState(() => _isLoading = true);
      final response = await _apiRepository.getMyProperties();

      // إذا كانت القائمة فارغة، سنضيف بيانات وهمية للاختبار فقط
      if (response is List && response.isEmpty) {
        print("القائمة فارغة، سنعرض بيانات تجريبية");
        setState(() {
          _apartments = [
            Apartment(
              id: 1,
              title: "شقة تجريبية للاختبار",
              description: "هذا الوصف يظهر للتأكد من أن التصميم يعمل",
              price: 2500000.0,
              images: [], // اتركها فارغة لتجربة الـ placeholder
              numberOfRooms: 3,
              numberOfBathrooms: 2,
              area: 110.0,
              addressDetails: "دمشق، المزة",
              hasElevator: true,
            )
          ];
          _isLoading = false;
        });
        return; // توقف هنا ولا تكمل معالجة الـ response الفارغ
      }

      // الكود الأصلي لمعالجة البيانات القادمة من السيرفر
      if (response is List) {
        setState(() {
          _apartments = response.map((json) => Apartment.fromJson(json)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print("Error: $e");
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Properties"), backgroundColor: Colors.teal),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _apartments.length,
        itemBuilder: (context, index) {
          final apt = _apartments[index];
          return ListTile(
            title: Text(apt.title),
            subtitle: Text("${apt.price} SYP"),
            onTap: () => Get.to(() => ApartmentDetailsPage(apartment: apt)),
          );
        },
      ),
    );
  }
}