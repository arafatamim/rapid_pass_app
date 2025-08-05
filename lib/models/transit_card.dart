import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class TransitCard {
  final int id;
  final int userId;
  final String cardNumber;
  final String hexCardNo;
  final String name;
  final String phoneNumber;
  final String? fatherName;
  final String? motherName;
  final String? address;
  final String dateOfBirth;
  final String gender;
  final String nationality;
  final String? photoId;
  final String? photoIdNumber;
  final String? profession;
  final String balance;
  final String cardType;
  final String serverStatus;
  final int totalTransactions;
  final String transactionStartDate;
  final String transactionEndDate;
  final String status;
  final String syncStatus;
  final String syncedAt;
  final String? pendingAt;
  final String? updateAt;
  final String? unsyncedAt;
  final String createdAt;
  final String updatedAt;
  final List<RawTransaction> transactionHistory;

  TransitCard({
    required this.id,
    required this.userId,
    required this.cardNumber,
    required this.hexCardNo,
    required this.name,
    required this.phoneNumber,
    this.fatherName,
    this.motherName,
    this.address,
    required this.dateOfBirth,
    required this.gender,
    required this.nationality,
    this.photoId,
    this.photoIdNumber,
    this.profession,
    required this.balance,
    required this.cardType,
    required this.serverStatus,
    required this.totalTransactions,
    required this.transactionStartDate,
    required this.transactionEndDate,
    required this.status,
    required this.syncStatus,
    required this.syncedAt,
    this.pendingAt,
    this.updateAt,
    this.unsyncedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.transactionHistory,
  });

  factory TransitCard.fromJson(Map<String, dynamic> json) {
    return TransitCard(
      id: json['id'],
      userId: json['user_id'],
      cardNumber: json['card_number'],
      hexCardNo: json['hex_card_no'],
      name: json['name'],
      phoneNumber: json['phone_number'],
      fatherName: json['father_name'],
      motherName: json['mother_name'],
      address: json['address'],
      dateOfBirth: json['date_of_birth'],
      gender: json['gender'],
      nationality: json['nationality'],
      photoId: json['photo_id'],
      photoIdNumber: json['photo_id_number'],
      profession: json['profession'],
      balance: json['balance'],
      cardType: json['card_type'],
      serverStatus: json['server_status'],
      totalTransactions: json['total_transactions'],
      transactionStartDate: json['transaction_start_date'],
      transactionEndDate: json['transaction_end_date'],
      status: json['status'],
      syncStatus: json['sync_status'],
      syncedAt: json['synced_at'],
      pendingAt: json['pending_at'],
      updateAt: json['update_at'],
      unsyncedAt: json['unsynced_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      transactionHistory: (json['transaction_history'] as List)
          .map((transaction) => RawTransaction.fromJson(transaction))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'card_number': cardNumber,
      'hex_card_no': hexCardNo,
      'name': name,
      'phone_number': phoneNumber,
      'father_name': fatherName,
      'mother_name': motherName,
      'address': address,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'nationality': nationality,
      'photo_id': photoId,
      'photo_id_number': photoIdNumber,
      'profession': profession,
      'balance': balance,
      'card_type': cardType,
      'server_status': serverStatus,
      'total_transactions': totalTransactions,
      'transaction_start_date': transactionStartDate,
      'transaction_end_date': transactionEndDate,
      'status': status,
      'sync_status': syncStatus,
      'synced_at': syncedAt,
      'pending_at': pendingAt,
      'update_at': updateAt,
      'unsynced_at': unsyncedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'transaction_history': transactionHistory.map((t) => t.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'TransitCard{id: $id, name: $name, cardNumber: $cardNumber, balance: $balance}';
  }

  List<Transaction> getFormattedTransactions() {
    // sort in ascending order
    final sorted = transactionHistory.reversed.toList();

    final mergedTransactions = <Transaction>[];
    int i = 0;

    while (i < sorted.length) {
      final cur = sorted[i];
      if (cur.serviceType.contains("Ride & Deduction")) {
        // initial tap and deduction
        final next = sorted.elementAtOrNull(i + 1);
        if (next != null && next.serviceType.contains("Alight & Refund")) {
          // final tap and exit
          mergedTransactions.add(
            Transaction(
              timeStamp: next.dateTime,
              type: TransactionType.trip,
              charge: cur.transactionValue + next.transactionValue,
              balance: double.parse(next.balance),
              originStation: cur.originStation,
              destinationStation: next.destinationStation,
            ),
          );
          i += 2; // skip over the next transaction
        } else {
          // not tapped on exit so its a fine
          mergedTransactions.add(
            Transaction(
              timeStamp: cur.dateTime,
              type: TransactionType.fine,
              charge: cur.transactionValue,
              balance: double.parse(cur.balance),
              originStation: cur.destinationStation,
              destinationStation: null,
            ),
          );
          i += 1;
        }
      } else {
        mergedTransactions.add(
          Transaction(
            timeStamp: cur.dateTime,
            type: cur.transactionType,
            charge: cur.transactionValue,
            balance: double.parse(cur.balance),
            originStation: cur.originStation,
            destinationStation:
                cur.destinationStation == "x" ? null : cur.destinationStation,
          ),
        );
        i += 1;
      }
    }

    return mergedTransactions;
  }
}

class RawTransaction {
  final int id;
  final String phoneNumber;
  final String cardNumber;
  final String serviceType;
  final String transactionDataId;
  final String svLogId;
  final String? originStation;
  final String? destinationStation;
  final String spentAmount;
  final String balance;
  final String dateStamp;
  final String timeStamp;
  final String createdAt;
  final String updatedAt;

  RawTransaction({
    required this.id,
    required this.phoneNumber,
    required this.cardNumber,
    required this.serviceType,
    required this.transactionDataId,
    required this.svLogId,
    this.originStation,
    this.destinationStation,
    required this.spentAmount,
    required this.balance,
    required this.dateStamp,
    required this.timeStamp,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RawTransaction.fromJson(Map<String, dynamic> json) {
    return RawTransaction(
      id: json['id'],
      phoneNumber: json['phone_number'],
      cardNumber: json['card_number'],
      serviceType: json['service_type'],
      transactionDataId: json['transaction_data_id'],
      svLogId: json['sv_log_id'],
      originStation: json['origin_station'],
      destinationStation: json['destination_station'],
      spentAmount: json['spent_amount'],
      balance: json['balance'],
      dateStamp: json['date_stamp'],
      timeStamp: json['time_stamp'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone_number': phoneNumber,
      'card_number': cardNumber,
      'service_type': serviceType,
      'transaction_data_id': transactionDataId,
      'sv_log_id': svLogId,
      'origin_station': originStation,
      'destination_station': destinationStation,
      'spent_amount': spentAmount,
      'balance': balance,
      'date_stamp': dateStamp,
      'time_stamp': timeStamp,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  String toString() {
    return 'TransactionHistory{id: $id, serviceType: $serviceType, amount: $spentAmount, balance: $balance, originStation: $originStation, destinationStation: $destinationStation}';
  }

  DateTime get dateTime =>
      DateFormat("yyyy-MM-dd HH:mm:ss").parse("$dateStamp $timeStamp");

  double get transactionValue => double.parse(spentAmount);

  String get sign => transactionValue > 0 ? '+' : '-';
  Color get amountColor => transactionValue > 0 ? Colors.green : Colors.red;

  TransactionType get transactionType => serviceType.contains("Recharge")
      ? TransactionType.recharge
      : serviceType.contains("Issue")
          ? TransactionType.issue
          : (serviceType.contains("Exit") ||
                  serviceType.contains("Alight & Refund"))
              ? TransactionType.trip
              : TransactionType.unknown;
}

enum TransactionType { trip, issue, recharge, fine, unknown }

class Transaction {
  DateTime timeStamp;
  TransactionType type;
  double charge;
  double balance;
  String? originStation;
  String? destinationStation;

  Transaction({
    required this.timeStamp,
    required this.type,
    required this.charge,
    required this.balance,
    this.originStation,
    this.destinationStation,
  });

  @override
  String toString() {
    return 'Transaction{timeStamp: $timeStamp, type: $type, charge: $charge, balance: $balance, originStation: $originStation, destinationStation: $destinationStation}';
  }

  IconData get icon => switch (type) {
        TransactionType.trip => Icons.directions_transit,
        TransactionType.issue => Icons.card_membership,
        TransactionType.recharge => Icons.monetization_on,
        TransactionType.fine => Icons.warning,
        TransactionType.unknown => Icons.help,
      };

  String get sign => charge > 0 ? '+' : '-';
  String get formattedValue =>
      "$sign৳${NumberFormat.currency(decimalDigits: 0, locale: Platform.localeName, symbol: "").format(charge.abs())}";
  Color get color => charge > 0 ? Colors.green : Colors.red;
  String get formattedDate =>
      DateFormat.yMMMMd(Platform.localeName).format(timeStamp);
  String getFormattedTime(bool is24Hour) => is24Hour
      ? DateFormat.Hm(Platform.localeName).format(timeStamp)
      : DateFormat.jm(Platform.localeName).format(timeStamp);
}
