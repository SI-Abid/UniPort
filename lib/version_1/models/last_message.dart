import 'package:uniport/version_1/models/models.dart';

class LastMessage {
  final Message message;
  final UserModel sender;

  LastMessage({required this.message, required this.sender});
}

class GroupLastMessage extends LastMessage {
  final String batch;
  final List<String> sections;

  GroupLastMessage({
    required this.batch,
    required this.sections,
    required Message message,
    required UserModel sender,
  }) : super(message: message, sender: sender);
}
