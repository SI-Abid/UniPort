import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uniport/version_1/models/models.dart';
import 'package:uniport/version_1/providers/chat_repository.dart';

import 'user_provider.dart';

final chatControllerProvider = Provider((ref) {
  final chatRepository = ref.watch(chatRepositoryProvider);
  return ChatController(
    ref: ref,
    chatRepository: chatRepository,
  );
});

final batchProvider = FutureProvider((ref) {
  final chatController = ref.watch(chatControllerProvider);
  return chatController.getBatches();
});

final teacherProvider = FutureProvider((ref) {
  final chatController = ref.watch(chatControllerProvider);
  return chatController.getTeachers();
});

class ChatController {
  final ChatRepository chatRepository;
  final ProviderRef ref;

  ChatController({required this.ref, required this.chatRepository});

  void sendMessage({required String recieverId, required String text}) {
    final user = ref.read(userProvider);
    ref.read(chatRepositoryProvider).sendText(user, recieverId, text);
  }

  void sendImage({required String recieverId, required String path}) {
    final user = ref.read(userProvider);
    ref.read(chatRepositoryProvider).sendImage(user, recieverId, path);
  }

  Stream<List<Message>> chatStream({required String recieverId}) {
    return ref.read(chatRepositoryProvider).getChatStream(recieverId);
  }

  Stream<List<Stream<LastMessage>>> lastMessageStream() {
    final user = ref.read(userProvider);
    final List<UserModel> users = ref
        .read(userListProvider)
        .when(data: (data) => data, error: (_, __) => [], loading: () => []);
    return ref.read(chatRepositoryProvider).getLastMessageStream(user, users);
  }

  Stream<List<GroupLastMessage>> groupLastMessageStream() {
    final user = ref.read(userProvider);
    final stream =
        ref.read(chatRepositoryProvider).getGroupLastMessageStream(user);
    return stream;
  }

  Stream<List<GroupMessage>> groupChatStream({required String groupId}) {
    return ref.read(chatRepositoryProvider).getGroupChatStream(groupId);
  }

  void sendGroupMessage({required String groupId, required String text}) {
    final user = ref.read(userProvider);
    ref.read(chatRepositoryProvider).sendGroupText(user, groupId, text);
  }

  void sendGroupImage({required String groupId, required String path}) {
    final user = ref.read(userProvider);
    ref.read(chatRepositoryProvider).sendGroupImage(user, groupId, path);
  }

  void deleteMessage({required Message message, required String chatId}) {
    chatRepository.deleteMessage(chatId: chatId, message: message);
  }

  void deleteChat({required String chatId, String? collection}) {
    chatRepository.deleteChat(
        chatId: chatId, collection: collection ?? 'chats');
  }

  Future<List<BatchModel>> getBatches() async {
    return await chatRepository.getBatchList();
  }

  Future<List<UserModel>> getTeachers() async {
    return await chatRepository.getApprovedTeachersList();
  }

  void readMessage(Message message) {
    chatRepository.markAsRead(message);
  }
}
