// ignore_for_file: file_names

import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveToken(String token) async {
    await _prefs.setString('auth_token', token);
    log("token saved$token");
  }

  String? getToken() {
    return _prefs.getString('auth_token');
  }

  Future<void> removeToken() async {
    await _prefs.remove('auth_token');
  }

  Future<void> saveBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  bool getBool(String key) {
    return _prefs.getBool(key) ?? false;
  }

  Future<void> saveString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  Future<void> saveInt(String key, int value) async {
    log("Save int: $value");
    await _prefs.setInt(key, value);
  }

  String? getString(String key) {
    return _prefs.getString(key);
  }

  clear() {
    log("All clear");
    return _prefs.clear();
  }

  int? getInt(String key) {
    return _prefs.getInt(key);
  }
}
