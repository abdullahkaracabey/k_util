import 'package:k_util/api/phone_auth_api.dart';
import 'package:k_util/managers/base_auth_manager.dart';
import 'package:k_util/models/app_error.dart';
import 'package:k_util/models/base_model.dart';
import 'package:k_util/models/base_view_state.dart';

mixin PhoneAuth<T extends BaseModel> on BaseAuthManager<T> {
  late String phoneCountryCode;

  String? _currentPhoneNumber;
  String? _verificationId;

  String? get currentPhoneNumber => _currentPhoneNumber;
  late Function(String) __onCodeSent;
  late Function(dynamic) __onVerificationCompleted;

  Future<void> sendCode(String phoneNumber,
      {required Function(String) onCodeSent,
      required Function(dynamic) onVerificationCompleted,
      required OnError onError}) async {
    _currentPhoneNumber = phoneNumber;
    __onCodeSent = onCodeSent;
    __onVerificationCompleted = onVerificationCompleted;
    return await callRequest(() => _login(phoneNumber, onError));
  }

  _onCodeSent(p0) {
    _verificationId = p0;
    __onCodeSent(p0);
  }

  _onVerificationCompleted(dynamic params) async {
    if (authApi is BasePhoneAuthApi) {
      var result =
          await (authApi as BasePhoneAuthApi).signInWithCredential(params);

      __onVerificationCompleted(result);
    }
  }

  Future<dynamic> verify(
    String password,
  ) async {
    return await callRequest(() => _verify(_verificationId!, password));
  }

  Future<void> _login(String phoneNumber, OnError onError) async {
    if (authApi is BasePhoneAuthApi) {
      await (authApi as BasePhoneAuthApi).sendCode(phoneNumber,
          onCodeSent: _onCodeSent,
          verificationCompleted: _onVerificationCompleted,
          onError: onError);
      return;
    }
    throw const AppException(
        code: AppException.kDeveloperLog,
        message: "authApi should be BasePhoneAuthApi");
  }

  Future<void> _verify(String verificationId, String password) async {
    if (authApi is BasePhoneAuthApi) {
      await (authApi as BasePhoneAuthApi)
          .verify(verificationId: verificationId, password: password);
      return;
    }
    throw const AppException(
        code: AppException.kDeveloperLog,
        message: "authApi should be BasePhoneAuthApi");
  }
}
