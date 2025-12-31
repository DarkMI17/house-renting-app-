class ApiConfig {
  // Change this to your actual IP
  static const String serverBaseUrl = 'http://192.168.1.8:8000'; // ← Keep this as base URL
  static const String apiBaseUrl = '$serverBaseUrl/api'; // ← API endpoint

  // Static method to build image URLs
  static String getImageUrl(String imagePath) {
    if (imagePath.startsWith('http')) {
      return imagePath; // Already a full URL
    }

    if (imagePath.startsWith('/storage/')) {
      // Path like: /storage/apartments_images/filename.jpg
      return '$serverBaseUrl$imagePath';
    }

    // Path like: apartments_images/filename.jpg
    return '$serverBaseUrl/storage/$imagePath';
  }

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