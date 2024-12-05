import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/routes.dart';
import '../../../blocs/fetch_groups/fetch_groups_bloc.dart';
import '../../../cubits/auth_cubit.dart';
import '../../../cubits/create_group_cubit.dart';
import '../../../cubits/create_note_cubit.dart';
import '../../../cubits/edit_note_cubit.dart';
import '../../../cubits/fetch_group_cubit.dart';
import '../../../cubits/fetch_note_cubit.dart';
import '../../../data/models/user.dart';
import '../../../data/repository/auth_repository.dart';
import '../../../data/repository/chat_repository.dart';
import '../../../data/repository/note_repository.dart';
import '../../widgets/drawer_container.dart';
import 'widgets/chat_container.dart';
import 'widgets/note_container.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();

  static Route route(RouteSettings routeSettings) {
    return MaterialPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider<FetchNoteCubit>(
            create: (_) => FetchNoteCubit(NoteRepository()),
          ),
          BlocProvider<CreateNoteCubit>(
            create: (_) => CreateNoteCubit(NoteRepository(), AuthRepository()),
          ),
          BlocProvider<EditNoteCubit>(
            create: (_) => EditNoteCubit(NoteRepository()),
          ),
          BlocProvider<FetchGroupCubit>(
            create: (_) => FetchGroupCubit(ChatRepository()),
          ),
          BlocProvider<CreateGroupCubit>(
            create: (_) => CreateGroupCubit(ChatRepository()),
          ),
          BlocProvider<FetchGroupsBloc>(
            create: (_) => FetchGroupsBloc(ChatRepository())..add(FetchGroups()),
          ),
        ],
        child: const HomeScreen(),
      ),
    );
  }
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  int _currentIndex = 0;
  late TabController _tabController;
  late UserModel sender;

  final List<Widget> _screens = [const NoteContainer(), const ChatContainer()];

  bool isInitStateCompleted = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    sender = context.read<AuthCubit>().getUserDetails();
    _setUserOnlineStatus(true);
    isInitStateCompleted = true;
  }

  @override
  void dispose() {
    _setUserOnlineStatus(false);
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached || state == AppLifecycleState.inactive || state == AppLifecycleState.hidden) {
      // WidgetsBinding.instance.removeObserver(this);
      _setUserOnlineStatus(false);
    } else if (state == AppLifecycleState.resumed) {
      // WidgetsBinding.instance.addObserver(this);
      _setUserOnlineStatus(true);
    }
  }

  void _setUserOnlineStatus(bool isOnline) {
    WidgetsBinding.instance.addObserver(this);
    context.read<AuthCubit>().setUserStatus(sender.id, isOnline);
  }

  Widget buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
          _tabController.index = index;
        });
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.event_note),
          label: 'Notes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Chat',
        ),
      ],
    );
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    _tabController.addListener(() {
      setState(() {
        _currentIndex = _tabController.index;
      });
    });

    // if (isInitStateCompleted) {
    //   WidgetsBinding.instance.addObserver(this);
    //   _setUserOnlineStatus(false);
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: TabBarView(
        controller: _tabController,
        children: _screens,
      ),
      bottomNavigationBar: buildBottomNavigationBar(),
      drawer: DrawerContainer(),
    );
  }
}
