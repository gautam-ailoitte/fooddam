import '../../../../config/cache/db_provider.dart';
import '../../../../config/my_shared_pref.dart';

abstract class LocalDataSource {
  String? getAccessToken();

  Future<bool> setAccessToken(String token);

  Future<void> logout();
}

class LocalDataSourceImpl extends LocalDataSource {
  final MySharedPref mySharedPref;
  final DBProvider dbProvider;

  LocalDataSourceImpl(
    this.mySharedPref,
    this.dbProvider,
  );

  @override
  String? getAccessToken() {
    return mySharedPref.getAccessToken();
  }

  @override
  Future<bool> setAccessToken(String token) {
    return mySharedPref.setAccessToken(token);
  }

  @override
  Future<void> logout() async {
    return await mySharedPref.logout();
  }
}
