import 'package:shared_preferences/shared_preferences.dart';

class AuthState {
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userRoleKey = 'user_role';

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Get user role
  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userRoleKey);
  }

  // Set user as logged in
  static Future<void> setLoggedIn({required String role}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setString(_userRoleKey, role);
  }

  // Log out user
  static Future<void> logOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, false);
    await prefs.remove(_userRoleKey);
  }
}
