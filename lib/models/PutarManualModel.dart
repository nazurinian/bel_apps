import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';

class PutarManual {
  bool putar;
  int choice;

  PutarManual({
    required this.putar,
    required this.choice,
  });

  PutarManual.fromSnapshot(DataSnapshot snapshot)
      : putar = (snapshot.value as Map<String, dynamic>)["putar"],
        choice = (snapshot.value as Map<String, dynamic>)["choice"];

  factory PutarManual.fromRawJson(String str) =>
      PutarManual.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PutarManual.fromJson(Map<dynamic, dynamic> json) => PutarManual(
        putar: json["putar"],
        choice: json["choice"],
      );

  Map<String, dynamic> toJson() => {
        "putar": putar,
        "choice": choice,
      };
}
