import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/chat_message.dart';
import '../models/group.dart';

class ChatRepository {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('chat_rooms');
  final DatabaseReference _rootDbRef = FirebaseDatabase.instance.ref();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // // Add message
  // Future<void> addMessage(ChatMessage message) async {
  //   await _dbRef.push().set(message.toMap());
  // }

  Future<void> sendPrivateMessage(
      {required String receiverId,
      required String senderId,
      required ChatMessage message}) async {
    List<String> ids = [receiverId, senderId];
    ids.sort();
    final chatRoomId = ids.join('_');
    await _dbRef.child('private').child(chatRoomId).push().update(message.toMap());
  }

  // Fetch messages
  Stream<DatabaseEvent> fetchPrivateMessages(
      {required String receiverId, required String senderId}) {
    List<String> ids = [receiverId, senderId];
    ids.sort();
    final chatRoomId = ids.join('_');
    return _dbRef.child('private').child(chatRoomId).orderByChild('timestamp').onValue;
    // return _dbRef.child(chatRoomId).orderByChild('timestamp').onValue.map((event) {
    //   final messages = <ChatMessage>[];
    //   final data = event.snapshot.value;
    //   if (data != null) {
    //     // data.forEach((key, value) {
    //     //   messages.add(ChatMessage.fromMap(value));
    //     // });
    //   }
    //   // return messages;
    // });
  }

  Future<void> createGroup({
    required Group groupData,
  }) async {
    final groupId = _rootDbRef.child('groups').push().key;
    groupData.id = groupId!;

    await _rootDbRef.child('groups').child(groupId).set(groupData.toJson());
  }

  Stream<DatabaseEvent> fetchGroups() {
    return _rootDbRef.child('groups').onValue;
  }

  Stream<DatabaseEvent> fetchGroupMessages({required String groupId}) {
    return _dbRef.child('group').child(groupId).onValue;
  }

  Future<void> addMemberToGroup({
    required String groupId,
    required List<String> memberIds,
  }) async {
    // memberIds to Map<String, Object?>
    final Map<String, Object?> memberMap = {};
    memberIds.asMap().forEach((index, memberId) {
      memberMap['$index'] = memberId;
    });


    await _rootDbRef.child('groups').child(groupId).child('members').update(memberMap);
  }

  Future<void> sendGroupMessage({
    required String groupId,
    required ChatMessage message,
  }) async {
    await _dbRef.child('group').child(groupId).push().update(message.toMap());
  }

  // Upload multimedia
  Future<String?> uploadMedia(String path, String filePath) async {
    final ref = _storage.ref().child(path);
    await ref.putFile(File(filePath));
    return await ref.getDownloadURL();
  }
}
