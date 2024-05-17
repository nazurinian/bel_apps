import 'package:bel_sekolah/utils/Helper.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PutarManualPage extends StatefulWidget {
  const PutarManualPage({super.key});

  @override
  State<PutarManualPage> createState() => _PutarManualPageState();
}

class _PutarManualPageState extends State<PutarManualPage> {
  DatabaseReference putar =
      FirebaseDatabase.instance.ref('putar-manual/').child('putar');
  DatabaseReference choice =
      FirebaseDatabase.instance.ref('putar-manual/').child('choice');

  bool _switchValue = false;
  bool _isLoading = true;

  int _counter = 0;

  // bool _isSwitchOn = false;
  TextEditingController _controller = TextEditingController(text: '0');
  final int _minValue = 0;
  final int _maxValue = 6;

  final List<String> pilihan = [
    "Amelia",
    "Bernadette",
    "Caroline",
    "Dorothy",
    "Emily",
    "Felicity"
  ];

  void getDataRealtime() async {
    Stream<DatabaseEvent> streamPutar = putar.onValue;
    streamPutar.listen((event) {
      if (event.snapshot.value != null) {
        // print(event.snapshot.value);
        setState(() {
          _isLoading = false;
          _switchValue = event.snapshot.value as bool;
        });
      }
    }, onError: (error) {
      // Fluttertoast.showToast(msg: error, toastLength: Toast.LENGTH_SHORT);
      ToastUtil.showToast(error, ToastStatus.error);
    });

    Stream<DatabaseEvent> streamChoice = choice.onValue;
    streamChoice.listen((event) {
      if (event.snapshot.value != null) {
        // print(event.snapshot.value);
        setState(() {
          int val = event.snapshot.value as int;
          _counter = val;
          _controller.text = '$val';
        });
      }
    }, onError: (error) {
      // Fluttertoast.showToast(msg: error, toastLength: Toast.LENGTH_SHORT);
      ToastUtil.showToast(error, ToastStatus.error);
    });
  }

  void updateStatusPutarManual(bool newValue, int resetChoice) {
    putar
        .set(newValue)
        .then((value) => ToastUtil.showToast("Data berhasil diupdate", ToastStatus.success))
        // .then((value) => print("Data berhasil diupdate"))
        .catchError((error) => ToastUtil.showToast("Gagal mengupdate data: \n$error", ToastStatus.error));
        // .catchError((error) => print("Gagal mengupdate data: \n$error"));
    choice
        .set(resetChoice)
        .then((value) => ToastUtil.showToast("Data berhasil diupdate", ToastStatus.success))
        // .then((value) => print("Data berhasil diupdate"))
        .catchError((error) => ToastUtil.showToast("Gagal mengupdate data: \n$error", ToastStatus.error));
        // .catchError((error) => print("Gagal mengupdate data: \n$error"));
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
  }

  void _onSwitchChanged(bool value) {
    if (_counter > 0) {
      setState(
        () {
          if (value) {
            String msg = "Ingin memutar langsung bel saat ini?";
            DialogUtil.showConfirmationDialog(
                context: context,
                title: "Konfirmasi",
                content: msg,
                onConfirm: () {
                  setState(() {
                    _switchValue = value; // Mengubah nilai switch
                  });
                  // startPlay();
                  updateStatusPutarManual(value, _counter);
                  // print("on value : $value");
                  // print("on counter : $_counter");
                  // Navigator.of(context).pop();
                });
          } else {
            String msg =
                "Bel sedang diputar saat ini, ingin menghentikan pemutaran?";
            DialogUtil.showConfirmationDialog(
                context: context,
                title: "Konfirmasi",
                content: msg,
                onConfirm: () {
                  setState(() {
                    _counter = 0;
                    _controller.text = '0';
                    _switchValue = value; // Mengubah nilai switch
                  });
                  // stopPlay();
                  updateStatusPutarManual(value, _counter);
                  // print("off value : $value");
                  // print("off counter : $_counter");
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
      body: Container(
        margin: const EdgeInsets.all(8),
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
                                    fontSize: 18,
                                  ),
                                ),
                                leading: Text(
                                  "${index + 1}",
                                  style: TextStyle(
                                    color: _counter == (index + 1)
                                        ? Colors.green
                                        : Colors.black,
                                    fontSize: 18,
                                  ),
                                ),
                                // onTap: () => _onTitleTap(index + 1),
                                onTap: () {},
                              );
                            },
                          ),
                          const SizedBox(height: 16),
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
    );
  }
}
