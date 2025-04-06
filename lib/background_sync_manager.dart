import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class BackgroundSyncManager with WidgetsBindingObserver {
  Timer? _timer;
  late final Connectivity _connectivity;
  late final StreamSubscription<ConnectivityResult> _connectivitySub;
  final Future<void> Function() onSync;

  BackgroundSyncManager({required this.onSync});

  void start() {
    _connectivity = Connectivity();
    WidgetsBinding.instance.addObserver(this);

    // Start periodic sync every 1 minute
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      print('[Sync] Fetching latest posts...');
      onSync();
    });

    // Listen for connectivity changes (back online)
    _connectivitySub = _connectivity.onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        print('[Sync] Back online → syncing...');
        onSync();
      }
    });
  }

  void dispose() {
    _timer?.cancel();
    _connectivitySub.cancel();
    WidgetsBinding.instance.removeObserver(this);
  }

  // Detect app resume from background
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print('[Sync] App resumed → syncing...');
      onSync();
    }
  }
}
