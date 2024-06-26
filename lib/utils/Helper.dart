import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

enum ToastStatus { success, error }

class ToastUtil {
  static void showToast(String message, ToastStatus status) {
    Color backgroundColor;
    switch (status) {
      case ToastStatus.success:
        backgroundColor = Colors.green;
        break;
      case ToastStatus.error:
        backgroundColor = Colors.red;
        break;
    }

    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: backgroundColor,
      textColor: Colors.white,
    );
  }
}

class DialogUtil {
  static void showConfirmationDialog({
    required BuildContext context,
    required String title,
    required Widget content,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: content,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Tidak'),
            ),
            TextButton(
              onPressed: () {
                onConfirm();
                Navigator.of(context).pop();
              },
              child: const Text('Ya'),
            ),
          ],
        );
      },
    );
  }
}

class SnackbarUtil {
  static void showSnackbar({
    required BuildContext context,
    required String message,
    // Color backgroundColor = Colors.black87,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        // backgroundColor: backgroundColor,
      ),
    );
  }
}
