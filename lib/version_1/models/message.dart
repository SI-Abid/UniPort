class Message {
  final String message; // message content
  final String sender;  // uid of the sender
  final bool? seen;     // whether the message is seen or not
  final int createdAt;  // timestamp of the message
  Message({
    required this.message,
    required this.sender,
    required this.createdAt,
    this.seen = false,
  });
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'sender': sender,
      'createdAt': createdAt,
      'seen': seen,
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      message: json['message'],
      sender: json['sender'],
      createdAt: json['createdAt'],
      seen: json['seen'],
    );
  }
}