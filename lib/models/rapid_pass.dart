import 'dart:convert';

import 'package:html/dom.dart' as dom;
import 'package:rapid_pass_info/helpers/exceptions.dart';
import 'package:rapid_pass_info/services/rapid_pass.dart';
import 'package:hive_ce/hive.dart';

part 'rapid_pass.g.dart';

@HiveType(typeId: 0)
class RapidPass extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;

  static const boxName = "rapid_pass";

  RapidPass(this.id, this.name);

  String toJson() {
    final Map<String, dynamic> object = {
      'id': id,
      'name': name,
    };
    final jsonString = jsonEncode(object);
    return jsonString;
  }

  factory RapidPass.fromJson(
    Map<String, dynamic> json, {
    required RapidPassService service,
  }) {
    final passId = json["id"] as String;
    final passName = json["name"] as String;
    return RapidPass(passId, passName);
  }

  @override
  String toString() {
    return 'RapidPass(id: $id, name: $name)';
  }

  RapidPass copyWith({
    String? id,
    String? name,
  }) {
    return RapidPass(
      id ?? this.id,
      name ?? this.name,
    );
  }
}

@HiveType(typeId: 1)
class RapidPassData extends HiveObject {
  @HiveField(0)
  final int balance;
  @HiveField(1)
  final DateTime lastUpdated;
  @HiveField(2)
  final bool isActive;

  static const boxName = "rapid_pass_cache";

  RapidPassData({
    required this.balance,
    required this.lastUpdated,
    required this.isActive,
  });

  factory RapidPassData.fromHTML(String html) {
    final document = dom.Document.html(html);
    final str = document.querySelector("table");
    if (str == null) {
      throw AppException(AppExceptionType.server);
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

  @override
  String toString() {
    return 'RapidPassData(balance: $balance, lastUpdated: $lastUpdated, isActive: $isActive)';
  }
}
