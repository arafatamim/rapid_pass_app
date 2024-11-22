import 'package:flutter/material.dart';
import 'package:rapid_pass_info/services/rapid_pass.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:rapid_pass_info/models/rapid_pass.dart';
import 'package:rapid_pass_info/pages/settings_page.dart';
import 'package:rapid_pass_info/widgets/pop_in_widget.dart';
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
      FutureBuilder<String?>(
        future: RapidPassService.instance
            .getLatestNotice(Localizations.localeOf(context)),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data!;
            return NoticeButton(data: data);
          }
          return const SizedBox.shrink();
        },
      ),
      ValueListenableBuilder(
        valueListenable: Hive.box<RapidPass>(RapidPass.boxName).listenable(),
        builder: (context, box, _) {
          if (selectedIndex == 0 && box.isNotEmpty) {
            return IconButton(
              icon: const Icon(Icons.add_card),
              tooltip: AppLocalizations.of(context)!.addRapidPass,
              onPressed: onAddCardPressed,
            );
          }
          return const SizedBox.shrink();
        },
      ),
      PopupMenuButton<String>(
        onSelected: (value) {
          if (value == "settings") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SettingsPage(),
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

class NoticeButton extends StatelessWidget {
  final String data;

  const NoticeButton({
    super.key,
    required this.data,
  });

  @override
  Widget build(context) {
    return PopInWidget(
      child: IconButton(
        icon: const Icon(Icons.warning_amber_rounded),
        tooltip: AppLocalizations.of(context)!.noticeTitle,
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                key: ValueKey(data),
                title: Text(
                  AppLocalizations.of(context)!.noticeFromAuthorities,
                ),
                content: SingleChildScrollView(child: Text(data)),
                actions: [
                  TextButton(
                    child: Text(
                      MaterialLocalizations.of(context).closeButtonLabel,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            },
          );
        },
      ),
    );
  }
}
