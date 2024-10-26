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

  static Future<dynamic> showBottomSheet({
    required Widget child,
    required BuildContext context,
    bool? enableDrag,
  }) async {
    final result = await showModalBottomSheet(
      enableDrag: enableDrag ?? false,
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
