import 'package:flutter/material.dart';

class RefreshNotifier extends InheritedWidget {
  final List<Future<void> Function()> _refreshCallbacks;

  const RefreshNotifier({
    super.key,
    required super.child,
    required List<Future<void> Function()> refreshCallbacks,
  })  : _refreshCallbacks = refreshCallbacks,
        super();

  static RefreshNotifier? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<RefreshNotifier>();
  }

  Future<void> refreshAll() async {
    final futures = _refreshCallbacks.map((callback) => callback());
    await Future.wait(futures);
  }

  @override
  bool updateShouldNotify(RefreshNotifier oldWidget) {
    return _refreshCallbacks != oldWidget._refreshCallbacks;
  }
}

class RefreshNotifierProvider extends StatefulWidget {
  final Widget child;

  const RefreshNotifierProvider({
    super.key,
    required this.child,
  });

  @override
  State<RefreshNotifierProvider> createState() =>
      _RefreshNotifierProviderState();
}

class _RefreshNotifierProviderState extends State<RefreshNotifierProvider> {
  final List<Future<void> Function()> _refreshCallbacks = [];

  void registerRefreshCallback(Future<void> Function() callback) {
    _refreshCallbacks.add(callback);
  }

  void unregisterRefreshCallback(Future<void> Function() callback) {
    _refreshCallbacks.remove(callback);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshNotifier(
      refreshCallbacks: _refreshCallbacks,
      child: _RefreshCallbackRegistrar(
        state: this,
        child: widget.child,
      ),
    );
  }
}

class _RefreshCallbackRegistrar extends StatefulWidget {
  final _RefreshNotifierProviderState state;
  final Widget child;

  const _RefreshCallbackRegistrar({
    required this.state,
    required this.child,
  });

  @override
  _RefreshCallbackRegistrarState createState() =>
      _RefreshCallbackRegistrarState();
}

class _RefreshCallbackRegistrarState extends State<_RefreshCallbackRegistrar> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

extension RefreshNotifierExtension on BuildContext {
  void registerRefreshCallback(Future<void> Function() callback) {
    final provider = findAncestorStateOfType<_RefreshNotifierProviderState>();
    provider?.registerRefreshCallback(callback);
  }

  void unregisterRefreshCallback(Future<void> Function() callback) {
    final provider = findAncestorStateOfType<_RefreshNotifierProviderState>();
    provider?.unregisterRefreshCallback(callback);
  }

  Future<void> refreshAll() async {
    return RefreshNotifier.of(this)?.refreshAll();
  }
}
