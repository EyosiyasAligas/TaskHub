import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:task_hub/ui/styles/colors.dart';

import '../ui/screens/splash_screen.dart';
import '../utils/ui_utils.dart';

Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  await Firebase.initializeApp(
    // options: DefaultFirebaseOptions.currentPlatform,
    options: const FirebaseOptions(
      apiKey: 'AIzaSyBDNU1FBh6QsnS1c5uIRZsJ6otflBzxWsE',
      appId: '1:719576140435:android:98f7b42b4f3ed00607db66',
      messagingSenderId: '719576140435',
      projectId: 'taskhub-d7f7e',
      storageBucket: 'taskhub-d7f7e.appspot.com',
    ),
  );
  // await NotificationUtility.initializeAwesomeNotification();

  // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Hive.initFlutter();
  await Hive.openBox('settings');
  await Hive.openBox('darkMode');
  runApp(const MyApp());
}

class GlobalScrollBehavior extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

  @override
  Widget build(BuildContext context) {

    var box = Hive.box('settings');
    bool? darkMode = box.get('darkMode');
    if (darkMode == null) {
      themeNotifier.value = ThemeMode.system;
    } else if(darkMode) {
      themeNotifier.value = ThemeMode.dark;
    } else {
      themeNotifier.value = ThemeMode.light;
    }

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentTheme, child) {
        return MaterialApp(
          navigatorKey: UiUtils.rootNavigatorKey,
          scaffoldMessengerKey: UiUtils.messengerKey,
          debugShowCheckedModeBanner: false,
          title: 'TaskHub',
          builder: (context, widget) {
            return ScrollConfiguration(
              behavior: GlobalScrollBehavior(),
              child: widget!,
            );
          },
          theme: ThemeData(
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: primaryColor,
              brightness: Brightness.light,
            ).copyWith(
              primary: primaryColor,
              onPrimary: onPrimaryColor,
              secondary: secondaryColor,
              onSecondary: onSecondaryColor,
              // background: backgroundColor,
              // error: errorColor,
              // onBackground: onBackgroundColor,
            ),
            textTheme: TextTheme(
              displayLarge: TextStyle(fontSize: UiUtils.largeFontSize, fontWeight: FontWeight.bold, color: Colors.black),
              displayMedium: TextStyle(fontSize: UiUtils.mediumFontSize, fontWeight: FontWeight.bold, color: Colors.black),
              displaySmall: TextStyle(fontSize: UiUtils.smallFontSize, color: Colors.black),
              bodyLarge: TextStyle(fontSize: UiUtils.screenTitleFontSize, color: Colors.black),
              bodyMedium: TextStyle(fontSize: UiUtils.screenSubTitleFontSize, color: Colors.black),
              bodySmall: TextStyle(fontSize: UiUtils.screenSubTitleFontSize, color: Colors.black),
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: primaryColor,
              brightness: Brightness.dark,
            ).copyWith(
              primary: primaryColor,
              onPrimary: onPrimaryColor,
              secondary: secondaryColor,
              onSecondary: onSecondaryColor,
              // background: backgroundColor,
              // error: errorColor,
              // onBackground: onBackgroundColor,
            ),

            textTheme: TextTheme(
              displayLarge: TextStyle(fontSize: UiUtils.largeFontSize, fontWeight: FontWeight.bold, color: Colors.white),
              displayMedium: TextStyle(fontSize: UiUtils.mediumFontSize, fontWeight: FontWeight.bold, color: Colors.white),
              displaySmall: TextStyle(fontSize: UiUtils.smallFontSize, color: Colors.white),
              bodyLarge: TextStyle(fontSize: UiUtils.screenTitleFontSize, color: Colors.white),
              bodyMedium: TextStyle(fontSize: UiUtils.screenSubTitleFontSize, color: Colors.white),
              bodySmall: TextStyle(fontSize: UiUtils.screenSubTitleFontSize, color: Colors.white),
            ),
            useMaterial3: true,
          ),
          themeMode: currentTheme,
          home: const SplashScreen(),
        );
      },
    );
  }
}