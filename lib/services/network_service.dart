import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';

class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  late Dio _dio;
  bool _isInitialized = false;

  void initialize() {
    if (_isInitialized) return;

    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: Duration(milliseconds: ApiConfig.connectTimeout),
        receiveTimeout: Duration(milliseconds: ApiConfig.receiveTimeout),
        headers: ApiConfig.getHeaders(),
      ),
    );

    // Add token interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');

        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        return handler.next(options);
      },
      onError: (DioException error, handler) {
        return handler.next(error);
      },
    ));

    _isInitialized = true;
  }

  // Check and ensure initialization
  void _ensureInitialized() {
    if (!_isInitialized) {
      initialize();
    }
  }

  // Generic GET request
  Future<Map<String, dynamic>> get(String endpoint) async {
    _ensureInitialized();
    try {
      final response = await _dio.get(endpoint);
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // Generic POST request with JSON
  Future<Map<String, dynamic>> post(
      String endpoint, {
        Map<String, dynamic>? data,
      }) async {
    _ensureInitialized();
    try {
      final response = await _dio.post(endpoint, data: data);
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // POST request with FormData (for file uploads)
  Future<Map<String, dynamic>> postFormData(
      String endpoint, {
        required FormData formData,
      }) async {
    _ensureInitialized();
    try {
      final response = await _dio.post(
        endpoint,
        data: formData,
        options: Options(
          headers: ApiConfig.getHeaders(),
        ),
      );
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // Generic PUT request
  Future<Map<String, dynamic>> put(
      String endpoint, {
        Map<String, dynamic>? data,
      }) async {
    _ensureInitialized();
    try {
      final response = await _dio.put(endpoint, data: data);
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // Generic DELETE request
  Future<Map<String, dynamic>> delete(
      String endpoint, {
        Map<String, dynamic>? data,
      }) async {
    _ensureInitialized();
    try {
      final response = await _dio.delete(endpoint, data: data);
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // Handle successful response
  Map<String, dynamic> _handleResponse(Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      return {
        'success': true,
        'statusCode': response.statusCode,
        'data': response.data,
        'message': response.data is Map ? (response.data['message'] ?? 'Success') : 'Success',
      };
    } else {
      return {
        'success': false,
        'statusCode': response.statusCode,
        'message': response.data is Map ? (response.data['message'] ?? 'Something went wrong') : 'Something went wrong',
        'errors': response.data is Map ? (response.data['errors'] ?? response.data) : response.data,
      };
    }
  }

  // Handle errors
  Map<String, dynamic> _handleError(dynamic error) {
    if (error is DioException) {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        return {
          'success': false,
          'message': 'Connection timeout. Please check your internet connection.',
        };
      } else if (error.type == DioExceptionType.connectionError) {
        return {
          'success': false,
          'message': 'No internet connection. Please check your network settings.',
        };
      } else if (error.response != null) {
        final response = error.response!;
        final responseData = response.data;
        final statusCode = response.statusCode ?? 0;

        return {
          'success': false,
          'statusCode': statusCode,
          'message': _extractErrorMessage(responseData) ?? 'Server error occurred',
          'errors': responseData is Map ? responseData['errors'] : responseData,
        };
      } else {
        return {
          'success': false,
          'message': 'No response from server. Please try again.',
        };
      }
    }

    return {
      'success': false,
      'message': 'An unexpected error occurred: ${error.toString()}',
    };
  }

  // Helper function to safely extract error message
  String? _extractErrorMessage(dynamic responseData) {
    if (responseData == null) return null;

    if (responseData is Map) {
      if (responseData['message'] != null) {
        return responseData['message'].toString();
      }
      if (responseData['error'] != null) {
        return responseData['error'].toString();
      }
      if (responseData['errors'] is Map) {
        final errors = responseData['errors'] as Map;
        if (errors.isNotEmpty) {
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            return firstError.first.toString();
          }
          return firstError.toString();
        }
      }
    }

    return null;
  }

  // Clear token and logout
  Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
  }

  String get baseUrl => ApiConfig.baseUrl;
}