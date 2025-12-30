import 'dart:io';
import 'package:dio/dio.dart'; // Standard import for Response and DioException
import 'dart:convert';
import 'network_service.dart';
import 'package:house_rent_app_002/services/services/storage_service.dart';

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

      // التصحيح: نعتبر العملية ناجحة إذا كان هناك توكن أو كانت الرسالة "Login successful"
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

  // 2. Register Logic/*
 /* Future<Map<String, dynamic>> register({
    required String phone,
    required String password,
    required String passwordConfirmation,
    required String first_name,
    required String last_name,
    required String dob,
    required String role,
    required File idImage,
  }) async {
    try {
      FormData formData = FormData.fromMap({
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
      });

      final response = await _networkService.post('/register', data: formData);

      // Using response.data here as well
      final Map<String, dynamic> responseData = response.data;

      if (response.statusCode == 201 || response.statusCode == 200) {
        String token = responseData['access_token'];
        await StorageService.saveToken(token);
        await StorageService.saveUser(jsonEncode(responseData['user']));
        return {'success': true, 'data': responseData};
      }
      return {'success': false, 'message': 'Registration failed'};
    } catch (e) {
      return {'success': false, 'message': 'Error during registration: $e'};
    }
  }*/
// 2. Register Logic - النسخة المصححة
// 2. Register Logic - النسخة المصححة لدعم الـ Avatar
  Future<Map<String, dynamic>> register({
    required String phone,
    required String password,
    required String passwordConfirmation,
    required String first_name,
    required String last_name,
    required String dob,
    required String role,
    required File idImage,
    File? avatar, // أضفنا هذا السطر لاستقبال الصورة الشخصية (اختياري)
  }) async {
    try {
      // 1. تجهيز البيانات الأساسية
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

      // 2. إضافة الـ avatar للـ Map فقط إذا لم يكن فارغاً
      if (avatar != null) {
        dataMap['avatar'] = await MultipartFile.fromFile(
          avatar.path,
          filename: avatar.path.split('/').last,
        );
      }

      // 3. تحويل الـ Map إلى FormData
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
  /// Function to create a property and upload its images in a single request
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


  // 1. جلب الشقق الخاصة بالمستخدم المسجل (التي أضفناها للباك إند)
  Future<List<dynamic>> getMyProperties() async {
    try {
      final response = await _networkService.get('/my-apartments');
      // السيرفر سيعيد مصفوفة من الشقق
      return response.data as List<dynamic>;
    } catch (e) {
      print("Error fetching my properties: $e");
      return [];
    }
  }

  // 2. حذف شقة (يتوافق مع Route::delete('/apartments/{id}'))
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

  // 3. تحديث شقة (يتوافق مع Route::put('/apartments/{id}'))
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
}
