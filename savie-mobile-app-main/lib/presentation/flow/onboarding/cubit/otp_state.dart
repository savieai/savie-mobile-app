part of 'otp_cubit.dart';

@freezed
class OtpState with _$OtpState {
  const factory OtpState.initial() = OtpInitial;
  const factory OtpState.sendingOTP() = SendingOTP;
  const factory OtpState.otpSendingFailed({
    required String message,
  }) = OtpSendingFailed;
  const factory OtpState.resendingOTP() = ResendingOTP;
  const factory OtpState.otpSent({
    required DateTime sentAt,
  }) = OtpSent;

  const factory OtpState.verifyingOTP() = VerifyingOTP;
  const factory OtpState.otpVerified() = OtpVerified;
  const factory OtpState.otpVerificationFailed() = OtpVerificationFailed;
}
