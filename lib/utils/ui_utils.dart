import 'package:flutter/material.dart';

class UiUtils {

  static double largeFontSize = 50.0;
  static double mediumFontSize = 40.0;
  static double smallFontSize = 30.0;
  static double screenTitleFontSize = 18.0;
  static double screenSubTitleFontSize = 14.0;
  static double textFieldFontSize = 15.0;

  static GlobalKey<NavigatorState> rootNavigatorKey =
  GlobalKey<NavigatorState>();

  static GlobalKey<ScaffoldMessengerState> messengerKey =
  GlobalKey<ScaffoldMessengerState>();

  static void showSnackBar(BuildContext context, String message, Color color) {
      final snackBar = SnackBar(
        width: 600,
        backgroundColor: color,
        showCloseIcon: true,
        behavior: SnackBarBehavior.floating,
        content: Text(message),
      );

    messengerKey.currentState!
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}