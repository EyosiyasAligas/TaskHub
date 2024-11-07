import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_hub/cubits/auth_cubit.dart';
import 'package:task_hub/data/repository/note_repository.dart';

import '../../../../app/routes.dart';
import '../../../../data/models/user.dart';
import '../../../../utils/ui_utils.dart';
import '../../../styles/colors.dart';

class ChatContainer extends StatefulWidget {
  const ChatContainer({super.key});

  @override
  State<ChatContainer> createState() => _ChatContainerState();
}

class _ChatContainerState extends State<ChatContainer>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<UserModel> users = [];

  //add shade of  600 colors to the list

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.delayed(Duration.zero, () async {
      users = await context.read<AuthCubit>().fetchUsers();
      print('Users from chat: $users');
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.menu,
          ),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        title: const Text('Chat Screen'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 22.0),
            child: CircleAvatar(
              radius: 16.2,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                context
                    .read<AuthCubit>()
                    .getUserDetails()
                    .email
                    .characters
                    .first
                    .toUpperCase(),
                style: TextStyle(
                  fontSize: UiUtils.screenTitleFontSize,
                  color: themeData.colorScheme.onSecondary,
                ),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: 'Personal',
            ),
            Tab(
              text: 'Group',
            ),
          ],
        ),
      ),
      body: Container(
        // constraints: BoxConstraints(
        //   maxHeight: size.height,
        // ),
        child: FutureBuilder(
          future: context.read<AuthCubit>().fetchUsers(),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return Center(child: CircularProgressIndicator());
            return TabBarView(

              // dragStartBehavior: DragStartBehavior.start,
              controller: _tabController,
              children: [
                SingleChildScrollView(
                  child: Container(
                    // color: themeData.colorScheme.primary,
                    alignment: Alignment.topLeft,
                    padding: EdgeInsets.only(top: size.height * 0.02),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(snapshot.data!.length, (index) {
                        return ListTile(
                          minVerticalPadding: 10,
                          leading: Padding(
                            padding: const EdgeInsets.only(right: 22.0, left: 5),
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: UiUtils
                                      .colors[index % UiUtils.colors.length + 1],
                                  child: Text(
                                    snapshot
                                        .data![index].userName.characters.first
                                        .toUpperCase(),
                                    style: TextStyle(
                                      fontSize: UiUtils.screenTitleFontSize + 4,
                                      color: themeData.colorScheme.onSecondary,
                                    ),
                                  ),
                                ),
                                StreamBuilder(
                                  stream: FirebaseDatabase.instance
                                      .ref('users/${snapshot
                                      .data![index].id}/isOnline')
                                      .onValue,
                                  builder: (context, streamSnapshot) {
                                    bool isReceiverOnline = false;
                                    streamSnapshot.data?.snapshot.value.toString() == 'true'
                                        ? isReceiverOnline = true
                                        : isReceiverOnline = false;
                                    //print id
                                    print('id: ${snapshot.data![index].id}');
                                    print('isReceiverOnline: ${streamSnapshot.data?.snapshot.value.toString()}');
                                    if (isReceiverOnline) {
                                      return Positioned(
                                        child: Container(
                                          height: 10,
                                          width: 10,
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        right: 0,
                                        bottom: 0,
                                      );
                                    }
                                    return SizedBox();
                                  }
                                ),
                              ],
                            ),
                          ),
                          title: Text(snapshot.data![index].userName),
                          trailing: Text('3:46 PM'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(snapshot.data![index].email),
                              Divider(),
                            ],
                          ),
                          onTap: () {
                            Navigator.pushNamed(context, Routes.chatScreen,
                                arguments: snapshot.data![index]);
                          },
                        );
                      }),
                    ),
                  ),
                ),
                Tab(
                  text: 'Group',
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
