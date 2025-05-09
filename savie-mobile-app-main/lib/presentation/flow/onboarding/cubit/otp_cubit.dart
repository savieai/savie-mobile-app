import 'package:either_dart/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../../domain/domain.dart';

part 'otp_state.dart';
part 'otp_cubit.freezed.dart';

final Map<String, DateTime> _emailsSentAt = <String, DateTime>{};

@Injectable()
class OtpCubit extends Cubit<OtpState> {
  OtpCubit(
    this._authRepository,
  ) : super(const OtpState.initial());

  final AuthRepository _authRepository;

  bool get otpVerified => state.whenOrNull(otpVerified: () => true) ?? false;

  Future<void> submitEmail(String email) async {
    emit(const OtpState.sendingOTP());
    await _submitEmail(email);
  }

  Future<void> resubmitEmail(String email) async {
    emit(const OtpState.resendingOTP());
    await _submitEmail(email);
  }

  Future<void> _submitEmail(String email) async {
    if (email == 'reviewer@savie.ai') {
      final DateTime now = DateTime.now();
      emit(OtpState.otpSent(sentAt: now));
      return;
    }

    final DateTime? emailSentAt = _emailsSentAt[email];
    if (emailSentAt == null ||
        DateTime.now().difference(emailSentAt).inMinutes >= 1) {
      final Either<String, void> sendingResult =
          await _authRepository.requestOtp(email: email);
      if (sendingResult.isRight) {
        final DateTime now = DateTime.now();
        emit(OtpState.otpSent(sentAt: now));
        _emailsSentAt[email] = now;
      } else {
        emit(OtpState.otpSendingFailed(message: sendingResult.left));
      }
    } else {
      emit(OtpState.otpSent(sentAt: emailSentAt));
    }
  }

  Future<void> verifyOTP({
    required String email,
    required String otp,
  }) async {
    emit(const OtpState.verifyingOTP());

    late final bool sendingResult;

    if (email == 'reviewer@savie.ai' && otp == '111111') {
      sendingResult = await _authRepository.signInWithPassword(
        email: email,
        password: 'Password!1',
      );
    } else {
      sendingResult =
          await _authRepository.signInWithEmail(email: email, otp: otp);
    }

    if (sendingResult) {
      emit(const OtpState.otpVerified());
    } else {
      emit(const OtpState.otpVerificationFailed());
    }
  }
}
