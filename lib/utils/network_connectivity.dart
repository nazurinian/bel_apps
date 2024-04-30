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
      initialData: [ConnectivityResult.none],
      builder: (context, snapshot) {
        final connectionStatus = snapshot.data!;
        return connectionStatus.contains(ConnectivityResult.none)
            ? disconnectedWidget
            : connectedWidget;
      },
    );
  }
}
