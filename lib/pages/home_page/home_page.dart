import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:rapid_pass_info/models/rapid_pass.dart';
import 'package:rapid_pass_info/pages/add_pass_page.dart';
import 'package:rapid_pass_info/pages/settings_page.dart';
import 'package:rapid_pass_info/services/rapid_pass.dart';
import 'package:rapid_pass_info/pages/home_page/views/cards_view.dart';
import 'package:rapid_pass_info/pages/home_page/views/find_fare_view.dart';
import 'package:rapid_pass_info/widgets/pop_in_widget.dart';
import 'package:rapid_pass_info/helpers/refresh_notifier.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return RefreshNotifierProvider(
      child: ValueListenableBuilder(
        valueListenable: Hive.box<RapidPass>(RapidPass.boxName).listenable(),
        child: FloatingActionButton(
          onPressed: _showAddPassPage,
          tooltip: AppLocalizations.of(context)!.addRapidPass,
          child: const Icon(Icons.add_card),
        ),
        builder: (context, box, child) {
          return Scaffold(
            key: _scaffoldKey,
            floatingActionButton:
                _selectedIndex == 0 && box.isEmpty ? child : null,
            endDrawer: const Drawer(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 24.0,
                  horizontal: 8.0,
                ),
                child: SafeArea(child: FindFareView()),
              ),
            ),
            onEndDrawerChanged: (open) {
              if (!open) {
                setState(() {
                  _selectedIndex = 0;
                });
              }
            },
            bottomNavigationBar: NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                if (index == 1) _scaffoldKey.currentState?.openEndDrawer();
                setState(() {
                  _selectedIndex = index;
                });
              },
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.credit_card),
                  label: AppLocalizations.of(context)!.myCards,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.route),
                  label: AppLocalizations.of(context)!.findFare,
                ),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                await context.refreshAll();
              },
              child: CustomScrollView(
                slivers: [
                  _buildAppBar(),
                  SliverPadding(
                    padding: const EdgeInsets.only(
                      left: 8.0,
                      right: 8.0,
                      bottom: 8.0,
                    ),
                    sliver: CardsView(passes: box.values.toList()),
                  ),

                  // SliverStack(
                  //   children: [
                  //     CardsView(passes: box.values.toList()),
                  //     const SliverToBoxAdapter(child: FindFareView()),
                  //   ].mapIndexed(
                  //     (index, element) {
                  //       return SliverOffstage(
                  //         offstage: index != _selectedIndex,
                  //         sliver: SliverPadding(
                  //           padding: const EdgeInsets.only(
                  //             left: 8.0,
                  //             right: 8.0,
                  //             bottom: 8.0,
                  //           ),
                  //           sliver: element,
                  //         ),
                  //       );
                  //     },
                  //   ).toList(),
                  // ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNoticeButton(String data) {
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
                content: Text(data),
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

  Widget _buildAppBar() {
    return SliverAppBar.large(
      title: Text(
        AppLocalizations.of(context)!.title,
        textAlign: TextAlign.center,
      ),
      primary: true,
      floating: false,
      pinned: true,
      actions: [
        FutureBuilder<String?>(
          future: RapidPassService.instance
              .getLatestNotice(Localizations.localeOf(context)),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final data = snapshot.data!;
              return _buildNoticeButton(data);
            }
            return const SizedBox.shrink();
          },
        ),
        ValueListenableBuilder(
          valueListenable: Hive.box<RapidPass>(RapidPass.boxName).listenable(),
          builder: (context, box, _) {
            if (_selectedIndex == 0 && box.isNotEmpty) {
              return IconButton(
                icon: const Icon(Icons.add_card),
                tooltip: AppLocalizations.of(context)!.addRapidPass,
                onPressed: _showAddPassPage,
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
        )
      ],
    );
  }

  void _showAddPassPage() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return const AddPassPage();
      },
    );
  }
}
