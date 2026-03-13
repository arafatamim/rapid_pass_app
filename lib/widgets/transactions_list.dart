import 'dart:io';

import 'package:flutter/material.dart';
import 'package:grouped_list/sliver_grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:rapid_pass_info/helpers/transport_route_localizations.dart';
import 'package:rapid_pass_info/l10n/app_localizations.dart';
import 'package:rapid_pass_info/models/merged_transit_card.dart';
import 'package:rapid_pass_info/widgets/currency_label.dart';
import 'package:rapid_pass_info/widgets/transaction_details.dart';
import 'package:relative_time/relative_time.dart';

double calculateTotalSpending(List<CardActivity> activities) {
  return activities
      .map((item) => item.charge ?? 0)
      .where((amount) => amount < 0)
      .fold(
        0.0,
        (sum, amount) => sum + amount,
      );
}

int getNumberOfTrips(List<CardActivity> activities) {
  return activities.where(_isTripLike).length;
}

double getTotalSpentForDay(List<CardActivity> activities, DateTime date) {
  return activities
      .where((activity) =>
          activity.timestamp.year == date.year &&
          activity.timestamp.month == date.month &&
          activity.timestamp.day == date.day)
      .map((item) => item.charge ?? 0)
      .where((amount) => amount < 0)
      .fold(
        0.0,
        (sum, amount) => sum + amount,
      );
}

int getNumberOfTransactionsForDay(
    List<CardActivity> activities, DateTime date) {
  return activities
      .where((activity) =>
          activity.timestamp.year == date.year &&
          activity.timestamp.month == date.month &&
          activity.timestamp.day == date.day)
      .length;
}

class TransactionList extends StatelessWidget {
  final List<CardActivity> activities;

  const TransactionList({
    super.key,
    required this.activities,
  });

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat.compact(locale: Platform.localeName);

    return SliverGroupedListView(
      elements: activities,
      groupBy: (activity) => DateTime(
        activity.timestamp.year,
        activity.timestamp.month,
        activity.timestamp.day,
      ),
      order: GroupedListOrder.DESC,
      sort: true,
      itemComparator: (a, b) => a.timestamp.compareTo(b.timestamp),
      groupHeaderBuilder: (item) {
        final now = DateTime.now();
        final difference = now.difference(item.timestamp);
        final relativeTime = RelativeTime(context);

        final transactionsForDay =
            getNumberOfTransactionsForDay(activities, item.timestamp);
        final totalSpentForDay =
            getTotalSpentForDay(activities, item.timestamp);

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
                      ? relativeTime.format(item.timestamp)
                      : DateFormat.yMMMd(Platform.localeName)
                          .format(item.timestamp),
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
      indexedItemBuilder: (context, activity, index) {
        final translatedTitle = _displayTitle(context, activity);
        return ListTile(
          leading: Icon(
            _iconForActivity(activity),
            color: (activity.charge ?? 0) > 0
                ? Colors.green
                : Theme.of(context).colorScheme.tertiary,
          ),
          title: Text(translatedTitle),
          subtitle: Text(
            _buildSubtitle(
              context,
              activity,
              MediaQuery.of(context).alwaysUse24HourFormat,
            ),
          ),
          trailing: activity.charge == null
              ? Text(
                  AppLocalizations.of(context)!.nfcLabel,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                )
              : CurrencyLabel(
                  amount: activity.charge!,
                  isCharge: true,
                ),
          onTap: () {
            showModalBottomSheet(
              context: context,
              constraints: const BoxConstraints(
                minWidth: double.infinity,
              ),
              builder: (context) {
                return TransactionDetails(activity: activity);
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
              numberFormat.format(calculateTotalSpending(activities).abs()),
              numberFormat.format(activities.length),
              numberFormat.format(getNumberOfTrips(activities)),
            ),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ),
    );
  }
}

bool _isTripLike(CardActivity activity) {
  if (activity.charge != null && activity.charge! < 0) {
    return true;
  }

  return switch (activity.phase) {
    CardActivityPhase.trip ||
    CardActivityPhase.boarding ||
    CardActivityPhase.alighting =>
      true,
    _ => false,
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
  final localizations = TransportRouteLocalizations.of(context);
  final translatedDestination = localizeActivityStation(
    localizations,
    activity,
    destination: true,
  );

  if (_isTripLike(activity) && activity.destinationStationIndex != null) {
    return translatedDestination;
  }

  if (_isTripLike(activity) &&
      activity.destination != null &&
      !activity.destination!.startsWith('Unknown')) {
    return translatedDestination;
  }

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

String _buildSubtitle(
  BuildContext context,
  CardActivity activity,
  bool is24Hour,
) {
  // final localizations = TransportRouteLocalizations.of(context);
  final time = is24Hour
      ? DateFormat.Hm(Platform.localeName).format(activity.timestamp)
      : DateFormat.jm(Platform.localeName).format(activity.timestamp);

  final parts = <String>[time];
  // final routeName = localizeActivityServiceName(
  //   AppLocalizations.of(context)!,
  //   localizations,
  //   activity,
  // );
  // if (routeName != null &&
  //     routeName.isNotEmpty &&
  //     routeName != activity.title &&
  //     !(activity.routeIndex != null && _isTripLike(activity))) {
  //   parts.add(routeName);
  // }
  // if (activity.eventPhase != null && !_isTripLike(activity)) {
  //   parts.add(
  //       localizeActivityEventPhase(AppLocalizations.of(context)!, activity)!);
  // }

  return parts.join(' • ');
}
