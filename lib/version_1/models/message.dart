class Message {
  final String content; // message content
  final String sender; // uid of the sender
  final int type; // 0 for text, 1 for image
  final int createdAt; // timestamp of the message
  Message({
    required this.content,
    required this.sender,
    required this.createdAt,
    this.type = 0,
  });
  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'sender': sender,
      'createdAt': createdAt,
      'type': type,
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      content: json['content'],
      sender: json['sender'],
      createdAt: json['createdAt'],
      type: json['type'] ?? 0,
    );
  }
}
