import 'package:rapid_pass_info/models/rapid_pass.dart';
import 'package:sqflite/sqflite.dart';

class Cache {
  final Database _db;
  final String tableName;

  const Cache({
    required Database database,
    required this.tableName,
  }) : _db = database;

  Future<RapidPassData?> get(String id) async {
    final response = await _db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (response.length > 1) {
      throw Exception("Multiple entries found for id: $id");
    }
    if (response.isEmpty) {
      return null;
    }

    final Map<String, dynamic> data = response.first;

    return RapidPassData(
      balance: data['balance'],
      lastUpdated: DateTime.parse(data['last_updated']),
      isActive: data['is_active'] == 1 ? true : false,
    );
  }

  /// [id] is the two digit prefix + the pass number.
  Future<void> set(String id, RapidPassData data) async {
    await _db.insert(
      tableName,
      {
        'id': id,
        'balance': data.balance,
        'last_updated': data.lastUpdated.toIso8601String(),
        'is_active': data.isActive ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<bool> delete(String id) async {
    final resp = await _db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (resp < 1) {
      return false;
    }
    return true;
  }

  Future<void> clear() async {
    await _db.delete(tableName);
  }
}
