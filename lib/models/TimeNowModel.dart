import 'package:intl/intl.dart';

class CustomTime {
  late int year;
  late int month;
  late int day;
  late int hours;
  late int minutes;
  late int seconds;
  late int weekday;
  late String dayName;

  CustomTime({
    required this.year,
    required this.month,
    required this.day,
    required this.hours,
    required this.minutes,
    required this.seconds,
    required this.weekday,
    required this.dayName,
  });

  factory CustomTime.getCurrentTime() {
    DateTime now = DateTime.now();
    String formattedDayName = DateFormat('EEEE').format(now);
    return CustomTime(
      year: now.year,
      month: now.month,
      day: now.day,
      hours: now.hour,
      minutes: now.minute,
      seconds: now.second,
      weekday: now.weekday,
      dayName: formattedDayName,
    );
  }

  String getAllTime() {
    DateTime now = DateTime.now();
    String formattedDateTime = DateFormat('EEEE, MM-dd-yyyy \nHH:mm:ss', 'id_ID').format(now);
    return formattedDateTime;
  }
}