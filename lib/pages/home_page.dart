import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:rapid_pass_info/models/rapid_pass.dart';
import 'package:rapid_pass_info/pages/add_pass_page.dart';
import 'package:rapid_pass_info/pages/settings_page.dart';
import 'package:rapid_pass_info/services/rapid_pass.dart';
import 'package:rapid_pass_info/widgets/card_list.dart';
import 'package:rapid_pass_info/widgets/empty_message.dart';
import 'package:rapid_pass_info/widgets/pop_in_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<RapidPass>(RapidPass.boxName).listenable(),
      child: FloatingActionButton(
        tooltip: AppLocalizations.of(context)!.addRapidPass,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddPassPage(),
            ),
          );
        },
        child: const Icon(Icons.add_card),
      ),
      builder: (context, box, child) {
        return Scaffold(
          floatingActionButton: child,
          body: RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: CustomScrollView(
              slivers: [
                _buildAppBar(),
                SliverPadding(
                  padding: const EdgeInsets.only(
                    left: 8,
                    right: 8,
                    bottom: 8,
                  ),
                  sliver: box.values.isEmpty
                      ? const SliverToBoxAdapter(
                          child: Center(
                            child: EmptyMessage(),
                          ),
                        )
                      : CardList(
                          passes: box.values.toList(),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar.large(
      title: Text(
        AppLocalizations.of(context)!.title,
        textAlign: TextAlign.center,
      ),
      actions: [
        FutureBuilder<String?>(
          future: RapidPassService.instance
              .getLatestNotice(Localizations.localeOf(context)),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final data = snapshot.data!;
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
                                MaterialLocalizations.of(context)
                                    .closeButtonLabel,
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
}
