import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';

class Schedule {
  bool? aktif;
  int? jam;
  int? menit;

  Schedule({
    this.aktif,
    this.jam,
    this.menit,
  });

  Schedule.fromSnapshot(DataSnapshot snapshot) :
        aktif = (snapshot.value as Map<String, dynamic>)["aktif"],
        jam = (snapshot.value as Map<String, dynamic>)["jam"],
        menit = (snapshot.value as Map<String, dynamic>)["menit"];

  factory Schedule.fromRawJson(String str) => Schedule.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Schedule.fromJson(Map<dynamic, dynamic> json) => Schedule(
    aktif: json["aktif"],
    jam: json["jam"],
    menit: json["menit"],
  );

  Map<String, dynamic> toJson() => {
    "aktif": aktif,
    "jam": jam,
    "menit": menit,
  };
}
