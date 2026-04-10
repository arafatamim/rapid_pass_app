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
  String get errorWhileLoading => 'An error occurred while loading cards';

  @override
  String get dragToReorder => 'Long press and drag this to reorder';

  @override
  String get credentialsCleared => 'Logged out successfully';

  @override
  String get unknown => 'Unknown';

  @override
  String get recharge => 'Recharge';

  @override
  String get cardIssued => 'Card issued';

  @override
  String get balance => 'Balance';

  @override
  String get lastUpdated => 'Last updated';

  @override
  String statisticsFooter(
      Object totalValue, Object transactions, Object trips) {
    return '$transactions transactions, ৳$totalValue spent on $trips total trips';
  }

  @override
  String spentAmount(Object value) {
    return 'Spent ৳$value';
  }

  @override
  String get transactions => 'Transactions';

  @override
  String get cardInfo => 'Card info';

  @override
  String get cardNumberLabel => 'Card number';

  @override
  String get nfcLinkStatus => 'NFC link';

  @override
  String get linkedShort => 'Linked';

  @override
  String get notLinked => 'Not linked';

  @override
  String get notLinkedYet => 'Not linked yet';

  @override
  String get unlinkPhysicalCard => 'Unlink physical card';

  @override
  String get syncStatus => 'Sync status';

  @override
  String get nfcHistoryLabel => 'NFC history';

  @override
  String get scanCard => 'Scan card';

  @override
  String get nfcLabel => 'NFC';

  @override
  String get nfcRecord => 'NFC record';

  @override
  String linkedIdm(Object idm) {
    return 'Linked: $idm';
  }

  @override
  String get nfcScanNewerThanServer => 'NFC scan is newer than server';

  @override
  String get serverSnapshotCurrent => 'Server snapshot current';

  @override
  String nfcOnlyTransactionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count NFC-only transactions',
      one: '1 NFC-only transaction',
    );
    return '$_temp0';
  }

  @override
  String get scanYourCard => 'Scan your card';

  @override
  String get chooseMatchingCard => 'Link this card';

  @override
  String get scanCardInstructions =>
      'Hold one physical card on the back of your phone. You will choose which saved card to link after the scan finishes.';

  @override
  String get chooseMatchingCardInstructions =>
      'Tap the saved card that matches the physical card you just scanned.';

  @override
  String get close => 'Close';

  @override
  String get scanAgain => 'Scan again';

  @override
  String get tryAgain => 'Try again';

  @override
  String get savingCardScan => 'Saving card scan';

  @override
  String get savingCardScanMessage =>
      'Please wait. Do not close this sheet yet.';

  @override
  String get couldNotScanCard => 'Could not scan this card';

  @override
  String get holdCardToBackOfPhone => 'Hold the card on the back of your phone';

  @override
  String get keepStillUntilPhoneReads =>
      'Keep it still for a second until the phone reads it.';

  @override
  String get readingCard => 'Reading card';

  @override
  String get keepCardInPlace => 'Keep the card in place until this finishes.';

  @override
  String get cardReadSuccessfully => 'Card read successfully';

  @override
  String currentBalanceValue(Object amount) {
    return 'Current balance: $amount';
  }

  @override
  String get turnOnNfcFirst => 'Turn on NFC first';

  @override
  String get enableNfcThenTryAgain =>
      'Enable NFC on your phone, then tap \"Try again\".';

  @override
  String get phoneDoesNotSupportNfc => 'This phone does not support NFC';

  @override
  String get usePhoneWithNfc =>
      'Use a phone with NFC to scan a physical Rapid Pass card.';

  @override
  String get readFailed => 'Read failed';

  @override
  String failedToStartNfcScanning(Object error) {
    return 'Failed to start NFC scanning: $error';
  }

  @override
  String linkedCardToIdm(Object cardNumber, Object idm) {
    return 'Linked $cardNumber to $idm.';
  }

  @override
  String physicalCardAlreadyLinked(Object cardNumber) {
    return 'This physical card is already linked to $cardNumber.';
  }

  @override
  String failedToSaveScan(Object error) {
    return 'Failed to save scan: $error';
  }

  @override
  String get rapidPassBalanceSystem => 'Rapid Pass Balance System';

  @override
  String get rapidPassCardSystem => 'Rapid Pass Card System';

  @override
  String get unknownService => 'Unknown Service';

  @override
  String get boarding => 'Boarding';

  @override
  String get alighting => 'Alighting';

  @override
  String get trip => 'Trip';

  @override
  String get balanceUpdate => 'Balance Update';

  @override
  String get issue => 'Issue';

  @override
  String get login => 'Login';

  @override
  String get emailOrPhone => 'Email or Mobile Number';

  @override
  String get emailValidation => 'Enter a valid email address or phone number';

  @override
  String get password => 'Password';

  @override
  String get passwordValidation => 'Enter a valid password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get createAnAccount => 'Create an account';

  @override
  String get logout => 'Logout';

  @override
  String logoutConfirmation(Object username) {
    return 'Are you sure you want to logout $username?';
  }

  @override
  String get loginFailed => 'Login failed. Check username and password.';

  @override
  String get accounts => 'Accounts';

  @override
  String get addAnAccount => 'Add an account';

  @override
  String get manageAccounts => 'Manage accounts';

  @override
  String get manageAccountsOnDevice => 'Manage saved accounts on this device';

  @override
  String get manageAccountsOnDeviceDescription =>
      'Remove saved credentials, cards, and linked NFC data from this phone.';

  @override
  String get accountDeletion => 'Account deletion';

  @override
  String get accountDeletionDescription =>
      'Open instructions for deleting local Amar Rapid Pass data and your Rapid Pass account.';

  @override
  String get removeAccountFromDeviceTitle =>
      'Remove saved account from this device?';

  @override
  String removeAccountFromDeviceMessage(Object username) {
    return 'This removes the saved login, cards, and linked NFC data for $username from this device only. It does not delete the Rapid Pass account itself.';
  }

  @override
  String get removeFromDevice => 'Remove from device';

  @override
  String get savedAccountRemoved => 'Saved account removed from this device.';

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
  String get fareNotAvailable =>
      'Fare information not available for this route.';

  @override
  String get rapidPass => 'Rapid Pass';

  @override
  String get cash => 'Cash';

  @override
  String get about => 'About';

  @override
  String get aboutDescription =>
      'Email support requests to Tamim Arafat (apps@arafatam.im). DISCLAIMER: This app is not officially affiliated with Dhaka Transport Coordination Authority (DTCA) or any other organisation. The data is fetched from the official DTCA website. Use at your own discretion.';

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

  @override
  String get welcomeDisclaimerTitle => 'Welcome to Amar Rapid Pass';

  @override
  String get welcomeDisclaimerBody =>
      'This is an independent, open-source application designed to help you check your Rapid Pass balance and transactions. Please note that this app is NOT affiliated with, endorsed by, or connected to DTCA (Dhaka Transport Coordination Authority) or any official government entity. Use at your own discretion.';

  @override
  String get iUnderstand => 'I understand';
}
