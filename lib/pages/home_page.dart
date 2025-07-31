import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rapid_pass_info/l10n/app_localizations.dart';
import 'package:rapid_pass_info/store/state.dart';
import 'package:rapid_pass_info/views/cards_view.dart';
import 'package:rapid_pass_info/views/find_fares_view.dart';
import 'package:rapid_pass_info/helpers/refresh_notifier.dart';
import 'package:rapid_pass_info/widgets/adaptive_scaffold.dart';
import 'package:rapid_pass_info/widgets/adaptive_app_bar.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:rapid_pass_info/helpers/media_queries.dart';
import 'package:collection/collection.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _adaptiveScaffoldKey = GlobalKey<AdaptiveScaffoldState>();

  int _selectedTabIndex = 0;

  void _onNavigationIndexChange(int index) {
    if (index == 1 && isLandscape(context)) {
      _adaptiveScaffoldKey.currentState?.scaffoldKey.currentState
          ?.openEndDrawer();
    }
    setState(() {
      _selectedTabIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> _launchCardCreationURL() async {
    final Uri url = Uri.parse('https://rapidpass.com.bd/user/card/create');
    if (!await launchUrl(url)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.cannotLaunchUrl),
          ),
        );
      }
    }
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

    return Consumer<CardsModel>(builder: (context, state, child) {
      return RefreshNotifierProvider(
        child: Consumer<CardsModel>(
          builder: (context, state, child) {
            return AdaptiveScaffold(
              key: _adaptiveScaffoldKey,
              currentIndex: _selectedTabIndex,
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
                    _selectedTabIndex = 0;
                  });
                }
              },
              onNavigationIndexChange: _onNavigationIndexChange,
              floatingActionButton:
                  _selectedTabIndex == 0 && state.cards.isEmpty
                      ? FloatingActionButton(
                          onPressed: _launchCardCreationURL,
                          tooltip: AppLocalizations.of(context)!.addRapidPass,
                          child: const Icon(Icons.add_card),
                        )
                      : null,
              title: Text(AppLocalizations.of(context)!.title),
              body: RefreshIndicator(
                onRefresh: () async {
                  try {
                    await Provider.of<CardsModel>(context, listen: false)
                        .refreshCards();
                  } catch (e) {
                    debugPrint('Error while loading cards: $e');
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(context)!.errorWhileLoading,
                          ),
                        ),
                      );
                    }
                  }
                },
                child: CustomScrollView(
                  slivers: [
                    AdaptiveAppBar(
                      selectedIndex: _selectedTabIndex,
                      onNavigationIndexChange: _onNavigationIndexChange,
                      destinations: destinations,
                      onAddCardPressed: _launchCardCreationURL,
                    ),
                    if (isLandscape(context))
                      SliverPadding(
                        padding: const EdgeInsets.only(
                          left: 8.0,
                          right: 8.0,
                          bottom: 8.0,
                        ),
                        sliver: CardsView(
                          cards: state.cards,
                        ),
                      ),
                    if (!isLandscape(context))
                      // tab view
                      SliverStack(
                        children: [
                          CardsView(
                            cards: state.cards,
                          ),
                          const SliverToBoxAdapter(child: FindFaresView()),
                        ].mapIndexed(
                          (index, element) {
                            return SliverOffstage(
                              offstage: index != _selectedTabIndex,
                              sliver: SliverPadding(
                                padding: const EdgeInsets.only(
                                  left: 16.0,
                                  right: 16.0,
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
    });
  }
}
