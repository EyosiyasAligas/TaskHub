import 'package:flutter/material.dart';

class UserModel {
  late final String id;
  late final String userName;
  late final String email;
  late final String fcmId;

  UserModel({
    required this.id,
    required this.userName,
    required this.email,
    required this.fcmId,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    id = json['localId'] ?? '';
    userName = json['displayName'] ?? "";
    email = json['email'] ?? '';
    fcmId = json['fcm_id'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['localId'] = id;
    data['user_name'] = userName;
    data['email'] = email;
    data['fcm_id'] = fcmId;
    return data;
  }
}