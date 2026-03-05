import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../data/models/user_preferences.dart';

/// 用户偏好管理服务
class PreferencesService {
  static final PreferencesService instance = PreferencesService._();
  PreferencesService._();

  static const String _keyPreferences = 'user_preferences';
  UserPreferences _preferences = const UserPreferences();

  /// 获取当前偏好
  UserPreferences get preferences => _preferences;

  /// 初始化
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyPreferences);
    if (jsonStr != null) {
      _preferences = UserPreferences.fromJson(json.decode(jsonStr));
    }
  }

  /// 更新用户角色
  Future<void> setRole(UserRole role) async {
    _preferences = UserPreferences(role: role);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPreferences, json.encode(_preferences.toJson()));
  }
}
