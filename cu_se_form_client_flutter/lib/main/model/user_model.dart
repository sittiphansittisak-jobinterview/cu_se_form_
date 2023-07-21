import 'package:cu_se_form_client_flutter/setting/shared_preferences_local_database.dart';

class UserModel {
  static const _accessJwtKey = 'user.accessJwt';
  static const _refreshJwtKey = 'user.refreshJwt';
  static const _emailKey = 'user.email';

  static String? getLatestEmail() => SharedPreferencesLocalDatabase.db.getString(_emailKey);
  static String? getAccessJwt() => SharedPreferencesLocalDatabase.db.getString(_accessJwtKey);
  static String? getRefreshJwt() => SharedPreferencesLocalDatabase.db.getString(_refreshJwtKey);
  static String? getEmail() => SharedPreferencesLocalDatabase.db.getString(_emailKey);
  static Future<bool> setAccessJwt(String? accessJwt) async => accessJwt == null ? false : await SharedPreferencesLocalDatabase.db.setString(_accessJwtKey, accessJwt);
  static Future<bool> setRefreshJwt(String? refreshJwt) async => refreshJwt == null ? false : await SharedPreferencesLocalDatabase.db.setString(_refreshJwtKey, refreshJwt);
  static Future<bool> setEmail(String? email) async => email == null ? false : await SharedPreferencesLocalDatabase.db.setString(_emailKey, email);

  //Should not failed.
  static Future removeAllJwt() async {
    await SharedPreferencesLocalDatabase.db.remove(_accessJwtKey);
    await SharedPreferencesLocalDatabase.db.remove(_refreshJwtKey);
  }
}
