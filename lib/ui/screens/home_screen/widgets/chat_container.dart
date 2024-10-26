import 'package:flutter/material.dart';

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
      body: const Center(
        child: Text('Chat Screen'),
      ),
    );
  }
}
