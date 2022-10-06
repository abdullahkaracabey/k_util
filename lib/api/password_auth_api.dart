abstract class BasePasswordAuthApi {
  Future<Map<String, dynamic>> signInWithPassword(
      String username, String password);
  Future<Map<String, dynamic>> signUpWithPassword(
      String username, String password);
  Future<Map<String, dynamic>> loginWithFacebook(String token);
  Future<Map<String, dynamic>> loginWithApple(Map<String, String> params);
  Future<Map<String, dynamic>> loginWithGoogle();
}
