import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:lottie/lottie.dart';
import 'package:task_hub/utils/local_storage_keys.dart';

import '../../app/app.dart';
import '../../app/routes.dart';
import '../../cubits/auth_cubit.dart';
import 'auth_screen/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();

  static Route route(RouteSettings routeSettings) {
    return MaterialPageRoute(
      builder: (_) => const SplashScreen(),
    );
  }
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    var box = Hive.box(settingsKey);
    bool? darkMode = box.get(darkModeKey);
    if (darkMode == null) {
      MyApp.themeNotifier.value = ThemeMode.system;
    } else if (darkMode) {
      MyApp.themeNotifier.value = ThemeMode.dark;
    } else {
      MyApp.themeNotifier.value = ThemeMode.light;
    }

    Future.delayed(const Duration(seconds: 3), () {
      navigateToNextScreen();
    });
  }

  void navigateToNextScreen() {
    if (context.read<AuthCubit>().state is Unauthenticated) {
      Navigator.of(context).pushReplacementNamed(Routes.login);
    } else {
      Navigator.of(context).pushReplacementNamed(Routes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Animate(
          effects: const [
            ScaleEffect(
              delay: Duration(
                milliseconds: 10,
              ),
              duration: Duration(
                seconds: 1,
              ),
            ),
          ],
          child:RotatedBox(
            quarterTurns: 0,
            child: Lottie.asset(
              'assets/task.json',
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
