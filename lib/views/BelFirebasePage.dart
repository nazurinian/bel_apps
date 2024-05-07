import 'package:bel_sekolah/models/ScheduleModel.dart';
import 'package:bel_sekolah/utils/NetworkConnectivity.dart';
import 'package:bel_sekolah/utils/DisplaySize.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:bel_sekolah/themes/colors/Colors.dart';
import 'package:bel_sekolah/views/NextSchedule.dart';
import '../utils/TimePicker.dart';

class BelFirebasePage extends StatefulWidget {
  const BelFirebasePage({super.key});

  @override
  State<BelFirebasePage> createState() => _BelFirebasePageState();
}

class _BelFirebasePageState extends State<BelFirebasePage>
    with SingleTickerProviderStateMixin {
  final url =
      "https://bel-sekolah-2-default-rtdb.asia-southeast1.firebasedatabase.app/";
  late FirebaseDatabase database;
  late TabController controller;

  @override
  void initState() {
    database =
        FirebaseDatabase.instanceFor(app: Firebase.app(), databaseURL: url);
    controller = TabController(vsync: this, length: 2);

    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
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
      body: ConnectionChecker(
        connectedWidget: Center(
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.only(
                      top: 16, bottom: 0, left: 16, right: 16),
                  child: TabBarView(
                    controller: controller,
                    children: [
                      Tab1(
                        firebaseDatabase: database,
                      ),
                      Tab2(
                        firebaseDatabase: database,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                width: screenWidth(context),
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(50)),
                    color: ColorsTheme.primaryBrown,
                  ),
                  child: NextSchedule(
                    firebaseDatabase: database,
                  ),
                ),
              ),
            ],
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

class Tab1 extends StatefulWidget {
  final FirebaseDatabase firebaseDatabase;

  const Tab1({super.key, required this.firebaseDatabase});

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
              decoration: TextDecoration.underline,
            ),
          ),
          Expanded(
            child: GetScheduleDatabase(
              scheduleDay: jadwal1,
              firebaseDatabase: widget.firebaseDatabase,
            ),
          ),
        ],
      ),
    );
  }
}

class Tab2 extends StatefulWidget {
  final FirebaseDatabase firebaseDatabase;

  const Tab2({super.key, required this.firebaseDatabase});

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
              decoration: TextDecoration.underline,
            ),
          ),
          Expanded(
            child: GetScheduleDatabase(
              scheduleDay: jadwal2,
              firebaseDatabase: widget.firebaseDatabase,
            ),
          ),
        ],
      ),
    );
  }
}

class GetScheduleDatabase extends StatefulWidget {
  final String scheduleDay;
  final FirebaseDatabase firebaseDatabase;

  const GetScheduleDatabase(
      {super.key, required this.scheduleDay, required this.firebaseDatabase});

  @override
  State<GetScheduleDatabase> createState() => _GetScheduleDatabaseState();
}

class _GetScheduleDatabaseState extends State<GetScheduleDatabase> {
  TimeOfDay? updateTime;
  late int selectedRadioTile;

  void updateScheduleTime(
    int index,
    TimeOfDay? time,
    bool? statusAktif,
    Schedule oldSchedule,
  ) {
    Schedule schedule;

    if (statusAktif != null) {
      schedule = Schedule(
          aktif: statusAktif, jam: oldSchedule.jam, menit: oldSchedule.menit);
    } else {
      schedule = Schedule(
          aktif: oldSchedule.aktif, jam: time!.hour, menit: time.minute);
    }

    Map<String, dynamic> scheduleJson = schedule.toJson();

    widget.firebaseDatabase
        .ref(widget.scheduleDay)
        .child(index.toString())
        .update(scheduleJson)
        .then((_) {
      print('Berhasil memperbarui bel');
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Berhasil memperbarui bel"),
      ));
    }).catchError(
      (error) {
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
      },
    );
  }

  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: FirebaseAnimatedList(
        shrinkWrap: true,
        padding: const EdgeInsets.only(bottom: 60),
        physics: const BouncingScrollPhysics(),
        defaultChild: const Center(child: CircularProgressIndicator()),
        query: widget.firebaseDatabase.ref(widget.scheduleDay),
        itemBuilder: (context, snapshot, animation, index) {
          final json = snapshot.value as Map<dynamic, dynamic>;
          final schedule = Schedule.fromJson(json);

          return listSchedule(schedule: schedule, index: index + 1);
        },
      ),
    );
  }

  Widget listSchedule({required Schedule schedule, required int index}) {
    String aktif = schedule.aktif.toString();
    String jam = schedule.jam.toString().padLeft(2, '0');
    String menit = schedule.menit.toString().padLeft(2, '0');
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
                      TimePicker.customTime(
                        context,
                        jamKe,
                        int.parse(jam),
                        int.parse(menit),
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
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Tidak'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      updateScheduleTime(
                                          index, selectedTime, null, schedule);
                                    },
                                    child: const Text('Ya'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
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
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          bool statusVal = bool.parse(aktif);
                          selectedRadioTile = statusVal ? 1 : 2;
                          return SafeArea(
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
                                          title: const Text("True"),
                                          value: 1,
                                          groupValue: selectedRadioTile,
                                          onChanged: (val) {
                                            print("Radio Tile pressed $val");
                                            setState(() {
                                              selectedRadioTile = val!;
                                            });
                                          }),
                                      RadioListTile(
                                        title: const Text("False"),
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
                                },
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
                                    updateScheduleTime(
                                      index,
                                      null,
                                      selectedRadioTile == 1 ? true : false,
                                      schedule,
                                    );
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
