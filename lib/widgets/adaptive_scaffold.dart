import 'package:flutter/material.dart';
import 'package:rapid_pass_info/helpers/media_queries.dart';

class AdaptiveScaffoldDestination {
  final String title;
  final IconData icon;

  const AdaptiveScaffoldDestination({
    required this.title,
    required this.icon,
  });
}

class AdaptiveScaffold extends StatefulWidget {
  final Widget title;
  final Widget? body;
  final int currentIndex;
  final Widget? endDrawer;
  final ValueChanged<bool>? onEndDrawerChanged;
  final List<AdaptiveScaffoldDestination> destinations;
  final ValueChanged<int>? onNavigationIndexChange;
  final Widget? floatingActionButton;

  const AdaptiveScaffold({
    required this.title,
    this.body,
    this.endDrawer,
    this.onEndDrawerChanged,
    required this.currentIndex,
    required this.destinations,
    this.onNavigationIndexChange,
    this.floatingActionButton,
    super.key,
  });

  @override
  State<AdaptiveScaffold> createState() => AdaptiveScaffoldState();
}

class AdaptiveScaffoldState extends State<AdaptiveScaffold> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    if (isLargeScreen(context)) {
      return Scaffold(
        endDrawer: widget.endDrawer,
        onEndDrawerChanged: widget.onEndDrawerChanged,
        key: scaffoldKey,
        floatingActionButton: widget.floatingActionButton,
        body: Row(
          children: [
            NavigationRail(
              labelType: NavigationRailLabelType.all,
              destinations: widget.destinations
                  .map(
                    (e) => NavigationRailDestination(
                      icon: Icon(e.icon),
                      label: Text(e.title),
                    ),
                  )
                  .toList(),
              selectedIndex: widget.currentIndex,
              onDestinationSelected: widget.onNavigationIndexChange,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: widget.body!,
            ),
          ],
        ),
      );
    }

    if (isMediumScreen(context) || isLandscape(context)) {
      return Scaffold(
        endDrawer: widget.endDrawer,
        onEndDrawerChanged: widget.onEndDrawerChanged,
        key: scaffoldKey,
        floatingActionButton: widget.floatingActionButton,
        body: widget.body!,
      );
    }

    return Scaffold(
      body: widget.body,
      endDrawer: widget.endDrawer,
      onEndDrawerChanged: widget.onEndDrawerChanged,
      bottomNavigationBar: NavigationBar(
        destinations: [
          ...widget.destinations.map(
            (d) => NavigationDestination(
              icon: Icon(d.icon),
              label: d.title,
            ),
          ),
        ],
        selectedIndex: widget.currentIndex,
        onDestinationSelected: widget.onNavigationIndexChange,
      ),
      floatingActionButton: widget.floatingActionButton,
    );
  }
}
