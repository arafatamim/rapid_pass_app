import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EmptyMessage extends StatelessWidget {
  const EmptyMessage({super.key});

  @override
  Widget build(BuildContext context) {
    final hintColor = Theme.of(context).hintColor;

    return AspectRatio(
      aspectRatio: 1.8,
      child: Card(
        color: Theme.of(context).colorScheme.onInverseSurface,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.info, color: hintColor, size: 36),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.addFirstCard,
                  style: TextStyle(color: hintColor),
                  textAlign: TextAlign.center,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
