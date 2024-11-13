import 'dart:io';

import 'package:flutter/material.dart';
import 'package:rapid_pass_info/helpers/exceptions.dart';
import 'package:rapid_pass_info/models/rapid_pass.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
import 'package:http/io_client.dart';

http.Client makeClient() {
  var ioClient = HttpClient();
  ioClient.badCertificateCallback = (_, __, ___) => true;
  ioClient.connectionTimeout = const Duration(seconds: 20);
  return IOClient(ioClient);
}

class RapidPassService {
  final http.Client client;

  RapidPassService._() : client = makeClient();

  static final instance = RapidPassService._();

  /// [id] is the two digit prefix + the pass number.
  Future<RapidPassData> getRapidPass(String id) async {
    try {
      final response = await client.post(
        Uri.parse(
          "https://rapidpass.com.bd/bn/index.php/welcome/searchRegistraionInfo",
        ),
        body: {"search": id},
      );
      final body = response.body;
      return RapidPassData.fromHTML(body);
    } on SocketException {
      throw AppException(AppExceptionType.network);
    } catch (e) {
      debugPrint("Error: $e");
      rethrow;
    }
  }

  Future<String?> getLatestNotice(Locale locale) async {
    try {
      final url = switch (locale) {
        Locale(languageCode: "bn") => "https://rapidpass.com.bd/bn/?lang=bn",
        Locale(languageCode: "en") =>
          "https://rapidpass.com.bd/index.php/welcome/home?lang=en",
        _ => throw AppException(AppExceptionType.invalidLocale)
      };
      final response = await client.get(Uri.parse(url));
      final html = response.body;
      final text = _parseNotice(html);
      return text;
    } on SocketException {
      throw AppException(AppExceptionType.network);
    } catch (e) {
      debugPrint("Error: $e");
      rethrow;
    }
  }

  static String? _parseNotice(String html) {
    final document = dom.Document.html(html);

    final marqueeEl = document.querySelector(".notice_board marquee");
    final marqueeText = marqueeEl?.text.trim();

    return marqueeText;
  }
}
