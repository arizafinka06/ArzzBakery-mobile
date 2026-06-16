part of '../main.dart';

// ==================== STORAGE SERVICE ====================
class StorageService {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final userJson = _prefs.getString('currentUser');
    if (userJson != null) {
      currentUser = User.fromJson(jsonDecode(userJson));
    }
  }

  static Future<void> saveUser(User? user) async {
    if (user == null) {
      await _prefs.remove('currentUser');
    } else {
      await _prefs.setString('currentUser', jsonEncode(user.toJson()));
    }
  }

  static Future<void> clearAll() async {
    await _prefs.clear();
    currentUser = null;
    orderHistory.clear();
  }
}
