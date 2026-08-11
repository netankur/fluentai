import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';

class StorageService {
  static const String _settingsKey = 'fluentai_app_settings';

  Future<AppSettings> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString(_settingsKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final Map<String, dynamic> map = jsonDecode(jsonStr);
        return AppSettings.fromJson(map);
      }
    } catch (_) {
      // Fallback to defaults on corrupt storage
    }
    return const AppSettings();
  }

  Future<bool> saveSettings(AppSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(settings.toJson());
      return await prefs.setString(_settingsKey, jsonStr);
    } catch (_) {
      return false;
    }
  }
}
