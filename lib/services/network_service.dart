import 'package:dio/dio.dart' as dio_service;
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:house_rent_app_002/services/services/storage_service.dart';
import 'config.dart';
import '../pages/login.dart';
import 'package:dio/dio.dart';
class NetworkService {
  static final NetworkService _instance = NetworkService._internal();

  factory NetworkService() => _instance;

  NetworkService._internal();

  late dio_service.Dio _dio;
  bool _isInitialized = false;

  void initialize() {
    if (_isInitialized) return;

    _dio = dio_service.Dio(
      dio_service.BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );


    _dio.interceptors.add(dio_service.InterceptorsWrapper(
      onRequest: (options, handler) {

        final token = StorageService.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        options.headers['Accept'] = 'application/json';
        return handler.next(options);
      },
      onError: (dio_service.DioException error, handler) {

        if (error.response?.statusCode == 401) {
          StorageService.logout();
          Get.offAll(() => const LoginPage());
        }
        return handler.next(error);
      },
    ));
    _isInitialized = true;
  }

  Future<dio_service.Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    if (!_isInitialized) initialize();

    return await _dio.get(path, queryParameters: queryParameters);
  }

  Future<dio_service.Response> post(String path, {dynamic data}) async {
    if (!_isInitialized) initialize();
    return await _dio.post(path, data: data);
  }

  Future<Response> delete(String path, {Object? data, Map<String,
      dynamic>? queryParameters, Options? options}) async {
    return await _dio.delete(
        path, data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response> put(String path, {Object? data, Map<String,
      dynamic>? queryParameters, Options? options}) async {
    return await _dio.put(
        path, data: data, queryParameters: queryParameters, options: options);
  }






}