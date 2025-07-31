import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rapid_pass_info/l10n/app_localizations.dart';
import 'package:rapid_pass_info/pages/settings_page.dart';
import 'package:rapid_pass_info/store/state.dart';
import 'package:rapid_pass_info/widgets/adaptive_scaffold.dart';
import 'package:rapid_pass_info/helpers/media_queries.dart';

class AdaptiveAppBar extends StatelessWidget {
  final int selectedIndex;
  final void Function(int)? onNavigationIndexChange;
  final List<AdaptiveScaffoldDestination> destinations;
  final double navBarWidth;
  final VoidCallback? onAddCardPressed;

  const AdaptiveAppBar({
    super.key,
    required this.selectedIndex,
    this.onNavigationIndexChange,
    required this.destinations,
    this.navBarWidth = 140,
    this.onAddCardPressed,
  });

  @override
  Widget build(context) {
    final title = Text(
      AppLocalizations.of(context)!.title,
      textAlign: TextAlign.center,
    );
    final customisedNavBar = NavigationBar(
      labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
      selectedIndex: selectedIndex,
      destinations: destinations
          .map(
            (e) => NavigationDestination(
              icon: Icon(e.icon),
              label: e.title,
            ),
          )
          .toList(),
      onDestinationSelected: onNavigationIndexChange,
      backgroundColor: Colors.transparent,
    );
    const primary = true;
    const floating = false;
    const pinned = true;

    final actions = [
      Consumer<CardsModel>(
        builder: (context, state, child) {
          if (selectedIndex == 0 && state.cards.isNotEmpty) {
            return child!;
          }
          return const SizedBox.shrink();
        },
        child: IconButton(
          icon: const Icon(Icons.add_card),
          tooltip: AppLocalizations.of(context)!.addRapidPass,
          onPressed: onAddCardPressed,
        ),
      ),
      PopupMenuButton<String>(
        onSelected: (value) {
          if (value == "settings") {
            final cardsModel = Provider.of<CardsModel>(context, listen: false);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ChangeNotifierProvider.value(
                  value: cardsModel,
                  child: const SettingsPage(),
                ),
              ),
            );
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem<String>(
            value: 'settings',
            child: Text(AppLocalizations.of(context)!.settings),
          ),
        ],
      ),
    ];

    if (isSmallScreen(context)) {
      return SliverAppBar(
        title: isLandscape(context) && !isLargeScreen(context)
            ? SizedBox(
                width: navBarWidth,
                child: customisedNavBar,
              )
            : title,
        primary: primary,
        floating: floating,
        pinned: pinned,
        actions: actions,
      );
    }

    return SliverAppBar.large(
      title: title,
      primary: primary,
      floating: floating,
      pinned: pinned,
      actions: actions,
    );
  }
}
