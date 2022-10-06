import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectionManager {
  static final ConnectionManager _instance = ConnectionManager._internal();
  bool hasConnection = true;
  factory ConnectionManager() {
    return _instance;
  }
  ConnectionManager._internal() {
    Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult connectivityResult) {
      if (connectivityResult == ConnectivityResult.mobile) {
        hasConnection = true;
      } else if (connectivityResult == ConnectivityResult.wifi) {
        hasConnection = true;
      } else {
        hasConnection = false;
      }
    });
  }
}
