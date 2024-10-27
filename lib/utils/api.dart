import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'constants.dart';
import 'local_storage_keys.dart';

class ApiException implements Exception {
  String errorMessage;

  ApiException(this.errorMessage);

  @override
  String toString() {
    return errorMessage;
  }
}

class Api {
  static Map<String, String> headers() {
    final String jwtToken = Hive.box(authBoxKey).get(jwtTokenKey) ?? "";
    if (kDebugMode) {
      print("token is: $jwtToken");
    }
    return {
      "Content-Type": "application/json",
      // "Authorization": "Bearer $jwtToken",
    };
  }

  // app APIs
  static String login = "${authBaseUrl}signInWithPassword?key=$apiKey";
  static String signUp = "${authBaseUrl}signUp?key=$apiKey";
  static String logOut = "${authBaseUrl}signOut?key=$apiKey";
  static String forgotPassword = "${authBaseUrl}sendOobCode?key=$apiKey";

  // static String note = "${realTimeDatabaseBaseUrl}notes.json";

  static String note(String userId) =>
      "${realTimeDatabaseBaseUrl}notes/$userId.json";

  static String updateNote({required String userId, required String id}) =>
      "${realTimeDatabaseBaseUrl}notes//$id.json";

  // Api methods
  static Future<Map<String, dynamic>> post({
    required Map<String, dynamic> body,
    required String url,
    required bool useAuthToken,
  }) async {
    try {
      final uri = Uri.parse(url);
      final response = await http.post(
        uri,
        headers: useAuthToken ? headers() : {},
        body: json.encode(body),
      );
      if (kDebugMode) {
        print("API Called POST: $url");
        print("Body Params: $body");
        print("Header: ${useAuthToken ? headers() : {}}");
        print("Response: ${response.body}");
      }

      final responseData = json.decode(response.body) as Map<String, dynamic>;

      if (responseData['error'] != null) {
        if (kDebugMode) {
          print("POST ERROR: ${responseData['error']['message'].toString()}");
        }
        throw ApiException(responseData['error']['message'].toString());
      }

      return responseData;
    } on SocketException {
      throw ApiException('No Internet Connection, Please try again later');
    } on FirebaseAuthException catch (e) {
      throw ApiException(
          e.message ?? 'Something went wrong, Please try again later');
    }
  }

  static Future<Map<String, dynamic>> get({
    required String url,
    required bool useAuthToken,
  }) async {
    try {
      final uri = Uri.parse(url);
      final response = await http.get(
        uri,
        headers: useAuthToken ? headers() : {},
      );
      if (kDebugMode) {
        print("API Called GET: $url");
        print("Response: ${response.body}");
      }

      final responseData = json.decode(response.body) as Map<String, dynamic>;
      if (responseData['error']) {
        if (kDebugMode) {
          print("GET ERROR: ${responseData['code']}");
        }
        throw ApiException(responseData['code'].toString());
      }

      return responseData;
    } on SocketException {
      throw ApiException('No Internet Connection, Please try again later');
    } on FirebaseAuthException catch (e) {
      throw ApiException(
          e.message ?? 'Something went wrong, Please try again later');
    }
  }

  static Future<void> download({
    required String url,
    required String savePath,
    required Function updateDownloadedPercentage,
  }) async {
    try {
      final uri = Uri.parse(url);
      final request = http.Request('GET', uri);
      final response = await http.Client().send(request);

      final total = response.contentLength ?? 1;
      int bytes = 0;

      final file = File(savePath).openSync(mode: FileMode.write);
      await for (var chunk in response.stream) {
        file.writeFromSync(chunk);
        bytes += chunk.length;
        final double percentage = (bytes / total) * 100;
        updateDownloadedPercentage(percentage < 0.0 ? 99.0 : percentage);
      }
      file.close();
    } on SocketException {
      throw ApiException('No Internet Connection, Please try again later');
    } on FirebaseAuthException catch (e) {
      throw ApiException(
          e.message ?? 'Something went wrong, Please try again later');
    } catch (e) {
      throw ApiException('Something went wrong, Please try again later');
    }
  }
}
