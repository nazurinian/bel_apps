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
