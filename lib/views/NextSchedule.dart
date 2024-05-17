import 'dart:async';
import 'package:bel_sekolah/utils/DisplaySize.dart';
import 'package:bel_sekolah/utils/Helper.dart';
import 'package:flutter/material.dart';
import 'package:bel_sekolah/themes/colors/Colors.dart';
import 'package:bel_sekolah/models/ScheduleModel.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/TimeNowModel.dart';

class NextSchedule extends StatefulWidget {
  final FirebaseDatabase firebaseDatabase;

  const NextSchedule({super.key, required this.firebaseDatabase});

  @override
  State<NextSchedule> createState() => _NextScheduleState();
}

class _NextScheduleState extends State<NextSchedule> {
  late Timer _timer;
  late CustomTime _currentTime;

  final List<String> jamTitles = [
    "Literasi Pagi",
    "Masuk jam ke-1",
    "Masuk jam ke-2",
    "Masuk jam ke-3",
    "Masuk jam ke-4",
    "Istirahat ke-1",
    "Masuk jam ke-5",
    "Masuk jam ke-6",
    "Masuk jam ke-7",
    "Masuk jam ke-8",
    "Masuk jam ke-9",
    "Masuk jam ke-10",
    "Istirahat ke-2",
    "Masuk jam ke-11",
    "Masuk jam ke-12",
    "Waktu pulang"
  ];

  @override
  void initState() {
    _updateTime();
    getDataRealtime();
    super.initState();
  }

  List<Schedule> schedules = [];
  String hariNormal = "jadwal/senin-kamis";
  String hariJumat = "jadwal/jumat";

  void getDataRealtime() async {
    String dayNameRef = "jadwal/senin-kamis";
    int hariIni = _currentTime.weekday;
    if (hariIni == 5) {
      dayNameRef = hariJumat;
    }

    DatabaseReference ref = widget.firebaseDatabase.ref(dayNameRef);
    Stream<DatabaseEvent> stream = ref.onValue;
    stream.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          schedules.clear();
          for (final data in event.snapshot.children) {
            schedules.add(Schedule.fromJson(data.value as Map));
          }
        });
      }
    }, onError: (error) {
      ToastUtil.showToast(error, ToastStatus.error);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateTime() {
    _currentTime = CustomTime.getCurrentTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = CustomTime.getCurrentTime();
      });
    });
  }

  Widget getScheduleTitle(CustomTime currentTime, List<Schedule> schedule) {
    String belNow = "";

    if (currentTime.weekday >= 1 && currentTime.weekday <= 5) {
      int currentMinutes = currentTime.hours * 60 + currentTime.minutes;

      for (int i = 0; i < schedule.length; i++) {
        int scheduleMinutes = (schedule[i].jam! * 60) + schedule[i].menit!;
        int firstScheduleMinutes = (schedule[0].jam! * 60) + schedule[0].menit!;
        int lastScheduleMinutes = (schedule[15].jam! * 60) + schedule[15].menit!;

        if (currentMinutes < firstScheduleMinutes) {
          belNow = "Belum masuk";
          break;
        } else {
          if (currentMinutes >= lastScheduleMinutes + 60) {
            belNow = "Diluar jadwal";
          } else {
            if (currentMinutes >= scheduleMinutes) {
              belNow = jamTitles[i];
            }
          }
        }
      }
    } else if (currentTime.weekday == 6 || currentTime.weekday == 7) {
      belNow = 'Hari Libur';
    }

    return Text(
      "Saat ini : \n$belNow",
      textAlign: TextAlign.center,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: ColorsTheme.green,
      ),
    );
  }

  Widget nextTimeSchedule(CustomTime currentTime, List<Schedule> schedule) {
    String nextBel = "";

    if (currentTime.weekday >= 1 && currentTime.weekday <= 5) {
      int currentMinutes = currentTime.hours * 60 + currentTime.minutes;

      for (int i = 0; i < schedules.length; i++) {
        int jadwalJam = schedule[i].jam!;
        int jadwalMenit = schedule[i].menit!;

        int scheduleMinutes = jadwalJam * 60 + jadwalMenit;
        int firstScheduleMinutes = (schedule[0].jam! * 60) + schedule[0].menit!;
        int lastScheduleMinutes = (schedule[15].jam! * 60) +
            schedule[15].menit!;

        if (currentMinutes < firstScheduleMinutes) {
          nextBel =
          "${_formathm(schedule[0].jam!)}:${_formathm(schedule[0].menit!)}";
          break;
        } else {
          if (currentMinutes >= lastScheduleMinutes) {
            nextBel = "---";
          } else {
            if (currentMinutes >= scheduleMinutes) {
              nextBel =
              "${_formathm(schedule[i + 1].jam!)}:${_formathm(
                  schedule[i + 1].menit!)}";
            }
          }
        }
      }
    } else if (currentTime.weekday == 6 || currentTime.weekday == 7) {
      nextBel = 'Hari Senin';
    }

    return Text(
      "Next Bel : \n$nextBel",
      textAlign: TextAlign.center,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: ColorsTheme.yellow,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(
              width: screenWidth(context) * 0.3,
              child: getScheduleTitle(_currentTime, schedules)),
          SizedBox(
            width: screenWidth(context) * 0.3,
            child: Text(
              _currentTime.getAllTime(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: ColorsTheme.lightBackground,
              ),
            ),
          ),
          SizedBox(
              width: screenWidth(context) * 0.3,
              child: nextTimeSchedule(_currentTime, schedules)),
        ],
      ),
    );
  }

  String _formathm(int hm) {
    return hm.toString().padLeft(2, '0');
  }
}
