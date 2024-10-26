import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/routes.dart';
import '../../../cubits/auth_cubit.dart';
import '../../../cubits/fetch_note_cubit.dart';
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
        ],
        child: const HomeScreen(),
      ),
    );
  }
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late TabController _tabController;

  final List<Widget> _screens = [const NoteContainer(), const ChatContainer()];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
