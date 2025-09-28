import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rapid_pass_info/models/account.dart';
import 'package:rapid_pass_info/models/transit_card.dart';
import 'package:rapid_pass_info/services/rapid_pass.dart';
import 'package:uuid/uuid.dart';

class AccountService extends ChangeNotifier {
  static final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(groupId: 'com.arafatamim.amar_rapid_pass'),
  );

  static const String _accountsKey = 'saved_accounts';

  static AccountService? _instance;
  static AccountService get instance => _instance ??= AccountService._();

  AccountService._();

  List<Account> _accounts = [];

  List<Account> get accounts => _accounts;
  bool get hasMultipleAccounts => _accounts.length > 1;
  ConsolidatedData get consolidatedData => getConsolidatedData();

  Future<void> initialize() async {
    await _loadAccounts();
  }

  Future<Account> addAccount({
    required String username,
    required String password,
  }) async {
    try {
      final existingAccount = _checkExistingAccount(username);
      if (existingAccount != null) {
        return existingAccount;
      }

      final session = await RapidPassService.instance
          .login(username: username, password: password);
      final cards = await RapidPassService.instance.getCards(session);
      final account = Account(
        id: const Uuid().v4(),
        username: username,
        cards: cards,
        session: session,
      );

      await _saveAccountCredentials(account.id, username, password);

      _accounts.add(account);

      await _saveAccounts();
      notifyListeners();
      return account;
    } catch (e) {
      debugPrint('Error adding account: $e');
      rethrow;
    }
  }

  Future<void> removeAccount(String accountId) async {
    _accounts.removeWhere((account) => account.id == accountId);

    await _clearAccountCredentials(accountId);

    await _saveAccounts();
    notifyListeners();
  }

  Future<void> reorderAccounts(int oldIndex, int newIndex) async {
    if (oldIndex < 0 ||
        oldIndex >= _accounts.length ||
        newIndex < 0 ||
        newIndex >= _accounts.length) {
      throw ArgumentError('Invalid indices');
    }

    final account = _accounts.removeAt(oldIndex);
    _accounts.insert(newIndex, account);

    await _saveAccounts();
    notifyListeners();
  }

  Future<void> refreshAllAccounts() async {
    for (int i = 0; i < _accounts.length; i++) {
      try {
        final account = _accounts[i];
        final credentials = await _getAccountCredentials(account.id);

        if (credentials["username"] != null &&
            credentials["password"] != null) {
          final session = await RapidPassService.instance.login(
            username: credentials["username"]!,
            password: credentials["password"]!,
          );

          final cards = await RapidPassService.instance.getCards(session);

          _accounts[i] = account.copyWith(
            cards: cards,
            session: session,
          );
        }
      } catch (e) {
        debugPrint('Error refreshing account ${_accounts[i].username}: $e');
      }
    }

    await _saveAccounts();
    notifyListeners();
  }

  ConsolidatedData getConsolidatedData() {
    final allCards = <TransitCard>[];
    final allTransactions = <Transaction>[];
    double totalBalance = 0.0;

    for (final account in _accounts) {
      allCards.addAll(account.cards);
      allTransactions.addAll(account.allTransactions);
      totalBalance += account.totalBalance;
    }

    allTransactions.sort((a, b) => b.timeStamp.compareTo(a.timeStamp));

    return ConsolidatedData(
      allCards: allCards,
      allTransactions: allTransactions,
      totalBalance: totalBalance,
    );
  }

  Future<void> _loadAccounts() async {
    try {
      final accountsJson = await _storage.read(key: _accountsKey);
      if (accountsJson != null) {
        final List<dynamic> accountsList = jsonDecode(accountsJson);
        _accounts = accountsList.map((json) => Account.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error loading accounts: $e');
      _accounts = [];
    }
  }

  Future<void> _saveAccounts() async {
    final accountsJson = jsonEncode(_accounts.map((a) => a.toJson()).toList());
    await _storage.write(key: _accountsKey, value: accountsJson);
  }

  Future<void> _saveAccountCredentials(
      String accountId, String username, String password) async {
    await _storage.write(key: '${accountId}_username', value: username);
    await _storage.write(key: '${accountId}_password', value: password);
  }

  Future<Map<String, String?>> _getAccountCredentials(String accountId) async {
    final username = await _storage.read(key: '${accountId}_username');
    final password = await _storage.read(key: '${accountId}_password');
    return {'username': username, 'password': password};
  }

  Future<void> _clearAccountCredentials(String accountId) async {
    await _storage.delete(key: '${accountId}_username');
    await _storage.delete(key: '${accountId}_password');
  }

  Account? _checkExistingAccount(String username) {
    final existingAccount =
        _accounts.firstWhereOrNull((account) => account.username == username);
    if (existingAccount != null) {
      return existingAccount;
    }
    return null;
  }
}

class ConsolidatedData {
  final List<TransitCard> allCards;
  final List<Transaction> allTransactions;
  final double totalBalance;

  ConsolidatedData({
    required this.allCards,
    required this.allTransactions,
    required this.totalBalance,
  });
}
