import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:task_hub/data/models/chat_message.dart';

import '../../cubits/auth_cubit.dart';
import '../../cubits/fetch_chat_cubit.dart';
import '../../cubits/send_chat_cubit.dart';
import '../../data/models/user.dart';
import '../../data/repository/chat_repository.dart';
import '../../utils/ui_utils.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.receiver});

  final UserModel receiver;

  static Route route(RouteSettings routeSettings) {
    final UserModel args = routeSettings.arguments as UserModel;
    return MaterialPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider<FetchChatCubit>(
            create: (_) => FetchChatCubit(ChatRepository()),
          ),
          BlocProvider<SendChatCubit>(
            create: (_) => SendChatCubit(ChatRepository()),
          ),
        ],
        child: ChatScreen(
          receiver: args,
        ),
      ),
    );
  }

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController textController = TextEditingController();
  FocusNode focusNode = FocusNode();
  bool isReceiverOnline = false;
  File? _imageFile;

  final ImagePicker _picker = ImagePicker();
  final ScrollController listScrollController = ScrollController();
  ChatMessage message = ChatMessage(
    content: '',
    receiverId: '',
    senderId: '',
    receiverName: '',
    timestamp: DateTime.now(),
    id: '',
    senderName: '',
  );

  UserModel sender = UserModel(
    id: '',
    userName: '',
    email: '',
    fcmId: '',
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    sender = context.read<AuthCubit>().getUserDetails();
    // context.read<FetchChatCubit>().fetchChatMessagesOnce(
    //   receiverId: widget.receiver.id,
    //   senderId: senderId,
    // );

    context
        .read<FetchChatCubit>()
        .fetchChatMessages(receiverId: widget.receiver.id, senderId: sender.id);
    // Scroll to bottom after the messages are loaded

    _listenToReceiverStatus();
  }

  Stream<DatabaseEvent> _listenToReceiverStatus() {
    return FirebaseDatabase.instance
        .ref('users/${widget.receiver.id}/isOnline')
        .onValue;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    textController.dispose();
    listScrollController.dispose();
    focusNode.dispose();
  }

  void sendMessage(ChatMessage message) {
    if (textController.text.trim().isNotEmpty) {
      context.read<SendChatCubit>().sendChatMessage(
            receiverId: widget.receiver.id,
            senderId: sender.id,
            chatMessage: message,
          );
    }
    textController.clear();
    _imageFile = null;
    setState(() {});
    scrollToBottom();
    setState(() {});
  }

  // void _openFile(String fileUrl) {
  //   // Implement file opening logic
  //   // For example, you can use url_launcher to open the file URL
  //   launch(fileUrl);
  // }

  Future<File?> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      return _imageFile;
    } else {
      return null;
    }
  }

  void scrollToBottom() {
    listScrollController.animateTo(
      listScrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.easeOut,
    );
  }

  Widget buildMessagesList(ThemeData themeData, Size size) {
    return BlocBuilder<FetchChatCubit, FetchChatState>(
      builder: (context, state) {
        if (state is FetchChatInProgress) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (state is FetchChatFailure) {
          return Center(
            child: Text(state.errorMessage),
          );
        }
        if (state is FetchChatSuccess) {
          return StreamBuilder(
            // stream: context.read<FetchChatCubit>().fetchChatMessages(
            //     receiverId: widget.receiver.id, senderId: sender.id),
            stream: state.chatMessages,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (!snapshot.hasData &&
                  snapshot.connectionState == ConnectionState.done) {
                return const Center(
                  child: Text('No messages'),
                );
              }
              if (snapshot.data == null ||
                  snapshot.data!.snapshot.value == null) {
                return const Center(
                  child: Text('No messages'),
                );
              }
              if (snapshot.hasData) {
                if (snapshot.data!.snapshot.value != null) {
                  Future.delayed(const Duration(milliseconds: 200))
                      .then((value) {
                    scrollToBottom();
                  });
                  Map<String, dynamic>? fetchedData = jsonDecode(jsonEncode(
                      snapshot.data!.snapshot.value,
                      toEncodable: (e) => e.toString()));
                  final messages = <ChatMessage>[];
                  fetchedData?.forEach((key, value) {
                    messages.add(ChatMessage.fromMap(value));
                  });
                  messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
                  // Group messages by date
                  Map<String, List<ChatMessage>> groupedMessages = {};
                  for (var message in messages) {
                    String date = UiUtils.getChatDate(message.timestamp);
                    if (groupedMessages[date] == null) {
                      groupedMessages[date] = [];
                    }
                    groupedMessages[date]!.add(message);
                  }

                  return ListView.builder(
                    controller: listScrollController,
                    itemCount: groupedMessages.length,
                    itemBuilder: (context, index) {
                      String date = groupedMessages.keys.elementAt(index);
                      List<ChatMessage> dateMessages = groupedMessages[date]!;
                      // Check if the message is sent by the current user not just the first message
                      bool isSender = dateMessages.first.senderId == sender.id;
                      return Column(
                        // crossAxisAlignment:
                        // isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Center(
                              child: Text(
                                date,
                                style: themeData.textTheme.bodySmall,
                              ),
                            ),
                          ),
                          ...dateMessages
                              .map((message) =>
                                  buildMessageItem(themeData, size, message))
                              .toList(),
                        ],
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              }
              return const SizedBox.shrink();
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget buildMessageItem(ThemeData themeData, Size size, ChatMessage message) {
    bool isSender = message.senderId == sender.id;
    return Container(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: isSender
                  ? themeData.colorScheme.primary.withOpacity(0.3)
                  : themeData.colorScheme.secondary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            constraints: BoxConstraints(
              maxWidth: size.width * 0.7,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
            child: message.content.trim().isNotEmpty
                ? Text(message.content)
                : _imageFile != null
                    ? Image.file(
                        _imageFile!,
                        fit: BoxFit.cover,
                      )
                    : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget buildTextField(ThemeData themeData, Size size) {
    return Container(
      constraints: const BoxConstraints(
          // maxHeight: double.infinity,
          ),
      decoration: BoxDecoration(
        color: themeData.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: themeData.colorScheme.onSurface.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: TextField(
          expands: true,
          maxLines: null,
          style: TextStyle(
            fontSize: themeData.textTheme.bodyLarge!.fontSize,
            color: themeData.textTheme.bodyLarge!.color,
          ),
          decoration: InputDecoration(
            hintText: 'Message',
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            suffixIcon: textController.text.trim().isEmpty && _imageFile == null
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.link_outlined),
                        onPressed: () {
                          // Implement image picker
                          //imagePicker();
                          _pickImage(ImageSource.gallery);
                          setState(() {});
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.mic),
                        onPressed: () {
                          // Implement voice recording
                        },
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (_imageFile != null)
                        Image.file(_imageFile!, fit: BoxFit.cover),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () {
                          sendMessage(message);
                        },
                      ),
                    ],
                  ),
            border: InputBorder.none,
          ),
          textInputAction: TextInputAction.newline,
          keyboardType: TextInputType.multiline,
          controller: textController,
          onChanged: (value) {
            message = ChatMessage(
              content: value,
              receiverId: widget.receiver.id,
              senderId: sender.id,
              receiverName: widget.receiver.userName,
              timestamp: DateTime.now(),
              id: '',
              senderName: sender.userName,
            );
            // print('typed Message: ${sendMessage.content}');
            setState(() {});
          },
        ),
      ),
    );
  }

  Widget buildBody(ThemeData themeData, Size size) {
    var mediaQuery = MediaQuery.of(context);
    var bottomPadding = mediaQuery.viewInsets.bottom;
    var topPadding = mediaQuery.viewInsets.top;
    var keyboardHeight = mediaQuery.viewInsets.bottom;
    return SingleChildScrollView(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: size.height -
              topPadding -
              bottomPadding -
              buildAppBar(themeData).preferredSize.height -
              30,
        ),
        child: Column(
          children: [
            Expanded(
              child: buildMessagesList(themeData, size),
            ),
            buildTextField(themeData, size),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget buildAppBar(ThemeData themeData) {
    return AppBar(
      title: StreamBuilder(
          stream: _listenToReceiverStatus(),
          builder: (context, snapshot) {
            var isReceiverOnline = false;
            snapshot.data?.snapshot.value.toString() == 'true'
                ? isReceiverOnline = true
                : isReceiverOnline = false;
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 0),
              leading: CircleAvatar(
                radius: 22,
                backgroundColor: UiUtils.colors[2 % UiUtils.colors.length + 1],
                child: Text(
                  widget.receiver.userName.characters.first.toUpperCase(),
                  style: TextStyle(
                    fontSize: UiUtils.screenTitleFontSize + 1,
                    color: themeData.colorScheme.onSecondary,
                  ),
                ),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.receiver.userName),
                ],
              ),
              subtitle: Row(
                children: [
                  isReceiverOnline
                      ? const Text('Online')
                      : const Text('Offline'),
                  const SizedBox(width: 5),
                  isReceiverOnline
                      ? const Icon(Icons.circle, color: Colors.green, size: 10)
                      : const Icon(Icons.circle, color: Colors.red, size: 10),
                ],
              ),
            );
          }),
      actions: [
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.search),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: buildAppBar(themeData),
      body: buildBody(themeData, size),
    );
  }
}
