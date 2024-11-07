class ChatMessage {
  String id;
  final String senderId;
  final String receiverId;
  final String senderName;
  final String receiverName;
  final String content;
  final DateTime timestamp;
  final String? imageUrl; // New attribute for image messages
  final String? audioUrl; // New attribute for audio messages
  final bool isGroup;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.senderName,
    required this.receiverName,
    required this.content,
    required this.timestamp,
    this.imageUrl,
    this.audioUrl,
    this.isGroup = false,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'],
      senderId: map['senderId'],
      receiverId: map['receiverId'],
      senderName: map['senderName'],
      receiverName: map['receiverName'],
      content: map['content'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      imageUrl: map['imageUrl'],
      audioUrl: map['audioUrl'],
      isGroup: map['isGroup'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'senderName': senderName,
      'receiverName': receiverName,
      'content': content,
        'timestamp': timestamp.millisecondsSinceEpoch,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'isGroup': isGroup,
    };
  }
}
