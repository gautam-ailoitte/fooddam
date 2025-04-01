import 'package:shared_preferences/shared_preferences.dart';

/// Class containing 'SharedPreferences' instance, all data will be
/// stored/read using this class
class AiloitteSharedPref {
  static const userType = "user_type";
  static const accessToken = "access_token";
  static const userId = "user_id";
  static const fcmToken = "fcm_token";
  static const showIntroScreen = "shouldShowIntroScreen";
  static const registrationFlag = "registration";
  static const userRole = "role";

  final SharedPreferences _pref;

  AiloitteSharedPref(this._pref);

  /// Save access token
  void saveAccessToken(String token) {
    _pref.setString(accessToken, token);
  }

  /// Get access token
  String getAccessToken() {
    return _pref.getString(accessToken) ?? "";
  }

  /// Getting the user's ID
  int getUserId() {
    return _pref.getInt(userId) ?? -1;
  }

  /// Saving the user's ID
  void setUserId(final int id) {
    _pref.setInt(userId, id);
  }

  /// Saving the user type
  void setUserType(final String type) {
    _pref.setString(userType, type);
  }

  /// Saving the user type
  String getUserType() {
    return _pref.getString(userType) ?? "";
  }

  /// deleting the user id
  void deleteUserType() {
    _pref.remove(userType);
  }

  /// logout the user
  void logout() {
    _pref.remove(userType);
    _pref.remove(accessToken);
    _pref.remove(fcmToken);
    _pref.remove(userId);
    _pref.remove(userRole);
    _pref.remove(userRole);
    _pref.remove(registrationFlag);
  }

  /// Function called when we need to check if we have to show profile screen to the user
  bool shouldPassFCMTokenToServer() {
    return _pref.getBool(fcmToken) ?? true;
  }

  /// Function called when logging out the user
  void fcmTokenPassedToServer() {
    _pref.setBool(fcmToken, false);
  }

  /// Function called when we need to check if we have to show profile screen to the user
  bool shouldShowIntroScreen() {
    final shouldShowIntro = _pref.getBool(showIntroScreen) ?? true;
    if (shouldShowIntro) {
      _pref.setBool(showIntroScreen, false);
    }
    return shouldShowIntro;
  }

  ///Function called when logging out the user
  bool isRegistrationCompleted() {
    return _pref.getBool(registrationFlag) ?? false;
  }

  void setRegistrationCompletedFlag(bool flag) {
    _pref.setBool(registrationFlag, flag);
  }

  ///Function to get the user current role
  Future<String> getUserRole() async {
    return  _pref.getString(userRole) ?? "";
  }

  Future<void> setUserRole(String role) async {
    await _pref.setString(userRole, role);
    return;
  }

/*/// Function to store countries cache data to local data base (SharedPref)
  void storeCountriesCachedData(Map<String, dynamic> cache) {
    _pref.setString(CACHE_COUNTRY_DATA, jsonEncode(cache));
  }

  ///Function to get stored countries data from shared Pref
  Map<String, dynamic>? getCountiesCachedData() {
    var cacheData = _pref.getString(CACHE_COUNTRY_DATA) ?? null;
    if (cacheData != null) {
      return jsonDecode(cacheData);
    }
    return null;
  }*/

}
