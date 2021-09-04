library authorization_key;

import 'package:shared_preferences/shared_preferences.dart';

/// The authorization key storage namespace class.
///
/// It use [SharedPreferences] to manipulate the recieved authorization key from the server.
class AuthorizationKey {
  static SharedPreferences? _instance;

  static Future<SharedPreferences?> _getInstance() async {
    if (_instance == null) _instance = await SharedPreferences.getInstance();
    return _instance;
  }

  /// Save the authorization key.
  static Future<bool> put(String encoded) async {
    SharedPreferences? pref = await _getInstance();
    if (pref == null) return false;
    bool c = await pref.setString('Authorization', 'JWT $encoded');
    return c;
  }

  /// Remove the autorization key.
  static Future<bool> delete() async {
    SharedPreferences? pref = await _getInstance();
    if (pref == null) return false;
    bool c = await pref.remove('Authorization');
    return c;
  }

  /// Get the authorization key.
  static Future<String?> get() async {
    SharedPreferences? pref = await _getInstance();
    if (pref == null) return null;
    String? c = pref.getString('Authorization');
    return c;
  }
}
