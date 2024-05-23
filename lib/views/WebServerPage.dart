import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:network_info_plus/network_info_plus.dart';

class WebServerPage extends StatefulWidget {
  const WebServerPage({super.key});

  @override
  State<WebServerPage> createState() => _WebServerPageState();
}

class _WebServerPageState extends State<WebServerPage> {
  late WebViewController _controller;
  bool _isConnectedToCorrectWifi = false;
  bool _isLoading = false;
  final String _correctUrl = 'http://10.0.0.1';

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              _isLoading = true;
            });
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            debugPrint('Page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
            });
            debugPrint('''
              Page resource error:
                code: ${error.errorCode}
                description: ${error.description}
                errorType: ${error.errorType}
                isForMainFrame: ${error.isForMainFrame}
          ''');
          },
          onNavigationRequest: (NavigationRequest request) {
            setState(() {
              _isLoading = false;
            });
            debugPrint('allowing navigation to ${request.url}');
            return NavigationDecision.navigate;
          },
          onUrlChange: (UrlChange change) {
            setState(() {
              _isLoading = false;
            });
            debugPrint('url change to ${change.url}');
          },
          onHttpAuthRequest: (HttpAuthRequest request) {},
        ),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        },
      )
      ..loadRequest(Uri.parse(_correctUrl));
    _checkConnectivity();
  }

  void _checkConnectivity() async {
    // Check if the platform is Android and the version is 9 (Pie) or higher
    if (Platform.isAndroid && (await _isAndroidVersion9OrHigher())) {
      final List<ConnectivityResult> result =
          await (Connectivity().checkConnectivity());

      if (result.contains(ConnectivityResult.wifi)) {
        // Get the current Wi-Fi network's SSID
        final String? ssid = await NetworkInfo().getWifiName();
        if (ssid == 'BSIB-AP' || ssid == '"BSIB-AP"' || ssid == '""BSIB-AP""') {
          setState(() {
            _isConnectedToCorrectWifi = true;
          });
          print('SSID True: $ssid');
          return;
        } else {
          setState(() {
            _isConnectedToCorrectWifi = true;
          });
          print('SSID False: $ssid');
          print('Device is not connected to Wi-Fi');
        }
      }
    } else {
      // Handle the case where the device is not running Android 9 or higher
      _isConnectedToCorrectWifi = true;
      print('This feature is not supported on this version of Android');
    }
  }

  Future<bool> _isAndroidVersion9OrHigher() async {
    if (!kIsWeb && Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      return androidInfo.version.sdkInt >=
          28; // 28 corresponds to Android 9 (Pie)
    }
    return false;
  }

  @override
  void dispose() {
    _controller.clearCache();
    super.dispose();
  }

  Future<bool?> _goBack(BuildContext context) async {
    if (await _controller.canGoBack()) {
      _controller.goBack();
      return Future.value(false);
    } else {
      final shouldExit = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Keluar dari mode AP\nBel Sekolah?'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: Text('No'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text('Yes'),
            ),
          ],
        ),
      );
      return Future.value(shouldExit ?? false);
    }
  }

  // @override
  // Widget build(BuildContext context) {
  //   return PopScope(
  //       canPop: false,
  //       // onPopInvoked: () => _goBack(context),
  //       onPopInvoked: (didPop) async {
  //         if (didPop) {
  //           return;
  //         } else {
  //           final bool shouldPop = await _goBack(context) ?? false;
  //           if (context.mounted && shouldPop) {
  //             Navigator.pop(context);
  //           }
  //         }
  //       },

  // Future<bool?> _goBack(BuildContext context) {
  //     if (await _controller.canGoBack()) {
  //   _controller.goBack();
  //   return Future.value(false);
  //   } else {
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: Text('Keluar dari mode AP\nBel Sekolah?'),
  //       actions: [
  //         ElevatedButton(
  //           onPressed: () {
  //             Navigator.pop(context, false);
  //             // Navigator.pop(context, false);
  //           },
  //           child: Text('No'),
  //         ),
  //         ElevatedButton(
  //           onPressed: () {
  //             Navigator.pop(context, false);
  //             // Navigator.pop(context, true);
  //           },
  //           child: Text('Yes'),
  //         ),
  //       ],
  //     ) :
  //   );
  // }
  //   }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) {
          Navigator.pop(context);
          return;
        } else {
          final bool? shouldPop = await _goBack(context);
          if (shouldPop == true) {
            if (context.mounted) {
              Navigator.pop(context);
            }
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mode AP Bel Sekolah'),
        ),
        body: !_isConnectedToCorrectWifi
            ? Container(
                padding: const EdgeInsets.all(24),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.wifi_off,
                      color: Colors.red,
                      size: 100,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Hubungkan dengan WiFi Access Point Bel Sekolah',
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            // : _success
            //     ? const Center(child: CircularProgressIndicator())
            : _isLoading
                ? const Center(child: CircularProgressIndicator())
                : WebViewWidget(
                    controller: _controller,
                  ),
      ),
    );
  }
}