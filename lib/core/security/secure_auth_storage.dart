import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kTokenKey = "token";

class AuthSecuredStorage {
  final FlutterSecureStorage _storage;

  AuthSecuredStorage({
    FlutterSecureStorage? storage,
  }) : _storage = storage ??
      const FlutterSecureStorage(
        aOptions: AndroidOptions(
          encryptedSharedPreferences: true,
        ),
      );

  Future<void> writeToken({required String token}) async {
    await _storage.write(key: _kTokenKey, value: token);
  }

  Future<String> readToken() async {
    return await _storage.read(key: _kTokenKey) ?? 'empty-token';
  }
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwtToken', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwtToken');
  }

  Future<void> removeToken() async {
    await _storage.delete(key: _kTokenKey);
  }

  Future<void> writeId({required String id}) async {
    await _storage.write(key: 'id', value: id);
  }

  Future<String?> readId() async {
    return await _storage.read(key: 'id');
  }

  Future<void> writeReminderId({required String ReminderId}) async {
    await _storage.write(key: 'ReminderId', value: ReminderId);
  }

  Future<String?> readReminderId() async {
    return await _storage.read(key: 'ReminderId');
  }

  Future<void> writeScanId({required String scanId}) async {
    await _storage.write(key: 'scanId', value: scanId);
  }

  Future<String?> readScanId() async {
    return await _storage.read(key: 'scanId');
  }

  Future<void> writeLogId({required String logId}) async {
    await _storage.write(key: 'logId', value: logId);
  }

  Future<String?> readLogId() async {
    return await _storage.read(key: 'logId');
  }

  Future<void> writeToggle({required String toggle}) async {
    await _storage.write(key: 'toggle', value: toggle);
  }

  Future<String?> readToggle() async {
    return await _storage.read(key: 'toggle');
  }

  Future<void> writeMorningToggleForDate(DateTime date, String toggle) async {
    final key = "MorningToggle_${DateFormat('yyyy-MM-dd').format(date)}";
    await _storage.write(key: key, value: toggle);
  }

  Future<String?> readMorningToggleForDate(DateTime date) async {
    final key = "MorningToggle_${DateFormat('yyyy-MM-dd').format(date)}";
    return await _storage.read(key: key);
  }

  Future<void> writeEveningToggleForDate(DateTime date, String toggle) async {
    final key = "EveningToggle_${DateFormat('yyyy-MM-dd').format(date)}";
    await _storage.write(key: key, value: toggle);
  }

  Future<String?> readEveningToggleForDate(DateTime date) async {
    final key = "EveningToggle_${DateFormat('yyyy-MM-dd').format(date)}";
    return await _storage.read(key: key);
  }

  Future<void> writeImagePath({required String path}) async {
    await _storage.write(key: 'imagePath', value: path);
  }

  Future<String?> readImagePath() async {
    return await _storage.read(key: 'imagePath');
  }


  Future<void> clear() async {
    await _storage.deleteAll();
  }
}
