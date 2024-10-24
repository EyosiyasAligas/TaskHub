import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/routes.dart';
import '../../../cubits/auth_cubit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();

  static Route route(RouteSettings routeSettings) {
    return MaterialPageRoute(
      builder: (_) => const HomeScreen(),
    );
  }
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              context.read<AuthCubit>().signOut();
              Navigator.of(context).pushReplacementNamed(Routes.login);
            },
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }
}
