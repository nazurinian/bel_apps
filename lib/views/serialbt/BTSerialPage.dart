import 'dart:async';

import 'package:bel_sekolah/utils/PermissionHandler.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scoped_model/scoped_model.dart';

import './BackgroundCollectedPage.dart';
import './BackgroundCollectingTask.dart';
import './ChatPage.dart';
import './DiscoveryPage.dart';
import './SelectBondedDevicePage.dart';

// import './helpers/LineChart.dart';

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

  BackgroundCollectingTask? _collectingTask;

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
    _collectingTask?.dispose();
    _discoverableTimeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Bluetooth Serial'),
      ),
      body: PermissionHandlerWidget(
        notPermittedBuilder: () async {
          String message = "";
          IconData? icon;

          PermissionStatus locationPermissionData =
              await Permission.location.status;
          PermissionStatus bluetoothPermissionData =
              await Permission.bluetoothScan.status;

          if (bluetoothPermissionData.isDenied &&
              locationPermissionData.isDenied) {
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
            if (bluetoothPermissionData.isDenied) {
              icon = Icons.bluetooth_disabled;
              message = "Izin bluetooth belum diberikan";
            }
            if (locationPermissionData.isDenied) {
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
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 8),
              //   child: const Text("Dibeberapa android tertentu, bluetooth dapat diaktifkan dan dinonaktifkan secara manual melalui sistem", style: TextStyle(fontSize: 10),textAlign: TextAlign.center,),
              // ),
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
              /*ListTile(
                    title: _discoverableTimeoutSecondsLeft == 0
                        ? const Text("Discoverable")
                        : Text(
                            "Discoverable for ${_discoverableTimeoutSecondsLeft}s"),
                    subtitle: const Text("PsychoX-Luna"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: _discoverableTimeoutSecondsLeft != 0,
                          onChanged: null,
                        ),
                        const IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: null,
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: () async {
                            print('Discoverable requested');
                            final int timeout = (await FlutterBluetoothSerial.instance
                                .requestDiscoverable(60))!;
                            if (timeout < 0) {
                              print('Discoverable mode denied');
                            } else {
                              print(
                                  'Discoverable mode acquired for $timeout seconds');
                            }
                            setState(() {
                              _discoverableTimeoutTimer?.cancel();
                              _discoverableTimeoutSecondsLeft = timeout;
                              _discoverableTimeoutTimer =
                                  Timer.periodic(const Duration(seconds: 1), (Timer timer) {
                                setState(() {
                                  if (_discoverableTimeoutSecondsLeft < 0) {
                                    FlutterBluetoothSerial.instance.isDiscoverable
                                        .then((isDiscoverable) {
                                      if (isDiscoverable ?? false) {
                                        print(
                                            "Discoverable after timeout... might be infinity timeout :F");
                                        _discoverableTimeoutSecondsLeft += 1;
                                      }
                                    });
                                    timer.cancel();
                                    _discoverableTimeoutSecondsLeft = 0;
                                  } else {
                                    _discoverableTimeoutSecondsLeft -= 1;
                                  }
                                });
                              });
                            });
                          },
                        )
                      ],
                    ),
                  ),*/
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
                      print("Trying to auto-pair with Pin 1234");
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
                        print(
                            'Discovery -> selected ' + selectedDevice.address);
                      } else {
                        print('Discovery -> no device selected');
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
                      print('Connect -> selected ' + selectedDevice.address);
                      _startChat(context, selectedDevice);
                    } else {
                      print('Connect -> no device selected');
                    }
                  },
                ),
              ),
              /*const Divider(),
              const ListTile(title: Text('Multiple connections example')),
              ListTile(
                title: ElevatedButton(
                  child: ((_collectingTask?.inProgress ?? false)
                      ? const Text('Disconnect and stop background collecting')
                      : const Text('Connect to start background collecting')),
                  onPressed: () async {
                    if (_collectingTask?.inProgress ?? false) {
                      await _collectingTask!.cancel();
                      setState(() {
                        */ /* Update for `_collectingTask.inProgress` */ /*
                      });
                    } else {
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
                        await _startBackgroundTask(context, selectedDevice);
                        setState(() {
                          */ /* Update for `_collectingTask.inProgress` */ /*
                        });
                      }
                    }
                  },
                ),
              ),
              ListTile(
                title: ElevatedButton(
                  child: const Text('View background collected data'),
                  onPressed: (_collectingTask != null)
                      ? () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return ScopedModel<BackgroundCollectingTask>(
                                  model: _collectingTask!,
                                  child: BackgroundCollectedPage(),
                                );
                              },
                            ),
                          );
                        }
                      : null,
                ),
              ),*/
            ],
          );
        },
      ),
    );
  }

/*  Future<void> requestPermission() async {
    // Periksa status izin Bluetooth dan izin lokasi
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
      Permission.location,
    ].request();

    // Periksa setiap status izin
    statuses.forEach((permission, status) {
      if (permission == Permission.location) {
        if (status.isGranted) {
            Fluttertoast.showToast(
                msg: "Akses lokasi diberikan", toastLength: Toast.LENGTH_SHORT);
        }
        if (status.isDenied) {
          Fluttertoast.showToast(
              msg: "Harap berikan akses lokasi", toastLength: Toast.LENGTH_SHORT);
        }
        if (status.isPermanentlyDenied) {
          Fluttertoast.showToast(
              msg: "Harap berikan izin lokasi dan bluetooth", toastLength: Toast.LENGTH_SHORT);
          openAppSettings();
        }
      }
      if (permission == Permission.bluetoothScan) {
        if (status.isGranted) {
          Fluttertoast.showToast(
              msg: "Akses bluetooth diberikan", toastLength: Toast.LENGTH_SHORT);
        }
        if (status.isDenied) {
          Fluttertoast.showToast(
              msg: "Harap berikan akses bluetooth", toastLength: Toast.LENGTH_SHORT);
        }
        if (status.isPermanentlyDenied) {
          Fluttertoast.showToast(
              msg: "Harap berikan izin lokasi dan bluetooth", toastLength: Toast.LENGTH_SHORT);
          openAppSettings();
        }
      }
    });
  }*/

  void _startChat(BuildContext context, BluetoothDevice server) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return ChatPage(server: server);
        },
      ),
    );
  }

  Future<void> _startBackgroundTask(
    BuildContext context,
    BluetoothDevice server,
  ) async {
    try {
      _collectingTask = await BackgroundCollectingTask.connect(server);
      await _collectingTask!.start();
    } catch (ex) {
      _collectingTask?.cancel();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error occured while connecting'),
            content: Text("${ex.toString()}"),
            actions: <Widget>[
              TextButton(
                child: const Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
}

class SlashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0;

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
