import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
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

  final _database = FirebaseDatabase.instance.ref('users');

  Future<Map<String, dynamic>> signIn(
      {required String email, required String password}) async {
    final url = Api.login;
    final body = {
      'email': email,
      'password': password,
      'returnSecureToken': true,
    };

    try {
      final response = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      var userMap = {
        'email': email,
        // 'fcm_id': await FirebaseMessaging.instance.getToken(),
        'localId': response.user!.uid,
        'displayName': email.split('@')[0],
        'fcm_id': '',
      };
      String? token = await response.user!.getIdToken();
      print('userMap: $userMap');
      return {"jwtToken": token, "user": UserModel.fromJson(Map.from(userMap))};
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
      //signUp using firebase sdk
      final response = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      await _database.child(response.user!.uid).set({
        'id': response.user!.uid,
        'email': email,
        'isOnline': true,
      });
      var userMap = {
        'email': email,
        // 'fcm_id': await FirebaseMessaging.instance.getToken(),
        'localId': response.user!.uid,
        'displayName': email.split('@')[0],
        'fcm_id': '',
      };
      String? token = await response.user!.getIdToken();
      print('userMap: $userMap');
      return {"jwtToken": token, "user": UserModel.fromJson(Map.from(userMap))};
    } catch (e) {
      throw ApiException('Failed to sign up: $e');
    }
  }

  Future<void> signOut(String token) async {
    final body = {
      'idToken': token,
    };

    try {
      setIsLogIn(false);
      setJwtToken("");
      setUserDetails(UserModel.fromJson({}));
      final response = await FirebaseAuth.instance.signOut();
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

  Future<void> setUserStatus(String userId, bool isOnline) async {
    await _database.child(userId).update({'isOnline': isOnline});
  }

  Stream<DatabaseEvent> getUserStatus(String receiverId) {
    return FirebaseDatabase.instance
        .ref('users/$receiverId}/isOnline')
        .onValue;
  }

  Future<List<UserModel>> fetchUsers() async {
    try {
      final response = await _database.get();
      if (response.value != null) {
        Map<String, dynamic> fetchedData = jsonDecode(
            jsonEncode(response.value, toEncodable: (e) => e.toString()));

        Map<String, String> users = {};
        fetchedData.forEach((key, value) {
          users[key] = value['email'];
        });
        //remove current user from the list
        users.remove(getUserDetails().id);
        print('users: $users');
        // convert map to list of UserModel
        List<UserModel> usersList = users.entries
            .map((e) => UserModel(
                  id: e.key,
                  email: e.value,
                  userName: e.value.split('@')[0],
                  fcmId: '',
                ))
            .toList();
        return usersList;
      }
      return [];
    } catch (e) {
      return [];
      // throw ApiException(e.toString());
    }
  }

  Stream<DatabaseEvent> fetchUserStream(String userId) {
    return _database.child(userId).onValue;
  }
}
