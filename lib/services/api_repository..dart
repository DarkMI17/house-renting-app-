import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';

class ApiRepository {
  late String _baseUrl;
  Map<String, String>? _headers;

  ApiRepository() {
    _baseUrl = ApiConfig.baseUrl;
  }

  // Helper method to get headers with token
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // Helper method to handle response
  Map<String, dynamic> _handleResponse(http.Response response) {
    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return {
        'success': true,
        'statusCode': response.statusCode,
        'data': data,
        'message': data['message'] ?? 'Success',
      };
    } else {
      return {
        'success': false,
        'statusCode': response.statusCode,
        'message': data['message'] ?? 'Something went wrong',
        'errors': data['errors'] ?? data,
      };
    }
  }

  // ========== AUTH APIs ==========

  Future<Map<String, dynamic>> login(String phone, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl${ApiConfig.login}'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'phone': phone,
          'password': password,
        }),
      );

      final result = _handleResponse(response);

      if (result['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        final token = result['data']['access_token'];
        final user = result['data']['user'];

        await prefs.setString('token', token);
        await prefs.setString('user', jsonEncode(user));
      }

      return result;
    } catch (e) {
      return {
        'success': false,
        'message': 'Login failed',
      };
    }
  }

  Future<Map<String, dynamic>> register({
    required String phone,
    required String password,
    required String passwordConfirmation,
    required String firstName,
    required String lastName,
    required String dob,
    required String role,
    required File idImage,
  }) async {
    try {
      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl${ApiConfig.register}'),
      );

      // Add headers
      request.headers.addAll(await _getHeaders());

      // Add fields
      request.fields['phone'] = phone;
      request.fields['password'] = password;
      request.fields['password_confirmation'] = passwordConfirmation;
      request.fields['first_name'] = firstName;
      request.fields['last_name'] = lastName;
      request.fields['dob'] = dob;
      request.fields['role'] = role;

      // Add ID image
      request.files.add(
        await http.MultipartFile.fromPath(
          'id_image',
          idImage.path,
          filename: 'id_${DateTime.now().millisecondsSinceEpoch}.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      final result = _handleResponse(response);

      if (result['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        final token = result['data']['access_token'];
        final user = result['data']['user'];

        await prefs.setString('token', token);
        await prefs.setString('user', jsonEncode(user));
      }

      return result;
    } catch (e) {
      return {
        'success': false,
        'message': 'Registration failed',
      };
    }
  }

  Future<Map<String, dynamic>> logout() async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl${ApiConfig.logout}'),
        headers: await _getHeaders(),
      );

      await _clearAuthData();
      return _handleResponse(response);
    } catch (e) {
      await _clearAuthData();
      return {
        'success': true,
        'message': 'Logged out locally',
      };
    }
  }

  // ========== USER PROFILE APIs ==========

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/profile'),
        headers: await _getHeaders(),
      );
      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to get profile',
      };
    }
  }

  Future<Map<String, dynamic>> getUser() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/profile'),
        headers: await _getHeaders(),
      );

      final result = _handleResponse(response);

      if (result['success'] == true) {
        final user = result['data']['user'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(user));

        return {
          'success': true,
          'user': user,
          'message': 'User info retrieved successfully',
        };
      } else {
        final localUser = await getStoredUser();
        if (localUser != null) {
          return {
            'success': true,
            'user': localUser,
            'message': 'Using cached user data',
          };
        } else {
          return {
            'success': false,
            'message': result['message'] ?? 'Failed to get user info',
          };
        }
      }
    } catch (e) {
      final localUser = await getStoredUser();
      if (localUser != null) {
        return {
          'success': true,
          'user': localUser,
          'message': 'Using cached data',
        };
      }

      return {
        'success': false,
        'message': 'Failed to get user info',
      };
    }
  }

  // ========== PROPERTY APIs ==========

  Future<Map<String, dynamic>> createProperty(Map<String, dynamic> propertyData) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/apartments'),
        headers: await _getHeaders(),
        body: jsonEncode(propertyData),
      );
      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to create property',
      };
    }
  }

  Future<Map<String, dynamic>> uploadPropertyImages(int propertyId, List<File> images) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/apartments/$propertyId/images'),
      );

      request.headers.addAll(await _getHeaders());

      // Add images
      for (final image in images) {
        if (await image.exists()) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'images[]',
              image.path,
              filename: 'property_${propertyId}_image_${DateTime.now().millisecondsSinceEpoch}.jpg',
              contentType: MediaType('image', 'jpeg'),
            ),
          );
        }
      }

      if (request.files.isEmpty) {
        return {
          'success': false,
          'message': 'No valid images to upload',
        };
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to upload images',
      };
    }
  }

  // ========== LOCAL STORAGE HELPERS ==========

  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token != null && token.isNotEmpty;
  }

  Future<Map<String, dynamic>?> getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('user');

    if (userString != null && userString.isNotEmpty) {
      try {
        return jsonDecode(userString);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }


  Future<void> updateStoredUser(Map<String, dynamic> userData) async {
    print('📝 [ApiRepository] Updating stored user...');

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(userData));

    print('   ✅ User data updated');
  }
  // Test connection
  Future<void> testConnection() async {
    try {
      await http.get(Uri.parse(_baseUrl));
    } catch (e) {
      // Connection failed
    }
  }
}