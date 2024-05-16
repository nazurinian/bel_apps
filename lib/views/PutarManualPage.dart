import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PutarManualPage extends StatefulWidget {
  const PutarManualPage({super.key});

  @override
  State<PutarManualPage> createState() => _PutarManualPageState();
}

class _PutarManualPageState extends State<PutarManualPage> {
  DatabaseReference ref =
      FirebaseDatabase.instance.ref('putar-manual/').child('putar');
  bool _switchValue = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    getDataRealtime();
  }

  void getDataRealtime() async {
    // DatabaseReference ref = FirebaseDatabase.instance.ref("putar-manual/eputar");
    Stream<DatabaseEvent> stream = ref.onValue;
    stream.listen((event) {
      if (event.snapshot.value != null) {
        print(event.snapshot.value);
        setState(() {
          _isLoading = false;
          _switchValue = event.snapshot.value as bool;
        });
      }
    }, onError: (error) {
      Fluttertoast.showToast(msg: error, toastLength: Toast.LENGTH_SHORT);
    });
  }

  void updateStatusPutarManual(bool newValue) {
    ref
        .set(newValue)
        .then((value) => print("Data berhasil diupdate"))
        .catchError((error) => print("Gagal mengupdate data: $error"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Putar Manual Bel"),
      ),
      body: Container(
        alignment: Alignment.center,
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Putar Bel Manual",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Transform.scale(
                    scale: 2.0,
                    child: Switch(
                      value: _switchValue,
                      onChanged: (value) {
                        setState(
                          () {
                            if (value) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Konfirmasi'),
                                    content: const Text(
                                        'Ingin memutar langsung bel saat ini?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Tidak'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            _switchValue =
                                                value; // Mengubah nilai switch
                                          });
                                          // startPlay();
                                          updateStatusPutarManual(true);
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Ya'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            } else {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Konfirmasi'),
                                    content: const Text(
                                        'Bel sedang diputar saat ini, ingin menghentikan pemutaran?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Tidak'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            _switchValue =
                                                value; // Mengubah nilai switch
                                          });
                                          // stopPlay();
                                          updateStatusPutarManual(false);
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Ya'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
