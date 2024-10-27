import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:task_hub/data/repository/note_repository.dart';

import '../../../../app/routes.dart';
import '../../../../cubits/auth_cubit.dart';
import '../../../../cubits/fetch_note_cubit.dart';
import '../../../../data/models/note.dart';
import '../../../../utils/ui_utils.dart';
import '../../../styles/colors.dart';
import '../../../widgets/custom_shimmer_container.dart';
import '../../../widgets/custom_sliver_app_bar.dart';
import '../../../widgets/error_container.dart';
import '../../../widgets/shimmer_loading_container.dart';

class NoteContainer extends StatefulWidget {
  const NoteContainer({super.key});

  @override
  State<NoteContainer> createState() => _NoteContainerState();
}

class _NoteContainerState extends State<NoteContainer> {
  bool isGrid = true;
  bool isLongPressed = false;
  List<Note> selectedNotes = [];
  List<Note> fetchedNotes = [];

  int numberOfGridItems() {
    if (isGrid) {
      return MediaQuery.of(context).orientation == Orientation.landscape
          ? 3
          : 2;
    } else {
      return 1;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, () {
      context
          .read<FetchNoteCubit>()
          .fetchNotes(userId: context.read<AuthCubit>().getUserDetails().id);
    });
  }

  Widget buildBody(ThemeData themeData, Size size, List<Note> notes) {
    List<Note> pinnedNotes = notes.where((note) => note.isPinned).toList();
    List<Note> unPinnedNotes = notes.where((note) => !note.isPinned).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (pinnedNotes.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 5, left: 20),
            child: Text(
              'Pinned Notes',
              style: TextStyle(
                fontSize: UiUtils.screenSubTitleFontSize - 1,
              ),
            ),
          ),
        if (pinnedNotes.isNotEmpty) buildNotes(themeData, size, pinnedNotes),
        if (pinnedNotes.isNotEmpty)
          const SizedBox(
            height: 10,
          ),
        if (pinnedNotes.isNotEmpty && unPinnedNotes.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 5, left: 20),
            child: Text(
              'Others',
              style: TextStyle(
                fontSize: UiUtils.screenSubTitleFontSize - 1,
              ),
            ),
          ),
        buildNotes(themeData, size, unPinnedNotes),
      ],
    );
  }

  Widget buildNotes(ThemeData themeData, Size size, List<Note> notes) {
    return Container(
      // height: size.height,
      padding: const EdgeInsets.all(8.0),
      // width: double.infinity,
      child: StaggeredGrid.count(
        crossAxisCount: numberOfGridItems(),
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
        children: notes
            .map(
              (note) => buildNoteItem(note, themeData, size),
            )
            .toList(),
      ),
    );
  }

  Widget buildNoteItem(Note note, ThemeData themeData, Size size) {
    List<TodoItem> notCompletedToDoItems = note.todoItems != null
        ? note.todoItems!.where((item) => item.isCompleted == false).toList()
        : [];
    List<TodoItem> completedToDoItems = note.todoItems != null
        ? note.todoItems!.where((item) => item.isCompleted == true).toList()
        : [];
    return Dismissible(
      key: Key(note.id),
      onDismissed: (direction) {
        note.isArchived = !note.isArchived;
        fetchedNotes.remove(note);
        selectedNotes.remove(note);
        setState(() {});
        UiUtils.showSnackBar(context, 'Note archived', successColor,
            label: 'Undo', onPressed: () {
          note.isArchived = !note.isArchived;
          fetchedNotes.add(note);
          setState(() {});
        });
      },
      child: GestureDetector(
        onLongPress: () {
          if (!selectedNotes.contains(note)) {
            isLongPressed = true;
            setState(() {
              selectedNotes.add(note);
            });
          } else {
            isLongPressed = true;
            setState(() {
              selectedNotes.remove(note);
            });
          }
          if (selectedNotes.isEmpty) {
            isLongPressed = false;
          }
        },
        onTap: () {
          if (isLongPressed && selectedNotes.isNotEmpty) {
            if (!selectedNotes.contains(note)) {
              setState(() {
                selectedNotes.add(note);
              });
            } else {
              setState(() {
                selectedNotes.remove(note);
              });
            }
          } else {
            Navigator.pushNamed(context, Routes.addOrEditNote, arguments: note);
          }
          if (selectedNotes.isEmpty) {
            isLongPressed = false;
          }
        },
        child: Container(
          padding: const EdgeInsets.all(5.0),
          constraints: BoxConstraints(
            minHeight: 40,
            maxHeight: size.height * 0.8,
          ),
          decoration: BoxDecoration(
            color: note.color == null || note.color!.isEmpty
                ? Colors.transparent
                : Color(note.color!.hashCode),
            border: Border.all(
              color: selectedNotes.contains(note)
                  ? themeData.primaryColorLight
                  : note.color!.isEmpty
                      ? Colors.grey.shade400
                      : Colors.transparent,
              width: selectedNotes.contains(note) ? 3 : 1,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: IntrinsicHeight(
            child: ListTile(
              contentPadding: const EdgeInsets.all(8),
              title: note.title.isNotEmpty
                  ? Text(
                      note.title,
                      style: TextStyle(
                        fontSize: UiUtils.screenTitleFontSize - 2,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
              subtitle: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!note.isTodo)
                    Text(
                      note.content.toString(),
                      maxLines: 10,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: UiUtils.screenSubTitleFontSize - 1,
                        color: themeData.textTheme.titleSmall!.color,
                      ),
                    ),
                  if (note.isTodo && note.todoItems != null)
                    Column(
                      children: List.generate(
                        notCompletedToDoItems.length >= 10
                            ? 10
                            : notCompletedToDoItems.length,
                        (index) {
                          var item = notCompletedToDoItems[index];
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              if (!item.isCompleted)
                                Icon(
                                  Icons.check_box_outline_blank,
                                  size: 13,
                                  color: themeData.textTheme.titleSmall!.color,
                                ),
                              if (!item.isCompleted) const SizedBox(width: 2),
                              if (!item.isCompleted)
                                Text(
                                  item.task,
                                  style: TextStyle(
                                    fontSize:
                                        UiUtils.screenSubTitleFontSize - 1,
                                    color:
                                        themeData.textTheme.titleSmall!.color,
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  if (completedToDoItems.isNotEmpty) const SizedBox(height: 5),
                  if (completedToDoItems.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.only(left: 3),
                      child: Row(
                        children: [
                          Icon(
                            Icons.add,
                            size: 10,
                            color: themeData.textTheme.titleSmall!.color!
                                .withOpacity(0.7),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            completedToDoItems.length > 1
                                ? '${completedToDoItems.length} ticked items'
                                : '${completedToDoItems.length} ticked item',
                            style: TextStyle(
                              fontSize: UiUtils.screenSubTitleFontSize - 3.5,
                              color: themeData.textTheme.titleSmall!.color!
                                  .withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (note.tags.isNotEmpty) const SizedBox(height: 5),
                  if (note.tags.isNotEmpty)
                    Wrap(
                      spacing: 5,
                      runSpacing: 0,
                      children: List.generate(
                        note.tags.length >= 3 ? 3 : note.tags.length,
                        (index) {
                          int tagsPlus = 0;
                          if (note.tags.length > 3) {
                            tagsPlus = note.tags.length - 2;
                          }
                          return Chip(
                            side: const BorderSide(
                              color: Colors.transparent,
                              width: 0,
                            ),
                            padding: const EdgeInsets.all(0),
                            labelPadding:
                                const EdgeInsets.symmetric(horizontal: 5),
                            elevation: 0,
                            color: MaterialStateColor.resolveWith(
                              (states) =>
                                  note.color != null && note.color!.isNotEmpty
                                      ? Color(note.color!.hashCode - 0xFD000)
                                          .withOpacity(0.5)
                                      : themeData.textTheme.bodySmall!.color!
                                          .withOpacity(0.2),
                            ),
                            surfaceTintColor: Colors.transparent,
                            visualDensity: VisualDensity.compact,
                            label: Text(
                              note.tags.length > 3 && index == 2
                                  ? '+$tagsPlus'
                                  : note.tags[index],
                              style: TextStyle(
                                fontSize: UiUtils.screenSubTitleFontSize - 5,
                                color: themeData.textTheme.titleSmall!.color,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildAppBar(ThemeData themeData, Size size) {
    return CustomSliverAppBar(
      titleText: '',
      isBackButtonShown: false,
      titleWidget: Container(
        width: MediaQuery.sizeOf(context).width,
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
        margin: const EdgeInsets.only(top: 10),
        alignment: Alignment.bottomCenter,
        decoration: BoxDecoration(
          color: themeData.appBarTheme.backgroundColor,
          borderRadius: BorderRadius.circular(60),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.menu,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Text(
                  'Search your notes',
                  style: TextStyle(
                    fontSize: UiUtils.screenTitleFontSize - 1.5,
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  isGrid = !isGrid;
                });
              },
              icon: Icon(
                isGrid ? Icons.list : Icons.grid_view,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12.0, left: 10),
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
        ),
      ),
      expandedHeight: 70.0,
      pinned: false,
      floating: false,
    );
  }

  Widget buildNoteItemShimmer(Size size) {
    return Container(
      padding: const EdgeInsets.all(5.0),
      constraints: BoxConstraints(
        minHeight: 40,
        maxHeight: size.height * 0.8,
      ),
      decoration: BoxDecoration(
        color: shimmerContentColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: IntrinsicHeight(
        child: ShimmerLoadingContainer(
          child: ListTile(
            contentPadding: const EdgeInsets.all(8),
            title: CustomShimmerContainer(
              height: 20,
              width: size.width * 0.6,
            ),
            subtitle: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                CustomShimmerContainer(
                  height: 14,
                  width: size.width * 0.8,
                ),
                const SizedBox(height: 8),
                CustomShimmerContainer(
                  height: 14,
                  width: size.width * 0.7,
                ),
                const SizedBox(height: 8),
                CustomShimmerContainer(
                  height: 14,
                  width: size.width * 0.5,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 5,
                  children: List.generate(2, (index) {
                    return const CustomShimmerContainer(
                      height: 20,
                      width: 50,
                      borderRadius: 5,
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildNotesShimmer(Size size) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: StaggeredGrid.count(
        crossAxisCount: numberOfGridItems(),
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
        children: List.generate(
          7,
          (index) => buildNoteItemShimmer(size),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    var size = MediaQuery.sizeOf(context);
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Container(
        padding: EdgeInsets.only(
            right: 10, bottom: MediaQuery.of(context).padding.bottom),
        child: FloatingActionButton(
          isExtended: true,
          onPressed: () {
            Navigator.pushNamed(context, Routes.addOrEditNote);
          },
          child: const Icon(Icons.add),
        ),
      ),
      appBar: selectedNotes.isNotEmpty
          ? AppBar(
              leading: IconButton(
                onPressed: () {
                  setState(() {
                    selectedNotes.clear();
                  });
                },
                icon: const Icon(Icons.close),
              ),
              title: Text(
                selectedNotes.length.toString(),
                style: TextStyle(fontSize: UiUtils.screenTitleFontSize + 2),
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    for (var note in selectedNotes) {
                      note.isPinned = !note.isPinned;
                    }
                    selectedNotes.clear();
                    setState(() {});
                  },
                  icon: const Icon(Icons.push_pin),
                ),
                IconButton(
                  onPressed: () {
                    // Navigator.pushNamed(context, Routes.addOrEditNote);
                  },
                  icon: const Icon(Icons.notification_add_outlined),
                ),
                IconButton(
                  onPressed: () {
                    // Navigator.pushNamed(context, Routes.addOrEditNote);
                  },
                  icon: const Icon(Icons.color_lens_outlined),
                ),
                IconButton(
                  onPressed: () {
                    // Navigator.pushNamed(context, Routes.addOrEditNote);
                  },
                  icon: const Icon(Icons.label_outline),
                ),
                IconButton(
                  onPressed: () {
                    showMenu(
                      context: context,
                      position: const RelativeRect.fromLTRB(1, 0, 0, 0),
                      items: [
                        const PopupMenuItem(
                          child: Text('Archive'),
                        ),
                        const PopupMenuItem(
                          child: Text('Delete'),
                        ),
                      ],
                    );
                  },
                  icon: const Icon(Icons.more_vert),
                ),
              ],
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () {
          return Future.delayed(Duration.zero, () {
            context.read<FetchNoteCubit>().fetchNotes(
                userId: context.read<AuthCubit>().getUserDetails().id);
          });
        },
        displacement: MediaQuery.of(context).padding.top,
        child: Container(
          width: size.width,
          margin:
              EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
          constraints: BoxConstraints(
            // minWidth: size.width,
            // maxWidth: size.width * 10,
            minHeight: size.height,
            maxHeight: double.infinity,
          ),
          child: IntrinsicHeight(
            child: IntrinsicWidth(
              child: CustomScrollView(
                slivers: [
                  if (selectedNotes.isEmpty) buildAppBar(themeData, size),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        return BlocBuilder<FetchNoteCubit, FetchNoteState>(
                          builder: (context, state) {
                            if (state is FetchNoteInProgress) {
                              return buildNotesShimmer(size);
                            }
                            if (state is FetchNoteFailure) {
                              return ErrorContainer(
                                errorMessageText: state.errorMessage,
                                onTapRetry: () {
                                  context.read<FetchNoteCubit>().fetchNotes(
                                      userId: context
                                          .read<AuthCubit>()
                                          .getUserDetails()
                                          .id);
                                },
                              );
                            }
                            if (state is FetchNoteSuccess) {
                              // fetchedNotes = state.notes
                              //     .where((note) => !note.isArchived)
                              //     .toList();
                              return StreamBuilder(
                                builder: (context, snapshot) {
                                  return buildBody(themeData, size, snapshot.data ?? []);
                                }, stream: state.notes,
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        );
                      },
                      childCount: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      // drawer: DrawerContainer(),
    );
  }
}
