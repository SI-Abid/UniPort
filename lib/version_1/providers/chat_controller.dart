import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uniport/version_1/models/batch_model.dart';
import 'package:uniport/version_1/models/last_message.dart';
import 'package:uniport/version_1/models/models.dart';
import 'package:uniport/version_1/providers/auth_controller.dart';
import 'package:uniport/version_1/providers/chat_repository.dart';

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
    ref
        .read(userAuthProvider)
        .whenData((value) => chatRepository.sendText(value!, recieverId, text));
  }

  void sendImage({required String recieverId, required String path}) {
    ref.read(userAuthProvider).whenData(
        (value) => chatRepository.sendImage(value!, recieverId, path));
  }

  Stream<List<Message>> chatStream({required String recieverId}) {
    return ref.read(chatRepositoryProvider).getChatStream(recieverId);
  }

  Stream<List<LastMessage>> lastMessageStream() {
    return ref.read(chatRepositoryProvider).getLastMessageStream();
  }

  Stream<List<GroupLastMessage>> groupLastMessageStream() {
    final stream = ref.read(userAuthProvider).whenData((value) {
      return chatRepository.getGroupLastMessageStream(value!);
    });
    return stream.asData!.value;
  }

  Stream<List<GroupMessage>> groupChatStream({required String groupId}) {
    return ref.read(chatRepositoryProvider).getGroupChatStream(groupId);
  }

  void sendGroupMessage({required String groupId, required String text}) {
    ref.read(userAuthProvider).whenData(
        (value) => chatRepository.sendGroupText(value!, groupId, text));
  }

  void sendGroupImage({required String groupId, required String path}) {
    ref.read(userAuthProvider).whenData(
        (value) => chatRepository.sendGroupImage(value!, groupId, path));
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
}
