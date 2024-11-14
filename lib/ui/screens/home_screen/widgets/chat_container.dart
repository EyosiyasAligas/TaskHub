import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_hub/cubits/auth_cubit.dart';
import 'package:task_hub/cubits/create_group_cubit.dart';
import 'package:task_hub/data/models/group.dart';
import 'package:task_hub/data/repository/note_repository.dart';

import '../../../../app/routes.dart';
import '../../../../blocs/fetch_groups/fetch_groups_bloc.dart';
import '../../../../cubits/fetch_group_cubit.dart';
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
  List<bool> isUserSelected = [];

  var currentTabIndex = 0;

  TextEditingController groupNameController = TextEditingController();
  TextEditingController groupMembersController = TextEditingController();

  //add shade of  600 colors to the list

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.delayed(Duration.zero, () async {
      users = await context.read<AuthCubit>().fetchUsers();
      isUserSelected = List.generate(users.length, (index) => false);
      print('Users from chat: $users');
      // context.read<FetchGroupsBloc>().add(FetchGroups());
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _tabController.dispose();
    groupMembersController.dispose();
    groupNameController.dispose();
  }

  void createGroup(Group group) {
    context.read<CreateGroupCubit>().createGroup(groupData: group);
  }

  Widget buildAddGroup(ThemeData themeData, Size size) {
    return StatefulBuilder(builder: (context, setStat) {
      return SingleChildScrollView(
        child: Container(
          height: size.height * 0.8,
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
                      'Create Group',
                      style: themeData.textTheme.bodyLarge,
                    ),
                    TextField(
                      controller: groupNameController,
                      decoration: const InputDecoration(
                        hintText: 'Group Name',
                      ),
                      onChanged: (value) {
                        setStat(() {});
                      },
                    ),
                    const SizedBox(height: 25),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Users',
                          // style: themeData.textTheme.bodySmall,
                        ),
                        const SizedBox(height: 5),
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
                              subtitle: Divider(),
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
                          if (groupNameController.text.isNotEmpty) {
                            List<String> selectedUsers = [];
                            selectedUsers = users
                                .where((element) =>
                                    isUserSelected[users.indexOf(element)])
                                .map((e) => e.id)
                                .toList();
                            selectedUsers.add(
                                context.read<AuthCubit>().getUserDetails().id);
                            createGroup(
                              Group(
                                name: groupNameController.text,
                                members: selectedUsers,
                                id: '',
                                creatorId: context
                                    .read<AuthCubit>()
                                    .getUserDetails()
                                    .id,
                                lastMessage: '',
                                lastMessageTime: '',
                              ),
                            );
                            Navigator.pop(context);
                            UiUtils.showSnackBar(
                              context,
                              'Group Created',
                              successColor,
                            );
                            isUserSelected =
                                List.generate(users.length, (index) => false);
                            groupNameController.clear();
                          } else {
                            UiUtils.showOverlay(
                              context,
                              'Group name cannot be empty',
                              themeData.colorScheme.error,
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
                          'Create Group',
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
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    _tabController.addListener(() {
      currentTabIndex = _tabController.index;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    currentTabIndex = _tabController.index;

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: currentTabIndex == 1
          ? Container(
              padding: EdgeInsets.only(
                  right: 10, bottom: MediaQuery.of(context).padding.bottom),
              child: FloatingActionButton(
                isExtended: true,
                onPressed: () {
                  UiUtils.showBottomSheet(
                      child: buildAddGroup(themeData, size), context: context);
                },
                child: const Icon(Icons.add),
              ),
            )
          : null,
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
          onTap: (index) {
            context.read<FetchGroupsBloc>().add(FetchGroups());
            _tabController.addListener(() {
              setState(() {
                currentTabIndex = _tabController.index;
              });
            });
          },
          controller: _tabController,
          tabs: const [
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
        child: TabBarView(
          dragStartBehavior: DragStartBehavior.start,
          controller: _tabController,
          children: [
            FutureBuilder(
                future: context.read<AuthCubit>().fetchUsers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return SingleChildScrollView(
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
                              padding:
                                  const EdgeInsets.only(right: 22.0, left: 5),
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 28,
                                    backgroundColor: UiUtils.colors[
                                        index % UiUtils.colors.length + 1],
                                    child: Text(
                                      snapshot.data![index].userName.characters
                                          .first
                                          .toUpperCase(),
                                      style: TextStyle(
                                        fontSize:
                                            UiUtils.screenTitleFontSize + 4,
                                        color:
                                            themeData.colorScheme.onSecondary,
                                      ),
                                    ),
                                  ),
                                  StreamBuilder(
                                      stream: FirebaseDatabase.instance
                                          .ref(
                                              'users/${snapshot.data![index].id}/isOnline')
                                          .onValue,
                                      builder: (context, streamSnapshot) {
                                        bool isReceiverOnline = false;
                                        streamSnapshot.data?.snapshot.value
                                                    .toString() ==
                                                'true'
                                            ? isReceiverOnline = true
                                            : isReceiverOnline = false;
                                        //print id
                                        print(
                                            'id: ${snapshot.data![index].id}');
                                        print(
                                            'isReceiverOnline: ${streamSnapshot.data?.snapshot.value.toString()}');
                                        if (isReceiverOnline) {
                                          return Positioned(
                                            right: 0,
                                            bottom: 0,
                                            child: Container(
                                              height: 10,
                                              width: 10,
                                              decoration: const BoxDecoration(
                                                color: Colors.green,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          );
                                        }
                                        return const SizedBox();
                                      }),
                                ],
                              ),
                            ),
                            title: Text(snapshot.data![index].userName),
                            trailing: const Text('3:46 PM'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(snapshot.data![index].email),
                                const Divider(),
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
                  );
                }),
            BlocConsumer<FetchGroupsBloc, FetchGroupsState>(
              listener: (context, state) {
                if (state is FetchGroupsInitial) {
                  context.read<FetchGroupsBloc>().add(FetchGroups());
                }
                if (state is FetchGroupsFailure) {
                  UiUtils.showSnackBar(context, state.errorMessage, Colors.red);
                }
              },
              builder: (context, state) {
                // if (state is FetchGroupsInitial) {
                //   return const Center(child: CircularProgressIndicator());
                // }
                if (state is FetchGroupsInProgress) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is FetchGroupsFailure) {
                  return Center(
                    child: Text(state.errorMessage),
                  );
                }
                if (state is FetchGroupsSuccess) {
                  List<Group> groups = state.groups;
                  // check if user id is in the members and show only if true
                  print('Groups from UI: ${groups.first.name}');
                  groups = groups
                      .where((element) => element.members.contains(
                          context.read<AuthCubit>().getUserDetails().id))
                      .toList();
                  if (groups.isEmpty) {
                    return const Center(
                      child: Text('No group available'),
                    );
                  }
                  return Container(
                    // color: themeData.colorScheme.primary,
                    alignment: Alignment.topLeft,
                    padding: EdgeInsets.only(top: size.height * 0.02),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(groups.length, (index) {
                        return ListTile(
                          minVerticalPadding: 10,
                          leading: Padding(
                            padding:
                                const EdgeInsets.only(right: 22.0, left: 5),
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: UiUtils.colors[
                                      index % UiUtils.colors.length + 1],
                                  child: Text(
                                    groups[index]
                                        .name
                                        .characters
                                        .first
                                        .toUpperCase(),
                                    style: TextStyle(
                                      fontSize: UiUtils.screenTitleFontSize + 4,
                                      color: themeData.colorScheme.onSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          title: Text(groups[index].name),
                          trailing: Text(groups[index].lastMessageTime),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(groups[index].lastMessage),
                              const Divider(),
                            ],
                          ),
                          onTap: () {
                            Navigator.pushNamed(context, Routes.groupChatScreen,
                                arguments: groups[index]);
                          },
                        );
                      }),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ],
        ),
      ),
    );
  }
}
