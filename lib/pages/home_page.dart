import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:rapid_pass_info/models/rapid_pass.dart';
import 'package:rapid_pass_info/pages/add_pass_page.dart';
import 'package:rapid_pass_info/views/cards_view.dart';
import 'package:rapid_pass_info/views/find_fares_view.dart';
import 'package:rapid_pass_info/helpers/refresh_notifier.dart';
import 'package:rapid_pass_info/widgets/adaptive_scaffold.dart';
import 'package:rapid_pass_info/widgets/adaptive_app_bar.dart';
import 'package:side_sheet/side_sheet.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:rapid_pass_info/helpers/media_queries.dart';
import 'package:collection/collection.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _adaptiveScaffoldKey = GlobalKey<AdaptiveScaffoldState>();

  int _selectedIndex = 0;

  void _onNavigationIndexChange(int index) {
    if (index == 1 && isLandscape(context)) {
      _adaptiveScaffoldKey.currentState?.scaffoldKey.currentState
          ?.openEndDrawer();
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final destinations = [
      AdaptiveScaffoldDestination(
        icon: Icons.credit_card,
        title: AppLocalizations.of(context)!.myCards,
      ),
      AdaptiveScaffoldDestination(
        icon: Icons.route,
        title: AppLocalizations.of(context)!.findFares,
      ),
    ];

    return RefreshNotifierProvider(
      child: ValueListenableBuilder(
        valueListenable: Hive.box<RapidPass>(RapidPass.boxName).listenable(),
        child: FloatingActionButton(
          onPressed: _showAddPassPage,
          tooltip: AppLocalizations.of(context)!.addRapidPass,
          child: const Icon(Icons.add_card),
        ),
        builder: (context, box, child) {
          return AdaptiveScaffold(
            key: _adaptiveScaffoldKey,
            currentIndex: _selectedIndex,
            destinations: destinations,
            endDrawer: const Drawer(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 24.0,
                    horizontal: 8.0,
                  ),
                  child: SafeArea(child: FindFaresView()),
                ),
              ),
            ),
            onEndDrawerChanged: (open) {
              if (!open) {
                setState(() {
                  _selectedIndex = 0;
                });
              }
            },
            onNavigationIndexChange: _onNavigationIndexChange,
            floatingActionButton:
                _selectedIndex == 0 && box.isEmpty ? child : null,
            title: Text(AppLocalizations.of(context)!.title),
            body: RefreshIndicator(
              onRefresh: () async {
                await context.refreshAll();
              },
              child: CustomScrollView(
                slivers: [
                  AdaptiveAppBar(
                    selectedIndex: _selectedIndex,
                    onNavigationIndexChange: _onNavigationIndexChange,
                    destinations: destinations,
                    onAddCardPressed: _showAddPassPage,
                  ),
                  if (isLandscape(context))
                    SliverPadding(
                      padding: const EdgeInsets.only(
                        left: 8.0,
                        right: 8.0,
                        bottom: 8.0,
                      ),
                      sliver: CardsView(passes: box.values.toList()),
                    ),
                  if (!isLandscape(context))
                    SliverStack(
                      children: [
                        CardsView(passes: box.values.toList()),
                        const SliverToBoxAdapter(child: FindFaresView()),
                      ].mapIndexed(
                        (index, element) {
                          return SliverOffstage(
                            offstage: index != _selectedIndex,
                            sliver: SliverPadding(
                              padding: const EdgeInsets.only(
                                left: 8.0,
                                right: 8.0,
                                bottom: 8.0,
                              ),
                              sliver: element,
                            ),
                          );
                        },
                      ).toList(),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddPassPage() {
    if (isLandscape(context) || isSmallScreen(context)) {
      SideSheet.right(
        context: context,
        sheetColor: Theme.of(context).colorScheme.surface,
        width: 350,
        sheetBorderRadius: 16.0,
        barrierDismissible: true,
        body: const SingleChildScrollView(child: AddPassPage()),
      );
    } else {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return const AddPassPage();
        },
      );
    }
  }
}
