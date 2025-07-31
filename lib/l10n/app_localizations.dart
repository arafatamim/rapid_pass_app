import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

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
    Locale('bn'),
    Locale('en')
  ];

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Amar Rapid Pass'**
  String get title;

  /// No description provided for @noticeTitle.
  ///
  /// In en, this message translates to:
  /// **'Notice'**
  String get noticeTitle;

  /// No description provided for @noticeFromAuthorities.
  ///
  /// In en, this message translates to:
  /// **'Notice from authorities'**
  String get noticeFromAuthorities;

  /// No description provided for @cardNumberCopied.
  ///
  /// In en, this message translates to:
  /// **'Card number copied to clipboard: {number}'**
  String cardNumberCopied(Object number);

  /// No description provided for @removeCard.
  ///
  /// In en, this message translates to:
  /// **'Remove card'**
  String get removeCard;

  /// No description provided for @copyCardNumber.
  ///
  /// In en, this message translates to:
  /// **'Copy card number'**
  String get copyCardNumber;

  /// No description provided for @cardInactive.
  ///
  /// In en, this message translates to:
  /// **'card inactive'**
  String get cardInactive;

  /// No description provided for @lowBalance.
  ///
  /// In en, this message translates to:
  /// **'low balance'**
  String get lowBalance;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'inactive'**
  String get inactive;

  /// No description provided for @cached.
  ///
  /// In en, this message translates to:
  /// **'displaying cached information due to server issues'**
  String get cached;

  /// No description provided for @errorWhileLoading.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while loading cards'**
  String get errorWhileLoading;

  /// No description provided for @dragToReorder.
  ///
  /// In en, this message translates to:
  /// **'Long press and drag this to reorder'**
  String get dragToReorder;

  /// No description provided for @credentialsCleared.
  ///
  /// In en, this message translates to:
  /// **'Logged out successfully'**
  String get credentialsCleared;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @recharge.
  ///
  /// In en, this message translates to:
  /// **'Recharge'**
  String get recharge;

  /// No description provided for @cardIssued.
  ///
  /// In en, this message translates to:
  /// **'Card issued'**
  String get cardIssued;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated'**
  String get lastUpdated;

  /// No description provided for @statisticsFooter.
  ///
  /// In en, this message translates to:
  /// **'{transactions} transactions, ৳{totalValue} spent on {trips} total trips'**
  String statisticsFooter(Object totalValue, Object transactions, Object trips);

  /// No description provided for @spentAmount.
  ///
  /// In en, this message translates to:
  /// **'Spent ৳{value}'**
  String spentAmount(Object value);

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @emailOrPhone.
  ///
  /// In en, this message translates to:
  /// **'Email or Mobile Number'**
  String get emailOrPhone;

  /// No description provided for @emailValidation.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address or phone number'**
  String get emailValidation;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordValidation.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid password'**
  String get passwordValidation;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @createAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get createAnAccount;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout {username}?'**
  String logoutConfirmation(Object username);

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Check username and password.'**
  String get loginFailed;

  /// No description provided for @addFirstCard.
  ///
  /// In en, this message translates to:
  /// **'Add your first card using the + button below'**
  String get addFirstCard;

  /// No description provided for @cannotLaunchUrl.
  ///
  /// In en, this message translates to:
  /// **'Cannot launch URL'**
  String get cannotLaunchUrl;

  /// No description provided for @addRapidPass.
  ///
  /// In en, this message translates to:
  /// **'Add Rapid Pass'**
  String get addRapidPass;

  /// No description provided for @cardNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Card number'**
  String get cardNumberHint;

  /// No description provided for @cardNumberValidator.
  ///
  /// In en, this message translates to:
  /// **'Enter the 14-digit card number on the back of your card'**
  String get cardNumberValidator;

  /// No description provided for @cardNameHint.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get cardNameHint;

  /// No description provided for @cardNameValidator.
  ///
  /// In en, this message translates to:
  /// **'Enter a name to save this card as'**
  String get cardNameValidator;

  /// No description provided for @cardNumberExists.
  ///
  /// In en, this message translates to:
  /// **'A card with this number already exists'**
  String get cardNumberExists;

  /// No description provided for @myCards.
  ///
  /// In en, this message translates to:
  /// **'My Cards'**
  String get myCards;

  /// No description provided for @findFares.
  ///
  /// In en, this message translates to:
  /// **'Find Fares'**
  String get findFares;

  /// No description provided for @chooseOrigin.
  ///
  /// In en, this message translates to:
  /// **'Choose start location'**
  String get chooseOrigin;

  /// No description provided for @chooseDestination.
  ///
  /// In en, this message translates to:
  /// **'Choose destination'**
  String get chooseDestination;

  /// No description provided for @rapidPass.
  ///
  /// In en, this message translates to:
  /// **'Rapid Pass'**
  String get rapidPass;

  /// No description provided for @cash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'Made by Tamim Arafat (tamim.arafat@gmail.com). DISCLAIMER: This app is not officially affiliated with Dhaka Transport Coordination Authority (DTCA) or any other organisation. The data is fetched from the official DTCA website. Use at your own discretion.'**
  String get aboutDescription;

  /// No description provided for @viewSource.
  ///
  /// In en, this message translates to:
  /// **'View source code'**
  String get viewSource;

  /// No description provided for @viewPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'View privacy policy'**
  String get viewPrivacyPolicy;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all saved passes'**
  String get clearAll;

  /// No description provided for @clearAllConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all saved passes?'**
  String get clearAllConfirmation;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @networkException.
  ///
  /// In en, this message translates to:
  /// **'No internet connection or server is down'**
  String get networkException;

  /// No description provided for @serverException.
  ///
  /// In en, this message translates to:
  /// **'Server maintenance ongoing'**
  String get serverException;

  /// No description provided for @notFoundException.
  ///
  /// In en, this message translates to:
  /// **'Card not found'**
  String get notFoundException;
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
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
