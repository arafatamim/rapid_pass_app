import 'dart:io';
import 'dart:math';

import 'package:rapid_pass_info/models/rapid_pass.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

http.Client makeClient() {
  var ioClient = HttpClient()..badCertificateCallback = (_, __, ___) => true;
  return IOClient(ioClient);
}

final random = Random();

class RapidPassService {
  static Future<RapidPassData> getRapidPass(String name, int number) async {
    final client = makeClient();
    try {
      final response = await client.post(
        Uri.parse(
          "https://rapidpass.com.bd/bn/index.php/welcome/searchRegistraionInfo",
        ),
        body: {"search": "RP$number"},
      );
      final body = response.body;
      return RapidPassData.fromHTML(body);
    } catch (e) {
      print(e);
      rethrow;
    } finally {
      client.close();
    }
  }
}
