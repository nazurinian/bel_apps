import 'dart:async';
import 'package:bel_sekolah/utils/PermissionHandler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';

import './ChatPage.dart';
import './DiscoveryPage.dart';
import './SelectBondedDevicePage.dart';

class BTSerialPage extends StatefulWidget {
  const BTSerialPage({super.key});

  @override
  State<BTSerialPage> createState() => _BTSerialPage();
}

class _BTSerialPage extends State<BTSerialPage> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  String _address = "...";
  String _name = "...";

  Timer? _discoverableTimeoutTimer;
  int _discoverableTimeoutSecondsLeft = 0;

  bool _autoAcceptPairingRequests = false;

  @override
  void initState() {
    super.initState();
    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    Future.doWhile(() async {
      // Wait if adapter not enabled
      if ((await FlutterBluetoothSerial.instance.isEnabled) ?? false) {
        return false;
      }
      await Future.delayed(const Duration(milliseconds: 0xDD));
      return true;
    }).then((_) {
      // Update the address field
      FlutterBluetoothSerial.instance.address.then((address) {
        setState(() {
          _address = address!;
        });
      });
    });

    FlutterBluetoothSerial.instance.name.then((name) {
      setState(() {
        _name = name!;
      });
    });

    // Listen for futher state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;

        // Discoverable mode is disabled when Bluetooth gets disabled
        _discoverableTimeoutTimer = null;
        _discoverableTimeoutSecondsLeft = 0;
      });
    });
  }

  @override
  void dispose() {
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    _discoverableTimeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Serial'),
      ),
      body: PermissionHandlerWidget(
        notPermittedBuilder: () async {
          String message = "";
          IconData? icon;

          PermissionStatus locationPermissionData =
              await Permission.location.status;
          PermissionStatus bluetoothPermissionData =
              await Permission.bluetoothScan.status;

          // Sekali tolak, sama tolak selamanya (2x tolak)
          if ((bluetoothPermissionData.isDenied || bluetoothPermissionData.isPermanentlyDenied) &&
              (locationPermissionData.isDenied || locationPermissionData.isPermanentlyDenied)) {
            // icon = Icons.camera;
            message = "Izin lokasi dan bluetooth \nbelum diberikan";
            return Center(
              child: Container(
                height: 350,
                width: 250,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Stack(
                  children: [
                    const SizedBox(width: 8.0), // Spacer
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      bottom: 65,
                      child: CustomPaint(
                        size: const Size(120, 120),
                        painter: SlashPainter(),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.bluetooth_disabled,
                              size: 120.0,
                            ),
                            SizedBox(width: 8.0), // Spacer
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_disabled,
                              size: 120.0,
                            ),
                          ],
                        ),
                        Text(
                          message,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          } else {
            if (bluetoothPermissionData.isDenied || bluetoothPermissionData.isPermanentlyDenied) {
              icon = Icons.bluetooth_disabled;
              message = "Izin bluetooth belum diberikan";
            }
            if (locationPermissionData.isDenied || locationPermissionData.isPermanentlyDenied) {
              icon = Icons.location_disabled;
              message = "Izin lokasi belum diberikan";
            }
          }

          return Center(
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
          );
        },
        permittedBuilder: () {
          return ListView(
            physics: const BouncingScrollPhysics(),
            children: <Widget>[
              const Divider(),
              const ListTile(
                  title: Text(
                'General',
                style: TextStyle(fontWeight: FontWeight.bold),
              )),
              SwitchListTile(
                title: const Text('Enable Bluetooth'),
                value: _bluetoothState.isEnabled,
                onChanged: (bool value) {
                  // Do the request and update with the true value then
                  future() async {
                    // async lambda seems to not working
                    if (value) {
                      await FlutterBluetoothSerial.instance.requestEnable();
                    } else {
                      await FlutterBluetoothSerial.instance.requestDisable();
                    }
                  }

                  future().then((_) {
                    setState(() {});
                  });
                },
              ),
              const ListTile(
                subtitle: Text(
                  "Dibeberapa android tertentu, bluetooth hanya dapat diaktifkan dan dinonaktifkan secara manual melalui sistem",
                  style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ),
              ListTile(
                title: const Text('Bluetooth status'),
                subtitle: Text(_bluetoothState.toString()),
                trailing: ElevatedButton(
                  child: const Text('Settings'),
                  onPressed: () {
                    FlutterBluetoothSerial.instance.openSettings();
                  },
                ),
              ),
              ListTile(
                title: const Text('Local adapter address'),
                subtitle: Text(_address),
              ),
              ListTile(
                title: const Text('Local adapter name'),
                subtitle: Text(_name),
                onLongPress: null,
              ),
              const Divider(),
              const ListTile(
                  title: Text(
                'Devices discovery and connection',
                style: TextStyle(fontWeight: FontWeight.bold),
              )),
              SwitchListTile(
                title: const Text('Auto-try specific pin when pairing'),
                subtitle: const Text('Pin 1234'),
                value: _autoAcceptPairingRequests,
                onChanged: (bool value) {
                  setState(() {
                    _autoAcceptPairingRequests = value;
                  });
                  if (value) {
                    FlutterBluetoothSerial.instance.setPairingRequestHandler(
                        (BluetoothPairingRequest request) {
                      if (request.pairingVariant == PairingVariant.Pin) {
                        return Future.value("1234");
                      }
                      return Future.value(null);
                    });
                  } else {
                    FlutterBluetoothSerial.instance
                        .setPairingRequestHandler(null);
                  }
                },
              ),
              ListTile(
                title: ElevatedButton(
                    child: const Text('Explore discovered devices'),
                    onPressed: () async {
                      final BluetoothDevice? selectedDevice =
                          await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return const DiscoveryPage();
                          },
                        ),
                      );

                      if (selectedDevice != null) {
                      } else {
                      }
                    }),
              ),
              ListTile(
                title: ElevatedButton(
                  child: const Text('Connect to paired device to chat'),
                  onPressed: () async {
                    final BluetoothDevice? selectedDevice =
                        await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return const SelectBondedDevicePage(
                              checkAvailability: false);
                        },
                      ),
                    );

                    if (selectedDevice != null) {
                      _startChat(context, selectedDevice);
                    } else {
                    }
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _startChat(BuildContext context, BluetoothDevice server) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return ChatPage(server: server);
        },
      ),
    );
  }
}

class SlashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 4.0;

    canvas.drawLine(
      Offset(0, size.height), // start point
      Offset(size.width, 0), // end point
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
