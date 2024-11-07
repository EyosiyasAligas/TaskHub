import 'package:flutter/material.dart';

class UiUtils {
  static double largeFontSize = 50.0;
  static double mediumFontSize = 40.0;
  static double smallFontSize = 30.0;
  static double screenTitleFontSize = 18.0;
  static double screenSubTitleFontSize = 14.0;
  static double textFieldFontSize = 15.0;

  static double bottomSheetTopRadius = 20;

  static double shimmerLoadingContainerDefaultHeight = 7;

  static GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();

  static GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static List<String> months = [
    // just 3 letters
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static List<Color> colors = [
    Colors.red.shade600,
    Colors.pink.shade600,
    Colors.purple.shade600,
    Colors.deepPurple.shade600,
    Colors.indigo.shade600,
    Colors.blue.shade600,
    Colors.lightBlue.shade600,
    Colors.cyan.shade600,
    Colors.teal.shade600,
    Colors.green.shade600,
    Colors.lightGreen.shade600,
    Colors.amber.shade600,
    Colors.orange.shade600,
    Colors.deepOrange.shade600,
    Colors.brown.shade600,
    Colors.grey.shade600,
    Colors.blueGrey.shade600,
  ];

  static String getMonth(int index) {
    return months[index - 1];
  }

  static String getChatDate(DateTime date) {
    final now = DateTime.now();
    // if it is from this year i want to show (Nov 8) if it is not i want to show (8 Nov 2022)
    if (date.year == now.year) {
      return '${getMonth(date.month)} ${date.day}';
    } else {
      return '${date.day} ${getMonth(date.month)} ${date.year}';
    }
  }

  static String getReminderTime(DateTime date) {
    final now = DateTime.now();
    // if it is today i and yesterday i want to show (Today/yeaterday 5:30 AM/PM)
    // if it is not today or yesterday i want to show (8 Nov 2021 5:30 AM/PM)
    // if it is past date i want to show (Expired)
    // i don't want to show 0 hour i want 1 to 12 format and AM and PM
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today at ${date.hour == 0 ? 12 : date.hour % 12}:${date.minute.toString().padLeft(2, '0')} ${date.hour > 12 ? 'PM' : 'AM'}';
    } else if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day - 1) {
      return 'Yesterday at ${date.hour == 0 ? 12 : date.hour % 12}:${date.minute.toString().padLeft(2, '0')} ${date.hour > 12 ? 'PM' : 'AM'}';
    } else if (date.isBefore(now)) {
      return 'Expired';
    } else {
      return '${getMonth(date.month)} ${date.day} at ${date.hour == 0 ? 12 : date.hour % 12}:${date.minute.toString().padLeft(2, '0')} ${date.hour > 12 ? 'PM' : 'AM'}';
    }
  }

  static String getFormattedDate(DateTime date) {
    // if it is today, return 'Today' and if it is yesterday, return 'Yesterday' and the time
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today at ${date.hour == 0 ? 12 : date.hour % 12}:${date.minute.toString().padLeft(2, '0')} ${date.hour > 12 ? 'PM' : 'AM'}';
    } else if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day - 1) {
      return 'Yesterday at ${date.hour == 0 ? 12 : date.hour % 12}:${date.minute.toString().padLeft(2, '0')} ${date.hour > 12 ? 'PM' : 'AM'}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  static Future<dynamic> showBottomSheet({
    required Widget child,
    required BuildContext context,
    bool? enableDrag,
  }) async {
    final result = await showModalBottomSheet(
      enableDrag: enableDrag ?? false,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(bottomSheetTopRadius),
          topRight: Radius.circular(bottomSheetTopRadius),
        ),
      ),
      context: context,
      builder: (_) => child,
    );

    return result;
  }

  static void showOverlay(BuildContext context, String message, Color color) {
    final overlay = Overlay.of(context);
    final size = MediaQuery.sizeOf(context);
    OverlayEntry? overlayEntry;

    void dismissOverlay() {
      if (overlayEntry != null) {
        overlayEntry!.remove();
        overlayEntry = null;
      }
    }

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: size.height * 0.05,
        left: size.width * 0.1,
        right: size.width * 0.1,
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            onHorizontalDragEnd: (details) {
              // Dismiss when swipe ends
              dismissOverlay();
            },
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry!);

    Future.delayed(const Duration(seconds: 3), () {
      if (overlayEntry != null) {
        overlayEntry!.remove();
      }
    });
  }

  static void showSnackBar(BuildContext context, String message, Color color,
      {String? label, VoidCallback? onPressed}) {
    final snackBar = SnackBar(
      margin: EdgeInsets.symmetric(
          horizontal: 20, vertical: MediaQuery.sizeOf(context).height * 0.05),
      dismissDirection: DismissDirection.horizontal,
      backgroundColor: color,
      showCloseIcon: label != null ? false : true,
      action: label != null && onPressed != null
          ? SnackBarAction(
              label: label,
              textColor: Colors.white,
              onPressed: onPressed,
            )
          : null,
      behavior: SnackBarBehavior.floating,
      content: Text(message, style: const TextStyle(color: Colors.white)),
    );

    messengerKey.currentState!
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  static void showAlertDialog(
      BuildContext context, String title, String message,
      {String? positiveLabel,
      String? negativeLabel,
      VoidCallback? onPositivePressed,
      VoidCallback? onNegativePressed}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          if (negativeLabel != null)
            TextButton(
              onPressed: onNegativePressed,
              child: Text(negativeLabel),
            ),
          if (positiveLabel != null)
            TextButton(
              onPressed: onPositivePressed,
              child: Text(positiveLabel),
            ),
        ],
      ),
    );
  }

  static String? validateEmail(String email) {
    if (email.isEmpty) {
      return 'Email is required';
    }

    // Check if the email matches the general structure
    final RegExp emailRegex =
        RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");

    // Check for invalid characters
    final RegExp invalidCharacters = RegExp(r"[^a-zA-Z0-9._%+-@]");

    if (invalidCharacters.hasMatch(email)) {
      return 'Email contains invalid characters';
    }

    // Check if email matches the regex
    if (!emailRegex.hasMatch(email)) {
      if (!email.contains('@')) {
        return 'Email must contain "@"';
      }
      if (!email.contains('.')) {
        return 'Email must contain a domain (e.g., ".com", ".net")';
      }
      return 'Enter a valid email address';
    }

    // No error, email is valid
    return null;
  }
}
