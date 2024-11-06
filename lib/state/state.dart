import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:rapid_pass_info/models/rapid_pass.dart';
import 'package:rapid_pass_info/services/rapid_pass.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rapid_pass_info/helpers/cache.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppState with ChangeNotifier, DiagnosticableTreeMixin {
  final List<RapidPass> _passes = [];
  Cache? _cache;

  List<RapidPass> get passes => List.unmodifiable(_passes);

  Cache? get cache => _cache;

  AppState() {
    _loadPasses();
    _initCache();
    notifyListeners();
  }

  Future<void> _saveToDisk() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("passes", jsonEncode(_passes));
  }

  Future<void> _initCache() async {
    final path = await getDatabasesPath();

    const tableName = "cache";

    final db = await openDatabase(
      join(path, "amar_rapid_pass.db"),
      onCreate: (db, version) {
        return db.execute(
          """CREATE TABLE $tableName (
                    id TEXT PRIMARY KEY,
                    balance INTEGER,
                    last_updated DATETIME,
                    is_active INTEGER,
                    created DATETIME DEFAULT CURRENT_TIMESTAMP
                  )""",
        );
      },
      version: 1,
    );

    final cache = Cache(
      database: db,
      tableName: tableName,
    );

    _cache = cache;

    notifyListeners();
  }

  Future<void> addPass(String id, String name) async {
    final pass = RapidPassService.getRapidPass(id);

    final passItem = RapidPass(
      id,
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

    await _saveToDisk();

    await _cache?.delete(id);

    notifyListeners();
  }

  void reorderPasses(int oldIndex, int newIndex) {
    final item = _passes.removeAt(oldIndex);
    _passes.insert(newIndex, item);

    _saveToDisk();

    notifyListeners();
  }

  Future<void> clearAllPasses() async {
    _passes.clear();
    await _saveToDisk();

    await _cache?.clear();

    notifyListeners();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty('passes', passes));
    properties.add(DiagnosticsProperty<Cache>('cache', cache));
  }
}
