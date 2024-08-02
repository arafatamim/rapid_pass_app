import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:rapid_pass_info/models/rapid_pass.dart';
import 'package:rapid_pass_info/services/rapid_pass.dart';
import 'package:shared_preferences/shared_preferences.dart';

String generateUniqueId() {
  return DateTime.now().microsecondsSinceEpoch.toString();
}

class AppState with ChangeNotifier, DiagnosticableTreeMixin {
  final List<RapidPass> _passes = [];

  List<RapidPass> get passes => List.unmodifiable(_passes);

  AppState() {
    _loadPasses();
    notifyListeners();
  }

  Future<void> _saveToDisk() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("passes", jsonEncode(_passes));
  }

  Future<void> addPass(String name, int cardNumber) async {
    final pass = RapidPassService.getRapidPass(name, cardNumber);

    final id = generateUniqueId();

    final passItem = RapidPass(
      id,
      number: cardNumber,
      name: name,
      data: pass,
    );
    _passes.add(passItem);

    _saveToDisk();

    notifyListeners();
  }

  Future<void> _loadPasses() async {
    final sharedPrefs = await SharedPreferences.getInstance();
    final rawPasses = sharedPrefs.getString("passes");

    if (rawPasses != null) {
      final list = jsonDecode(rawPasses) as List<dynamic>;
      for (var item in list) {
        _passes.add(RapidPass.fromJson(jsonDecode(item)));
      }
    }

    notifyListeners();
  }

  Future<void> removePass(String id) async {
    _passes.removeWhere((element) => element.id == id);

    _saveToDisk();

    notifyListeners();
  }

  void reorderPasses(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = _passes.removeAt(oldIndex);
    _passes.insert(newIndex, item);

    _saveToDisk();

    notifyListeners();
  }

  void notifyUpdate() {
    notifyListeners();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty('passes', passes));
  }
}

// RP32124011615238
