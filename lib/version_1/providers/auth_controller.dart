import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uniport/version_1/models/user.dart';
import 'package:uniport/version_1/providers/auth_repository.dart';


final authControllerProvider = Provider((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthController(
    authRepository: authRepository,
    ref: ref,
  );
});

final userAuthProvider = FutureProvider((ref) {
  final authController = ref.watch(authControllerProvider);
  return authController.getUser();
});

class AuthController {
  final AuthRepository authRepository;
  final ProviderRef ref;

  AuthController({
    required this.authRepository,
    required this.ref,
  });

  Future<UserModel?> getUser() async {
    return await authRepository.getUser();
  }

  void signInWithGoogle(BuildContext context) {
    authRepository.signInWithGoogle(context);
  }

  void signOut(BuildContext context) {
    authRepository.signOut(context);
  }

  void signInWithEmail(BuildContext context,
      {required String email, required String password}) {
    authRepository.signInWithEmail(context, email: email, password: password);
  }

  void setOnlineStatus(bool status) {
    authRepository.updateOnlineStatus(status);
  }

  void createUser(BuildContext context,
      {Map<String, dynamic> data = const {}, bool lastStep = false}) {
    authRepository.createUser(context, data: data, lastStep: lastStep);
  }
}
