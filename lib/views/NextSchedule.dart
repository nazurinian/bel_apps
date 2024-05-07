import 'dart:async';
import 'package:bel_sekolah/colors/colors.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_database/ui/firebase_list.dart';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:bel_sekolah/models/schedule.dart';
import 'package:firebase_database/firebase_database.dart';

import '../utils/TimeNow.dart';

class NextSchedule extends StatefulWidget {
  final FirebaseDatabase firebaseDatabase;

  const NextSchedule({super.key, required this.firebaseDatabase});

  @override
  State<NextSchedule> createState() => _NextScheduleState();
}

class _NextScheduleState extends State<NextSchedule> {
  // late String _timeString;
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
    // getData();
    getDataRealtime();
    _updateTime();
    // _timeString = _formatDateTime(DateTime.now());
    // _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => _getTime());
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
          // var data = event.snapshot.value;
          // for (var i = 1; i < data.length; i++) {
          //   schedules.add(Schedule.fromJson(data[i]));
          // }
          for (final data in event.snapshot.children) {
            schedules.add(Schedule.fromJson(data.value as Map));
          }
        });
      }

      print("ini schedule jal: ${schedules[0].jam}");
      // for (final child in event.snapshot.children) {
      //   // Handle the post.
      //   setState(() {
      //     schedules.clear();
      //     var data = event.snapshot.value;
      //     for (var i = 1; i < data.length; i++) {
      //       schedules.add(Schedule.fromJson(data[i]));
      //     }
      //   });
      // }
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

  // List<Schedule> schedule = [];

  // Future<void> fetchSchedule() async {
  //   try {
  //     List<Schedule> fetchedSchedule = await getSchedule();
  //     setState(() {
  //       schedule = fetchedSchedule;
  //     });
  //   } catch (error) {
  //     print('Error fetching schedule: $error');
  //     // Handle error fetching schedule
  //   }
  // }

  // Future<List<Schedule>> getSchedule() async {
  //   DataSnapshot scheduleSnapshot =
  //       await widget.firebaseDatabase.ref("jadwal/senin-kamis").get();
  //
  //   List<Schedule> fetchedSchedule = [];
  //
  //   if (scheduleSnapshot.value != null &&
  //       scheduleSnapshot.value is List<dynamic>) {
  //     List<dynamic> scheduleData = scheduleSnapshot.value as List<dynamic>;
  //
  //     scheduleData.forEach((value) {
  //       if (value is Map<dynamic, dynamic>) {
  //         // Membuat objek Schedule dari data yang diterima
  //         Schedule schedule = Schedule(
  //           aktif: value['aktif'] ?? false,
  //           jam: value['jam'] ?? 0,
  //           menit: value['menit'] ?? 0,
  //         );
  //         fetchedSchedule.add(schedule);
  //       } else {
  //         print("Invalid schedule data: $value"); // Handle invalid data
  //       }
  //     });
  //   } else {
  //     print("Invalid schedule data"); // Handle invalid data
  //   }
  //
  //   return fetchedSchedule;
  // }

  Widget getScheduleTitle(
      CustomTime currentTime, int nextSchedule, List<Schedule> schedule) {
    String belNow = "Diluar jadwal";
    for (int i = 0; i < schedule.length; i++) {
      int scheduleMinutes = (schedule[i].jam! * 60) + schedule[i].menit!;

      if (currentTime.hours * 60 + currentTime.minutes <= scheduleMinutes) {
        belNow = jamTitles[i + nextSchedule];
      }
    }

    // Jika waktu saat ini setelah semua jadwal, kembalikan pesan di luar jadwal
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

  // String getScheduleTitle(CustomTime currentTime, int nextSchedule, Schedule schedule) {
  //   // Memeriksa jadwal yang sesuai dengan waktu saat ini
  //   for (int i = 0; i < jamTitles.length; i++) {
  //     int scheduleMinutes = (schedule.jam! * 60) + schedule.menit!;
  //
  //     if (currentTime.hours * 60 + currentTime.minutes <= scheduleMinutes) {
  //       return jamTitles[i + nextSchedule];
  //     }
  //   }
  //
  //   // Jika waktu saat ini setelah semua jadwal, kembalikan pesan di luar jadwal
  //   return "Diluar jadwal";
  // }
  //
  // String nextTimeSchedule(CustomTime currentTime, Schedule schedule) {
  //   int currentMinutes = currentTime.hours * 60 + currentTime.minutes;
  //
  //   // Memeriksa jadwal yang sesuai dengan waktu saat ini
  //   for (int i = 0; i < jamTitles.length; i++) {
  //     int jadwalJam = schedule.jam!;
  //     int jadwalMenit = schedule.menit!;
  //
  //     int scheduleMinutes = jadwalJam * 60 + jadwalMenit;
  //
  //     if (currentMinutes <= scheduleMinutes) {
  //       return "Bel : $jadwalJam:$jadwalMenit";
  //     }
  //   }
  //
  //   return "----------------";
  // }
  Map<dynamic, dynamic>? _seninKamisJadwal;

  // void _fetchData() {
  //   widget.firebaseDatabase.ref("jadwal/").child(path)
  //       .once()
  //       .then((DataSnapshot snapshot) {
  //     if (snapshot.value != null) {
  //       setState(() {
  //         _isLoading = false;
  //         _seninKamisJadwal = snapshot.value;
  //       });
  //     }
  //   }).catchError((error) {
  //     print("Failed to fetch data: $error");
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(
            _currentTime.getAllTime(),
            textAlign: TextAlign.center,
            style: TextStyle(
                fontWeight: FontWeight.bold, color: ColorsTheme.lightBackground),
          ),
          getScheduleTitle(_currentTime, 0, schedules),
          nextTimeSchedule(_currentTime, schedules),
        ],
      ),
    );
    // return FirebaseList(query: query);
    // return FirebaseAnimatedList(
    //   shrinkWrap: true,
    //   physics: const BouncingScrollPhysics(),
    //   defaultChild: const Center(child: CircularProgressIndicator()),
    //   query: widget.firebaseDatabase.ref("jadwal/senin-kamis"),
    //   itemBuilder: (context, snapshot, animation, index) {
    //     final json = snapshot.value as Map<dynamic, dynamic>;
    //     final schedule = Schedule.fromJson(json);

    // if (index >= 0 && index <= 15) {
    //   return Column(
    //     children: [
    //       Center(
    //         child: Text(
    //           _currentTime.getAllTime(),
    //           textAlign: TextAlign.center,
    //           style: TextStyle(
    //               fontWeight: FontWeight.bold,
    //               color: ColorsTheme.lightBackground),
    //         ),
    //       ),
    //       Text(nextTimeSchedule(_currentTime, schedule)),
    //       Text(getScheduleTitle(_currentTime, 0, schedule)),
    //       // const Text(
    //       //     "STATIC ITEM TO DISPLAY ON TOP AS A HEADER FOR BELOW FIREBAE LIST"),
    //     ],
    //   );
    // } else {
    //       return Column(
    //         children: [
    //           nextTimeSchedule(_currentTime, schedule),
    //           getScheduleTitle(_currentTime, 0, schedule),
    //         ],
    //       );
    //     // }
    //   },
    // );
    // if (schedule.jam == 8 && schedule.menit == 0) {
    //   return Text("schedule.jam.toString()");
    // } else {
    //   return Text("Tai");
    // }
    // });

    ///Ini pake futureBuilder
    // return Center(
    //   child: Column(
    //     mainAxisAlignment: MainAxisAlignment.center,
    //     children: [
    //       Text(
    //         _timeString,
    //         textAlign: TextAlign.center,
    //         style: TextStyle(
    //           fontWeight: FontWeight.bold,
    //           color: Colors.black, // Assuming your theme uses black text color
    //         ),
    //       ),
    //       SizedBox(height: 20),
    //       // Gunakan FutureBuilder untuk menampilkan data jadwal
    //       FutureBuilder<List<Schedule>>(
    //         future: getSchedule(),
    //         builder: (context, snapshot) {
    //           if (snapshot.connectionState == ConnectionState.waiting) {
    //             return CircularProgressIndicator(); // Tampilkan indikator loading jika data sedang dimuat
    //           } else if (snapshot.hasError) {
    //             return Text('Error: ${snapshot.error}'); // Tampilkan pesan error jika ada kesalahan
    //           } else {
    //             // Tampilkan daftar jadwal jika data tersedia
    //             return ListView.builder(
    //               shrinkWrap: true,
    //               itemCount: 1,
    //               itemBuilder: (context, index) {
    //                 return ListTile(
    //                   title: Text(jamTitles[7]), // Menggunakan judul waktu yang telah ditentukan
    //                   subtitle: Text(snapshot.data![7].jam.toString()), // Menggunakan deskripsi dari objek Schedule
    //                 );
    //               },
    //             );
    //           }
    //         },
    //       ),
    //     ],
    //   ),
    // );

    /// ini langsung tanpa data
    // return Center(child:
    //           Text(
    //             _timeString,
    //             textAlign: TextAlign.center,
    //             style: TextStyle(
    //                 fontWeight: FontWeight.bold,
    //                 color: ColorsTheme.lightBackground),
    //           ),);
    // database.onValue.listen((database) {
    //   setState(() {
    //     _isLoading = false;
    //     _data = database.snapshot.value as Map<dynamic, dynamic>?;
    //   });
    // });

    /// ini pake animatedList
    // return FirebaseAnimatedList(
    //     shrinkWrap: true,
    //     padding: const EdgeInsets.only(bottom: 60),
    //     physics: const BouncingScrollPhysics(),
    //     defaultChild: const Center(child: CircularProgressIndicator()),
    //     query: widget.firebaseDatabase.ref("jadwal/senin-kamis"),
    //     itemBuilder: (context, snapshot, animation, index) {
    //       _data = snapshot.value as Map<dynamic, dynamic>;
    //       _data!.forEach((key, value) {
    //         if (value['jam'] == 8) {
    //           return Text("8");
    //         } else{
    //           return Text("0")
    //         }
    //       });
    // if (schedule.jam == 8 && schedule.menit == 0) {
    //   return Text("schedule.jam.toString()");
    // } else {
    //   return Text("Tai");
    // }
    // });

    /// ini pake streamBuilder
    //   StreamBuilder(
    //   stream: widget.firebaseDatabase.ref("jadwal/senin-kamis").onValue,
    //   builder: (context, snapshot) {
    //     if (snapshot.connectionState == ConnectionState.waiting) {
    //       return const Center(child: CircularProgressIndicator());
    //     }
    //     if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
    //       return const Center(child: Text('No data found!'));
    //     }
    //     var data = snapshot.data!.snapshot.value;
    //     // Lakukan iterasi pada data
    //     if (data is Map) {
    //       bool found = false;
    //       data.forEach((key, value) {
    //         if (value['jam'] == 8 && value['menit'] == 0) {
    //           found = true;
    //           // Lakukan sesuatu jika ditemukan kesamaan data
    //         }
    //       });
    //       if (!found) {
    //         return const Center(child: Text('Data tidak ditemukan!'));
    //       }
    //     }
    //     if (snapshot.hasData) {
    //       return Center(child:
    //       Text(
    //         _timeString,
    //         textAlign: TextAlign.center,
    //         style: TextStyle(
    //             fontWeight: FontWeight.bold,
    //             color: ColorsTheme.lightBackground),
    //       ),);
    //     }
    //     return CircularProgressIndicator();
    //   },
    // );

    // return Center(child:
    //           Text(
    //             _timeString,
    //             textAlign: TextAlign.center,
    //             style: TextStyle(
    //                 fontWeight: FontWeight.bold,
    //                 color: ColorsTheme.lightBackground),
    //           ),);
  }

  /// untuk mengambil waktu saat ini
// void _getTime() {
//   final DateTime now = DateTime.now();
//   final String formattedDateTime = _formatDateTime(now);
//   setState(() {
//     _timeString = formattedDateTime;
//   });
// }

// String _formatDateTime(DateTime dateTime) {
//   return DateFormat('EEEE, MM-dd-yyyy \nHH:mm:ss', 'id_ID').format(dateTime);
// }
}
