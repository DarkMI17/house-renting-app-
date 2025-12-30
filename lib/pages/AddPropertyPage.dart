import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart'; // أضفنا GetX للرسائل والتنقل
import 'dart:io';
import '../services/api_repository..dart';

class AddPropertyPage extends StatefulWidget {
  const AddPropertyPage({super.key});

  @override
  State<AddPropertyPage> createState() => _AddPropertyPageState();
}

class _AddPropertyPageState extends State<AddPropertyPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _roomsController = TextEditingController();
  final TextEditingController _bathroomsController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
/*final List<Map<String, dynamic>> _syrianCities = [
  {'id': 1, 'name': 'Damascus City', 'province_id': 1},
  {'id': 2, 'name': 'Aleppo', 'province_id': 2},
  {'id': 3, 'name': 'Jaramana', 'province_id': 8}, // مدينة جرمانا تابعة لمحافظة ريف دمشق رقم 8
];*/
  final List<Map<String, dynamic>> _syrianCities = [
    {'id': 1, 'name': 'Damascus'},
    {'id': 2, 'name': 'Aleppo'},
    {'id': 3, 'name': 'Homs'},
    {'id': 4, 'name': 'Hama'},
    {'id': 5, 'name': 'Latakia'},
    {'id': 6, 'name': 'Tartus'},
    {'id': 7, 'name': 'Idlib'},
    {'id': 8, 'name': 'Rif Dimashq'},
    {'id': 9, 'name': 'Daraa'},
    {'id': 10, 'name': 'As-Suwayda'},
    {'id': 11, 'name': 'Quneitra'},
    {'id': 12, 'name': 'Deir ez-Zor'},
    {'id': 13, 'name': 'Al-Hasakah'},
    {'id': 14, 'name': 'Raqqa'},
    {'id': 15, 'name': 'Al-Qamishli'},
  ];

  int? _selectedCityId;
  bool _hasElevator = false;
  bool _hasBalcony = false;
  final String _selectedStatus = 'available';
  final List<File> _selectedImages = [];
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();
  final ApiRepository _apiRepository = ApiRepository();

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() => _selectedImages.add(File(image.path)));
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() => _selectedImages.add(File(image.path)));
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to take photo');
    }
  }

  void _removeImage(int index) {
    setState(() => _selectedImages.removeAt(index));
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCityId == null) {
      Get.snackbar('Required', 'Please select a city', backgroundColor: Colors.orange);
      return;
    }

    if (_selectedImages.isEmpty) {
      Get.snackbar('Required', 'Please add at least one image', backgroundColor: Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final propertyData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': double.parse(_priceController.text),
        'number_of_rooms': int.parse(_roomsController.text),
        'number_of_bathrooms': int.parse(_bathroomsController.text),
        'area': double.parse(_areaController.text),
        'address_details': _addressController.text.trim(),
        'city_id': _selectedCityId,
        //'province_id': selectedCityData['province_id'],
        'has_elevator': _hasElevator ? 1 : 0,
        'has_balcony': _hasBalcony ? 1 : 0,
        'status': _selectedStatus,
      };

      // استدعاء تابع واحد مدمج يرسل البيانات والصور معاً
      final response = await _apiRepository.addPropertyWithImages(
        propertyData,
        _selectedImages,
      );

      if (response['success'] == true || response['message'] == 'Property created successfully') {
        Get.snackbar('Success', 'Property listed successfully!', backgroundColor: Colors.green, colorText: Colors.white);
        Get.back(result: true);
      } else {
        // هنا سيطبع لكِ السيرفر أي حقل ناقص بالضبط
        Get.snackbar('Failed', response['message'] ?? 'Error creating property');
      }

    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occurred: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List Your Property'),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Property Details', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal)),
              const SizedBox(height: 20),

              // Title
              _buildTextField(_titleController, 'Property Title', Icons.title),
              const SizedBox(height: 15),

              // Description
              _buildTextField(_descriptionController, 'Description', Icons.description, maxLines: 3),
              const SizedBox(height: 15),

              // Price & City
              Row(
                children: [
                  Expanded(child: _buildTextField(_priceController, 'Price (\$)', Icons.attach_money, isNumber: true)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildCityDropdown()),
                ],
              ),
              const SizedBox(height: 15),

              _buildTextField(_addressController, 'Address Details', Icons.location_on),
              const SizedBox(height: 25),

              const Text('Features', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(child: _buildTextField(_roomsController, 'Bedrooms', Icons.bed, isNumber: true)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildTextField(_bathroomsController, 'Baths', Icons.bathtub, isNumber: true)),
                ],
              ),
              const SizedBox(height: 15),
              _buildTextField(_areaController, 'Area (sq ft)', Icons.square_foot, isNumber: true),

              const SizedBox(height: 10),

              // Amenities
              CheckboxListTile(
                title: const Text('Has Elevator'),
                value: _hasElevator,
                onChanged: (v) => setState(() => _hasElevator = v!),
                activeColor: Colors.teal,
                contentPadding: EdgeInsets.zero,
              ),
              CheckboxListTile(
                title: const Text('Has Balcony'),
                value: _hasBalcony,
                onChanged: (v) => setState(() => _hasBalcony = v!),
                activeColor: Colors.teal,
                contentPadding: EdgeInsets.zero,
              ),

              const SizedBox(height: 20),
              const Text('Property Images', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
              const SizedBox(height: 15),

              _buildImageGrid(),

              const SizedBox(height: 15),

              // Image Source Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Gallery'),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.teal),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _takePhoto,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera'),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.teal),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('LIST PROPERTY', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI Helper Widgets ---

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1, bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.teal),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
    );
  }

  Widget _buildCityDropdown() {
    return DropdownButtonFormField<int>(
      initialValue: _selectedCityId,
      decoration: InputDecoration(
        labelText: 'City',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
      ),
      items: _syrianCities.map((city) => DropdownMenuItem<int>(value: city['id'], child: Text(city['name']))).toList(),
      onChanged: (v) => setState(() => _selectedCityId = v),
      validator: (v) => v == null ? 'Required' : null,
    );
  }

  Widget _buildImageGrid() {
    if (_selectedImages.isEmpty) return const SizedBox.shrink();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10),
      itemCount: _selectedImages.length,
      itemBuilder: (context, index) => Stack(
        children: [
          Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), image: DecorationImage(image: FileImage(_selectedImages[index]), fit: BoxFit.cover)),
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