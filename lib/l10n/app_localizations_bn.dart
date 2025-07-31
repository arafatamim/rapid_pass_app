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
  String get rapidPass => 'র‍্যাপিড পাস';

  @override
  String get cash => 'নগদ';

  @override
  String get about => 'অ্যাপ সম্পর্কে';

  @override
  String get aboutDescription =>
      'ডেভেলপারঃ তামিম আরাফাত (tamim.arafat@gmail.com). অস্বীকৃতি: এই অ্যাপটি ঢাকা পরিবহন সমন্বয় কর্তৃপক্ষ (DTCA) বা অন্য কোনো সংস্থার সাথে আনুষ্ঠানিকভাবে সম্পর্কিত নয়। তথ্য DTCA এর অফিসিয়াল ওয়েবসাইট থেকে সংগ্রহ করা হয়েছে। নিজ দায়িত্বে ব্যবহার করুন।';

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
}
