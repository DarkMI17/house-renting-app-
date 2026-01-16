import 'package:dio/dio.dart' as dio_service;
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:house_rent_app_002/services/services/storage_service.dart';
import 'config.dart';
import '../pages/login.dart';

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

  // GET request
  Future<dio_service.Response> get(
      String path, {
        Map<String, dynamic>? queryParameters,
        dio_service.Options? options,
        dio_service.CancelToken? cancelToken,
        dio_service.ProgressCallback? onReceiveProgress,
      }) async {
    if (!_isInitialized) initialize();
    return await _dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }

  // POST request
  Future<dio_service.Response> post(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        dio_service.Options? options,
        dio_service.CancelToken? cancelToken,
        dio_service.ProgressCallback? onSendProgress,
        dio_service.ProgressCallback? onReceiveProgress,
      }) async {
    if (!_isInitialized) initialize();
    return await _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  // PUT request
  Future<dio_service.Response> put(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        dio_service.Options? options,
        dio_service.CancelToken? cancelToken,
        dio_service.ProgressCallback? onSendProgress,
        dio_service.ProgressCallback? onReceiveProgress,
      }) async {
    if (!_isInitialized) initialize();
    return await _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  // DELETE request
  Future<dio_service.Response> delete(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        dio_service.Options? options,
        dio_service.CancelToken? cancelToken,
      }) async {
    if (!_isInitialized) initialize();
    return await _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }
}
