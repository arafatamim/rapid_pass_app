// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get title => 'Amar Rapid Pass';

  @override
  String get noticeTitle => 'Notice';

  @override
  String get noticeFromAuthorities => 'Notice from authorities';

  @override
  String cardNumberCopied(Object number) {
    return 'Card number copied to clipboard: $number';
  }

  @override
  String get removeCard => 'Remove card';

  @override
  String get copyCardNumber => 'Copy card number';

  @override
  String get cardInactive => 'card inactive';

  @override
  String get lowBalance => 'low balance';

  @override
  String get inactive => 'inactive';

  @override
  String get cached => 'displaying cached information due to server issues';

  @override
  String get errorWhileLoading => 'An error occurred while loading the card';

  @override
  String get dragToReorder => 'Long press and drag this to reorder';

  @override
  String get addFirstCard => 'Add your first card using the + button below';

  @override
  String get cannotLaunchUrl => 'Cannot launch URL';

  @override
  String get addRapidPass => 'Add Rapid Pass';

  @override
  String get cardNumberHint => 'Card number';

  @override
  String get cardNumberValidator =>
      'Enter the 14-digit card number on the back of your card';

  @override
  String get cardNameHint => 'Name';

  @override
  String get cardNameValidator => 'Enter a name to save this card as';

  @override
  String get cardNumberExists => 'A card with this number already exists';

  @override
  String get myCards => 'My Cards';

  @override
  String get findFares => 'Find Fares';

  @override
  String get chooseOrigin => 'Choose start location';

  @override
  String get chooseDestination => 'Choose destination';

  @override
  String get rapidPass => 'Rapid Pass';

  @override
  String get cash => 'Cash';

  @override
  String get about => 'About';

  @override
  String get aboutDescription =>
      'Made by Tamim Arafat (tamim.arafat@gmail.com). DISCLAIMER: This app is not officially affiliated with Dhaka Transport Coordination Authority (DTCA) or any other organisation. The data is fetched from the official DTCA website. Use at your own discretion.';

  @override
  String get viewSource => 'View source code';

  @override
  String get viewPrivacyPolicy => 'View privacy policy';

  @override
  String get settings => 'Settings';

  @override
  String get clearAll => 'Clear all saved passes';

  @override
  String get clearAllConfirmation =>
      'Are you sure you want to clear all saved passes?';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get cancel => 'Cancel';

  @override
  String get networkException => 'No internet connection or server is down';

  @override
  String get serverException => 'Server maintenance ongoing';

  @override
  String get notFoundException => 'Card not found';
}
