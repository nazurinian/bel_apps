import 'package:bel_sekolah/utils/time_picker.dart';
import 'package:bel_sekolah/views/serial_bt_page.dart';
import 'package:flutter/material.dart';
import 'package:bel_sekolah/views/bel_firebase_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late int selectedRadio;
  late int selectedRadioTile;

  @override
  void initState() {
    super.initState();
    selectedRadio = 0;
    selectedRadioTile = 0;
  }

  setSelectedRadio(int val) {
    setState(() {
      selectedRadio = val;
    });
  }
  setSelectedRadioTile(int val) {
    setState(() {
      selectedRadioTile = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        centerTitle: true,
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SerialBTPage(),
                      )),
                  child: const Text("Menu Bluetooth"),
                ),
                const SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BelFirebasePage(),
                      )),
                  child: const Text("Edit Jadwal"),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                Waktu.customTime(
                  context,
                  "Testing aja",
                  15,
                  5,
                      (TimeOfDay selectedTime) {
                    print('Selected time: $selectedTime');
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Waktu yang Dipilih'),
                          content: Text(
                            'Jam: ${selectedTime.hour}:${selectedTime.minute}',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
              child: const Text('Pilih Waktu'),
            ),

            RadioListTile(
              value: 1,
              groupValue: selectedRadioTile,
              title: Text("Radio 1"),
              subtitle: Text("Radio 1 Subtitle"),
              onChanged: (val) {
                print("Radio Tile pressed $val");
                setSelectedRadioTile(val!);
              },
              activeColor: Colors.red,
              secondary: TextButton(
                child: Text("Say Hi"),
                onPressed: () {
                  print("Say Hello");
                },
              ),
              selected: true,
            ),
            RadioListTile(
              value: 2,
              groupValue: selectedRadioTile,
              title: Text("Radio 2"),
              subtitle: Text("Radio 2 Subtitle"),
              onChanged: (val) {
                print("Radio Tile pressed $val");
                setSelectedRadioTile(val!);
              },
              activeColor: Colors.red,
              secondary: TextButton(
                child: Text("Say Hi"),
                onPressed: () {
                  print("Say Hello");
                },
              ),
              selected: false,
            ),
            Divider(
              height: 20,
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}
