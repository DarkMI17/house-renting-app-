import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

  // Syrian cities list
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
  String _selectedStatus = 'available';
  List<File> _selectedImages = [];
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();
  final ApiRepository _apiRepository = ApiRepository();

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImages.add(File(image.path));
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          _selectedImages.add(File(image.path));
        });
      }
    } catch (e) {
      print('Error taking photo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to take photo: $e')),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCityId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a city')),
      );
      return;
    }

    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one image')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Prepare property data
      final propertyData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'price': double.parse(_priceController.text),
        'number_of_rooms': int.parse(_roomsController.text),
        'number_of_bathrooms': int.parse(_bathroomsController.text),
        'area': double.parse(_areaController.text),
        'address_details': _addressController.text,
        'city_id': _selectedCityId, // Only city_id is needed now
        'has_elevator': _hasElevator,
        'has_balcony': _hasBalcony,
        'status': _selectedStatus,
      };

      print('📦 Submitting property data: $propertyData');

      // Create property
      final response = await _apiRepository.createProperty(propertyData);

      if (response['success'] == true) {
        final propertyId = response['data']['id'];
        print('✅ Property created with ID: $propertyId');

        // Upload images if property was created
        final uploadResponse = await _apiRepository.uploadPropertyImages(
          propertyId,
          _selectedImages,
        );

        if (uploadResponse['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Property listed successfully!')),
          );

          // Navigate back after successful submission
          Future.delayed(const Duration(seconds: 1), () {
            Navigator.pop(context, true);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Property created but images failed: ${uploadResponse['message']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create property: ${response['message']}')),
        );
      }

    } catch (e) {
      print('🔥 Submit form error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to list property: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List Your Property'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              const Text(
                'Property Details',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 20),

              // Property Title
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Property Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.title, color: Colors.teal),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter property title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.description, color: Colors.teal),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Price
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Price (\$/month)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.attach_money, color: Colors.teal),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Syrian City Dropdown
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButtonFormField<int?>(
                      value: _selectedCityId,
                      decoration: const InputDecoration(
                        labelText: 'City',
                        border: InputBorder.none,
                      ),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('Select City'),
                        ),
                        ..._syrianCities.map<DropdownMenuItem<int?>>((city) {
                          return DropdownMenuItem<int?>(
                            value: city['id'] as int,
                            child: Text(city['name']),
                          );
                        }).toList(),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCityId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select city';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Address Details
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Address Details',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.location_on, color: Colors.teal),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter address details';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Property Features
              const Text(
                'Property Features',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 15),

              Row(
                children: [
                  // Number of Rooms
                  Expanded(
                    child: TextFormField(
                      controller: _roomsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Bedrooms',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(Icons.bed, color: Colors.teal),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter number';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Enter valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Number of Bathrooms
                  Expanded(
                    child: TextFormField(
                      controller: _bathroomsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Bathrooms',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(Icons.bathtub, color: Colors.teal),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter number';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Enter valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // Area
              TextFormField(
                controller: _areaController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Area (sq ft)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.square_foot, color: Colors.teal),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter area';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Amenities
              const Text(
                'Amenities',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: CheckboxListTile(
                      title: const Text('Has Elevator'),
                      value: _hasElevator,
                      activeColor: Colors.teal,
                      onChanged: (value) {
                        setState(() {
                          _hasElevator = value ?? false;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: CheckboxListTile(
                      title: const Text('Has Balcony'),
                      value: _hasBalcony,
                      activeColor: Colors.teal,
                      onChanged: (value) {
                        setState(() {
                          _hasBalcony = value ?? false;
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Status
              const Text(
                'Status',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 10),

              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'available',
                    child: Text('Available'),
                  ),
                  DropdownMenuItem(
                    value: 'rented',
                    child: Text('Rented'),
                  ),
                  DropdownMenuItem(
                    value: 'pending',
                    child: Text('Pending'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value!;
                  });
                },
              ),

              const SizedBox(height: 30),

              // Images Section
              const Text(
                'Property Images',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Add at least one image of your property',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 15),

              // Image Grid
              if (_selectedImages.isNotEmpty)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1,
                  ),
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image: FileImage(_selectedImages[index]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 5,
                          right: 5,
                          child: GestureDetector(
                            onTap: () => _removeImage(index),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),

              const SizedBox(height: 15),

              // Image Buttons
              Row(
                children: [
                  Expanded(
                    child: MaterialButton(
                      onPressed: _pickImage,
                      color: Colors.teal.withOpacity(0.1),
                      textColor: Colors.teal,
                      height: 50,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.photo_library),
                          SizedBox(width: 10),
                          Text('Choose from Gallery'),
                        ],
                      ),
                    ),
                  ),


                ],
              ),

              const SizedBox(height: 30),

              // Submit Button
              MaterialButton(
                onPressed: _isLoading ? null : _submitForm,
                color: Colors.teal,
                textColor: Colors.white,
                minWidth: double.infinity,
                height: 50,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  'List Property',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}