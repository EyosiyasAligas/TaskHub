import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:task_hub/cubits/Fetch_group_message_cubit.dart';
import 'package:task_hub/cubits/create_group_cubit.dart';
import 'package:async/async.dart';

import '../../cubits/auth_cubit.dart';
import '../../cubits/fetch_chat_cubit.dart';
import '../../cubits/send_chat_cubit.dart';
import '../../cubits/send_group_message._cubit.dart';
import '../../data/models/chat_message.dart';
import '../../data/models/group.dart';
import '../../data/models/user.dart';
import '../../data/repository/chat_repository.dart';
import '../../utils/ui_utils.dart';
import '../styles/colors.dart';

class GroupChatScreen extends StatefulWidget {
  const GroupChatScreen({super.key, required this.receiver});

  final Group receiver;

  static Route route(RouteSettings routeSettings) {
    final Group args = routeSettings.arguments as Group;
    return MaterialPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider<FetchGroupMessageCubit>(
            create: (_) => FetchGroupMessageCubit(ChatRepository()),
          ),
          BlocProvider<SendGroupMessageCubit>(
            create: (_) => SendGroupMessageCubit(ChatRepository()),
          ),
          BlocProvider<CreateGroupCubit>(
            create: (_) => CreateGroupCubit(ChatRepository()),
          ),
        ],
        child: GroupChatScreen(
          receiver: args,
        ),
      ),
    );
  }

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController textController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  FocusNode focusNode = FocusNode();
  bool isReceiverOnline = false;
  File? _imageFile;
  bool isSearching = false;
  List<ChatMessage> allMessages = [];
  List<ChatMessage> filteredMessages = [];

  List<UserModel> users = [];

  List<bool> isUserSelected = [];

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
    groupMembers: [],
    groupName: '',
    creatorId: '',
    isGroup: true,
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
        .read<FetchGroupMessageCubit>()
        .fetchGroupMessages(groupId: widget.receiver.id);

    Future.delayed(Duration.zero).then((value) async {
      users = await context.read<AuthCubit>().fetchUsers();
      isUserSelected = List.generate(users.length, (index) => false);
      var members = widget.receiver.members;
      isUserSelected = List.generate(users.length, (index) {
        if (members.contains(users[index].id)) {
          return true;
        }
        return false;
      });
    });

    _listenToGroupMembersStatus();
  }

  void searchMessages(String query) {
    if (searchController.text.isEmpty) {
      setState(() {
        // isSearching = false;
        filteredMessages = allMessages;
      });
    } else {
      setState(() {
        // isSearching = true;
        filteredMessages = allMessages.where((message) {
          return message.content.toLowerCase().contains(query.toLowerCase());
        }).toList();
      });
    }
  }

  Stream<int> _listenToGroupMembersStatus() {
    List<Stream<DatabaseEvent>> memberStatusStreams =
        widget.receiver.members.map((memberId) {
      return FirebaseDatabase.instance.ref('users/$memberId/isOnline').onValue;
    }).toList();

    return StreamGroup.merge(memberStatusStreams).map((event) {
      int onlineCount = 0;
      for (var memberId in widget.receiver.members) {
        var isOnline =
            FirebaseDatabase.instance.ref('users/$memberId/isOnline').once();
        if (isOnline == 'true') {
          onlineCount++;
        }
      }
      return onlineCount;
    });
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
      context.read<SendGroupMessageCubit>().sendGroupMessage(
            groupId: widget.receiver.id,
            senderId: sender.id,
            message: message,
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
    return Container(
      child: BlocBuilder<FetchGroupMessageCubit, FetchGroupMessageState>(
        builder: (context, state) {
          if (state is FetchGroupMessageInProgress) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (state is FetchGroupMessageFailure) {
            return Center(
              child: Text(state.errorMessage),
            );
          }
          if (state is FetchGroupMessageSuccess) {
            // print('group Messages: ${state.messages}');
            return StreamBuilder(
              // stream: context.read<FetchChatCubit>().fetchChatMessages(
              //     receiverId: widget.receiver.id, senderId: sender.id),
              stream: state.messages,
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
                  print('group Messages: ${snapshot.data!.snapshot.value}');
                  return const Center(
                    child: Text('No messages'),
                  );
                }
                if (snapshot.hasData) {
                  print('group Messages: $snapshot');
                  if (snapshot.data!.snapshot.value != null) {
                    // Future.delayed(const Duration(milliseconds: 200))
                    //     .then((value) {
                    //   scrollToBottom();
                    // });
                    Map<String, dynamic>? fetchedData = jsonDecode(jsonEncode(
                        snapshot.data!.snapshot.value,
                        toEncodable: (e) => e.toString()));
                    print('group Messages: $fetchedData');
                    final messages = <ChatMessage>[];
                    fetchedData?.forEach((key, value) {
                      messages.add(ChatMessage.fromMap(value));
                    });
                    messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
                    // Group messages by date
                    allMessages = messages;
                    filteredMessages =
                        isSearching ? filteredMessages : allMessages;
                    Map<String, List<ChatMessage>> groupedMessages = {};
                    for (var message in filteredMessages) {
                      String date = UiUtils.getChatDate(message.timestamp);
                      if (groupedMessages[date] == null) {
                        groupedMessages[date] = [];
                      }
                      groupedMessages[date]!.add(message);
                    }

                    List<String> reversedKeys =
                        groupedMessages.keys.toList().reversed.toList();

                    return ListView.builder(
                      controller: listScrollController,
                      reverse: true,
                      itemCount: reversedKeys.length,
                      itemBuilder: (context, index) {
                        String date = groupedMessages.keys.elementAt(index);
                        List<ChatMessage> dateMessages =
                            groupedMessages[reversedKeys[index]]!;
                        // Check if the message is sent by the current user not just the first message
                        bool isSender =
                            dateMessages.first.senderId == sender.id;
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Center(
                                child: Text(
                                  reversedKeys[index],
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
      ),
    );
  }

  void addMembers(List<String> memberIds, String groupId) {
    context
        .read<CreateGroupCubit>()
        .addMemberToGroup(groupId: groupId, memberIds: memberIds);
  }

  Widget buildMessageItem(ThemeData themeData, Size size, ChatMessage message) {
    bool isSender = message.senderId == sender.id;
    bool isAdmin = message.creatorId == sender.id;
    return Container(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isSender)
            Text(
              message.senderName,
              style: themeData.textTheme.bodySmall,
            ),
          Container(
            decoration: BoxDecoration(
              color: isSender
                  ? themeData.colorScheme.primary.withOpacity(0.3)
                  : themeData.colorScheme.secondary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            constraints: BoxConstraints(
              maxWidth: size.width * 0.7,
              minWidth: size.width * 0.1,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
            child: IntrinsicWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (!isSender)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (message.senderName.isNotEmpty)
                          Text(
                            message.senderName,
                            style: TextStyle(
                              fontSize: UiUtils.screenSubTitleFontSize + 2,
                              fontWeight: FontWeight.bold,
                              color: themeData.textTheme.bodySmall!.color,
                            ),
                          ),
                        if (isAdmin)
                          Text(
                            'Admin',
                            style: themeData.textTheme.titleSmall,
                          ),
                      ],
                    ),
                  if (message.content.isNotEmpty)
                    Text(
                      message.content,
                      style: const TextStyle(
                          // fontSize: themeData.textTheme.bodyLarge!.fontSize ,
                          // color: themeData.textTheme.bodyLarge!.color,
                          ),
                    ),
                  if (message.imageUrl != null)
                    Image.network(
                      message.imageUrl!,
                      fit: BoxFit.cover,
                    ),
                ],
              ),
            ),
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
                    mainAxisAlignment: MainAxisAlignment.end,
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
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
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
              receiverId: '',
              senderId: sender.id,
              receiverName: '',
              timestamp: DateTime.now(),
              id: '',
              isGroup: true,
              groupMembers: widget.receiver.members,
              groupName: widget.receiver.name,
              creatorId: widget.receiver.creatorId,
              senderName: sender.email.split('@')[0],
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
              buildAppBar(themeData, size).preferredSize.height -
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

  Stream<DatabaseEvent> fetchUserStream(String userId) {
    return context.read<AuthCubit>().fetchUserStream(userId);
  }

  Widget buildGroupProfile(ThemeData themeData, Size size, Group group) {
    return StatefulBuilder(
      builder: (context, setStat) {
        return Container(
          color: themeData.scaffoldBackgroundColor,
          height: size.height * 0.7,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                alignment: Alignment.center,
                child: Text(
                  group.name,
                  style: themeData.textTheme.bodyLarge,
                ),
              ),
              ...group.members.map(
                (e) => StreamBuilder<DatabaseEvent>(
                  stream: fetchUserStream(e),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      // return const Center(
                      //   child: CircularProgressIndicator(),
                      // );
                    }
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text('An error occurred'),
                      );
                    }
                    if (snapshot.data == null) {
                      // return Center(
                      //   child: Text('No data'),
                      // );
                    }
                    if (snapshot.hasData) {
                      // var user = UserModel.fromJson(snapshot.data!.snapshot.value);
                      Map<String, dynamic> fetchedData = jsonDecode(jsonEncode(
                          snapshot.data!.snapshot.value,
                          toEncodable: (e) => e.toString()));
                      UserModel user = UserModel.fromJson(fetchedData);
                      bool isOnline = false;
                      if (fetchedData['isOnline'] == true) {
                        isOnline = true;
                      }
                      bool isAdmin = group.creatorId == e;

                      print('userfetched: $user');
                      if (snapshot.data!.snapshot.value != null) {
                        return ListTile(
                          leading: CircleAvatar(
                            radius: 25,
                            backgroundColor:
                                UiUtils.colors[2 % UiUtils.colors.length + 1],
                            child: Text(
                              user.email.characters.first.toUpperCase(),
                              style: TextStyle(
                                fontSize: UiUtils.screenTitleFontSize + 1,
                                color: themeData.colorScheme.onSecondary,
                              ),
                            ),
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                user.email.split('@')[0],
                                style: themeData.textTheme.bodyLarge,
                              ),
                              if (isAdmin)
                                Text(
                                  'Admin',
                                  style: themeData.textTheme.titleSmall,
                                ),
                            ],
                          ),
                          subtitle: Text(
                            user.email,
                            style: themeData.textTheme.bodySmall,
                          ),
                          trailing: Icon(
                            Icons.circle,
                            size: 10,
                            color: isOnline ? Colors.green : Colors.red,
                          ),
                        );
                      }
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget buildAppBar(ThemeData themeData, Size size) {
    return AppBar(
      title: StreamBuilder(
          stream: _listenToGroupMembersStatus(),
          builder: (context, snapshot) {
            // var isReceiverOnline = false;
            // snapshot.data! == 0
            //     ? isReceiverOnline = true
            //     : isReceiverOnline = false;
            return ListTile(
              onTap: () {
                UiUtils.showBottomSheet(
                    child: buildGroupProfile(themeData, size, widget.receiver),
                    context: context);
              },
              contentPadding: const EdgeInsets.symmetric(horizontal: 0),
              leading: CircleAvatar(
                radius: 22,
                backgroundColor: UiUtils.colors[2 % UiUtils.colors.length + 1],
                child: Text(
                  widget.receiver.name.characters.first.toUpperCase(),
                  style: TextStyle(
                    fontSize: UiUtils.screenTitleFontSize + 1,
                    color: themeData.colorScheme.onSecondary,
                  ),
                ),
              ),
              title: isSearching
                  ? TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search messages...',
                        border: InputBorder.none,
                      ),
                      onChanged: searchMessages,
                    )
                  : Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FittedBox(
                            child: Text(widget.receiver.name),
                          ),
                        ],
                      ),
                    ),
              subtitle: !isSearching
                  ? Row(
                      children: [
                        if (snapshot.hasData)
                          Row(
                            children: [
                              snapshot.data == 0
                                  ? Text(
                                      'no members online',
                                      style: TextStyle(
                                          fontSize:
                                              UiUtils.screenSubTitleFontSize -
                                                  2),
                                    )
                                  : Text('${snapshot.data} online'),
                            ],
                          ),
                        const SizedBox(width: 5),
                        if (snapshot.hasData)
                          isReceiverOnline
                              ? const Icon(Icons.circle,
                                  color: Colors.green, size: 6)
                              : const Icon(Icons.circle,
                                  color: Colors.red, size: 6),
                      ],
                    )
                  : null,
            );
          }),
      actions: [
        IconButton(
          onPressed: () {
            setState(() {
              isSearching = !isSearching;

              if (isSearching) {
                searchController.clear();
                searchMessages('');
                // isSearching = false;
              } else {
                searchController.clear();
                searchMessages('');
                // isSearching = true;
              }
            });
          },
          icon: Icon(isSearching ? Icons.close: Icons.search),
        ),
        if (widget.receiver.creatorId ==
            context.read<AuthCubit>().getUserDetails().id)
          IconButton(
            onPressed: () {
              UiUtils.showBottomSheet(
                  child: buildAddGroup(themeData, size), context: context);
            },
            icon: const Icon(Icons.add),
          ),
      ],
    );
  }

  Widget buildAddGroup(ThemeData themeData, Size size) {
    return StatefulBuilder(builder: (context, setStat) {
      return SingleChildScrollView(
        child: Container(
          height: size.height * 0.7,
          color: themeData.scaffoldBackgroundColor,
          alignment: Alignment.bottomLeft,
          padding: EdgeInsets.only(
              right: 10, bottom: MediaQuery.of(context).padding.bottom),
          child: Column(
            children: [
              //build a section to add group name and members
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      'Add Members',
                      style: themeData.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 25),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        ...List.generate(users.length, (index) {
                          return GestureDetector(
                            onTap: () {
                              isUserSelected[index] = !isUserSelected[index];

                              setStat(() {});
                              setState(() {});
                            },
                            child: ListTile(
                              minVerticalPadding: 20,
                              leading: Container(
                                // padding: const EdgeInsets.all(8),
                                margin: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    width: 2,
                                    color: isUserSelected[index]
                                        ? themeData.primaryColorLight
                                        : themeData.colorScheme.onPrimary
                                            .withOpacity(0.5),
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Colors.transparent,
                                  child: Text(
                                    users[index].userName[0].toUpperCase(),
                                    style: TextStyle(
                                      color:
                                          themeData.textTheme.titleSmall!.color,
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(
                                users[index].email,
                                style: TextStyle(
                                  color: themeData.textTheme.titleSmall!.color,
                                ),
                              ),
                              subtitle: const Divider(),
                            ),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        onPressed: () {
                          if (true) {
                            List<String> selectedUsers = [];
                            selectedUsers = users
                                .where((element) =>
                                    isUserSelected[users.indexOf(element)])
                                .map((e) => e.id)
                                .toList();
                            selectedUsers.add(
                                context.read<AuthCubit>().getUserDetails().id);
                            Group groupData = widget.receiver;
                            groupData.members = selectedUsers;
                            addMembers(
                              selectedUsers,
                              widget.receiver.id,
                            );
                            Navigator.pop(context);
                            UiUtils.showSnackBar(
                              context,
                              'Members updated',
                              successColor,
                            );
                            var members = widget.receiver.members;
                            isUserSelected =
                                List.generate(users.length, (index) {
                              if (members.contains(users[index].id)) {
                                return true;
                              }
                              return false;
                            });
                          } else {
                            UiUtils.showOverlay(
                              context,
                              'Group name cannot be empty',
                              themeData.errorColor,
                            );
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              themeData.colorScheme.primary),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                        child: Text(
                          'Save',
                          style: themeData.textTheme.bodySmall,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: buildAppBar(themeData, size),
      body: buildBody(themeData, size),
    );
  }
}
