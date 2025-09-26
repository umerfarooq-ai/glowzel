
import 'dart:convert';

import '../../../Constant/keys.dart';
import '../../../core/security/secure_auth_storage.dart';
import '../../../core/storage_services/storage_service.dart';
import '../../../utils/logger/logger.dart';

class SessionRepository {
  final StorageService _storageService;
  final AuthSecuredStorage _authSecuredStorage;

  final _log = logger(SessionRepository);

  SessionRepository(
      {required StorageService storageService,
        required AuthSecuredStorage authSecuredStorage})
      : _authSecuredStorage = authSecuredStorage,
        _storageService = storageService;

  Future<void> setLoggedIn(bool value) async {
    await _storageService.setBool(StorageKeys.isLoggedIn, value);
    _log.i('setLoggedIn $value');
  }

  bool isLoggedIn() {
    bool isLoggedIn = _storageService.getBool(StorageKeys.isLoggedIn);
    _log.i('isLoggedIn: $isLoggedIn');
    return isLoggedIn;
  }

  Future<void> setToken(String token) async {
    await _authSecuredStorage.writeToken(token: token);
    _log.i('token set with value $token');
  }

  Future<String?> getToken() async {
    return await _authSecuredStorage.readToken();
  }

  Future<void> removeToken() async {
    await _authSecuredStorage.removeToken();
    _log.i('token removed');
  }

  Future<void> clearLocalStorage() async {
    await _storageService.clear();
  }
  Future<void> setId(String id) async {
    await _authSecuredStorage.writeId(id: id);
    _log.i('UUID set with value $id');
  }

  Future<String?> getId() async {
    return await _authSecuredStorage.readId();
  }

  Future<void> setReminderId(String ReminderId) async {
    await _authSecuredStorage.writeReminderId(ReminderId: ReminderId);
    _log.i('ReminderId set with value $ReminderId');
  }

  Future<String?> getReminderId() async {
    return await _authSecuredStorage.readReminderId();
  }

  Future<void> setScanId(String scanId) async {
    await _authSecuredStorage.writeScanId(scanId: scanId);
    _log.i('Scan ID set with value $scanId');
  }

  Future<String?> getScanId() async {
    final scanId = await _authSecuredStorage.readScanId();
    _log.i('Retrieved scan ID: $scanId');
    return scanId;
  }

  Future<void> setLogId(String logId) async {
    await _authSecuredStorage.writeLogId(logId: logId);
    _log.i('Log ID set with value $logId');
  }

  Future<String?> getLogId() async {
    final logId = await _authSecuredStorage.readLogId();
    _log.i('Retrieved log ID: $logId');
    return logId;
  }

  Future<void> setToggle(String toggle) async {
    await _authSecuredStorage.writeToggle(toggle: toggle);
    _log.i('Steps set with value $toggle');
  }

  Future<String?> getToggle() async {
    final toggle = await _authSecuredStorage.readToggle();
    _log.i('Retrieved steps: $toggle');
    return toggle;
  }

  Future<void> setMorningToggleForDate(DateTime date, List<bool> toggles) async {
    final encoded = jsonEncode(toggles);
    await _authSecuredStorage.writeMorningToggleForDate(date, encoded);
  }

  Future<List<bool>?> getMorningToggleForDate(DateTime date) async {
    final saved = await _authSecuredStorage.readMorningToggleForDate(date);
    if (saved == null) return null;
    return List<bool>.from(jsonDecode(saved));
  }

  Future<void> setEveningToggleForDate(DateTime date, List<bool> toggles) async {
    final encoded = jsonEncode(toggles);
    await _authSecuredStorage.writeEveningToggleForDate(date, encoded);
  }

  Future<List<bool>?> getEveningToggleForDate(DateTime date) async {
    final saved = await _authSecuredStorage.readEveningToggleForDate(date);
    if (saved == null) return null;
    return List<bool>.from(jsonDecode(saved));
  }


  Future<void> setImagePath(String path) async {
    await _authSecuredStorage.writeImagePath(path: path);
    _log.i('Image path set with value $path');
  }

  Future<String?> getImagePath() async {
    final path = await _authSecuredStorage.readImagePath();
    _log.i('Retrieved image path: $path');
    return path;
  }

}
