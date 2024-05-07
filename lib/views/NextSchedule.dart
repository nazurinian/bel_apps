import 'dart:async';
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

  Map<dynamic, dynamic>? _data;
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
    "Masuk jam ke-11",
    "Masuk jam ke-12",
    "Istirahat ke-2",
    "Waktu pulang"
  ];

  @override
  void initState() {
    getDataRealtime();
    _updateTime();
    super.initState();
  }

  void getData() async {
    DatabaseReference ref = widget.firebaseDatabase.ref("jadwal/senin-kamis");
    DatabaseEvent event = await ref.once();
    print(event.snapshot.value);
  }

  List<Schedule> schedules = [];

  void getDataRealtime() async {
    DatabaseReference ref = widget.firebaseDatabase.ref("jadwal/senin-kamis");
    Stream<DatabaseEvent> stream = ref.onValue;
    stream.listen((event) {
      print(event.snapshot.value);
      if (event.snapshot.value != null) {
        setState(() {
          schedules.clear();
          for (final data in event.snapshot.children) {
            schedules.add(Schedule.fromJson(data.value as Map));
          }
        });
      }

      print("ini schedule jal: ${schedules[0].jam}");
    }, onError: (error) {
      print("error ambil data : $error");
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

  Widget getScheduleTitle(
      CustomTime currentTime, int nextSchedule, List<Schedule> schedule) {
    String belNow = "Diluar jadwal";
    for (int i = 0; i < schedule.length; i++) {
      int scheduleMinutes = (schedule[i].jam! * 60) + schedule[i].menit!;

      if (currentTime.hours * 60 + currentTime.minutes <= scheduleMinutes) {
        belNow = jamTitles[i + nextSchedule];
      }
    }

    return Text(belNow);
  }

  Widget nextTimeSchedule(CustomTime currentTime, List<Schedule> schedule) {
    int currentMinutes = currentTime.hours * 60 + currentTime.minutes;

    String nextBel = "----------------";

    for (int i = 0; i < schedules.length; i++) {
      int jadwalJam = schedule[i].jam!;
      int jadwalMenit = schedule[i].menit!;

      int scheduleMinutes = jadwalJam * 60 + jadwalMenit;

      if (currentMinutes <= scheduleMinutes) {
        nextBel = "Bel : $jadwalJam:$jadwalMenit";
      }
    }

    return Text(nextBel);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(
            _currentTime.getAllTime(),
            textAlign: TextAlign.center,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: ColorsTheme.lightBackground),
          ),
          getScheduleTitle(_currentTime, 0, schedules),
          nextTimeSchedule(_currentTime, schedules),
        ],
      ),
    );
  }
}
