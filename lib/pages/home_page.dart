import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rapid_pass_info/models/rapid_pass.dart';
import 'package:rapid_pass_info/pages/add_pass_page.dart';
import 'package:rapid_pass_info/state/state.dart';
import 'package:rapid_pass_info/widgets/card_layout.dart';
import 'package:rapid_pass_info/widgets/empty_message.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' hide AppState;
import '../helpers/ad_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  BannerAd? _bannerAd;

  Future<InitializationStatus> _initGoogleMobileAds() {
    return MobileAds.instance.initialize();
  }

  void _loadAd() {
    final bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: AdHelper.bannerAdUnitId,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAd failed to load: $error');
          ad.dispose();
        },
        onAdClosed: (ad) {
          setState(() {
            _bannerAd = null;
          });
          ad.dispose();
        },
      ),
    );

    // Start loading.
    bannerAd.load();
  }

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      _initGoogleMobileAds().then((status) {
        _loadAd();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      child: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddPassPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      builder: (context, state, child) {
        return Scaffold(
          floatingActionButton: child,
          bottomNavigationBar: (_bannerAd != null)
              ? SizedBox(
                  width: _bannerAd!.size.width.toDouble(),
                  height: _bannerAd!.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd!),
                )
              : null,
          body: RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: CustomScrollView(
              slivers: [
                SliverAppBar.large(
                  title: Text(
                    AppLocalizations.of(context)!.title,
                    textAlign: TextAlign.center,
                  ),
                  actions: [
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'about') {
                          showAboutDialog(
                            context: context,
                            applicationName:
                                AppLocalizations.of(context)!.title,
                            applicationVersion: '1.0.0',
                            applicationIcon: Image.asset(
                              'assets/icon/icon.png',
                              width: 48,
                              height: 48,
                            ),
                            children: [
                              Text(
                                AppLocalizations.of(context)!.aboutDescription,
                              ),
                            ],
                          );
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem<String>(
                          value: 'about',
                          child: Text(AppLocalizations.of(context)!.about),
                        ),
                      ],
                    )
                  ],
                ),
                SliverPadding(
                  padding: const EdgeInsets.only(
                    left: 8,
                    right: 8,
                    bottom: 8,
                  ),
                  sliver: state.passes.isEmpty
                      ? const SliverToBoxAdapter(
                          child: Center(
                            child: EmptyMessage(),
                          ),
                        )
                      : CardList(passes: state.passes),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }
}

class CardList extends StatefulWidget {
  final List<RapidPass> passes;

  const CardList({
    super.key,
    required this.passes,
  });

  @override
  State<CardList> createState() => _CardListState();
}

class _CardListState extends State<CardList> {
  @override
  Widget build(BuildContext context) {
    return SliverReorderableList(
      itemCount: widget.passes.length,
      onReorder: (oldIndex, newIndex) {
        context.read<AppState>().reorderPasses(oldIndex, newIndex);
      },
      itemBuilder: (context, index) {
        final pass = widget.passes[index];
        return AnimatedSwitcher(
          key: ValueKey(pass.id),
          transitionBuilder: (child, animation) {
            return SizeTransition(
              sizeFactor: animation,
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          duration: const Duration(milliseconds: 300),
          child: CardItem(pass: pass, index: index),
        );
      },
    );
  }
}

class CardItem extends StatefulWidget {
  final RapidPass pass;
  final int index;

  const CardItem({
    super.key,
    required this.pass,
    required this.index,
  });

  @override
  State<CardItem> createState() => _CardItemState();
}

class _CardItemState extends State<CardItem> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      key: ValueKey(widget.pass.id),
      future: widget.pass.data,
      builder: (context, snapshot) {
        if ((snapshot.connectionState == ConnectionState.done ||
                snapshot.connectionState == ConnectionState.active) &&
            snapshot.hasError) {
          return CardLayoutError(
            index: widget.index,
            message: switch (snapshot.error) {
              SocketException _ => AppLocalizations.of(context)!.noInternet,
              _ => snapshot.error,
            },
            passName: widget.pass.name,
            passNumber: widget.pass.number,
            onCopy: () => _onCopy(widget.pass),
            onDelete: () => _onDelete(widget.pass),
          );
        }
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          final passData = snapshot.data!;
          return CardLayoutSuccess(
            index: widget.index,
            passName: widget.pass.name,
            passNumber: widget.pass.number,
            passData: passData,
            onCopy: () => _onCopy(widget.pass),
            onDelete: () => _onDelete(widget.pass),
          );
        }
        return CardLayoutLoading(
          index: widget.index,
          passNumber: widget.pass.number,
          passName: widget.pass.name,
        );
      },
    );
  }

  void _onDelete(RapidPass pass) {
    context.read<AppState>().removePass(pass.id);
  }

  void _onCopy(RapidPass pass) async {
    await Clipboard.setData(
      ClipboardData(text: "RP${pass.number}"),
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.cardNumberCopied),
      ),
    );
  }
}
