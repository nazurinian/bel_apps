import 'package:bel_sekolah/models/PutarManualModel.dart';
import 'package:bel_sekolah/utils/Helper.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../utils/NetworkConnectivity.dart';

class PutarManualPage extends StatefulWidget {
  const PutarManualPage({super.key});

  @override
  State<PutarManualPage> createState() => _PutarManualPageState();
}

class _PutarManualPageState extends State<PutarManualPage> {
  DatabaseReference ref =
      FirebaseDatabase.instance.ref('putar-manual/');

  bool _switchValue = false;
  bool _isLoading = true;
  int _counter = 0;

  final TextEditingController _controller = TextEditingController(text: '0');
  final int _minValue = 0;
  final int _maxValue = 6;

  final List<String> pilihan = [
    "Bel literasi pagi",
    "Bel awal masuk jam kelas",
    "Bel diantara jam-jam kelas",
    "Bel istirahat",
    "Bel pulang",
    "Bel 5 menit sebelum masuk"
  ];


  PutarManual? putarManual;

  void getDataRealtime() async {
    Stream<DatabaseEvent> stream = ref.onValue;
    stream.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          putarManual = PutarManual.fromJson(event.snapshot.value as Map);

          _isLoading = false;
          _switchValue = putarManual!.putar;
          _counter = putarManual!.choice;
          _controller.text = '${putarManual!.choice}';
        });
      }
    }, onError: (error) {
      ToastUtil.showToast(error, ToastStatus.error);
    });
  }

  /// TIME OUT UNTUK NGEFALSE IN PUTAR MANUAL, ATUR 5 menit
  // void checkAndResetPutar() async {
  //   await Future.delayed(const Duration(minutes: 5));
  //   bool putar = true;
  //   Stream<DatabaseEvent> stream = ref.child('putar').onValue;
  //   stream.listen((event) {
  //     if (event.snapshot.value != null) {
  //       setState(() {
  //         putar = event.snapshot.value as bool;
  //         print("pemutaran saat ini : $putar");
  //       });
  //     }
  //   });
  //
  //   if (putar == true) {
  //     print('putar has been reset to false');
  //   } else {
  //     print('putar is already false');
  //   }
  // }

  void updateStatusPutarManual(PutarManual manual) {
    Map<String, dynamic> ptrManual = manual.toJson();

    String update = _switchValue ? "mengaktifkan" : "menonaktifkan";
    String errorUpdate = _switchValue ? "mengaktifkan" : "menonaktifkan";

    ref
        .update(ptrManual)
        .then((value) => ToastUtil.showToast("Berhasil $update bel manual" , ToastStatus.success))
        .catchError((error) => ToastUtil.showToast("Gagal $errorUpdate bel manual\ndata: $error", ToastStatus.error));
  }

  void _incrementCounter() {
    setState(() {
      if (_counter < _maxValue) {
        _counter++;
        _controller.text = _counter.toString();
      }
    });
  }

  void _decrementCounter() {
    setState(() {
      if (_counter > _minValue) {
        _counter--;
        _controller.text = _counter.toString();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getDataRealtime();
    // checkAndResetPutar();
  }

  void _onSwitchChanged(bool value) {
    if (_counter > 0) {
      setState(
        () {
          if (value) {
            Text content =
            const Text("Ingin memutar langsung bel saat ini?");
            DialogUtil.showConfirmationDialog(
                context: context,
                title: "Konfirmasi",
                content: content,
                onConfirm: () {
                  setState(() {
                    _switchValue = value; // Mengubah nilai switch
                  });
                  PutarManual manual;
                  manual = PutarManual(putar: value, choice: _counter);
                  // startPlay;
                  updateStatusPutarManual(manual);
                });
          } else {
            Text content =
                const Text("Bel sedang diputar saat ini, ingin menghentikan pemutaran?");
            DialogUtil.showConfirmationDialog(
                context: context,
                title: "Konfirmasi",
                content: content,
                onConfirm: () {
                  setState(() {
                    _counter = 0;
                    _controller.text = '0';
                    _switchValue = value; // Mengubah nilai switch
                  });
                  PutarManual manual;
                  manual = PutarManual(putar: value, choice: _counter);
                  // stopPlay;
                  updateStatusPutarManual(manual);
                });
          }
        },
      );
    } else {
      ToastUtil.showToast("Setidaknya angka harus 1,\ntidak boleh 0 atau kosong", ToastStatus.error);
    }
  }

  void _onTitleTap(int index) {
    setState(() {
      _counter = index;
      _controller.text = _counter.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Putar Manual Bel"),
      ),
      body: ConnectionChecker(
        connectedWidget: Container(
          margin: const EdgeInsets.all(16),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        child: Column(
                          children: [
                            const Padding(
                              padding:
                                  EdgeInsets.only(left: 8, right: 8, top: 16),
                              child: Text(
                                "Pilih Pilihan Putar",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 22,
                                ),
                              ),
                            ),
                            const Divider(
                              thickness: 3,
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              itemCount: pilihan.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  dense: true,
                                  visualDensity:
                                      const VisualDensity(vertical: -4),
                                  // to compact
                                  title: Text(
                                    pilihan[index],
                                    style: TextStyle(
                                      color: _counter == (index + 1)
                                          ? Colors.green
                                          : Colors.black,
                                      fontSize: 14,
                                    ),
                                  ),
                                  leading: Text(
                                    "${index + 1}",
                                    style: TextStyle(
                                      color: _counter == (index + 1)
                                          ? Colors.green
                                          : Colors.black,
                                      fontSize: 14,
                                    ),
                                  ),
                                  // onTap: () => _onTitleTap(index + 1),
                                  onTap: () {},
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children:
                                  List.generate((pilihan.length + 1), (index) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4.0),
                                  child: GestureDetector(
                                    onTap: () =>
                                        _switchValue ? null : _onTitleTap(index),
                                    child: SizedBox(
                                      width: 30,
                                      child: Card(
                                        color: _counter == index
                                            ? Colors.green
                                            : Colors.white24,
                                        child: Text(
                                          '$index',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed:
                                        _switchValue ? null : _decrementCounter,
                                    child: const Text(
                                      '-',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  SizedBox(
                                    width: 50,
                                    child: TextField(
                                      controller: _controller,
                                      keyboardType: TextInputType.number,
                                      enabled: !_switchValue,
                                      onChanged: (text) {
                                        int value = int.tryParse(text) ?? 0;
                                        if (value < _minValue) {
                                          value = _minValue;
                                        } else if (value > _maxValue) {
                                          value = _maxValue;
                                        }
                                        _counter = value;
                                        _controller.text = _counter.toString();
                                        setState(() {});
                                      },
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  ElevatedButton(
                                    onPressed:
                                        _switchValue ? null : _incrementCounter,
                                    child: const Text(
                                      '+',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        height: 16,
                        child: const Divider(
                          thickness: 2,
                        ),
                      ),
                      Card(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 8, right: 8, top: 16),
                              child: Text(
                                "${_switchValue ? "Nonaktifkan" : "Aktifkan"} Pemutaran Bel",
                                style: const TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const Divider(
                              thickness: 3,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Transform.scale(
                                scale: 1.5,
                                child: Switch(
                                  value: _switchValue,
                                  onChanged: _onSwitchChanged,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
        ),
        disconnectedWidget: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.signal_wifi_connected_no_internet_4,
                size: 120.0,
              ),
              Text(
                "'Tidak ada koneksi internet",
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
