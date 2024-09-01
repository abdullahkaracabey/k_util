class AppException implements Exception {
  static const int kNotConnected = 1;
  static const int kRemoteAddressNotReached = 2;
  static const int kNotCorrect = 100;
  static const int kPrivacyPolicy = 101;
  static const int kUserPolicy = 102;
  static const int kUnPermitted = 103;
  static const int kUnknownError = 500;
  static const int kUnAuthorized = 401;
  static const int kNotFound = 404;
  static const int kDeveloperLog = 900;
  static const kWarningPhoneNumberWithoutZero = 903;
  static const kWarningPhoneNotTrue = 905;
  static const kWarningCodeNotTrue = 906;
  static const kWarningMinOfferAmount = 907;
  static const kCartEmpty = 908;
  static const kLoginFailed = 909;

  static const kNotAuthorized = 401;
  static const kUserNotFound = 1000;
  static const kUserDisabled = 1001;
  static const kWrongPassword = 1002;
  static const kTooManyRequests = 1003;
  static const kEmailAlreadyInUse = 1004;
  static const kWeakPassword = 1005;
  static const kOperationNotAllowed = 1006;
  static const kInvalidEmail = 1007;
  static const kUnknown = 1008;
  static const kPhotoProcessError = 1009;
  static const kLocationNotFound = 1010;
  static const kErrorUserNameContainsAppName = 1011;

  static const unknownError = AppException(code: AppException.kUnknownError);
  static const unAuthorized = AppException(code: AppException.kUnAuthorized);
  static const unPermitted = AppException(code: AppException.kUnPermitted);
  static const notConnected = AppException(code: AppException.kNotConnected);
  static const loginFailed = AppException(code: AppException.kLoginFailed);

  final int? code;
  final String? message;

  const AppException({this.code, this.message});

  @override
  String toString() {
    return "AppException Code: $code, message: $message";
  }
}
