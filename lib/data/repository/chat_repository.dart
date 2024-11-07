import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/chat_message.dart';

class ChatRepository {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('chat_rooms');
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

  // Upload multimedia
  Future<String?> uploadMedia(String path, String filePath) async {
    final ref = _storage.ref().child(path);
    await ref.putFile(File(filePath));
    return await ref.getDownloadURL();
  }
}
