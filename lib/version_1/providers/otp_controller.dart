import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uniport/version_1/providers/otp_repository.dart';

final otpControllerProvider = Provider((ref) {
  final otpRepository = ref.watch(otpRepositoryProvider);
  return OtpController(ref: ref, otpRepository: otpRepository);
});

class OtpController {
  final ProviderRef ref;
  final OtpRepository otpRepository;

  OtpController({
    required this.ref,
    required this.otpRepository,
  });

  void sendOtp(BuildContext context, {required String email}) {
    otpRepository.sendOtp(context, email: email);
  }

  void verifyOtp(BuildContext context,
      {required String email, required String otp}) {
    otpRepository.verifyOtp(context, email: email, otp: otp);
  }

  void setPassword(BuildContext context, {required String password}) {
    otpRepository.setNewPassword(context, password: password);
  }
}
