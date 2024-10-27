import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_hub/cubits/auth_cubit.dart';

import '../../../../app/routes.dart';

class ChatContainer extends StatefulWidget {
  const ChatContainer({super.key});

  @override
  State<ChatContainer> createState() => _ChatContainerState();
}

class _ChatContainerState extends State<ChatContainer> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('initState from ChatContainer');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Screen'),
      ),
      body: Center(
        child: TextButton(
          onPressed: () {
            context.read<AuthCubit>().signOut();
            Navigator.of(context).pushNamed(Routes.login);
          },
          child: const Text('Logout'),
        ),
      ),
    );
  }
}
