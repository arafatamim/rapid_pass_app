import 'package:elegant_spring_animation/elegant_spring_animation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rapid_pass_info/helpers/refresh_notifier.dart';
import 'package:rapid_pass_info/l10n/app_localizations.dart';
import 'package:rapid_pass_info/pages/accounts_page.dart';
import 'package:rapid_pass_info/pages/settings_page.dart';
import 'package:rapid_pass_info/services/account_service.dart';
import 'package:rapid_pass_info/views/cards_view.dart';
import 'package:rapid_pass_info/views/find_fares_view.dart';
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
  int _currentPageIndex = 0;

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
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
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

    return Consumer<AccountService>(
      builder: (context, state, child) {
        final actions = [
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
            floatingActionButton: _currentPageIndex == 0 &&
                    state.consolidatedData.allCards.isEmpty
                ? FloatingActionButton(
                    onPressed: _launchCardCreationURL,
                    tooltip: AppLocalizations.of(context)!.addRapidPass,
                    child: const Icon(Icons.add_card),
                  )
                : null,
            bottomNavigationBar: NavigationBar(
              destinations: destinations,
              selectedIndex: _currentPageIndex,
              onDestinationSelected: _onNavigationIndexChange,
            ),
            body: PageView(
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
                                AppLocalizations.of(context)!.errorWhileLoading,
                              ),
                            ),
                          );
                        }
                      }
                    },
                    child: CardsView(
                      cards: state.consolidatedData.allCards,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: FindFaresView(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
