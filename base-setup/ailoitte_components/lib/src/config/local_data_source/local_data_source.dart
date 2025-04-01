import 'package:ailoitte_components/src/config/shared_pref/shared_pref.dart';

/// Class for saving/loading data from local storage
class AiloitteLocalDataSource {
  final AiloitteSharedPref _sharedPref;
  //final AiloitteSharedPref _dbProvider;



  AiloitteLocalDataSource({required AiloitteSharedPref sharedPref,})
      :_sharedPref = sharedPref;

  
  void deleteUserType() {
    // TODO: implement deleteUserType
  }

  
  void fcmTokenPassedToServer() {
    _sharedPref.fcmTokenPassedToServer();
  }

  
  String getAccessToken() {
    return _sharedPref.getAccessToken();
  }



  
  int getUserId() {
    // TODO: implement getUserId
    throw UnimplementedError();
  }

  
  String getUserType() {
    // TODO: implement getUserType
    throw UnimplementedError();
  }

  
  void logout() {
    _sharedPref.logout();
  }

  
  void saveAccessToken(String accessToken) {
    _sharedPref.saveAccessToken(accessToken);
  }

  
  void saveUserId(int userId) {
    // TODO: implement saveUserId
  }

  
  void saveUserType(String userType) {
    // TODO: implement saveUserType
  }

  
  Future<bool> shouldPassFCMTokenToServer() async {
    return _sharedPref.shouldPassFCMTokenToServer();
  }

  
  Future<bool> shouldShowIntroScreen() async {
    return _sharedPref.shouldShowIntroScreen();
  }

  
  Future<bool> isRegistrationCompleted() async {
    return _sharedPref.isRegistrationCompleted();
  }

  
  void setRegistrationCompletedFlag(final bool flag) async {
    _sharedPref.setRegistrationCompletedFlag(flag);
  }

  
  Future<String> getUserRole() async {
    return await _sharedPref.getUserRole();
  }

  
  Future<void> setUserRole({required String role}) async {
    return await _sharedPref.setUserRole(role);
  }


}