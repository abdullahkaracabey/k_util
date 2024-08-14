import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConnectionManagerState {
  final ConnectivityResult connectivityState;

  ConnectionManagerState({required this.connectivityState});
}

class ConnectionManager extends AsyncNotifier<ConnectionManagerState> {
  static final ConnectionManager _instance = ConnectionManager._internal();
  bool get hasConnection =>
      state.value?.connectivityState != ConnectivityResult.none;
  factory ConnectionManager() {
    return _instance;
  }
  ConnectionManager._internal() {
    Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> connectivityResult) async {
      final connectivityState = _getConnectivityState(connectivityResult);
      await update((state) =>
          ConnectionManagerState(connectivityState: connectivityState));
    });
  }

  ConnectivityResult _getConnectivityState(
      List<ConnectivityResult> connectivityResult) {
    if (connectivityResult.contains(ConnectivityResult.mobile)) {
      return ConnectivityResult.mobile;
    } else if (connectivityResult.contains(ConnectivityResult.wifi)) {
      return ConnectivityResult.wifi;
    } else if (connectivityResult.contains(ConnectivityResult.ethernet)) {
      return ConnectivityResult.ethernet;
    } else if (connectivityResult.contains(ConnectivityResult.vpn)) {
      return ConnectivityResult.vpn;
    } else if (connectivityResult.contains(ConnectivityResult.bluetooth)) {
      return ConnectivityResult.bluetooth;
    } else if (connectivityResult.contains(ConnectivityResult.other)) {
      return ConnectivityResult.other;
    } else if (connectivityResult.contains(ConnectivityResult.none)) {
      return ConnectivityResult.none;
    }

    return ConnectivityResult.none;
  }

  @override
  FutureOr<ConnectionManagerState> build() async {
    final results = await Connectivity().checkConnectivity();
    final connectivityResult = _getConnectivityState(results);
    return ConnectionManagerState(connectivityState: connectivityResult);
  }
}

final connectionProvider =
    AsyncNotifierProvider<ConnectionManager, ConnectionManagerState>(
        ConnectionManager.new);
