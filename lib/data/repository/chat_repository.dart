import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/chat_message.dart';

class ChatRepository {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('chats');
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Add message
  Future<void> addMessage(ChatMessage message) async {
    await _dbRef.push().set(message.toMap());
  }

  // Fetch messages
  Stream<List<ChatMessage>> getMessages() {
    return _dbRef.onValue.map((event) {
      final messages = <ChatMessage>[];
      for (var child in event.snapshot.children) {
        final messageMap = Map<String, dynamic>.from(child.value as Map);
        messages.add(ChatMessage.fromMap(messageMap));
      }
      return messages;
    });
  }

  // Upload multimedia
  Future<String?> uploadMedia(String path, String filePath) async {
    final ref = _storage.ref().child(path);
    await ref.putFile(File(filePath));
    return await ref.getDownloadURL();
  }
}
