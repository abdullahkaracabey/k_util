// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'k_util_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class KUtilLocalizationsEn extends KUtilLocalizations {
  KUtilLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get error => 'Error';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get warningLogin => 'Please login';

  @override
  String get warningUnknownError => 'Sorry, there’s been a problem';

  @override
  String get ok => 'OK';
}
