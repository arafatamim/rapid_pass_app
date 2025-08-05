import 'dart:io';

import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:grouped_list/sliver_grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:rapid_pass_info/helpers/transport_route_localizations.dart';
import 'package:rapid_pass_info/l10n/app_localizations.dart';
import 'package:rapid_pass_info/models/transit_card.dart';
import 'package:rapid_pass_info/widgets/currency_label.dart';
import 'package:rapid_pass_info/widgets/transaction_details.dart';
import 'package:relative_time/relative_time.dart';

double calculateTotalSpending(List<Transaction> transactions) {
  return transactions
      .map((item) => item.charge)
      .where((amount) => amount < 0)
      .fold(
        0.0,
        (sum, amount) => sum + amount,
      );
}

int getNumberOfTrips(List<Transaction> transactions) {
  return transactions
      .map((item) => item.charge)
      .where((amount) => amount < 0)
      .length;
}

double getTotalSpentForDay(List<Transaction> transactions, DateTime date) {
  return transactions
      .where((transaction) =>
          transaction.timeStamp.year == date.year &&
          transaction.timeStamp.month == date.month &&
          transaction.timeStamp.day == date.day)
      .map((item) => item.charge)
      .where((amount) => amount < 0)
      .fold(
        0.0,
        (sum, amount) => sum + amount,
      );
}

int getNumberOfTransactionsForDay(
    List<Transaction> transactions, DateTime date) {
  return transactions
      .where((transaction) =>
          transaction.timeStamp.year == date.year &&
          transaction.timeStamp.month == date.month &&
          transaction.timeStamp.day == date.day)
      .length;
}

class TransactionList extends StatelessWidget {
  final List<Transaction> transactions;

  const TransactionList({
    super.key,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat.compact(locale: Platform.localeName);

    return SliverGroupedListView(
      elements: transactions,
      groupBy: (transaction) => DateTime(
        transaction.timeStamp.year,
        transaction.timeStamp.month,
        transaction.timeStamp.day,
      ),
      order: GroupedListOrder.DESC,
      sort: true,
      itemComparator: (a, b) => a.timeStamp.compareTo(b.timeStamp),
      groupHeaderBuilder: (item) {
        final now = DateTime.now();
        final difference = now.difference(item.timeStamp);
        final relativeTime = RelativeTime(context);

        final transactionsForDay =
            getNumberOfTransactionsForDay(transactions, item.timeStamp);
        final totalSpentForDay =
            getTotalSpentForDay(transactions, item.timeStamp);

        return Padding(
          padding: const EdgeInsets.only(
            top: 16.0,
          ),
          child: Container(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
                bottomLeft: Radius.circular(8.0),
                bottomRight: Radius.circular(8.0),
              ),
            ),
            child: Row(
              children: [
                Text(
                  difference.inDays < 60
                      ? relativeTime.format(item.timeStamp)
                      : DateFormat.yMMMd(Platform.localeName)
                          .format(item.timeStamp),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                if (transactionsForDay > 1)
                  Text(
                    AppLocalizations.of(context)!.spentAmount(
                      NumberFormat.compact(locale: Platform.localeName).format(
                        totalSpentForDay.abs(),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
      indexedItemBuilder: (context, transaction, index) {
        return ListTile(
          leading: Icon(
            transaction.icon,
            color: transaction.charge > 0
                ? Colors.green
                : Theme.of(context).colorScheme.tertiary,
          ),
          title: transaction.type == TransactionType.recharge
              ? Text(AppLocalizations.of(context)!.recharge)
              : transaction.type == TransactionType.issue
                  ? Text(AppLocalizations.of(context)!.cardIssued)
                  : Text(
                      TransportRouteLocalizations.of(context)
                              .translateFromLocale(
                                  transaction.destinationStation ?? '', "en") ??
                          transaction.destinationStation ??
                          AppLocalizations.of(context)!.unknown,
                    ),
          subtitle: transaction.charge < 0
              ? Text(
                  transaction.getFormattedTime(
                      MediaQuery.of(context).alwaysUse24HourFormat),
                )
              : null,
          trailing: CurrencyLabel(
            amount: transaction.charge,
            isCharge: true,
          ),
          onTap: () {
            showModalBottomSheet(
              context: context,
              constraints: const BoxConstraints(
                minWidth: double.infinity,
              ),
              builder: (context) {
                return TransactionDetails(transaction: transaction);
              },
            );
          },
        );
      },
      footer: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8.0),
              topRight: Radius.circular(8.0),
              bottomLeft: Radius.circular(16.0),
              bottomRight: Radius.circular(16.0),
            ),
          ),
          child: Text(
            AppLocalizations.of(context)!.statisticsFooter(
              numberFormat.format(calculateTotalSpending(transactions).abs()),
              numberFormat.format(transactions.length),
              numberFormat.format(getNumberOfTrips(transactions)),
            ),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ),
    );
  }
}
