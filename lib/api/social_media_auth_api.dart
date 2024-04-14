abstract class BaseSocialMediaAuthApi {
  Future<Map<String, dynamic>> loginWithFacebook(String token);
  Future<Map<String, dynamic>> loginWithApple(Map<String, String> params);
  Future<Map<String, dynamic>> loginWithGoogle(Map<String, String> params);
}
