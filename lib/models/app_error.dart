class AppException implements Exception {
  static const int kUnknownError = 500;
  static const int kUnAuthorized = 401;
  static const int kDeveloperLog = 900;

  static const unknownError = AppException(code: AppException.kUnknownError);
  static const unAuthorized = AppException(code: AppException.kUnAuthorized);

  final int? code;
  final String? message;

  const AppException({this.code, this.message});

  @override
  String toString() {
    return "AppException Code: $code, message: $message";
  }
}
