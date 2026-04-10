// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get title => 'আমার র‍্যাপিড পাস';

  @override
  String get noticeTitle => 'বিজ্ঞপ্তি';

  @override
  String get noticeFromAuthorities => 'কর্তৃপক্ষের পক্ষ থেকে বিজ্ঞপ্তি';

  @override
  String cardNumberCopied(Object number) {
    return 'কার্ড নাম্বার কপি করা হয়েছে: $number';
  }

  @override
  String get removeCard => 'কার্ড মুছে ফেলুন';

  @override
  String get copyCardNumber => 'কার্ড নাম্বার কপি করুন';

  @override
  String get cardInactive => 'কার্ড নিষ্ক্রিয়';

  @override
  String get lowBalance => 'ব্যালেন্স কম';

  @override
  String get inactive => 'নিষ্ক্রিয়';

  @override
  String get cached => 'সার্ভার জটিলতার কারণে পুরনো তথ্য দেখানো হচ্ছে';

  @override
  String get errorWhileLoading => 'কার্ড লোড করতে সমস্যা হয়েছে';

  @override
  String get dragToReorder => 'এটি প্রেস করে টেনে সিরিয়াল বদলান';

  @override
  String get credentialsCleared => 'সফলভাবে লগআউট হয়েছে';

  @override
  String get unknown => 'অজানা';

  @override
  String get recharge => 'রিচার্জ';

  @override
  String get cardIssued => 'কার্ড প্রদান';

  @override
  String get balance => 'ব্যালেন্স';

  @override
  String get lastUpdated => 'সর্বশেষ হালনাগাদ';

  @override
  String statisticsFooter(
      Object totalValue, Object transactions, Object trips) {
    return '$transactionsটি লেনদেন, মোট $tripsটি যাত্রায় খরচ হয়েছে ৳$totalValue';
  }

  @override
  String spentAmount(Object value) {
    return 'খরচ ৳$value';
  }

  @override
  String get transactions => 'লেনদেন';

  @override
  String get cardInfo => 'কার্ডের তথ্য';

  @override
  String get cardNumberLabel => 'কার্ড নাম্বার';

  @override
  String get nfcLinkStatus => 'এনএফসি সংযোগ';

  @override
  String get linkedShort => 'লিংকড';

  @override
  String get notLinked => 'লিংক নেই';

  @override
  String get notLinkedYet => 'এখনও সংযুক্ত করা হয়নি';

  @override
  String get unlinkPhysicalCard => 'ফিজিক্যাল কার্ডের লিংক সরান';

  @override
  String get syncStatus => 'সিঙ্ক অবস্থা';

  @override
  String get nfcHistoryLabel => 'এনএফসি ইতিহাস';

  @override
  String get scanCard => 'কার্ড স্ক্যান করুন';

  @override
  String get nfcLabel => 'এনএফসি';

  @override
  String get nfcRecord => 'এনএফসি রেকর্ড';

  @override
  String linkedIdm(Object idm) {
    return 'লিংক করা আছে: $idm';
  }

  @override
  String get nfcScanNewerThanServer =>
      'এনএফসি স্ক্যান সার্ভারের তথ্যের চেয়ে নতুন';

  @override
  String get serverSnapshotCurrent => 'সার্ভারের তথ্য হালনাগাদ আছে';

  @override
  String nfcOnlyTransactionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি শুধু-এনএফসি লেনদেন',
      one: '১টি শুধু-এনএফসি লেনদেন',
    );
    return '$_temp0';
  }

  @override
  String get scanYourCard => 'কার্ড স্ক্যান করুন';

  @override
  String get chooseMatchingCard => 'কার্ডটি সংযুক্ত করুন';

  @override
  String get scanCardInstructions =>
      'একটি ফিজিক্যাল কার্ড ফোনের পেছনে ধরুন। স্ক্যান শেষ হলে কোন সংরক্ষিত কার্ডের সাথে লিংক করবেন তা বেছে নিতে পারবেন।';

  @override
  String get chooseMatchingCardInstructions =>
      'যে সংরক্ষিত কার্ডটি সদ্য স্ক্যান করা ফিজিক্যাল কার্ডের সাথে মিলে, সেটিতে চাপুন।';

  @override
  String get close => 'বন্ধ করুন';

  @override
  String get scanAgain => 'আবার স্ক্যান করুন';

  @override
  String get tryAgain => 'আবার চেষ্টা করুন';

  @override
  String get savingCardScan => 'কার্ড স্ক্যান সংরক্ষণ করা হচ্ছে';

  @override
  String get savingCardScanMessage =>
      'অনুগ্রহ করে অপেক্ষা করুন। এখনই এই শিটটি বন্ধ করবেন না।';

  @override
  String get couldNotScanCard => 'কার্ডটি স্ক্যান করা যায়নি';

  @override
  String get holdCardToBackOfPhone => 'কার্ডটি ফোনের পেছনে ধরে রাখুন';

  @override
  String get keepStillUntilPhoneReads =>
      'ফোনটি কার্ড পড়া শেষ না করা পর্যন্ত এক সেকেন্ড স্থির রাখুন।';

  @override
  String get readingCard => 'কার্ড পড়া হচ্ছে';

  @override
  String get keepCardInPlace =>
      'এটি শেষ না হওয়া পর্যন্ত কার্ডটি একই জায়গায় ধরে রাখুন।';

  @override
  String get cardReadSuccessfully => 'কার্ড সফলভাবে পড়া হয়েছে';

  @override
  String currentBalanceValue(Object amount) {
    return 'বর্তমান ব্যালেন্স: $amount';
  }

  @override
  String get turnOnNfcFirst => 'আগে এনএফসি চালু করুন';

  @override
  String get enableNfcThenTryAgain =>
      'ফোনে এনএফসি চালু করে তারপর \"আবার চেষ্টা করুন\" চাপুন।';

  @override
  String get phoneDoesNotSupportNfc => 'এই ফোনে এনএফসি সাপোর্ট নেই';

  @override
  String get usePhoneWithNfc =>
      'ফিজিক্যাল র‍্যাপিড পাস কার্ড স্ক্যান করতে এনএফসি-যুক্ত ফোন ব্যবহার করুন।';

  @override
  String get readFailed => 'পড়া ব্যর্থ হয়েছে';

  @override
  String failedToStartNfcScanning(Object error) {
    return 'এনএফসি স্ক্যান শুরু করা যায়নি: $error';
  }

  @override
  String linkedCardToIdm(Object cardNumber, Object idm) {
    return '$cardNumber কার্ডটি $idm এর সাথে লিংক করা হয়েছে।';
  }

  @override
  String physicalCardAlreadyLinked(Object cardNumber) {
    return 'এই ফিজিক্যাল কার্ডটি ইতিমধ্যে $cardNumber এর সাথে লিংক করা আছে।';
  }

  @override
  String failedToSaveScan(Object error) {
    return 'স্ক্যান সংরক্ষণ করা যায়নি: $error';
  }

  @override
  String get rapidPassBalanceSystem => 'র‍্যাপিড পাস ব্যালেন্স সিস্টেম';

  @override
  String get rapidPassCardSystem => 'র‍্যাপিড পাস কার্ড সিস্টেম';

  @override
  String get unknownService => 'অজানা সেবা';

  @override
  String get boarding => 'বোর্ডিং';

  @override
  String get alighting => 'নামা';

  @override
  String get trip => 'যাত্রা';

  @override
  String get balanceUpdate => 'ব্যালেন্স আপডেট';

  @override
  String get issue => 'ইস্যু';

  @override
  String get login => 'লগইন';

  @override
  String get emailOrPhone => 'ইমেইল বা ফোন নম্বর';

  @override
  String get emailValidation => 'ইমেইল বা ফোন চেক করুন';

  @override
  String get password => 'পাসওয়ার্ড';

  @override
  String get passwordValidation => 'পাসওয়ার্ড চেক করুন';

  @override
  String get forgotPassword => 'পাসওয়ার্ড ভুলে গেছেন?';

  @override
  String get createAnAccount => 'একাউন্ট তৈরি করুন';

  @override
  String get logout => 'লগআউট';

  @override
  String logoutConfirmation(Object username) {
    return 'আপনি কি নিশ্চিত যে আপনি $username লগআউট করতে চান?';
  }

  @override
  String get loginFailed =>
      'লগইন ব্যর্থ হয়েছে। ইউজারনেম ও পাসওয়ার্ড চেক করুন';

  @override
  String get accounts => 'একাউন্ট';

  @override
  String get addAnAccount => 'একাউন্ট যোগ করুন';

  @override
  String get manageAccounts => 'একাউন্ট পরিচালনা';

  @override
  String get manageAccountsOnDevice => 'এই ডিভাইসে সংরক্ষিত একাউন্ট পরিচালনা';

  @override
  String get manageAccountsOnDeviceDescription =>
      'এই ফোন থেকে সংরক্ষিত লগইন, কার্ড এবং লিংক করা এনএফসি তথ্য সরান।';

  @override
  String get accountDeletion => 'একাউন্ট মুছে ফেলা';

  @override
  String get accountDeletionDescription =>
      'Amar Rapid Pass-এর লোকাল ডেটা ও Rapid Pass একাউন্ট মুছে ফেলার নির্দেশনা খুলুন।';

  @override
  String get removeAccountFromDeviceTitle =>
      'এই ডিভাইস থেকে সংরক্ষিত একাউন্ট সরাবেন?';

  @override
  String removeAccountFromDeviceMessage(Object username) {
    return 'এতে $username এর সংরক্ষিত লগইন, কার্ড এবং লিংক করা এনএফসি তথ্য শুধু এই ডিভাইস থেকে মুছে যাবে। Rapid Pass-এর মূল একাউন্ট মুছে যাবে না।';
  }

  @override
  String get removeFromDevice => 'ডিভাইস থেকে সরান';

  @override
  String get savedAccountRemoved =>
      'এই ডিভাইস থেকে সংরক্ষিত একাউন্ট সরানো হয়েছে।';

  @override
  String get addFirstCard =>
      'নিচের + বাটন ব্যাবহার করে আপনার প্রথম কার্ডটি যোগ করুন';

  @override
  String get cannotLaunchUrl => 'URL চালানো যাচ্ছে না';

  @override
  String get addRapidPass => 'র‍্যাপিড পাস যোগ করুন';

  @override
  String get cardNumberHint => 'কার্ড নাম্বার';

  @override
  String get cardNumberValidator => 'কার্ডের পিছনে ১৪-অঙ্কের নাম্বারটি লিখুন';

  @override
  String get cardNameHint => 'নাম';

  @override
  String get cardNameValidator => 'কার্ড সংরক্ষণের জন্য একটি নাম দিন';

  @override
  String get cardNumberExists => 'এই নাম্বারের কার্ড ইতিমধ্যে রয়েছে';

  @override
  String get myCards => 'আমার কার্ড';

  @override
  String get findFares => 'ভাড়া দেখুন';

  @override
  String get chooseOrigin => 'শুরুর লোকেশন বেছে নিন';

  @override
  String get chooseDestination => 'গন্তব্য বেছে নিন';

  @override
  String get fareNotAvailable => 'এই রুটের জন্য ভাড়ার তথ্য নেই।';

  @override
  String get rapidPass => 'র‍্যাপিড পাস';

  @override
  String get cash => 'নগদ';

  @override
  String get about => 'অ্যাপ সম্পর্কে';

  @override
  String get aboutDescription =>
      'অনুরোধের জন্য ইমেইল করুন: তামিম আরাফাত (apps@arafatam.im). অস্বীকৃতি: এই অ্যাপটি ঢাকা পরিবহন সমন্বয় কর্তৃপক্ষ (DTCA) বা অন্য কোনো সংস্থার সাথে আনুষ্ঠানিকভাবে সম্পর্কিত নয়। তথ্য DTCA এর অফিসিয়াল ওয়েবসাইট থেকে সংগ্রহ করা হয়েছে। নিজ দায়িত্বে ব্যবহার করুন।';

  @override
  String get viewSource => 'অ্যাপ এর সোর্স কোড দেখুন';

  @override
  String get viewPrivacyPolicy => 'গোপনীয়তা নীতি দেখুন';

  @override
  String get settings => 'সেটিংস';

  @override
  String get clearAll => 'সমস্ত সংরক্ষিত পাস মুছে ফেলুন';

  @override
  String get clearAllConfirmation => 'সমস্ত সংরক্ষিত পাস মুছে ফেলতে চান?';

  @override
  String get yes => 'হ্যাঁ';

  @override
  String get no => 'না';

  @override
  String get cancel => 'বাতিল করুন';

  @override
  String get networkException => 'ইন্টারনেট সংযোগ নেই অথবা সার্ভার বন্ধ';

  @override
  String get serverException => 'সার্ভার রক্ষণাবেক্ষণের কাজ চলছে';

  @override
  String get notFoundException => 'কার্ড খুঁজে পাওয়া যায়নি';

  @override
  String get welcomeDisclaimerTitle => 'আমার র‍্যাপিড পাসে স্বাগতম';

  @override
  String get welcomeDisclaimerBody =>
      'এটি একটি স্বতন্ত্র এবং ওপেন সোর্স অ্যাপ্লিকেশন যা আপনার র‍্যাপিড পাস ব্যালেন্স এবং লেনদেন দেখতে সাহায্য করে। মনে রাখবেন, এই অ্যাপটি ঢাকা পরিবহন সমন্বয় কর্তৃপক্ষ (DTCA) বা অন্য কোনো সরকারি সংস্থার সাথে কোনোভাবেই সম্পর্কিত বা অনুমোদিত নয়। নিজ দায়িত্বে ব্যবহার করুন।';

  @override
  String get iUnderstand => 'আমি বুঝতে পেরেছি';
}
