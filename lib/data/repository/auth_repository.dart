import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../utils/api.dart';
import '../../utils/constants.dart';
import '../../utils/local_storage_keys.dart';
import '../models/user.dart';

class AuthRepository {
  //LocalDataSource
  bool getIsLogIn() {
    return Hive.box(authBoxKey).get(isLogInKey) ?? false;
  }

  Future<void> setIsLogIn(bool value) async {
    return Hive.box(authBoxKey).put(isLogInKey, value);
  }

  UserModel getUserDetails() {
    return UserModel.fromJson(
      Map.from(Hive.box(authBoxKey).get(userDetailsKey) ?? {}),
    );
  }

  Future<void> setUserDetails(UserModel user) async {
    return Hive.box(authBoxKey).put(userDetailsKey, user.toJson());
  }

  String getJwtToken() {
    return Hive.box(authBoxKey).get(jwtTokenKey) ?? "";
  }

  Future<void> setJwtToken(String value) async {
    return Hive.box(authBoxKey).put(jwtTokenKey, value);
  }

  Future<Map<String, dynamic>> signIn(
      {required String email, required String password}) async {
    final url = Api.login;
    final body = {
      'email': email,
      'password': password,
      'returnSecureToken': true,
    };

    try {
      final response =
          await Api.post(body: body, url: url, useAuthToken: false);
      return {
        "jwtToken": response['idToken'],
        "user": UserModel.fromJson(Map.from(response))
      };
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<Map<String, dynamic>> signUp(
      {required String email, required String password}) async {
    final url = Api.signUp;
    final body = {
      'email': email,
      'password': password,
      'returnSecureToken': true,
    };

    try {
      final response =
          await Api.post(body: body, url: url, useAuthToken: false);
      return {
        "jwtToken": response['idToken'],
        "user": UserModel.fromJson(Map.from(response))
      };
    } catch (e) {
      throw ApiException('Failed to sign up: $e');
    }
  }

  Future<void> signOut(String token) async {
    final url = Api.logOut;
    final body = {
      'idToken': token,
    };

    try {
      setIsLogIn(false);
      setJwtToken("");
      setUserDetails(UserModel.fromJson({}));
      // await Api.post(body: body, url: url, useAuthToken: true);
    } catch (e) {
      throw ApiException('Failed to sign out: $e');
    }
  }

  Future<void> forgotPassword({required String email}) async {
    final url = Api.forgotPassword;
    final body = {
      "requestType": "PASSWORD_RESET",
      'email': email,
    };

    try {
      await Api.post(body: body, url: url, useAuthToken: false);
    } catch (e) {
      throw ApiException('Failed to reset password: $e');
    }
  }

// Future<UserModel?> fetchUserProfile() async {
//   try {
//     return UserModel.fromJson(
//       await Api.get(url: Api.profile, useAuthToken: true)
//           .then((value) => value['data']),
//     );
//   } catch (e) {
//     return null;
//     // throw ApiException(e.toString());
//   }
// }
}
