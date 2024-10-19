import 'dart:io';
import 'package:flutter/foundation.dart';

class AdHelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      if (kDebugMode) {
        return 'ca-app-pub-3940256099942544/9214589741'; // test adaptive banner
      }
      return 'ca-app-pub-8286895467012523/9056906632';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}
