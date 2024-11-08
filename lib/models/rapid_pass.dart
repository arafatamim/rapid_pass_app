import 'dart:convert';

import 'package:html/dom.dart' as dom;
import 'package:rapid_pass_info/services/rapid_pass.dart';

class RapidPassData {
  final int balance;
  final DateTime lastUpdated;
  final bool isActive;

  RapidPassData({
    required this.balance,
    required this.lastUpdated,
    required this.isActive,
  });

  factory RapidPassData.fromHTML(String html) {
    final document = dom.Document.html(html);
    final str = document.querySelector("table");
    if (str == null) {
      throw Exception("Invalid card number or server error");
    }
    final el1 = str
        .querySelectorAll("td.text-right")
        .map((e) => e.text.trim())
        .toList();
    final el2 = str
        .getElementsByClassName("badge badge-warning")[0]
        .text
        .trim()
        .split(" ")
        .where((element) => element.isNotEmpty)
        .toList();

    return RapidPassData(
      balance: int.parse(el1[1].trim().split(" ").last),
      lastUpdated: DateTime.parse(el2[3]),
      isActive: el1[2] == "Active" ? true : false,
    );
  }
}

class RapidPass {
  final String id;
  final String name;
  final Future<RapidPassData> data;

  const RapidPass(
    this.id, {
    required this.name,
    required this.data,
  });

  String toJson() {
    final Map<String, dynamic> object = {
      'id': id,
      'name': name,
    };
    final jsonString = jsonEncode(object);
    return jsonString;
  }

  factory RapidPass.fromJson(Map<String, dynamic> json) {
    final passId = json["id"] as String;
    final passName = json["name"] as String;
    return RapidPass(
      passId,
      name: passName,
      data: RapidPassService.getRapidPass(passId),
    );
  }
}
