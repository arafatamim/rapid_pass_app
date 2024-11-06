import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rapid_pass_info/models/rapid_pass.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

http.Client makeClient() {
  var ioClient = HttpClient();
  ioClient.badCertificateCallback = (_, __, ___) => true;
  ioClient.connectionTimeout = const Duration(seconds: 20);
  return IOClient(ioClient);
}

final random = Random();

class RapidPassService {
  /// [id] is the two digit prefix + the pass number.
  static Future<RapidPassData> getRapidPass(String id) async {
    final client = makeClient();
    try {
      final response = await client.post(
        Uri.parse(
          "https://rapidpass.com.bd/bn/index.php/welcome/searchRegistraionInfo",
        ),
        body: {"search": id},
      );
      final body = response.body;
      return RapidPassData.fromHTML(body);
    } catch (e) {
      debugPrint("Error: $e");
      rethrow;
    } finally {
      client.close();
    }
  }
}
