import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CurrencyLabel extends StatelessWidget {
  final double amount;
  final bool isCharge;
  final Color? amountColor;
  final Color? symbolColor;

  const CurrencyLabel({
    required this.amount,
    this.isCharge = false,
    this.amountColor,
    this.symbolColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final amountVal = isCharge ? amount.abs() : amount;
    final localColor =
        amount > 0 ? Colors.green : Theme.of(context).colorScheme.tertiary;

    return FittedBox(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isCharge)
            Text(
              amount > 0 ? '+' : '',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: amountColor ?? localColor,
                  ),
            ),
          Align(
            alignment: const Alignment(0, -0.3),
            child: Text(
              "৳",
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontSize: 20,
                    color: symbolColor ??
                        (isCharge ? localColor : Theme.of(context).hintColor),
                  ),
            ),
          ),
          Text(
            NumberFormat.compact(locale: Platform.localeName).format(amountVal),
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: amountColor ??
                      (isCharge
                          ? localColor
                          : Theme.of(context).colorScheme.onSurface),
                ),
          ),
        ],
      ),
    );
  }
}
