import 'dart:io';
import 'package:dio/dio.dart'; // Standard import for Response and DioException
import 'package:flutter/material.dart';
import 'dart:convert';
import 'network_service.dart';
import 'package:house_rent_app_002/services/services/storage_service.dart';
import 'package:http_parser/http_parser.dart';
class ApiRepository {
  final NetworkService _networkService = NetworkService();

  // 1. Login Logic
  Future<Map<String, dynamic>> login(String phone, String password) async {
    try {
      print("Sending Login Request for: $phone");

      final Response response = await _networkService.post('/login', data: {
        'phone': phone,
        'password': password,
      });

      final Map<String, dynamic> responseData = response.data;
      print("Server Response: $responseData");


      if (responseData['access_token'] != null || responseData['message'] == 'Login successful') {

        // إضافة حقل success يدوياً لكي تفهمه صفحة الـ LoginPage
        responseData['success'] = true;

        // حفظ التوكن
        String token = responseData['access_token'] ?? '';
        await StorageService.saveToken(token);
        print("Token Saved: $token");

        // حفظ بيانات المستخدم
        if (responseData['user'] != null) {
          await StorageService.saveUser(jsonEncode(responseData['user']));
          print(" User Data Saved");
        }

        return responseData;
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Login failed',
        };
      }
    } on DioException catch (e) {
      print("Dio Error: ${e.response?.data}");
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Invalid credentials',
      };
    } catch (e) {
      print("Unexpected Error: $e");
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }
  Future<Map<String, dynamic>> register({
    required String phone,
    required String password,
    required String passwordConfirmation,
    required String first_name,
    required String last_name,
    required String dob,
    required String role,
    required File idImage,
    File? avatar,
  }) async {
    try {

      Map<String, dynamic> dataMap = {
        'phone': phone,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'first_name': first_name,
        'last_name': last_name,
        'dob': dob,
        'role': role,
        'id_image': await MultipartFile.fromFile(
          idImage.path,
          filename: idImage.path.split('/').last,
        ),
      };


      if (avatar != null) {
        dataMap['avatar'] = await MultipartFile.fromFile(
          avatar.path,
          filename: avatar.path.split('/').last,
        );
      }


      FormData formData = FormData.fromMap(dataMap);

      final response = await _networkService.post('/register', data: formData);

      final Map<String, dynamic> responseData = response.data;

      if (response.statusCode == 201 || response.statusCode == 200) {
        /*String token = responseData['access_token'] ?? '';
        await StorageService.saveToken(token);
        if (responseData['user'] != null) {
          await StorageService.saveUser(jsonEncode(responseData['user']));
        }*/
        return {'success': true, 'data': responseData};
      }

      return {'success': false, 'message': 'Registration failed'};

    } on DioException catch (e) {
      String errorMessage = 'Validation failed';
      if (e.response?.data != null) {
        if (e.response?.data['errors'] != null) {
          Map errors = e.response?.data['errors'];
          errorMessage = errors.values.map((e) => e.join(', ')).join('\n');
        } else {
          errorMessage = e.response?.data['message'] ?? 'Check your data';
        }
      }
      print(" Register Error: $errorMessage");
      return {'success': false, 'message': errorMessage};
    } catch (e) {
      print(" Unexpected Error: $e");
      return {'success': false, 'message': 'An unexpected error occurred'};
    }
  }
  // 3. Logout
  Future<void> logout() async {
    await StorageService.logout();
  }
  Future<Map<String, dynamic>> createProperty(Map<String, dynamic> data) async {
    try {
      final response = await _networkService.post('/apartments', data: data);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      return {'success': false, 'message': 'Failed to create property: $e'};
    }
  }

  // 4. UPLOAD PROPERTY

  Future<Map<String, dynamic>> addPropertyWithImages(Map<String, dynamic> data, List<File> images) async {
    try {
      // 1. Initialize FormData with text fields (title, price, city_id, etc.)
      FormData formData = FormData.fromMap(data);

      // 2. Attach all selected images to the same FormData object
      for (var image in images) {
        formData.files.add(MapEntry(
          'images[]', // The key name expected by the server array
          await MultipartFile.fromFile(
            image.path,
            filename: image.path.split('/').last,
          ),
        ));
      }

      // 3. Send a single POST request containing both data and files
      final response = await _networkService.post(
        '/apartments',
        data: formData,
      );

      // Return the server response as a Map
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      // Specifically handle server-side validation errors (like 422)
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Validation failed'
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred: $e'
      };
    }
  }
  // 4. Stored User
  Future<Map<String, dynamic>?> getStoredUser() async {
    final userStr = StorageService.getUser();
    return userStr != null ? jsonDecode(userStr) : null;
  }

  // 6. Manually update stored user data
  Future<void> updateStoredUser(Map<String, dynamic> userData) async {
    // Encodes the Map into a JSON string and saves it via StorageService
    await StorageService.saveUser(jsonEncode(userData));
  }
  // 5. Get Profile
  Future<Map<String, dynamic>> getProfile() async {
    final response = await _networkService.get('/profile');
    return response.data as Map<String, dynamic>;
  }



  Future<List<dynamic>> getMyProperties() async {
    try {

      final response = await _networkService.get('/apartments');


      if (response.data is List) {
        return response.data;
      } else if (response.data is Map && response.data['data'] != null) {
        return response.data['data'];
      }
      return [];
    } catch (e) {
      print("Error fetching properties: $e");
      return [];
    }
  }


  Future<Map<String, dynamic>> deleteProperty(int id) async {
    try {
      final response = await _networkService.delete('/apartments/$id');
      return {
        'success': true,
        'message': 'Property deleted successfully'
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Failed to delete'
      };
    }
  }


  Future<Map<String, dynamic>> updateProperty(int id, Map<String, dynamic> data) async {
    try {
      final response = await _networkService.put('/apartments/$id', data: data);
      return {
        'success': true,
        'message': 'Property updated successfully',
        'data': response.data
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Update failed'
      };
    }
  }

  Future<Map<String, dynamic>> bookApartment(int apartmentId, DateTimeRange dates) async {
    try {
      final response = await _networkService.post('/bookings', data: {
        'apartment_id': apartmentId,
        'start_date': dates.start.toIso8601String(),
        'end_date': dates.end.toIso8601String(),
      });
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'message': 'Booking failed'};
    }
  }

  Future<Map<String, dynamic>> addReview(int apartmentId, double rating, String comment) async {
    try {
      final response = await _networkService.post('/reviews', data: {
        'apartment_id': apartmentId,
        'rating': rating.toInt(),
        'comment': comment,
      });
      return {'success': true, 'message': 'Review added!'};
    } catch (e) {
      return {'success': false, 'message': 'You must book first to review'};
    }
  }



  Future<Map<String, dynamic>> sendBookingRequest(int apartmentId, DateTimeRange range) async {
    try {
      final response = await _networkService.post('/bookings', data: {
        'apartment_id': apartmentId,
        'start_date': range.start.toIso8601String().split('T')[0], // YYYY-MM-DD
        'end_date': range.end.toIso8601String().split('T')[0],     // YYYY-MM-DD
      });

      return {
        'success': true,
        'data': response.data
      };
    } on DioException catch (e) {

      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'This date is already booked!'
      };
    }
  }
  Future<Response> getApartments({Map<String, dynamic>? filters}) async {
    return await _networkService.get('/apartments', queryParameters: filters);
  }

  Future<Map<String, dynamic>> getProvinces() async {
    try {
      final response = await _networkService.get('/provinces');

      var rawData = response.data;
      List<dynamic> list = [];
      if (rawData is Map) {
        list = rawData['provinces'] ?? rawData['data'] ?? [];
      } else if (rawData is List) {
        list = rawData;
      }
      return {'success': true, 'data': list};
    } catch (e) {
      return {'success': false, 'data': [], 'message': 'Failed to load provinces'};
    }
  }

  Future<Map<String, dynamic>> getCities(int provinceId) async {
    try {
      final response = await _networkService.get('/provinces/$provinceId/cities');
      var rawData = response.data;
      List<dynamic> list = [];
      if (rawData is Map) {
        list = rawData['cities'] ?? rawData['data'] ?? [];
      } else if (rawData is List) {
        list = rawData;
      }
      return {'success': true, 'data': list};
    } catch (e) {
      return {'success': false, 'data': [], 'message': 'Failed to load cities'};
    }
  }
  Future<Map<String, dynamic>> createApartment(Map<String, dynamic> data, List<File> images) async {
    try {
      FormData formData = FormData.fromMap(data);
      for (var image in images) {
        formData.files.add(MapEntry(
          'images[]',
          await MultipartFile.fromFile(image.path, contentType: MediaType('image', 'jpeg')),
        ));
      }
      final response = await _networkService.post('/apartments', data: formData);
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'message': 'Failed to create apartment'};
    }
  }


}