import 'package:shared_preferences/shared_preferences.dart';

const _kAccess = 'safed_prixod_access';
const _kRefresh = 'safed_prixod_refresh';

class TokenStorage {
  Future<String?> readAccess() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kAccess);
  }

  Future<String?> readRefresh() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kRefresh);
  }

  Future<void> saveTokens({required String access, String? refresh}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAccess, access);
    if (refresh != null && refresh.isNotEmpty) {
      await prefs.setString(_kRefresh, refresh);
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kAccess);
    await prefs.remove(_kRefresh);
  }
}
