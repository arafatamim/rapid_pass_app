import 'package:flutter/material.dart';

class TransportRouteLocalizations {
  final Locale locale;

  TransportRouteLocalizations(this.locale);

  static TransportRouteLocalizations of(BuildContext context) {
    return Localizations.of<TransportRouteLocalizations>(
        context, TransportRouteLocalizations)!;
  }

  static const LocalizationsDelegate<TransportRouteLocalizations> delegate =
      _TransportRouteLocalizationsDelegate();

  static final _localizedRouteNames = {
    'en': {5: 'MRT Line 6'},
    'bn': {5: 'এমআরটি লাইন ৬'},
  };

  static final _localizedStations = {
    'en': {
      5: {
        // Line 6
        0: 'Uttara North',
        1: 'Uttara Center',
        2: 'Uttara South',
        3: 'Pallabi',
        4: 'Mirpur 11',
        5: 'Mirpur 10',
        6: 'Kazipara',
        7: 'Shewrapara',
        8: 'Agargaon',
        9: 'Bijoy Sarani',
        10: 'Farmgate',
        11: 'Karwan Bazar',
        12: 'Shahbagh',
        13: 'Dhaka University',
        14: 'Bangladesh Secretariat',
        15: 'Motijheel',
        16: 'Kamalapur',
      },
    },
    'bn': {
      5: {
        // লাইন ৬
        0: 'উত্তরা উত্তর',
        1: 'উত্তরা সেন্টার',
        2: 'উত্তরা দক্ষিণ',
        3: 'পল্লবী',
        4: 'মিরপুর ১১',
        5: 'মিরপুর ১০',
        6: 'কাজীপাড়া',
        7: 'শেওড়াপাড়া',
        8: 'আগারগাঁও',
        9: 'বিজয় সরণী',
        10: 'ফার্মগেট',
        11: 'কারওয়ান বাজার',
        12: 'শাহবাগ',
        13: 'ঢাকা বিশ্ববিদ্যালয়',
        14: 'বাংলাদেশ সচিবালয়',
        15: 'মতিঝিল',
        16: 'কমলাপুর',
      },
    }
  };

  String translate(int routeIndex, int stationIndex) {
    final name =
        _localizedStations[locale.languageCode]?[routeIndex]?[stationIndex];
    if (name == null) {
      return _localizedStations['en']![routeIndex]![stationIndex]!;
    }
    return name;
  }

  String translateRouteName(int routeIndex) {
    final name = _localizedRouteNames[locale.languageCode]?[routeIndex];
    if (name == null) {
      return _localizedRouteNames['en']![routeIndex]!;
    }
    return name;
  }
}

class _TransportRouteLocalizationsDelegate
    extends LocalizationsDelegate<TransportRouteLocalizations> {
  const _TransportRouteLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'bn'].contains(locale.languageCode);
  }

  @override
  Future<TransportRouteLocalizations> load(Locale locale) async {
    return TransportRouteLocalizations(locale);
  }

  @override
  bool shouldReload(_TransportRouteLocalizationsDelegate old) => false;
}
