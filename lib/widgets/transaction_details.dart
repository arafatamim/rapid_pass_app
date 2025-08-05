import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rapid_pass_info/helpers/transport_route_localizations.dart';
import 'package:rapid_pass_info/l10n/app_localizations.dart';
import 'package:rapid_pass_info/models/transit_card.dart';
import 'package:rapid_pass_info/widgets/currency_label.dart';

class TransactionDetails extends StatelessWidget {
  final Transaction transaction;

  const TransactionDetails({super.key, required this.transaction});

  Widget buildTripHeader(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Icon(
              Icons.circle_outlined,
              size: 18,
              color: Theme.of(context).colorScheme.tertiary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                TransportRouteLocalizations.of(context).translateFromLocale(
                      transaction.originStation ?? "",
                      "en",
                    ) ??
                    transaction.originStation ??
                    AppLocalizations.of(context)!.unknown,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ],
        ),
        // connecting line
        if (transaction.originStation != null &&
            transaction.destinationStation != null)
          Row(
            children: [
              Container(
                width: 18,
                height: 18,
                alignment: Alignment.center,
                child: Container(
                  width: 2,
                  height: 18,
                  color: Theme.of(context).dividerColor,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(child: SizedBox()),
            ],
          ),
        Row(
          children: [
            Icon(
              Icons.circle,
              size: 18,
              color: Theme.of(context).colorScheme.tertiary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                TransportRouteLocalizations.of(context).translateFromLocale(
                      transaction.destinationStation ?? "",
                      "en",
                    ) ??
                    transaction.destinationStation ??
                    AppLocalizations.of(context)!.unknown,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildNonTripHeader(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              transaction.icon,
              color: Theme.of(context).colorScheme.tertiary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                transaction.type == TransactionType.recharge
                    ? AppLocalizations.of(context)!.recharge
                    : transaction.type == TransactionType.issue
                        ? AppLocalizations.of(context)!.cardIssued
                        : AppLocalizations.of(context)!.unknown,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          TransportRouteLocalizations.of(context).translateFromLocale(
                transaction.destinationStation ??
                    transaction.originStation ??
                    "",
                "en",
              ) ??
              transaction.destinationStation ??
              transaction.originStation ??
              AppLocalizations.of(context)!.unknown,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            transaction.type == TransactionType.trip
                ? buildTripHeader(context)
                : buildNonTripHeader(context),
            const SizedBox(height: 16),
            //divider
            Container(
              height: 1,
              width: double.infinity,
              color: Theme.of(context).dividerColor,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(transaction.formattedDate),
                    Text(transaction.getFormattedTime(
                      MediaQuery.of(context).alwaysUse24HourFormat,
                    )),
                  ],
                ),
                const Spacer(),
                CurrencyLabel(
                  amount: transaction.charge,
                  isCharge: true,
                  compactFormatting: false,
                )
              ],
            ),
            const SizedBox(height: 16),
            // balance
            Row(
              children: [
                Text(AppLocalizations.of(context)!.balance),
                const Spacer(),
                Text(
                  NumberFormat.simpleCurrency(
                          name: "BDT", locale: Platform.localeName)
                      .format(transaction.balance),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
