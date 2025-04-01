

import 'package:ailoitte_components/src/config/config.dart';

class AiloitteAuthenticationHelper {

  final AiloitteLocalDataSource _localDataSource;
  

  AiloitteAuthenticationHelper({required AiloitteLocalDataSource localDataSource,})
      :_localDataSource = localDataSource;
  
  
  //final MyRemoteConfig _myRemoteConfig;

  /// delete Auth Token
  Future<void> deleteToken() async {
    _localDataSource.logout();
  }

  /// Save Auth Token
  Future<void> saveToken(String token) async {
    _localDataSource.saveAccessToken(token);
    return;
  }

  /// Save user id
  Future<void> saveUserId(int id) async {
    _localDataSource.saveUserId(id);
  }

  /// Read Auth Token
  Future<String?> getToken() async {
    return _localDataSource.getAccessToken();
  }

  /// delete User Type
  Future<void> deleteUserType() async {
    _localDataSource.deleteUserType();
  }

  /// Save User Type
  Future<void> saveUserType(String userType) async {
    _localDataSource.saveUserType(userType);
  }

  /// Read User Type
  Future<String?> getUserType() async {
    return _localDataSource.getUserType();
  }

  /// Read User ID
  Future<int?> getUserId() async {
    return _localDataSource.getUserId();
  }

  Future<bool> shouldPassFCMTokenToServer() async {
    return _localDataSource.shouldPassFCMTokenToServer();
  }

  /// Function called when logging out the user
  void fcmTokenPassedToServer() {
    _localDataSource.fcmTokenPassedToServer();
  }

  Future<bool> shouldShowIntroScreen() async {
    return _localDataSource.shouldShowIntroScreen();
  }

  Future<bool> isRegistrationCompleted() async {
    return _localDataSource.isRegistrationCompleted();
  }

  void setRegistrationCompletedFlag(final bool flag) {
    _localDataSource.setRegistrationCompletedFlag(flag);
  }

  Future<String> getUserRole() async {
    return await _localDataSource.getUserRole();
  }

  Future<void> setUserRole({required final String role}) async {
    return await _localDataSource.setUserRole(role: role);
  }
}
