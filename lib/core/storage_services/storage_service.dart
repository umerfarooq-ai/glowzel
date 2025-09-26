
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  final SharedPreferences _preferences;

  StorageService({required SharedPreferences sharedPreferences}) : _preferences = sharedPreferences;

  Future<void> setString(String key, String value) async {
    await _preferences.setString(key, value);
  }

  Future<void> setInt(String key, int value) async {
    await _preferences.setInt(key, value);
  }

  int getInt(String key) {
    return _preferences.getInt(key) ?? 0;
  }

  Future<void> setBool(String key, bool value) async {
    await _preferences.setBool(key, value);
  }

  bool getBool(String key, [value]) {
    return _preferences.getBool(key) ?? value ?? false;
  }

  String getString(String key, [value]) {
    return _preferences.getString(key) ?? value ?? '';
  }

  Future<bool> remove(String key) async {
    return await _preferences.remove(key);
  }


  Future<bool> clear() async {
    return await _preferences.clear();
  }
  Future<void> clearUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
