import 'package:bel_sekolah/utils/size.dart';
import 'package:flutter/material.dart';
import '../colors/colors.dart';

class Waktu {
  static void customTime(
      BuildContext context, String schedule, int initHour, int initMinute, Function(TimeOfDay) onSelecttime) {
    // double tinggiHalaman = MediaQuery.of(context).size.height;
    // double lebarHalaman = MediaQuery.of(context).size.width;
    showTimePicker(
      helpText: schedule,
      initialTime: TimeOfDay(hour: initHour, minute: initMinute),
      initialEntryMode: TimePickerEntryMode.dial,
      context: context,
      builder: (context, child) {
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
            child: Container(
              margin: EdgeInsets.symmetric(
                  vertical: screenHeight(context) * 0.08,
                  horizontal: screenWidth(context) * 0.08),
              child: child!,
            ),
          // ),
        );
      },
    ).then((time) {
      if (time != null) {
        onSelecttime(time);
      }
    });
  }
}
