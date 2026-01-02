import 'package:shared_preferences/shared_preferences.dart';


class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }


  static Future<void> saveToken(String token) async =>
      await _prefs?.setString('access_token', token);

  static String? getToken() => _prefs?.getString('access_token');


  static Future<void> saveUser(String userJson) async =>
      await _prefs?.setString('user_data', userJson);

  static String? getUser() => _prefs?.getString('user_data');

  static Future<void> logout() async => await _prefs?.clear();
}