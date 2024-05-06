import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHandlerWidget extends StatefulWidget {
  final Widget Function() permittedBuilder;
  final Future<Widget> Function() notPermittedBuilder;

  const PermissionHandlerWidget({
    super.key,
    required this.permittedBuilder,
    required this.notPermittedBuilder,
  });

  @override
  State<PermissionHandlerWidget> createState() =>
      _PermissionHandlerWidgetState();
}

class _PermissionHandlerWidgetState extends State<PermissionHandlerWidget> {
  bool locationGranted = false;
  bool bluetoothGranted = false;
  bool permissionsRequested = false;

  @override
  void initState() {
    super.initState();
    requestPermission();
  }

  Future<void> requestPermission() async {
    // Periksa status izin Bluetooth dan izin lokasi
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
      Permission.location,
    ].request();

    // Periksa setiap status izin
    statuses.forEach(
      (permission, status) {
        if (permission == Permission.location) {
          if (status.isGranted) {
            locationGranted = true;
          }
          if (status.isPermanentlyDenied) {
            openAppSettings();
          }
        }
        if (permission == Permission.bluetoothScan) {
          if (status.isGranted) {
            bluetoothGranted = true;
          }
          if (status.isPermanentlyDenied) {
            openAppSettings();
          }
        }
      },
    );

    setState(() {
      permissionsRequested = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!permissionsRequested) {
      return const Center(
          child:
              CircularProgressIndicator()); // Menampilkan indikator loading saat permintaan izin sedang berjalan
    }

    return (locationGranted && bluetoothGranted)
        ? widget.permittedBuilder()
        : FutureBuilder<Widget>(
            future: widget.notPermittedBuilder(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child:
                        CircularProgressIndicator()); // Menampilkan indikator loading saat memuat widget notPermittedBuilder
              }
              return snapshot.data ??
                  Container(); // Mengembalikan widget dari future
            },
          );
  }
}

// Memeriksa status izin Bluetooth dan lokasi
// statuses.forEach((permission, status) {
// if (permission == Permission.location) {
// if (status.isGranted) {
// locationGranted = true;
// }
// } else if (permission == Permission.bluetooth) {
// if (status.isGranted) {
// bluetoothGranted = true;
// }
// }
// });
//
// // Memeriksa status izin dan mengembalikan widget sesuai
// // if (locationGranted && bluetoothGranted) {
// //   return permittedBuilder();
// // } else {
// //   return notPermittedBuilder(statuses);
// // }
//
// return (locationGranted && bluetoothGranted)
// ? widget.permittedBuilder()
//     : widget.notPermittedBuilder();
