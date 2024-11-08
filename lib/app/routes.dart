import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../ui/screens/add_or_edit_note_screen.dart';
import '../ui/screens/auth_screen/login_screen.dart';
import '../ui/screens/auth_screen/signup_screen.dart';
import '../ui/screens/chat_message_screen.dart';
import '../ui/screens/group_chat_screen.dart';
import '../ui/screens/home_screen/home_screen.dart';
import '../ui/screens/splash_screen.dart';

class Routes {
  static const String splash = "splash";
  static const String home = "/";
  static const String login = "login";
  static const String signup = "signup";

  static const String addOrEditNote = "/addOrEditNote";
  static const String chatScreen = "/chatScreen";
  static const String groupChatScreen = "/groupChatScreen";

  static String currentRoute = splash;

  static Route<dynamic> onGenerateRouted(RouteSettings routeSettings) {
    currentRoute = routeSettings.name ?? "";
    if (kDebugMode) {
      print("Route: $currentRoute");
    }
    switch (routeSettings.name) {
      case splash:
        {
          return SplashScreen.route(routeSettings);
        }
      case login:
        {
          return LoginScreen.route(routeSettings);
        }
      case signup:
        {
          return SignUpScreen.route(routeSettings);
        }
      case home:
        {
          return HomeScreen.route(routeSettings);
        }
      case addOrEditNote:
        {
          return AddOrEditNotesScreen.route(routeSettings);
        }
      case chatScreen:
        {
          return ChatScreen.route(routeSettings);
        }
      case groupChatScreen:
        {
          return GroupChatScreen.route(routeSettings);
        }
      default:
        {
          return MaterialPageRoute(builder: (context) => const Scaffold());
        }
    }
  }
}
