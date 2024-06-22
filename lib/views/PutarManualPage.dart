import 'package:bel_sekolah/models/PutarManualModel.dart';
import 'package:bel_sekolah/themes/colors/Colors.dart';
import 'package:bel_sekolah/themes/fonts/Fonts.dart';
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
  DatabaseReference ref = FirebaseDatabase.instance.ref('putar-manual/');

  bool _switchValue = false;
  bool _isLoading = true;
  int _counter = 0;

  final TextEditingController _controller = TextEditingController(text: '0');
  final int _minValue = 0;
  final int _maxValue = 7;

  final List<String> pilihan = [
    "Bel Literasi Pagi",
    "Bel Awal Masuk Jam Kelas",
    "Bel Pergantian Jam Kelas",
    "Audio 5 Menit Sebelum Bel",
    "Bel Istirahat",
    "Bel Pulang",
    "Alarm Keadaan Darurat"
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
  /// (DiGANTI LANGSUNG DARI ESP32 NYA)
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

    String update = _switchValue ? "Menjalankan" : "Menghentikan";
    String errorUpdate = _switchValue ? "Menjalankan" : "Menghentikan";

    ref
        .update(ptrManual)
        .then((value) => ToastUtil.showToast(
            "Berhasil $update Pemutaran Bel/Audio", ToastStatus.success))
        .catchError((error) => ToastUtil.showToast(
            "Gagal $errorUpdate Pemutaran Bel/Audio\ndata: $error", ToastStatus.error));
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
            Text content = Text("Putar Bel/Audio sekarang?\n(${pilihan[_counter-1]})", style: FontTheme.normal14Bold(color: Colors.black),);
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
            Text content = Text(
                "Bel/Audio sedang diputar saat ini.\nHentikan pemutaran?", style: FontTheme.normal14Bold(color: Colors.black),);
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
      ToastUtil.showToast(
          "Setidaknya angka harus 1,\ntidak boleh 0 atau kosong",
          ToastStatus.error);
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
        title: const Text("Putar Manual Bel/Audio",
          style: TextStyle(fontWeight: FontWeight.bold),),
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
                                return Card(
                                  clipBehavior: Clip.antiAlias,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  color: _counter == index + 1
                                      ? Colors.green
                                      : Colors.white24,
                                  child: ListTile(
                                    dense: true,
                                    splashColor: ColorsTheme.lightBackground2,
                                    visualDensity:
                                        const VisualDensity(vertical: -4),
                                    // to compact
                                    title: Text(
                                      pilihan[index],
                                      style: TextStyle(
                                        color: _counter == (index + 1)
                                            ? Colors.white
                                            : Colors.black,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
                                    leading: Text(
                                      "${index + 1}",
                                      style: TextStyle(
                                        color: _counter == (index + 1)
                                            ? Colors.white
                                            : Colors.black,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
                                    // onTap: () => _onTitleTap(index + 1),
                                    // onTap: () {},
                                    onTap: () => _switchValue
                                        ? null
                                        : _onTitleTap(index + 1),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children:
                                  List.generate((pilihan.length + 1), (index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0),
                                  child: GestureDetector(
                                    onTap: () => _switchValue
                                        ? null
                                        : _onTitleTap(index),
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
                                            fontWeight: FontWeight.bold
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
                                      style: FontTheme.normal14Bold(color: Colors.black),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  ElevatedButton(
                                    onPressed:
                                        _switchValue ? null : _incrementCounter,
                                    child: const Text(
                                      '+',
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                                "${_switchValue ? "Hentikan" : "Jalankan"} Pemutaran",
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
