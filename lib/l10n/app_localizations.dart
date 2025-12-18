import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
    Locale('ja'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Simple Magick'**
  String get appTitle;

  /// No description provided for @windowTitle.
  ///
  /// In en, this message translates to:
  /// **'Simple Magick: Batch Image Scaling Tool'**
  String get windowTitle;

  /// No description provided for @btnSelectImages.
  ///
  /// In en, this message translates to:
  /// **'Select Images'**
  String get btnSelectImages;

  /// No description provided for @btnScaleImages.
  ///
  /// In en, this message translates to:
  /// **'Scale Images'**
  String get btnScaleImages;

  /// No description provided for @btnClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get btnClear;

  /// No description provided for @btnOpenDir.
  ///
  /// In en, this message translates to:
  /// **'Open Dir'**
  String get btnOpenDir;

  /// No description provided for @labelScaleRatio.
  ///
  /// In en, this message translates to:
  /// **'Scale Ratio:'**
  String get labelScaleRatio;

  /// No description provided for @dialogTitleTip.
  ///
  /// In en, this message translates to:
  /// **'Tip'**
  String get dialogTitleTip;

  /// No description provided for @dialogContentOverwrite.
  ///
  /// In en, this message translates to:
  /// **'You have already scaled these images. Do you want to rescale and overwrite them?'**
  String get dialogContentOverwrite;

  /// No description provided for @btnYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get btnYes;

  /// No description provided for @btnNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get btnNo;

  /// No description provided for @colIndex.
  ///
  /// In en, this message translates to:
  /// **'Index'**
  String get colIndex;

  /// No description provided for @colFileName.
  ///
  /// In en, this message translates to:
  /// **'File Name'**
  String get colFileName;

  /// No description provided for @colResolution.
  ///
  /// In en, this message translates to:
  /// **'Resolution'**
  String get colResolution;

  /// No description provided for @colAspectRatio.
  ///
  /// In en, this message translates to:
  /// **'Aspect Ratio'**
  String get colAspectRatio;

  /// No description provided for @colSize.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get colSize;

  /// No description provided for @colNewResolution.
  ///
  /// In en, this message translates to:
  /// **'New Res'**
  String get colNewResolution;

  /// No description provided for @colNewSize.
  ///
  /// In en, this message translates to:
  /// **'New Size'**
  String get colNewSize;

  /// No description provided for @colStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get colStatus;

  /// No description provided for @colAction.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get colAction;

  /// No description provided for @statusProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get statusProcessing;

  /// No description provided for @statusDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get statusDone;

  /// No description provided for @statusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get statusFailed;

  /// No description provided for @statusError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get statusError;

  /// No description provided for @msgErrorPicking.
  ///
  /// In en, this message translates to:
  /// **'Error picking images: {error}'**
  String msgErrorPicking(Object error);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
