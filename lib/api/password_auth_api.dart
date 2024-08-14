abstract class BasePasswordAuthApi {
  Future<bool> isUserExists(String username);
  Future<Map<String, dynamic>> signInWithPassword(
      String username, String password);
  Future<Map<String, dynamic>> signUpWithPassword(
      String username, String password);

  Future<void> resetPassword(String username);
  Future<void> updatePassword(String newPassword);

  @Deprecated('Use BaseSocialMediaAuthApi instead')
  Future<Map<String, dynamic>> loginWithFacebook(String token);

  @Deprecated('Use BaseSocialMediaAuthApi instead')
  Future<Map<String, dynamic>> loginWithApple(Map<String, String> params);

  @Deprecated('Use BaseSocialMediaAuthApi instead')
  Future<Map<String, dynamic>> loginWithGoogle(Map<String, String> params);
}
