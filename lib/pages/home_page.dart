import 'package:elegant_spring_animation/elegant_spring_animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rapid_pass_info/helpers/refresh_notifier.dart';
import 'package:rapid_pass_info/l10n/app_localizations.dart';
import 'package:rapid_pass_info/models/dummy_merged_cards.dart';
import 'package:rapid_pass_info/models/merged_transit_card.dart';
import 'package:rapid_pass_info/pages/accounts_page.dart';
import 'package:rapid_pass_info/pages/nfc_debug_page.dart';
import 'package:rapid_pass_info/pages/settings_page.dart';
import 'package:rapid_pass_info/services/account_service.dart';
import 'package:rapid_pass_info/services/nfc.dart';
import 'package:rapid_pass_info/views/cards_view.dart';
import 'package:rapid_pass_info/views/find_fares_view.dart';
import 'package:rapid_pass_info/widgets/card_scan_sheet.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _pageController = PageController();
  final _showFabNotifier = ValueNotifier<bool>(true);
  int _currentPageIndex = 0;
  int _selectedCardIndex = 0;

  void _onNavigationIndexChange(int index) {
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 1000),
        curve: ElegantSpring.mediumBounce,
      );
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPageIndex = index;
    });
    _showFabNotifier.value = true;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _showFabNotifier.dispose();
    super.dispose();
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
      NavigationDestination(
        icon: const Icon(Icons.credit_card),
        label: AppLocalizations.of(context)!.myCards,
      ),
      NavigationDestination(
        icon: const Icon(Icons.route),
        label: AppLocalizations.of(context)!.findFares,
      ),
    ];
    final isTablet = MediaQuery.sizeOf(context).width >= 900;

    return Consumer<AccountService>(
      builder: (context, state, child) {
        final mergedCards =
            kDebugMode ? dummyMergedCards : state.mergedCardCollection.allCards;
        if (_selectedCardIndex >= mergedCards.length) {
          _selectedCardIndex = mergedCards.isEmpty ? 0 : mergedCards.length - 1;
        }
        if (kDebugMode && mergedCards.isNotEmpty) {
          _selectedCardIndex = 0;
        }

        final actions = [
          if (kDebugMode)
            IconButton(
              icon: const Icon(Icons.bug_report_outlined),
              tooltip: 'NFC debug',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const NfcDebugPage(),
                  ),
                );
              },
            ),
          if (_currentPageIndex == 0)
            IconButton(
              icon: const Icon(Icons.add_card),
              tooltip: AppLocalizations.of(context)!.addRapidPass,
              onPressed: _launchCardCreationURL,
            ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == "settings") {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ChangeNotifierProvider.value(
                      value: state,
                      child: const SettingsPage(),
                    ),
                  ),
                );
              }
              if (value == "manage_accounts") {
                Navigator.of(context).push(
                  ModalBottomSheetRoute(
                    isScrollControlled: false,
                    builder: (context) => ChangeNotifierProvider.value(
                      value: state,
                      child: const AccountsPage(),
                    ),
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'manage_accounts',
                child: Text(AppLocalizations.of(context)!.manageAccounts),
              ),
              PopupMenuItem<String>(
                value: 'settings',
                child: Text(AppLocalizations.of(context)!.settings),
              ),
            ],
          ),
        ];

        return RefreshNotifierProvider(
          child: Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)!.title),
              actions: actions,
            ),
            floatingActionButton: ValueListenableBuilder<bool>(
              valueListenable: _showFabNotifier,
              builder: (context, showFab, child) {
                final fab = showFab
                    ? _buildFloatingActionButton(
                        mergedCards,
                        RapidPassNfcService.instance.cardState,
                      )
                    : null;

                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: Tween<double>(
                          begin: 0.85,
                          end: 1,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: fab == null
                      ? const SizedBox.shrink(key: ValueKey('hidden-fab'))
                      : KeyedSubtree(
                          key: const ValueKey('visible-fab'),
                          child: fab,
                        ),
                );
              },
            ),
            bottomNavigationBar: isTablet
                ? null
                : NavigationBar(
                    destinations: destinations,
                    selectedIndex: _currentPageIndex,
                    onDestinationSelected: _onNavigationIndexChange,
                  ),
            body: Row(
              children: [
                if (isTablet)
                  NavigationRail(
                    selectedIndex: _currentPageIndex,
                    onDestinationSelected: _onNavigationIndexChange,
                    labelType: NavigationRailLabelType.all,
                    destinations: destinations
                        .map(
                          (destination) => NavigationRailDestination(
                            icon: destination.icon,
                            selectedIcon:
                                destination.selectedIcon ?? destination.icon,
                            label: Text(destination.label),
                          ),
                        )
                        .toList(),
                  ),
                Expanded(
                  child: PageView(
                    physics: const BouncingScrollPhysics(),
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: RefreshIndicator(
                          onRefresh: () async {
                            try {
                              await Provider.of<AccountService>(context,
                                      listen: false)
                                  .refreshAllAccounts();
                            } catch (e) {
                              debugPrint('Error while loading cards: $e');
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      AppLocalizations.of(context)!
                                          .errorWhileLoading,
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                          child: CardsView(
                            cards: mergedCards,
                            selectedCardIndex: _selectedCardIndex,
                            onSelectedCardChanged: (index) {
                              setState(() {
                                _selectedCardIndex = index;
                              });
                            },
                            onFabVisibilityChanged: (visible) {
                              if (_showFabNotifier.value == visible) {
                                return;
                              }
                              _showFabNotifier.value = visible;
                            },
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 500),
                          child: const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: FindFaresView(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget? _buildFloatingActionButton(
    List<MergedTransitCard> mergedCards,
    CardState nfcState,
  ) {
    if (_currentPageIndex != 0) {
      return null;
    }

    if (nfcState is NoNfcSupport) {
      return null;
    }

    if (mergedCards.isEmpty) {
      return FloatingActionButton(
        onPressed: _launchCardCreationURL,
        tooltip: AppLocalizations.of(context)!.addRapidPass,
        child: const Icon(Icons.add_card),
      );
    }

    return FloatingActionButton.extended(
      onPressed: () => _openScanSheet(mergedCards),
      icon: const Icon(Icons.nfc),
      label: Text(AppLocalizations.of(context)!.scanCard),
    );
  }

  Future<void> _openScanSheet(List<MergedTransitCard> cards) async {
    final accountService = context.read<AccountService>();
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return ChangeNotifierProvider.value(
          value: accountService,
          child: CardScanSheet(cards: cards),
        );
      },
    );

    if (result case final message?) {
      _showSnackBar(message);
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
