/*import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectionChecker extends StatefulWidget {
  final Widget connectedWidget;
  final Widget disconnectedWidget;

  const ConnectionChecker({
    super.key,
    required this.connectedWidget,
    required this.disconnectedWidget,
  });

  @override
  State<ConnectionChecker> createState() => _ConnectionCheckerState();
}

class _ConnectionCheckerState extends State<ConnectionChecker> {
  late List<ConnectivityResult> _connectionStatus;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> _initConnectivity() async {
    List<ConnectivityResult> result = [];
    try {
      result = await _connectivity.checkConnectivity();
    } catch (e) {
      print(e.toString());
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _connectionStatus = result;
    });
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    setState(() {
      _connectionStatus = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _connectionStatus == [ConnectivityResult.mobile] ||
        _connectionStatus == [ConnectivityResult.wifi]
        ? widget.disconnectedWidget // Menggunakan connectedWidget jika terhubung
        : widget.connectedWidget; // Menggunakan disconnectedWidget jika tidak terhubung
  }
}*/

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';

class ConnectionChecker extends StatelessWidget {
  final Widget connectedWidget;
  final Widget disconnectedWidget;

  const ConnectionChecker({
    super.key,
    required this.connectedWidget,
    required this.disconnectedWidget,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ConnectivityResult>>(
      stream: Connectivity().onConnectivityChanged,
      initialData: const [ConnectivityResult.none],
      builder: (context, snapshot) {
        final connectionStatus = snapshot.data!;

        if (kIsWeb) {
          return connectedWidget;
        } else {
          return connectionStatus.contains(ConnectivityResult.none)
              ? disconnectedWidget
              : connectedWidget;
        }
      },
    );
  }
}

/*import 'dart:async';

import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';

class ConnectionChecker extends StatefulWidget {
  final Widget connectedWidget;
  final Widget disconnectedWidget;

  const ConnectionChecker({
    super.key,
    required this.connectedWidget,
    required this.disconnectedWidget,
  });

  @override
  State<ConnectionChecker> createState() => _ConnectionCheckerState();
}

class _ConnectionCheckerState extends State<ConnectionChecker> {
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    super.dispose();
    _connectivitySubscription.cancel();
  }

  Future<void> initConnectivity() async {
    late List<ConnectivityResult> result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e);
      return;
    }
    if (!mounted) {
      return Future.value(null);
    }
    return _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    setState(() {
      _connectionStatus = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _connectionStatus == [ConnectivityResult.none]
        ? widget.disconnectedWidget
        : widget.connectedWidget;
  }
}*/

/*import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';

class ConnectionChecker extends StatelessWidget {
  final Widget connectedWidget;
  final Widget disconnectedWidget;

  const ConnectionChecker({
    super.key,
    required this.connectedWidget,
    required this.disconnectedWidget,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ConnectivityResult>>(
      stream: Connectivity().onConnectivityChanged,
      initialData: const [ConnectivityResult.none],
      builder: (context, snapshot) {
        final connectionStatus = snapshot.data!;

        if (kIsWeb) {
          return connectedWidget;
        } else {
          return connectionStatus.contains(ConnectivityResult.none)
              ? disconnectedWidget
              : connectedWidget;
        }
      },
    );
  }
}*/

/*
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;

class ConnectionChecker extends StatelessWidget {
  final Widget connectedWidget;
  final Widget disconnectedWidget;

  const ConnectionChecker({
    Key? key,
    required this.connectedWidget,
    required this.disconnectedWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ConnectivityResult>>(
      stream: Connectivity().onConnectivityChanged,
      initialData: const [ConnectivityResult.none],
      builder: (context, snapshot) {
        final connectionStatus = snapshot.data!;
        return FutureBuilder<bool>(
          future: hasInternet(connectionStatus),
          builder: (context, hasInternetSnapshot) {
            // if (hasInternetSnapshot.connectionState == ConnectionState.waiting) {
              // Menunggu hasil pengecekan koneksi
              // return CircularProgressIndicator();
            // } else {
              // Hasil pengecekan koneksi tersedia
              final bool hasInternet = hasInternetSnapshot.data ?? false;
              if (hasInternet) {
                return connectedWidget;
              } else {
                return disconnectedWidget;
              }
            // }
          },
        );
      },
    );
  }

  Future<bool> hasInternet(List<ConnectivityResult> connectivityResult) async {
    bool hasInternet;

    if (kIsWeb) {
      var connection = html.window.navigator.onLine;

      if (connection != null) {
        hasInternet = connection;
      } else {
        hasInternet = false;
      }
    } else {
      if (connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi)) {
        hasInternet = true;
      } else {
        hasInternet = false;
      }
    }

    return hasInternet;
  }
}
*/
