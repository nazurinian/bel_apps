import 'package:flutter/material.dart';

class TimePicker {
  static Future<TimeOfDay?> customTime(BuildContext context, String schedule, int initHour,
      int initMinute, Function(TimeOfDay) onSelectTime) {
    return showTimePicker(
      helpText: schedule,
      initialTime: TimeOfDay(hour: initHour, minute: initMinute),
      initialEntryMode: TimePickerEntryMode.dial,
      context: context,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: TimePickerTheme(
              data: TimePickerThemeData(
                dialTextStyle: const TextStyle(fontWeight: FontWeight.bold),
                helpTextStyle: const TextStyle(fontWeight: FontWeight.bold),
                cancelButtonStyle: ButtonStyle(
                  textStyle: WidgetStateProperty.all<TextStyle>(const TextStyle(fontWeight: FontWeight.bold)), // Bold text style
                ),
                confirmButtonStyle: ButtonStyle(
                  textStyle: WidgetStateProperty.all<TextStyle>(const TextStyle(fontWeight: FontWeight.bold)), // Bold text style
                ),
                dayPeriodTextStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
              child: child!,
            ),
          ),
        );
      },
    ).then(
          (TimeOfDay? time) {
        if (time != null) {
          onSelectTime(time);
        }
        return time; // Return the selected time
      },
    );
  }
}

/*import 'package:bel_sekolah/utils/DisplaySize.dart';
import 'package:flutter/material.dart';

class TimePicker {
  static void customTime(BuildContext context, String schedule, int initHour,
      int initMinute, Function(TimeOfDay) onSelecttime) {
    showTimePicker(
      helpText: schedule,
      initialTime: TimeOfDay(hour: initHour, minute: initMinute),
      initialEntryMode: TimePickerEntryMode.dial,
      context: context,
      builder: (context, child) {
        return SafeArea(
          child: Container(
            margin: EdgeInsets.symmetric(
                vertical: screenHeight(context) * 0.08,
                horizontal: screenWidth(context) * 0.08),
            child: child!,
          ),
        );
      },
    ).then(
      (time) {
        if (time != null) {
          onSelecttime(time);
        }
      },
    );
  }
}*/
