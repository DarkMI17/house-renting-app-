class ApiConfig {
  //change this to your IP
  static const String baseUrl = 'http://192.168.0.107:8000/api'; // CHANGE THIS
  static const String imageBaseUrl = '192.168.0.107:8000';
  // API Endpoints
  static const String login = '/login';
  static const String register = '/register';
  static const String logout = '/logout';

  // Headers
  static Map<String, String> getHeaders({String? token}) {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Requested-With': 'XMLHttpRequest',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
}