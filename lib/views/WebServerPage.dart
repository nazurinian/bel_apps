import 'dart:async';
import 'dart:io';

import 'package:bel_sekolah/utils/PermissionHandler.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
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
  late Timer _timer;
  bool _loadUrl = false;

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
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!_loadUrl) {
        _checkConnectivity();
      }
    });
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
            _loadUrl = true;
          });
          _controller.reload();
          print('SSID True: $ssid');
          return;
        } else {
          setState(() {
            _isConnectedToCorrectWifi = false;
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
    _timer.cancel();
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
          title: const Text('Keluar dari Mode AP\nBel Sekolah?'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Yes'),
            ),
          ],
        ),
      );
      return Future.value(shouldExit ?? false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PermissionHandlerWidget(notPermittedBuilder: () async {
      String message = "";
      IconData? icon;

      PermissionStatus locationPermissionData =
          await Permission.location.status;

      if (locationPermissionData.isDenied || locationPermissionData.isPermanentlyDenied) {
        icon = Icons.location_disabled;
        message = "Izin lokasi belum diberikan";
      }

      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white.withOpacity(0),
        ),
        body: Center(
          child: Container(
            height: 350,
            width: 250,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 120.0,
                ),
                Text(
                  message,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }, permittedBuilder: () {
      return PopScope(
        canPop: false,
        onPopInvoked: (didPop) async {
          if (didPop) {
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
                        'Hubungkan Smartphone ke WiFi Access Point Bel Sekolah',
                        style: TextStyle(fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : WebViewWidget(
                      controller: _controller,
                    ),
        ),
      );
    });
  }
}
