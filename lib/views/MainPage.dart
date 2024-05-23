import 'package:bel_sekolah/views/PutarManualPage.dart';
import 'package:bel_sekolah/views/WebServerPage.dart';
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
  bool isBelManualPressed = false;

  void allButtonAreValse() {
    isBluetoothPressed = false;
    isJadwalPressed = false;
    isBelManualPressed = false;
  }

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
                          isBelManualPressed = false;
                        });
                      },
                      onTapUp: (_) {
                        setState(() {
                          allButtonAreValse();
                        });
                      },
                      onTapCancel: () {
                        setState(() {
                          allButtonAreValse();
                        });
                      },
                      child: AnimatedContainer(
                        height: isBluetoothPressed
                            ? 250
                            : (isJadwalPressed || isBelManualPressed
                                ? 50
                                : 100),
                        width: isBluetoothPressed
                            ? 170
                            : (isJadwalPressed || isBelManualPressed
                                ? 120
                                : 150),
                        duration: const Duration(milliseconds: 300),
                        child: OutlinedButton(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            )),
                            side: MaterialStateProperty.all(
                                const BorderSide(color: Colors.redAccent)),
                            overlayColor:
                                MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                                if (states.contains(MaterialState.pressed)) {
                                  return Colors.redAccent.withOpacity(0.2);
                                }
                                return Colors.white;
                              },
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const WebServerPage(), // const BTSerialPage(),
                              ),
                            );
                          },
                          child: const Text(
                            "AP Mode", // "Menu Bluetooth",
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
                          isBelManualPressed = false;
                        });
                      },
                      onTapUp: (_) {
                        setState(() {
                          allButtonAreValse();
                        });
                      },
                      onTapCancel: () {
                        setState(() {
                          allButtonAreValse();
                        });
                      },
                      child: AnimatedContainer(
                        height: isJadwalPressed
                            ? 250
                            : (isBluetoothPressed || isBelManualPressed
                                ? 50
                                : 100),
                        width: isJadwalPressed
                            ? 170
                            : (isBluetoothPressed || isBelManualPressed
                                ? 120
                                : 150),
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
                                  return Colors.green.withOpacity(0.2);
                                }
                                return Colors.white;
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
                const SizedBox(height: 10),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   crossAxisAlignment: CrossAxisAlignment.center,
                //   children: [
                    GestureDetector(
                      onTapDown: (_) {
                        setState(() {
                          isBelManualPressed = true;
                          isJadwalPressed = false;
                          isBluetoothPressed = false;
                        });
                      },
                      onTapUp: (_) {
                        setState(() {
                          allButtonAreValse();
                        });
                      },
                      onTapCancel: () {
                        setState(() {
                          allButtonAreValse();
                        });
                      },
                      child: AnimatedContainer(
                        height: isBelManualPressed
                            ? 250
                            : ((isBluetoothPressed || isJadwalPressed) ? 50 : 100),
                        width: isBelManualPressed
                            ? 170
                            : ((isBluetoothPressed || isJadwalPressed) ? 120 : 150),
                        duration: const Duration(milliseconds: 300),
                        child: OutlinedButton(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            )),
                            side: MaterialStateProperty.all(
                                const BorderSide(color: Colors.blueAccent)),
                            overlayColor: MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                                if (states.contains(MaterialState.pressed)) {
                                  return Colors.blueAccent.withOpacity(0.2);
                                }
                                return Colors.white;
                              },
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PutarManualPage(),
                              ),
                            );
                          },
                          child: const Text(
                            "Putar manual",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black87),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // GestureDetector(
                    //   // onTapDown: (_) {
                    //   //   setState(() {
                    //   //     isBelManualPressed = true;
                    //   //     isJadwalPressed = false;
                    //   //     isBluetoothPressed = false;
                    //   //   });
                    //   // },
                    //   // onTapUp: (_) {
                    //   //   setState(() {
                    //   //     allButtonAreValse();
                    //   //   });
                    //   // },
                    //   // onTapCancel: () {
                    //   //   setState(() {
                    //   //     allButtonAreValse();
                    //   //   });
                    //   // },
                    //   child: AnimatedContainer(
                    //     // height: isBelManualPressed
                    //     //     ? 250
                    //     //     : ((isBluetoothPressed || isJadwalPressed) ? 50 : 100),
                    //     // width: isBelManualPressed
                    //     //     ? 170
                    //     //     : ((isBluetoothPressed || isJadwalPressed) ? 120 : 150),
                    //     height: 100,
                    //     width: 150,
                    //     duration: const Duration(milliseconds: 300),
                    //     child: OutlinedButton(
                    //       style: ButtonStyle(
                    //         shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    //           borderRadius: BorderRadius.circular(10),
                    //         )),
                    //         side: MaterialStateProperty.all(
                    //             const BorderSide(color: Colors.blueAccent)),
                    //         overlayColor: MaterialStateProperty.resolveWith<Color>(
                    //               (Set<MaterialState> states) {
                    //             if (states.contains(MaterialState.pressed)) {
                    //               return Colors.blueAccent.withOpacity(0.2);
                    //             }
                    //             return Colors.white;
                    //           },
                    //         ),
                    //       ),
                    //       onPressed: () {
                    //         Navigator.push(
                    //           context,
                    //           MaterialPageRoute(
                    //             builder: (context) => const WebServerPage(),
                    //           ),
                    //         );
                    //       },
                    //       child: const Text(
                    //         "AP Mode",
                    //         textAlign: TextAlign.center,
                    //         style: TextStyle(color: Colors.black87),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                //   ],
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
