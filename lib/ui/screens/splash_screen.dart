import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/adapters.dart';

import '../../app/app.dart';
import 'auth_screen/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    var box = Hive.box('settings');
    bool? darkMode = box.get('darkMode');
    if (darkMode == null) {
      MyApp.themeNotifier.value = ThemeMode.system;
    } else if(darkMode) {
      MyApp.themeNotifier.value = ThemeMode.dark;
    } else {
      MyApp.themeNotifier.value = ThemeMode.light;
    }

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
    });
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
          child: SvgPicture.asset(
            'assets/splash.svg',
          ),
        ),
      ),
    );
  }
}
