import '../k_util.dart';


abstract class BasePhoneAuthApi {
  Future<void> sendCode(String phone,
      {required Function(String) onCodeSent,
      required Function(dynamic) verificationCompleted,
      required OnError onError});
  Future<dynamic> verify(
      {required String verificationId, required String password});
  Future<dynamic> signInWithCredential(dynamic credential);
}
