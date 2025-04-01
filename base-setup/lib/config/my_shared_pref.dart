import 'package:shared_preferences/shared_preferences.dart';

/// Class containing 'SharedPreferences' instance, all data will be
/// stored/read using this class
class MySharedPref {
  static const accessToken = "access_token";

  final SharedPreferences _pref;

  MySharedPref(this._pref);

  Future<bool> setAccessToken(String token) {
    return _pref.setString(accessToken, token);
  }

  String? getAccessToken() {
    return _pref.getString(accessToken);
  }

  /// logout the user
  Future<void> logout() async {
    await _pref.remove(accessToken);
  }
}
