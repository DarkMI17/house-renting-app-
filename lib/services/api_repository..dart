// // import 'dart:io';
// // import 'package:dio/dio.dart'; // Standard import for Response and DioException
// // import 'dart:convert';
// // import 'network_service.dart';
// // import 'package:house_rent_app_002/services/services/storage_service.dart';
// //
// // class ApiRepository {
// //   final NetworkService _networkService = NetworkService();
// //
// //   // 1. Login Logic
// //   Future<Map<String, dynamic>> login(String phone, String password) async {
// //     try {
// //       print("Sending Login Request for: $phone");
// //
// //       final Response response = await _networkService.post('/login', data: {
// //         'phone': phone,
// //         'password': password,
// //       });
// //
// //       final Map<String, dynamic> responseData = response.data;
// //       print("Server Response: $responseData");
// //
// //       // التصحيح: نعتبر العملية ناجحة إذا كان هناك توكن أو كانت الرسالة "Login successful"
// //       if (responseData['access_token'] != null || responseData['message'] == 'Login successful') {
// //
// //         // إضافة حقل success يدوياً لكي تفهمه صفحة الـ LoginPage
// //         responseData['success'] = true;
// //
// //         // حفظ التوكن
// //         String token = responseData['access_token'] ?? '';
// //         await StorageService.saveToken(token);
// //         print("Token Saved: $token");
// //
// //         // حفظ بيانات المستخدم
// //         if (responseData['user'] != null) {
// //           await StorageService.saveUser(jsonEncode(responseData['user']));
// //           print(" User Data Saved");
// //         }
// //
// //         return responseData;
// //       } else {
// //         return {
// //           'success': false,
// //           'message': responseData['message'] ?? 'Login failed',
// //         };
// //       }
// //     } on DioException catch (e) {
// //       print("Dio Error: ${e.response?.data}");
// //       return {
// //         'success': false,
// //         'message': e.response?.data['message'] ?? 'Invalid credentials',
// //       };
// //     } catch (e) {
// //       print("Unexpected Error: $e");
// //       return {
// //         'success': false,
// //         'message': 'Error: ${e.toString()}',
// //       };
// //     }
// //   }
// //
// //   // 2. Register Logic/*
// //  /* Future<Map<String, dynamic>> register({
// //     required String phone,
// //     required String password,
// //     required String passwordConfirmation,
// //     required String first_name,
// //     required String last_name,
// //     required String dob,
// //     required String role,
// //     required File idImage,
// //   }) async {
// //     try {
// //       FormData formData = FormData.fromMap({
// //         'phone': phone,
// //         'password': password,
// //         'password_confirmation': passwordConfirmation,
// //         'first_name': first_name,
// //         'last_name': last_name,
// //         'dob': dob,
// //         'role': role,
// //         'id_image': await MultipartFile.fromFile(
// //           idImage.path,
// //           filename: idImage.path.split('/').last,
// //         ),
// //       });
// //
// //       final response = await _networkService.post('/register', data: formData);
// //
// //       // Using response.data here as well
// //       final Map<String, dynamic> responseData = response.data;
// //
// //       if (response.statusCode == 201 || response.statusCode == 200) {
// //         String token = responseData['access_token'];
// //         await StorageService.saveToken(token);
// //         await StorageService.saveUser(jsonEncode(responseData['user']));
// //         return {'success': true, 'data': responseData};
// //       }
// //       return {'success': false, 'message': 'Registration failed'};
// //     } catch (e) {
// //       return {'success': false, 'message': 'Error during registration: $e'};
// //     }
// //   }*/
// // // 2. Register Logic - النسخة المصححة
// // // 2. Register Logic - النسخة المصححة لدعم الـ Avatar
// //   Future<Map<String, dynamic>> register({
// //     required String phone,
// //     required String password,
// //     required String passwordConfirmation,
// //     required String first_name,
// //     required String last_name,
// //     required String dob,
// //     required String role,
// //     required File idImage,
// //     File? avatar, // أضفنا هذا السطر لاستقبال الصورة الشخصية (اختياري)
// //   }) async {
// //     try {
// //       // 1. تجهيز البيانات الأساسية
// //       Map<String, dynamic> dataMap = {
// //         'phone': phone,
// //         'password': password,
// //         'password_confirmation': passwordConfirmation,
// //         'first_name': first_name,
// //         'last_name': last_name,
// //         'dob': dob,
// //         'role': role,
// //         'id_image': await MultipartFile.fromFile(
// //           idImage.path,
// //           filename: idImage.path.split('/').last,
// //         ),
// //       };
// //
// //       // 2. إضافة الـ avatar للـ Map فقط إذا لم يكن فارغاً
// //       if (avatar != null) {
// //         dataMap['avatar'] = await MultipartFile.fromFile(
// //           avatar.path,
// //           filename: avatar.path.split('/').last,
// //         );
// //       }
// //
// //       // 3. تحويل الـ Map إلى FormData
// //       FormData formData = FormData.fromMap(dataMap);
// //
// //       final response = await _networkService.post('/register', data: formData);
// //
// //       final Map<String, dynamic> responseData = response.data;
// //
// //       if (response.statusCode == 201 || response.statusCode == 200) {
// //         /*String token = responseData['access_token'] ?? '';
// //         await StorageService.saveToken(token);
// //         if (responseData['user'] != null) {
// //           await StorageService.saveUser(jsonEncode(responseData['user']));
// //         }*/
// //         return {'success': true, 'data': responseData};
// //       }
// //
// //       return {'success': false, 'message': 'Registration failed'};
// //
// //     } on DioException catch (e) {
// //       String errorMessage = 'Validation failed';
// //       if (e.response?.data != null) {
// //         if (e.response?.data['errors'] != null) {
// //           Map errors = e.response?.data['errors'];
// //           errorMessage = errors.values.map((e) => e.join(', ')).join('\n');
// //         } else {
// //           errorMessage = e.response?.data['message'] ?? 'Check your data';
// //         }
// //       }
// //       print(" Register Error: $errorMessage");
// //       return {'success': false, 'message': errorMessage};
// //     } catch (e) {
// //       print(" Unexpected Error: $e");
// //       return {'success': false, 'message': 'An unexpected error occurred'};
// //     }
// //   }
// //   // 3. Logout
// //   Future<void> logout() async {
// //     await StorageService.logout();
// //   }
// //   Future<Map<String, dynamic>> createProperty(Map<String, dynamic> data) async {
// //     try {
// //       final response = await _networkService.post('/apartments', data: data);
// //       return response.data as Map<String, dynamic>;
// //     } catch (e) {
// //       return {'success': false, 'message': 'Failed to create property: $e'};
// //     }
// //   }
// //
// //   // 4. UPLOAD PROPERTY
// //   /// Function to create a property and upload its images in a single request
// //   Future<Map<String, dynamic>> addPropertyWithImages(Map<String, dynamic> data, List<File> images) async {
// //     try {
// //       // 1. Initialize FormData with text fields (title, price, city_id, etc.)
// //       FormData formData = FormData.fromMap(data);
// //
// //       // 2. Attach all selected images to the same FormData object
// //       for (var image in images) {
// //         formData.files.add(MapEntry(
// //           'images[]', // The key name expected by the server array
// //           await MultipartFile.fromFile(
// //             image.path,
// //             filename: image.path.split('/').last,
// //           ),
// //         ));
// //       }
// //
// //       // 3. Send a single POST request containing both data and files
// //       final response = await _networkService.post(
// //         '/apartments',
// //         data: formData,
// //       );
// //
// //       // Return the server response as a Map
// //       return response.data as Map<String, dynamic>;
// //     } on DioException catch (e) {
// //       // Specifically handle server-side validation errors (like 422)
// //       return {
// //         'success': false,
// //         'message': e.response?.data['message'] ?? 'Validation failed'
// //       };
// //     } catch (e) {
// //       return {
// //         'success': false,
// //         'message': 'An unexpected error occurred: $e'
// //       };
// //     }
// //   }
// //   // 4. Stored User
// //   Future<Map<String, dynamic>?> getStoredUser() async {
// //     final userStr = StorageService.getUser();
// //     return userStr != null ? jsonDecode(userStr) : null;
// //   }
// //
// //   // 6. Manually update stored user data
// //   Future<void> updateStoredUser(Map<String, dynamic> userData) async {
// //     // Encodes the Map into a JSON string and saves it via StorageService
// //     await StorageService.saveUser(jsonEncode(userData));
// //   }
// //   // 5. Get Profile
// //   Future<Map<String, dynamic>> getProfile() async {
// //     final response = await _networkService.get('/profile');
// //     return response.data as Map<String, dynamic>;
// //   }
// //
// //
// //   // 1. جلب الشقق الخاصة بالمستخدم المسجل (التي أضفناها للباك إند)
// //   Future<List<dynamic>> getMyProperties() async {
// //     try {
// //       final response = await _networkService.get('/my-apartments');
// //       // السيرفر سيعيد مصفوفة من الشقق
// //       return response.data as List<dynamic>;
// //     } catch (e) {
// //       print("Error fetching my properties: $e");
// //       return [];
// //     }
// //   }
// //
// //   // 2. حذف شقة (يتوافق مع Route::delete('/apartments/{id}'))
// //   Future<Map<String, dynamic>> deleteProperty(int id) async {
// //     try {
// //       final response = await _networkService.delete('/apartments/$id');
// //       return {
// //         'success': true,
// //         'message': 'Property deleted successfully'
// //       };
// //     } on DioException catch (e) {
// //       return {
// //         'success': false,
// //         'message': e.response?.data['message'] ?? 'Failed to delete'
// //       };
// //     }
// //   }
// //
// //   // 3. تحديث شقة (يتوافق مع Route::put('/apartments/{id}'))
// //   Future<Map<String, dynamic>> updateProperty(int id, Map<String, dynamic> data) async {
// //     try {
// //       final response = await _networkService.put('/apartments/$id', data: data);
// //       return {
// //         'success': true,
// //         'message': 'Property updated successfully',
// //         'data': response.data
// //       };
// //     } on DioException catch (e) {
// //       return {
// //         'success': false,
// //         'message': e.response?.data['message'] ?? 'Update failed'
// //       };
// //     }
// //   }
// // }
// import 'dart:io';
// import 'package:dio/dio.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
// import 'network_service.dart';
// import 'package:house_rent_app_002/services/services/storage_service.dart';
// import 'package:http_parser/http_parser.dart';
//
// class ApiRepository {
//   final NetworkService _networkService = NetworkService();
//
//   // ========== AUTH APIs (المصادقة) ==========
//
//   Future<Map<String, dynamic>> login(String phone, String password) async {
//     try {
//       final Response response = await _networkService.post('/login', data: {
//         'phone': phone,
//         'password': password,
//       });
//
//       final Map<String, dynamic> responseData = response.data;
//
//       if (responseData['access_token'] != null || responseData['message'] == 'Login successful') {
//         responseData['success'] = true;
//         String token = responseData['access_token'] ?? '';
//         await StorageService.saveToken(token);
//
//         if (responseData['user'] != null) {
//           await StorageService.saveUser(jsonEncode(responseData['user']));
//         }
//         return responseData;
//       } else {
//         return {'success': false, 'message': responseData['message'] ?? 'Login failed'};
//       }
//     } on DioException catch (e) {
//       return {'success': false, 'message': e.response?.data['message'] ?? 'Invalid credentials'};
//     } catch (e) {
//       return {'success': false, 'message': 'Error: ${e.toString()}'};
//     }
//   }
//
//   Future<Map<String, dynamic>> register({
//     required String phone,
//     required String password,
//     required String passwordConfirmation,
//     required String first_name,
//     required String last_name,
//     required String dob,
//     required String role,
//     required File idImage,
//     File? avatar,
//   }) async {
//     try {
//       Map<String, dynamic> dataMap = {
//         'phone': phone,
//         'password': password,
//         'password_confirmation': passwordConfirmation,
//         'first_name': first_name,
//         'last_name': last_name,
//         'dob': dob,
//         'role': role,
//         'id_image': await MultipartFile.fromFile(
//           idImage.path,
//           filename: 'id_${DateTime.now().millisecondsSinceEpoch}.jpg',
//           contentType: MediaType('image', 'jpeg'),
//         ),
//       };
//
//       if (avatar != null) {
//         dataMap['avatar'] = await MultipartFile.fromFile(
//           avatar.path,
//           filename: 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg',
//           contentType: MediaType('image', 'jpeg'),
//         );
//       }
//
//       FormData formData = FormData.fromMap(dataMap);
//       final response = await _networkService.post('/register', data: formData);
//       return {'success': true, 'data': response.data};
//     } on DioException catch (e) {
//       return {'success': false, 'message': e.response?.data['message'] ?? 'Registration failed'};
//     }
//   }
//
//   Future<void> logout() async {
//     try {
//       await _networkService.post('/logout');
//     } finally {
//       await StorageService.logout();
//     }
//   }
//
//   // ========== USER PROFILE APIs (الملف الشخصي) ==========
//
//   Future<Map<String, dynamic>> getProfile() async {
//     try {
//       final response = await _networkService.get('/profile');
//       return response.data as Map<String, dynamic>;
//     } catch (e) {
//       return {'success': false, 'message': 'Failed to load profile'};
//     }
//   }
//
//   Future<Map<String, dynamic>> getUser() async {
//     try {
//       final response = await _networkService.get('/profile');
//       final user = response.data['user'];
//       if (user != null) {
//         await StorageService.saveUser(jsonEncode(user));
//         return {'success': true, 'user': user};
//       }
//       return {'success': false, 'message': 'User not found'};
//     } catch (e) {
//       final localUser = await getStoredUser();
//       return localUser != null
//           ? {'success': true, 'user': localUser, 'message': 'Using cached data'}
//           : {'success': false, 'message': 'Failed to get user'};
//     }
//   }
//
//   // ========== LOCATION APIs (المواقع) ==========
//
//   Future<Map<String, dynamic>> getProvinces() async {
//     try {
//       final response = await _networkService.get('/provinces');
//       var data = response.data;
//       List<dynamic> list = (data is Map) ? (data['provinces'] ?? data['data'] ?? []) : data;
//       return {'success': true, 'data': list};
//     } catch (e) {
//       return {'success': false, 'data': [], 'message': 'Failed to load provinces'};
//     }
//   }
//
//   Future<Map<String, dynamic>> getCities(int provinceId) async {
//     try {
//       final response = await _networkService.get('/provinces/$provinceId/cities');
//       var data = response.data;
//       List<dynamic> list = (data is Map) ? (data['cities'] ?? data['data'] ?? []) : data;
//       return {'success': true, 'data': list};
//     } catch (e) {
//       return {'success': false, 'data': [], 'message': 'Failed to load cities'};
//     }
//   }
//
//   // ========== APARTMENT APIs (إدارة الشقق) ==========
//
//   // دالة مدمجة تدعم النصوص والصور المتعددة في طلب واحد
//   Future<Map<String, dynamic>> createApartment(Map<String, dynamic> data, List<File> images) async {
//     try {
//       FormData formData = FormData.fromMap(data);
//       for (var image in images) {
//         formData.files.add(MapEntry(
//           'images[]',
//           await MultipartFile.fromFile(image.path, contentType: MediaType('image', 'jpeg')),
//         ));
//       }
//       final response = await _networkService.post('/apartments', data: formData);
//       return {'success': true, 'data': response.data};
//     } catch (e) {
//       return {'success': false, 'message': 'Failed to create apartment'};
//     }
//   }
//
//   Future<Map<String, dynamic>> getApartments({int? provinceId, int? cityId, required int page}) async {
//     try {
//       Map<String, dynamic> query = {};
//       if (provinceId != null) query['province_id'] = provinceId;
//       if (cityId != null) query['city_id'] = cityId;
//
//       final response = await _networkService.get('/apartments');
//       return {'success': true, 'data': response.data};
//     } catch (e) {
//       return {'success': false, 'message': 'Failed to load apartments'};
//     }
//   }
//
//   Future<Map<String, dynamic>> getApartmentDetails(int id) async {
//     try {
//       final response = await _networkService.get('/apartments/$id');
//       return {'success': true, 'data': response.data};
//     } catch (e) {
//       return {'success': false, 'message': 'Failed to load details'};
//     }
//   }
//
//   Future<Map<String, dynamic>> deleteProperty(int id) async {
//     try {
//       await _networkService.delete('/apartments/$id');
//       return {'success': true, 'message': 'Deleted successfully'};
//     } catch (e) {
//       return {'success': false, 'message': 'Delete failed'};
//     }
//   }
//
//   // ========== STORAGE & HELPERS ==========
//
//   Future<Map<String, dynamic>?> getStoredUser() async {
//     final userStr = StorageService.getUser();
//     return userStr != null ? jsonDecode(userStr) : null;
//   }
//
//   Future<bool> isLoggedIn() async {
//     return StorageService.getToken() != null;
//   }
//
//   Future<bool> checkUserIsOwner() async {
//     final user = await getStoredUser();
//     return user != null && user['role'] == 'owner';
//   }
//   Future<void> updateStoredUser(Map<String, dynamic> userData) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('user', jsonEncode(userData));
//   }
// }
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'network_service.dart';
import 'package:house_rent_app_002/services/services/storage_service.dart';
import 'package:http_parser/http_parser.dart';

class ApiRepository {
  final NetworkService _networkService = NetworkService();

  // ========== AUTH APIs ==========

  Future<Map<String, dynamic>> login(String phone, String password) async {
    try {
      final Response response = await _networkService.post('/login', data: {
        'phone': phone,
        'password': password,
      });

      final Map<String, dynamic> responseData = response.data;

      if (responseData['access_token'] != null || responseData['message'] == 'Login successful') {
        responseData['success'] = true;
        String token = responseData['access_token'] ?? '';
        await StorageService.saveToken(token);

        if (responseData['user'] != null) {
          await StorageService.saveUser(jsonEncode(responseData['user']));
        }
        return responseData;
      } else {
        return {'success': false, 'message': responseData['message'] ?? 'Login failed'};
      }
    } on DioException catch (e) {
      return {'success': false, 'message': e.response?.data['message'] ?? 'Invalid credentials'};
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
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
          filename: 'id_${DateTime.now().millisecondsSinceEpoch}.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      };

      if (avatar != null) {
        dataMap['avatar'] = await MultipartFile.fromFile(
          avatar.path,
          filename: 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg',
          contentType: MediaType('image', 'jpeg'),
        );
      }

      FormData formData = FormData.fromMap(dataMap);
      final response = await _networkService.post('/register', data: formData);
      return {'success': true, 'data': response.data};
    } on DioException catch (e) {
      return {'success': false, 'message': e.response?.data['message'] ?? 'Registration failed'};
    }
  }

  Future<void> logout() async {
    try {
      await _networkService.post('/logout');
    } finally {
      await StorageService.logout();
    }
  }

  // ========== USER PROFILE APIs ==========

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _networkService.get('/profile');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      return {'success': false, 'message': 'Failed to load profile'};
    }
  }

  Future<Map<String, dynamic>> getUser() async {
    try {
      final response = await _networkService.get('/profile');
      final user = response.data['user'];
      if (user != null) {
        await StorageService.saveUser(jsonEncode(user));
        return {'success': true, 'user': user};
      }
      return {'success': false, 'message': 'User not found'};
    } catch (e) {
      final localUser = await getStoredUser();
      return localUser != null
          ? {'success': true, 'user': localUser, 'message': 'Using cached data'}
          : {'success': false, 'message': 'Failed to get user'};
    }
  }

  // ========== LOCATION APIs ==========

  Future<Map<String, dynamic>> getProvinces() async {
    try {
      final response = await _networkService.get('/provinces');
      // Fix: Specifically extract the list from the map
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

  // ========== APARTMENT APIs ==========

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

  // FIXED: This method was returning response.data (a Map) but your UI expected a List
  Future<Map<String, dynamic>> getApartments({int? provinceId, int? cityId, required int page}) async {
    try {
      // Build query parameters
      Map<String, dynamic> queryParams = {'page': page};
      if (provinceId != null) queryParams['province_id'] = provinceId;
      if (cityId != null) queryParams['city_id'] = cityId;

      // Make the API call
      final response = await _networkService.get('/apartments', queryParameters: queryParams);

      return {'success': true, 'data': response.data};
    } on DioException catch (e) {
      print("API Error: ${e.response?.statusCode} - ${e.response?.data}");
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Failed to load apartments'
      };
    } catch (e) {
      print("Unexpected Error: $e");
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> getApartmentDetails(int id) async {
    try {
      final response = await _networkService.get('/apartments/$id');
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'message': 'Failed to load details'};
    }
  }

  Future<Map<String, dynamic>> deleteProperty(int id) async {
    try {
      await _networkService.delete('/apartments/$id');
      return {'success': true, 'message': 'Deleted successfully'};
    } catch (e) {
      return {'success': false, 'message': 'Delete failed'};
    }
  }

  // ========== STORAGE & HELPERS ==========

  Future<Map<String, dynamic>?> getStoredUser() async {
    final userStr = StorageService.getUser();
    return userStr != null ? jsonDecode(userStr) : null;
  }

  Future<bool> isLoggedIn() async {
    return StorageService.getToken() != null;
  }

  Future<bool> checkUserIsOwner() async {
    final user = await getStoredUser();
    return user != null && user['role'] == 'owner';
  }

  Future<void> updateStoredUser(Map<String, dynamic> userData) async {
    await StorageService.saveUser(jsonEncode(userData));
  }
}