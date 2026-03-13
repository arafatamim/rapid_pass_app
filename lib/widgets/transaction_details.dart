import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rapid_pass_info/helpers/transport_route_localizations.dart';
import 'package:rapid_pass_info/l10n/app_localizations.dart';
import 'package:rapid_pass_info/models/merged_transit_card.dart';
import 'package:rapid_pass_info/widgets/currency_label.dart';

class TransactionDetails extends StatelessWidget {
  final CardActivity activity;

  const TransactionDetails({super.key, required this.activity});

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
                localizeActivityStation(
                  TransportRouteLocalizations.of(context),
                  activity,
                  destination: false,
                ),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ],
        ),
        // connecting line
        if (activity.origin != null && activity.destination != null)
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
                localizeActivityStation(
                  TransportRouteLocalizations.of(context),
                  activity,
                  destination: true,
                ),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildNonTripHeader(BuildContext context) {
    final localizations = TransportRouteLocalizations.of(context);
    final destinationLabel = localizeActivityStation(
      localizations,
      activity,
      destination: true,
    );
    final hasKnownDestination = activity.destinationStationIndex != null ||
        (activity.destination != null &&
            !activity.destination!.toLowerCase().startsWith('unknown'));

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              _iconForActivity(activity),
              color: Theme.of(context).colorScheme.tertiary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _displayTitle(context, activity),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          hasKnownDestination
              ? destinationLabel
              : localizeActivityServiceName(
                    AppLocalizations.of(context)!,
                    localizations,
                    activity,
                  ) ??
                  localizeActivityEventPhase(
                    AppLocalizations.of(context)!,
                    activity,
                  ) ??
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
            _isTripLike(activity)
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
                    Text(
                      DateFormat.yMMMMd(Platform.localeName)
                          .format(activity.timestamp),
                    ),
                    Text(
                      MediaQuery.of(context).alwaysUse24HourFormat
                          ? DateFormat.Hm(Platform.localeName)
                              .format(activity.timestamp)
                          : DateFormat.jm(Platform.localeName)
                              .format(activity.timestamp),
                    ),
                  ],
                ),
                const Spacer(),
                activity.charge == null
                    ? Text(
                        localizeActivityServiceName(
                              AppLocalizations.of(context)!,
                              TransportRouteLocalizations.of(context),
                              activity,
                            ) ??
                            AppLocalizations.of(context)!.nfcRecord,
                        style: Theme.of(context).textTheme.titleMedium,
                      )
                    : CurrencyLabel(
                        amount: activity.charge!,
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
                      .format(activity.balanceAfter),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

bool _isTripLike(CardActivity activity) {
  return switch (activity.phase) {
    CardActivityPhase.trip ||
    CardActivityPhase.boarding ||
    CardActivityPhase.alighting =>
      true,
    _ => activity.charge != null && activity.charge! < 0,
  };
}

IconData _iconForActivity(CardActivity activity) {
  if (activity.kind == CardActivityKind.recharge ||
      activity.kind == CardActivityKind.issue ||
      activity.kind == CardActivityKind.balanceUpdate ||
      activity.phase == CardActivityPhase.balanceUpdate ||
      activity.phase == CardActivityPhase.issue) {
    return Icons.monetization_on;
  }

  if (_isTripLike(activity)) {
    return switch (activity.routeIndex) {
      5 => Icons.subway,
      6 => Icons.directions_bus,
      _ => Icons.directions_transit,
    };
  }

  return Icons.receipt_long_outlined;
}

String _displayTitle(BuildContext context, CardActivity activity) {
  if (activity.source == CardActivitySource.server &&
      activity.kind == CardActivityKind.recharge) {
    return AppLocalizations.of(context)!.recharge;
  }

  if (activity.source == CardActivitySource.server &&
      activity.kind == CardActivityKind.issue) {
    return AppLocalizations.of(context)!.cardIssued;
  }

  if (activity.kind == CardActivityKind.balanceUpdate) {
    return AppLocalizations.of(context)!.balanceUpdate;
  }

  if (activity.kind == CardActivityKind.unknown) {
    return AppLocalizations.of(context)!.unknown;
  }

  return activity.title;
}
