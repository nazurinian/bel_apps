import 'dart:async';
import 'package:bel_sekolah/colors/colors.dart';
import 'package:bel_sekolah/utils/network_connectivity.dart';
import 'package:bel_sekolah/utils/size.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import '../utils/time_picker.dart';

class BelFirebasePage extends StatefulWidget {
  const BelFirebasePage({super.key});

  @override
  State<BelFirebasePage> createState() => _BelFirebasePageState();
}

class _BelFirebasePageState extends State<BelFirebasePage>
    with SingleTickerProviderStateMixin {
  late String _timeString;
  late TabController controller;
  Timer? _timer;

  @override
  void initState() {
    controller = TabController(vsync: this, length: 2);

    _timeString = _formatDateTime(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => _getTime());

    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    _timer?.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Jadwal Bel"),
        bottom: TabBar(
          controller: controller,
          tabs: const [
            Tab(
              icon: Icon(Icons.ac_unit),
              text: "Senin-Kamis",
            ),
            Tab(
              icon: Icon(Icons.access_alarm),
              text: "Jumat",
            ),
          ],
        ),
      ),
      body:
    ConnectionChecker(
        connectedWidget:
    Center(
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                right: 0,
                // height: screenHeight(context) - appBarHeight(context) - statusBarHeight(context),
                // width: screenWidth(context),
                child: Container(
                    padding: const EdgeInsets.only(
                        top: 16, bottom: 0, left: 16, right: 16),
                    child: TabBarView(
                      controller: controller,
                      children: const [
                        Tab1(),
                        Tab2(),
                      ],
                    )),
              ),
              Positioned(
                // height: 0,
                width: screenWidth(context),
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(50)),
                    color: ColorsTheme.primaryBrown,
                  ),
                  child: Text(
                    _timeString,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: ColorsTheme.lightBackground),
                  ),
                ),
              ),
            ],
          ),
        ),
        disconnectedWidget: const Center(
          child: Text('Tidak ada koneksi'), // Ganti pake icon
        ),
      ),
    );
  }

  void _getTime() {
    final DateTime now = DateTime.now();
    final String formattedDateTime = _formatDateTime(now);
    setState(() {
      _timeString = formattedDateTime;
    });
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('EEEE, MM-dd-yyyy \nHH:mm:ss', 'id_ID').format(dateTime);
  }
}

class Tab1 extends StatefulWidget {
  const Tab1({super.key});

  @override
  State<Tab1> createState() => _Tab1State();
}

class _Tab1State extends State<Tab1> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final jadwal1 = "jadwal/senin-kamis";

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      child: Column(
        children: [
          const Text(
            "Jadwal Senin-Kamis",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                decorationThickness: 2,
                decoration: TextDecoration.underline),
          ),
          Expanded(
            // child: _buildScheduleColumn(jadwal1),
            child: GetScheduleDatabase(scheduleDay: jadwal1),
          )
        ],
      ),
    );
  }
}

class Tab2 extends StatefulWidget {
  const Tab2({super.key});

  @override
  State<Tab2> createState() => _Tab2State();
}

class _Tab2State extends State<Tab2> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final jadwal2 = "jadwal/jumat";

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      child: Column(
        children: [
          const Text(
            "Jadwal Jum'at",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                decorationThickness: 2,
                decoration: TextDecoration.underline),
          ),
          Expanded(
            child: GetScheduleDatabase(scheduleDay: jadwal2),
          )
        ],
      ),
    );
  }
}

class GetScheduleDatabase extends StatefulWidget {
  final String scheduleDay;

  const GetScheduleDatabase({super.key, required this.scheduleDay});

  @override
  State<GetScheduleDatabase> createState() => _GetScheduleDatabaseState();
}

class _GetScheduleDatabaseState extends State<GetScheduleDatabase> {
  final url =
      "https://bel-sekolah-2-default-rtdb.asia-southeast1.firebasedatabase.app/";

  late FirebaseDatabase database;
  TimeOfDay? updateTime;
  late int selectedRadioTile;

  @override
  void initState() {
    database =
        FirebaseDatabase.instanceFor(app: Firebase.app(), databaseURL: url);
    super.initState();
  }

  void updateScheduleTime(int index, TimeOfDay? time, bool? statusAktif) {
    Map<String, String> schedule = {};

    if (statusAktif != null) {
      schedule['aktif'] = statusAktif.toString();
    } else {
      schedule['jam'] = time!.hour.toString();
      schedule['menit'] = time!.minute.toString();
    }

    database
        .ref(widget.scheduleDay)
        .child(index.toString())
        .update(schedule)
        .then((_) {
      print('Berhasil memperbarui bel');
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Berhasil memperbarui bel"),
      ));
    }).catchError((error) {
      print('Error: $error');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            title: const Text('Error'),
            content: Text('Terjadi kesalahan saat memperbarui bel: $error'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    });
  }

  Widget build(BuildContext context) {
    return Container(
      // padding: EdgeInsets.only(bottom: 100),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        // color: ColorsTheme.gray
/*        color: Colors.blue,
        border: Border.all(
          color: Colors.black,
          width: 1.0,
        ),*/
      ),
      child: FirebaseAnimatedList(
        shrinkWrap: true,
        padding: const EdgeInsets.only(bottom: 60),
        physics: const BouncingScrollPhysics(),
        defaultChild: const Center(child: CircularProgressIndicator()),
        query: database.ref(widget.scheduleDay),
        itemBuilder: (context, snapshot, animation, index) {
          Map schedule = snapshot.value as Map;
          schedule['key'] = snapshot.key;
          return listSchedule(schedule: schedule, index: index + 1);
        },
      ),
    );
  }

  Widget listSchedule({required Map schedule, required int index}) {
    String aktif = schedule['aktif'].toString();
    String jam = schedule['jam'].toString().padLeft(2, '0');
    String menit = schedule['menit'].toString().padLeft(2, '0');
    String jamKe = jamEditTitle(index.toString());

    return Card(
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.all(8),
            child: Text(
              jamKe,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Waktu.customTime(
                          context, jamKe, int.parse(jam), int.parse(menit),
                          (TimeOfDay selectedTime) {
                        print('Selected time: $selectedTime');
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              scrollable: true,
                              title: const Text('Waktu yang Dipilih'),
                              content: Text(
                                'Jam: ${_formathm(selectedTime.hour)}:${_formathm(selectedTime.minute)}',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    updateScheduleTime(
                                        index, selectedTime, null);
                                  },
                                  child: const Text('Ya'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Tidak'),
                                ),
                              ],
                            );
                          },
                        );
                      });
                    },
                    child: Card(
                      margin: const EdgeInsets.all(4),
                      elevation: 2,
                      child: Container(
                        height: 50,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text("Jam : $jam"),
                            Text("Menit : $menit"),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child:
                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          // return
                          // int selectedValue = statusVal ? 1 : 2;
                          // selectedValue= statusVal ? 1 : 2;
                          bool statusVal = bool.parse(aktif);
                          selectedRadioTile = statusVal ? 1 : 2;
                          return SafeArea(
                            // child: Theme(
                            // data: ThemeData.light().copyWith(
                            //   dividerColor: ColorsTheme.gray,
                            //   textTheme: TextTheme(
                            //     bodyText2: TextStyle(color: ColorsTheme.black),
                            //   ),
                            //   colorScheme: ColorScheme.fromSwatch().copyWith(
                            //     primary: ColorsTheme.orange,
                            //     onSurface: ColorsTheme.black,
                            //     onPrimary: ColorsTheme.orange,
                            //   ),
                            // ),
                            child: AlertDialog(
                              scrollable: true,
                              title: const Text("Status bel"),
                              content: StatefulBuilder(
                                builder: (context, setState) {
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "($jamKe)",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14),
                                      ),
                                      RadioListTile(
                                        title: Text("True"),
                                        value: 1,
                                        groupValue: selectedRadioTile,
                                        onChanged: (val) {
                                            print("Radio Tile pressed $val");
                                            // setSelectedRadioTile(val!);
                                            setState(() {
                                              selectedRadioTile = val!;
                                            });
                                        }
                                      ),
                                      RadioListTile(
                                        title: Text("False"),
                                        value: 2,
                                        groupValue: selectedRadioTile,
                                        onChanged: (val) {
                                          print("Radio Tile pressed $val");
                                          // setSelectedRadioTile(val!);
                                          setState(() {
                                            selectedRadioTile = val!;
                                          });
                                        },
                                        selected: false,
                                      ),
                                    ],
                                  );
                                }
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Tidak'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    updateScheduleTime(index, null, selectedRadioTile == 1 ? true : false);
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                      content: Text(
                                          "Berhasil mengubah status bel"),
                                    ));
                                  },
                                  child: const Text('Ya'),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: Card(
                      color: bool.parse(aktif)
                          ? Colors.blueAccent
                          : Colors.redAccent,
                      margin: const EdgeInsets.all(4),
                      elevation: 2,
                      child: Container(
                        width: 100,
                        height: 50,
                        alignment: Alignment.center,
                        child: Text("Aktif : $aktif"),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formathm(int hm) {
    return hm.toString().padLeft(2, '0');
  }

  String jamEditTitle(String jamKe) {
    switch (jamKe) {
      case '1':
        return "Literasi Pagi";
      case '2' || '3' || '4' || '5':
        return "Masuk jam kelas ke-${int.parse(jamKe) - 1}";
      case '7' || '8' || '9' || '10' || '11' || '12':
        return "Masuk jam kelas ke-${int.parse(jamKe) - 2}";
      case '14' || '15':
        return "Masuk jam kelas ke-${int.parse(jamKe) - 3}";
      case '6':
        return "Jam istirahat ke-1";
      case '13':
        return "Jam istirahat ke-2";
      case '16':
        return "Jam pulang";
      default:
        return "Waktu tidak valid";
    }
  }
}