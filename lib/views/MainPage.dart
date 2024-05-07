import 'package:flutter/material.dart';
import 'package:bel_sekolah/views/serialbt/BTSerialPage.dart';
import 'package:bel_sekolah/views/BelFirebasePage.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool isBluetoothPressed = false;
  bool isJadwalPressed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bel Home"),
        centerTitle: true,
      ),
      body: Container(
        alignment: Alignment.center,
        child: Stack(
          children: [
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: Opacity(
                opacity: 0.5,
                child: Icon(
                  Icons.multitrack_audio_sharp,
                  size: 300.0,
                  color: Colors.blue,
                ),
              ),
            ),
            const Divider(
              height: 20,
              color: Colors.deepPurpleAccent,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTapDown: (_) {
                        setState(() {
                          isBluetoothPressed = true;
                          isJadwalPressed = false;
                        });
                      },
                      onTapUp: (_) {
                        setState(() {
                          isBluetoothPressed = false;
                          isJadwalPressed = false;
                        });
                      },
                      onTapCancel: () {
                        setState(() {
                          isBluetoothPressed = false;
                          isJadwalPressed = false;
                        });
                      },
                      child: AnimatedContainer(
                        height: isBluetoothPressed
                            ? 250
                            : (isJadwalPressed ? 50 : 100),
                        width: isBluetoothPressed
                            ? 170
                            : (isJadwalPressed ? 120 : 150),
                        duration: const Duration(milliseconds: 300),
                        child: OutlinedButton(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            )),
                            side: MaterialStateProperty.all(
                                const BorderSide(color: Colors.green)),
                            overlayColor:
                                MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                                if (states.contains(MaterialState.pressed)) {
                                  return Colors.green.withOpacity(
                                      0.2);
                                }
                                return Colors
                                    .white;
                              },
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const BTSerialPage(),
                              ),
                            );
                          },
                          child: const Text(
                            "Menu Bluetooth",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black87),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTapDown: (_) {
                        setState(() {
                          isJadwalPressed = true;
                          isBluetoothPressed = false;
                        });
                      },
                      onTapUp: (_) {
                        setState(() {
                          isJadwalPressed = false;
                          isBluetoothPressed = false;
                        });
                      },
                      onTapCancel: () {
                        setState(() {
                          isJadwalPressed = false;
                          isBluetoothPressed = false;
                        });
                      },
                      child: AnimatedContainer(
                        height: isJadwalPressed
                            ? 250
                            : (isBluetoothPressed ? 50 : 100),
                        width: isJadwalPressed
                            ? 170
                            : (isBluetoothPressed ? 120 : 150),
                        duration: const Duration(milliseconds: 300),
                        child: OutlinedButton(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            )),
                            side: MaterialStateProperty.all(
                                const BorderSide(color: Colors.green)),
                            overlayColor:
                                MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                                if (states.contains(MaterialState.pressed)) {
                                  return Colors.green.withOpacity(
                                      0.2);
                                }
                                return Colors
                                    .white;
                              },
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const BelFirebasePage(),
                              ),
                            );
                          },
                          child: const Text(
                            "Edit Jadwal",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black87),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
