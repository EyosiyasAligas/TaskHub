import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:task_hub/utils/notification_service.dart';

import '../cubits/auth_cubit.dart';
import '../data/repository/auth_repository.dart';
import '../ui/screens/splash_screen.dart';
import '../ui/styles/colors.dart';
import '../utils/local_storage_keys.dart';
import '../utils/ui_utils.dart';
import 'routes.dart';

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
  await NotificationService().initNotifications();

  // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Hive.initFlutter();
  await Hive.openBox(authBoxKey);
  await Hive.openBox(settingsKey);
  await Hive.openBox(darkModeKey);
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

    var box = Hive.box(settingsKey);
    bool? darkMode = box.get(darkModeKey);
    if (darkMode == null) {
      themeNotifier.value = ThemeMode.system;
    } else if(darkMode) {
      themeNotifier.value = ThemeMode.dark;
    } else {
      themeNotifier.value = ThemeMode.light;
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (_) => AuthCubit(AuthRepository()),
        ),
      ],
      child: ValueListenableBuilder<ThemeMode>(
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
              primaryColor: primaryColor,
              primaryColorLight: Colors.blueAccent.shade700,
              appBarTheme: AppBarTheme(
                backgroundColor: Colors.blueGrey.shade100.withOpacity(0.5),
                actionsIconTheme: const IconThemeData(
                  size: 22
                ),
                titleTextStyle: TextStyle(
                  fontSize: UiUtils.screenTitleFontSize,
                  color: Colors.grey.shade800
                ),
                iconTheme: IconThemeData(
                  size: 22,
                  color: Colors.grey.shade800,
                ),
              ),
              bottomNavigationBarTheme: BottomNavigationBarThemeData(
                backgroundColor: Colors.grey.shade200,
                elevation: 0,
                selectedItemColor: primaryColor,
                // unselectedItemColor: Colors.grey,
              ),
              brightness: Brightness.light,
              scaffoldBackgroundColor: lightModeScaffoldBackgroundColor,
              colorScheme: ColorScheme.fromSeed(
                seedColor: primaryColor,
                primary: primaryColor,
                brightness: Brightness.light,
              ).copyWith(
                primary: primaryColor,
                onPrimary: onPrimaryColor,
                secondary: secondaryColor,
                onSecondary: onSecondaryColor,
                error: lightModeErrorColor,
                // background: backgroundColor,
                // onBackground: onBackgroundColor,
              ),
              textTheme: TextTheme(
                displayLarge: TextStyle(fontSize: UiUtils.largeFontSize, fontWeight: FontWeight.bold, color: Colors.black),
                displayMedium: TextStyle(fontSize: UiUtils.mediumFontSize, fontWeight: FontWeight.bold, color: Colors.black),
                displaySmall: TextStyle(fontSize: UiUtils.smallFontSize, color: Colors.black),
                bodyLarge: TextStyle(fontSize: UiUtils.screenTitleFontSize, color: Colors.black),
                bodyMedium: TextStyle(fontSize: UiUtils.screenSubTitleFontSize, color: Colors.black),
                bodySmall: TextStyle(fontSize: UiUtils.screenSubTitleFontSize, color: Colors.black),
                titleSmall: TextStyle(fontSize: UiUtils.screenSubTitleFontSize, color: Colors.grey.shade800),
              ),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              primaryColor: primaryColor,
              primaryColorLight: Colors.blueAccent.shade100,
              brightness: Brightness.dark,
              appBarTheme: AppBarTheme(
                backgroundColor: Colors.blueGrey.shade900.withOpacity(0.2),
                titleTextStyle: TextStyle(
                    fontSize: UiUtils.screenTitleFontSize,
                    color: Colors.grey.shade300
                ),
                actionsIconTheme: const IconThemeData(
                    size: 22
                ),
                iconTheme: IconThemeData(
                  size: 22,
                    color: Colors.grey.shade300
                ),
              ),
              bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                elevation: 0,
                selectedItemColor: secondaryColor,
                unselectedItemColor: Colors.grey,
              ),
              colorScheme: ColorScheme.fromSeed(
                primary: primaryColor,
                seedColor: primaryColor,
                brightness: Brightness.dark,
              ).copyWith(
                primary: primaryColor,
                onPrimary: onPrimaryColor,
                secondary: secondaryColor,
                onSecondary: onSecondaryColor,
                error: darkModeErrorColor,
                // background: backgroundColor,
                // onBackground: onBackgroundColor,
              ),

              textTheme: TextTheme(
                displayLarge: TextStyle(fontSize: UiUtils.largeFontSize, fontWeight: FontWeight.bold, color: Colors.white),
                displayMedium: TextStyle(fontSize: UiUtils.mediumFontSize, fontWeight: FontWeight.bold, color: Colors.white),
                displaySmall: TextStyle(fontSize: UiUtils.smallFontSize, color: Colors.white),
                bodyLarge: TextStyle(fontSize: UiUtils.screenTitleFontSize, color: Colors.white),
                bodyMedium: TextStyle(fontSize: UiUtils.screenSubTitleFontSize, color: Colors.white),
                bodySmall: TextStyle(fontSize: UiUtils.screenSubTitleFontSize, color: Colors.white),
                titleSmall: TextStyle(fontSize: UiUtils.screenSubTitleFontSize, color: Colors.grey.shade400 ),
              ),
              useMaterial3: true,
            ),
            themeMode: currentTheme,
            initialRoute: Routes.splash,
            onGenerateRoute: Routes.onGenerateRouted,
          );
        },
      ),
    );
  }
}