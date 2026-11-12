import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'k_scaffold_localizations_en.dart';
import 'k_scaffold_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of KScaffoldLocalizations
/// returned by `KScaffoldLocalizations.of(context)`.
///
/// Applications need to include `KScaffoldLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/k_scaffold_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: KScaffoldLocalizations.localizationsDelegates,
///   supportedLocales: KScaffoldLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the KScaffoldLocalizations.supportedLocales
/// property.
abstract class KScaffoldLocalizations {
  KScaffoldLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static KScaffoldLocalizations? of(BuildContext context) {
    return Localizations.of<KScaffoldLocalizations>(
        context, KScaffoldLocalizations);
  }

  static const LocalizationsDelegate<KScaffoldLocalizations> delegate =
      _KScaffoldLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr')
  ];

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @warningLogin.
  ///
  /// In en, this message translates to:
  /// **'Please login'**
  String get warningLogin;

  /// No description provided for @warningUnknownError.
  ///
  /// In en, this message translates to:
  /// **'Sorry, there’s been a problem'**
  String get warningUnknownError;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;
}

class _KScaffoldLocalizationsDelegate
    extends LocalizationsDelegate<KScaffoldLocalizations> {
  const _KScaffoldLocalizationsDelegate();

  @override
  Future<KScaffoldLocalizations> load(Locale locale) {
    return SynchronousFuture<KScaffoldLocalizations>(
        lookupKScaffoldLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_KScaffoldLocalizationsDelegate old) => false;
}

KScaffoldLocalizations lookupKScaffoldLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return KScaffoldLocalizationsEn();
    case 'tr':
      return KScaffoldLocalizationsTr();
  }

  throw FlutterError(
      'KScaffoldLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
