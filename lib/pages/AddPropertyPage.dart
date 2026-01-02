
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../services/api_repository.dart'; // تأكد من عدد النقاط في اسم ملفك

class AddPropertyPage extends StatefulWidget {
  const AddPropertyPage({super.key});

  @override
  State<AddPropertyPage> createState() => _AddPropertyPageState();
}

class _AddPropertyPageState extends State<AddPropertyPage> {
  final _formKey = GlobalKey<FormState>();

  // المتحكمات (Controllers)
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _roomsController = TextEditingController();
  final TextEditingController _bathroomsController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  final ApiRepository _apiRepository = ApiRepository();

  // متغيرات البيانات الديناميكية
  List<dynamic> _provinces = [];
  List<dynamic> _cities = [];
  List<dynamic> _filteredCities = [];

  int? _selectedProvinceId;
  int? _selectedCityId;

  bool _hasElevator = false;
  bool _hasBalcony = false;
  List<File> _selectedImages = [];
  bool _isLoading = false;
  bool _isLoadingData = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProvinces(); // جلب المحافظات عند فتح الصفحة
  }

  // دالة جلب المحافظات من السيرفر
  Future<void> _loadProvinces() async {
    setState(() => _isLoadingData = true);
    try {
      final response = await _apiRepository.getProvinces();
      if (response['success'] == true) {
        setState(() => _provinces = List<dynamic>.from(response['data'] ?? []));
      } else {
        Get.snackbar('Error', 'Failed to load provinces');
      }
    } catch (e) {
      Get.snackbar('Error', 'Connection error while loading provinces');
    } finally {
      setState(() => _isLoadingData = false);
    }
  }

  // دالة جلب المدن بناءً على المحافظة المختارة
  Future<void> _loadCities(int provinceId) async {
    setState(() {
      _isLoadingData = true;
      _selectedCityId = null; // تصفير المدينة عند تغيير المحافظة
    });
    try {
      final response = await _apiRepository.getCities(provinceId);
      if (response['success'] == true) {
        setState(() {
          _cities = List<dynamic>.from(response['data'] ?? []);
          _filteredCities = _cities; // في Laravel عادةً التصفية تتم في السيرفر
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load cities');
    } finally {
      setState(() => _isLoadingData = false);
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      if (_selectedImages.length < 5) {
        setState(() => _selectedImages.add(File(image.path)));
      } else {
        Get.snackbar('Limit reached', 'Maximum 5 images allowed');
      }
    }
  }

  void _removeImage(int index) {
    setState(() => _selectedImages.removeAt(index));
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCityId == null) {
      Get.snackbar('Required', 'Please select a city');
      return;
    }
    if (_selectedImages.isEmpty) {
      Get.snackbar('Required', 'Please add at least one image');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final propertyData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'price': double.parse(_priceController.text),
        'number_of_rooms': int.parse(_roomsController.text),
        'number_of_bathrooms': int.parse(_bathroomsController.text),
        'area': double.parse(_areaController.text),
        'address_details': _addressController.text,
        'province_id': _selectedProvinceId,
        'city_id': _selectedCityId,
        'has_elevator': _hasElevator ? 1 : 0,
        'has_balcony': _hasBalcony ? 1 : 0,
      };

      final response = await _apiRepository.createApartment(propertyData, _selectedImages);

      if (response['success'] == true) {
        Get.snackbar('Success', 'Property listed successfully and pending approval',
            backgroundColor: Colors.green, colorText: Colors.white);
        Future.delayed(const Duration(seconds: 2), () => Get.back());
      } else {
        Get.snackbar('Error', response['message'] ?? 'Failed to list property');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred while uploading');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Property'),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Property Details',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal)),
              const SizedBox(height: 20),

              _buildTextField(_titleController, 'Property Title*', Icons.title),
              const SizedBox(height: 15),
              _buildTextField(_descriptionController, 'Description*', Icons.description, maxLines: 3),
              const SizedBox(height: 15),
              _buildTextField(_priceController, 'Price (\$/month)*', Icons.attach_money, isNumber: true),
              const SizedBox(height: 15),

              // قائمة المحافظات الديناميكية
              _buildProvinceDropdown(),
              const SizedBox(height: 15),

              // قائمة المدن الديناميكية
              _buildCityDropdown(),
              const SizedBox(height: 15),

              _buildTextField(_addressController, 'Address Details*', Icons.location_on),
              const SizedBox(height: 20),

              const Text('Property Features',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(child: _buildTextField(_roomsController, 'Rooms*', Icons.bed, isNumber: true)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildTextField(_bathroomsController, 'Baths*', Icons.bathtub, isNumber: true)),
                ],
              ),
              const SizedBox(height: 15),
              _buildTextField(_areaController, 'Area (sq ft)*', Icons.square_foot, isNumber: true),
              const SizedBox(height: 20),

              // الميزات الإضافية
              Row(
                children: [
                  Expanded(child: _buildCheckbox('Elevator', _hasElevator, (v) => setState(() => _hasElevator = v!))),
                  const SizedBox(width: 10),
                  Expanded(child: _buildCheckbox('Balcony', _hasBalcony, (v) => setState(() => _hasBalcony = v!))),
                ],
              ),
              const SizedBox(height: 30),

              const Text('Property Images',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
              const SizedBox(height: 10),

              _buildImageGrid(),
              const SizedBox(height: 15),

              if (_selectedImages.length < 5)
                MaterialButton(
                  onPressed: _pickImage,
                  color: Colors.teal.withOpacity(0.1),
                  textColor: Colors.teal,
                  height: 50,
                  minWidth: double.infinity,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Icon(Icons.photo_library), SizedBox(width: 10), Text('Add Images')],
                  ),
                ),

              const SizedBox(height: 30),

              MaterialButton(
                onPressed: _isLoading ? null : _submitForm,
                color: Colors.teal,
                textColor: Colors.white,
                minWidth: double.infinity,
                height: 55,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('LIST PROPERTY', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // أدوات مساعدة لبناء الواجهة (UI Helpers)
  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.teal),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (v) => (v == null || v.isEmpty) ? 'Required field' : null,
    );
  }

  Widget _buildProvinceDropdown() {
    return DropdownButtonFormField<int>(
      value: _selectedProvinceId,
      decoration: InputDecoration(
        labelText: 'Province*',
        prefixIcon: const Icon(Icons.map, color: Colors.teal),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      items: _provinces.map((p) => DropdownMenuItem<int>(value: p['id'], child: Text(p['name']))).toList(),
      onChanged: (val) {
        setState(() => _selectedProvinceId = val);
        if (val != null) _loadCities(val);
      },
    );
  }

  Widget _buildCityDropdown() {
    return DropdownButtonFormField<int>(
      value: _selectedCityId,
      decoration: InputDecoration(
        labelText: 'City*',
        prefixIcon: const Icon(Icons.location_city, color: Colors.teal),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      items: _filteredCities.map((c) => DropdownMenuItem<int>(value: c['id'], child: Text(c['name']))).toList(),
      onChanged: (val) => setState(() => _selectedCityId = val),
      disabledHint: const Text("Select province first"),
    );
  }

  Widget _buildCheckbox(String title, bool value, Function(bool?) onChanged) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(10)),
      child: CheckboxListTile(
        title: Text(title, style: const TextStyle(fontSize: 14)),
        value: value,
        onChanged: onChanged,
        controlAffinity: ListTileControlAffinity.leading,
        activeColor: Colors.teal,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildImageGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10),
      itemCount: _selectedImages.length,
      itemBuilder: (context, index) => Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(image: FileImage(_selectedImages[index]), fit: BoxFit.cover),
            ),
          ),
          Positioned(
            top: 2, right: 2,
            child: GestureDetector(
              onTap: () => _removeImage(index),
              child: const CircleAvatar(radius: 12, backgroundColor: Colors.red, child: Icon(Icons.close, size: 16, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}