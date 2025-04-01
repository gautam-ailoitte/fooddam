// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:medguru/core/utils/constants.dart';
//
//
// /// Class containing Local DB methods, all data will be
// /// stored/read using this class
// class DBProvider {
//   late Box _userBox;
//   late Box _rolesBox;
//
//   /// Initialize User Info DB
//   _initializeUserBox() async {
//     _userBox = await Hive.openBox(DBConstants.userLocalDB);
//   }
//
//   /// Initialize User Info DB
//   _initializeRolesBox() async {
//     _rolesBox = await Hive.openBox(DBConstants.rolesLocalDB);
//   }
//
//
//   /// Save User Profile to Hive[Local DB]
//   Future<bool> saveUserInformation({required final String userData}) async {
//     await _initializeUserBox();
//     await _userBox.clear();
//     await _userBox.put("data", userData);
//     return Future.value(true);
//   }
//
//   /// This function will give the local information from DB
//   Future<String?> getUserInformation() async {
//     await _initializeUserBox();
//     return await _userBox.get("data");
//   }
//
//   /// Clear Hive [Local DB] While logout
//   void logout() async {
//     await _initializeUserBox();
//     await _initializeRolesBox();
//
//     await _userBox.clear();
//     await _rolesBox.clear();
//   }
// }
