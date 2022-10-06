import 'k_util_localizations.dart';

/// The translations for Turkish (`tr`).
class KUtilLocalizationsTr extends KUtilLocalizations {
  KUtilLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get error => 'Hata';

  @override
  String get passwordRequired => 'Şifre gereklidir.';

  @override
  String get warningLogin => 'Lütfen giriş yapın';

  @override
  String get warningUnknownError => 'Bilnmeyen bir hata oluştu';

  @override
  String get ok => 'Tamam';
}
