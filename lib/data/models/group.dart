class Group {
  String id;
  final String name;
  final String creatorId;
  List<String> members;
  final String lastMessage;
  final String lastMessageTime;

  Group({
    required this.id,
    required this.name,
    required this.creatorId,
    required this.members,
    required this.lastMessage,
    required this.lastMessageTime,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'],
      name: json['name'],
      creatorId: json['creatorId'],
      members: List<String>.from(json['members']),
      lastMessage: json['lastMessage'],
      lastMessageTime: json['lastMessageTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'creatorId': creatorId,
      'members': members,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime,
    };
  }
}