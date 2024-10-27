import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_hub/data/models/note.dart';
import 'package:task_hub/utils/ui_utils.dart';

import '../../cubits/auth_cubit.dart';
import '../../cubits/create_note_cubit.dart';
import '../../cubits/delete_note_cubit.dart';
import '../../cubits/edit_note_cubit.dart';
import '../../cubits/fetch_note_cubit.dart';
import '../../data/repository/auth_repository.dart';
import '../../data/repository/note_repository.dart';

class AddOrEditNotesScreen extends StatefulWidget {
  const AddOrEditNotesScreen({super.key, this.note});

  final Note? note;

  static Route route(RouteSettings routeSettings) {
    Note? note = routeSettings.arguments as Note?;
    return MaterialPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider<CreateNoteCubit>(
            create: (context) => CreateNoteCubit(NoteRepository(), AuthRepository()),
          ),
          BlocProvider<EditNoteCubit>(
            create: (context) => EditNoteCubit(NoteRepository()),
          ),
          BlocProvider<FetchNoteCubit>(
            create: (context) => FetchNoteCubit(NoteRepository()),
          ),
          BlocProvider<DeleteNoteCubit>(
            create: (context) => DeleteNoteCubit(NoteRepository()),
          ),
        ],
        child: AddOrEditNotesScreen(note: note),
      ),
    );
  }

  @override
  State<AddOrEditNotesScreen> createState() => _AddOrEditNotesScreenState();
}

class _AddOrEditNotesScreenState extends State<AddOrEditNotesScreen> {
  Note? note;
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  List<TextEditingController> completedTodoControllers = [];
  List<TextEditingController> notCompletedTodoControllers = [];
  bool isExpanded = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    note = widget.note;
    if (note != null) {
      Future.delayed(Duration.zero).then((value) {
        context.read<FetchNoteCubit>().fetchNotes(
            userId: context.read<AuthCubit>().getUserDetails().email);
        context.read<FetchNoteCubit>().getNotes().listen((event) {
          note = event.firstWhere((element) => element.id == note!.id);
        });

      });
    } else {
      note = Note(
        id: '',
        title: '',
        content: '',
        createdBy: context.read<AuthCubit>().getUserDetails().id,
      );
    }
  }

  void _createOrUpdateNote() {
    if (note!.id.isEmpty) {
      context.read<CreateNoteCubit>().createNote(
            note: note!,
          );
    } else {
      context.read<EditNoteCubit>().editNote(
            note: note!,
          );
    }
  }

  void updateNote() {
    context.read<EditNoteCubit>().editNote(
          note: note!,
        );
  }


  Widget buildTitle(ThemeData themeData, Size size) {
    titleController = TextEditingController(text: note!.title ?? '');
    return Container(
      constraints: const BoxConstraints(
        maxHeight: double.infinity,
      ),
      child: IntrinsicHeight(
        child: TextField(
          expands: true,
          maxLines: null,
          style: themeData.textTheme.titleLarge,
          decoration: const InputDecoration(
            hintText: 'Title',
            border: InputBorder.none,
          ),
          textInputAction: TextInputAction.next,
          controller: titleController,
          onChanged: (value) {
            note!.title = value;
            _createOrUpdateNote();
          },
        ),
      ),
    );
  }

  Widget buildContent(ThemeData themeData, Size size) {
    contentController = TextEditingController(text: note!.content ?? '');
    return Container(
      constraints: const BoxConstraints(
        maxHeight: double.infinity,
      ),
      child: IntrinsicHeight(
        child: TextField(
          expands: true,
          autofocus: note!.content!.isEmpty ? true : false,
          maxLines: null,
          style: TextStyle(
            fontSize: UiUtils.screenSubTitleFontSize + 2,
            fontWeight: FontWeight.w400,
            color: themeData.textTheme.bodyLarge!.color,
          ),
          decoration: const InputDecoration(
            hintText: 'Note',
            border: InputBorder.none,
          ),
          textInputAction: TextInputAction.done,
          controller: contentController,
          onChanged: (value) {
            note!.content = value;
            _createOrUpdateNote();
          },
        ),
      ),
    );
  }

  Widget buildToDOs(ThemeData themeData, Size size) {
    var completedTodoItems =
        note!.todoItems!.where((element) => element.isCompleted).toList();
    var notCompletedTodoItems =
        note!.todoItems!.where((element) => !element.isCompleted).toList();
    completedTodoControllers = List.generate(
      completedTodoItems.length,
      (index) => TextEditingController(text: completedTodoItems[index].task),
    );
    notCompletedTodoControllers = List.generate(
      notCompletedTodoItems.length,
      (index) => TextEditingController(text: notCompletedTodoItems[index].task),
    );
    return Container(
      alignment: Alignment.centerLeft,
      constraints: const BoxConstraints(
        maxHeight: double.infinity,
      ),
      child: IntrinsicHeight(
        child: Column(
          children: [
            if (notCompletedTodoItems.isNotEmpty)
              ...List.generate(
                notCompletedTodoItems.length,
                (index) {
                  return buildToDoItem(
                      themeData,
                      size,
                      notCompletedTodoItems[index],
                      notCompletedTodoControllers[index],
                      false);
                },
              ),
            if (notCompletedTodoItems.isNotEmpty)
              TextButton.icon(
                onPressed: () {
                  // FocusScope.of(context).nextFocus();
                  note!.todoItems!.add(TodoItem(task: '', isCompleted: false));
                  notCompletedTodoControllers.add(TextEditingController());
                  setState(() {});
                },
                icon: Icon(
                  Icons.add,
                  color: themeData.textTheme.titleSmall!.color,
                ),
                label: Text(
                  'List item',
                  style: TextStyle(
                    color: themeData.textTheme.titleSmall!.color,
                  ),
                ),
              ),
            if (completedTodoItems.isNotEmpty)
              InkWell(
                onTap: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Icon(isExpanded
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_up),
                      SizedBox(width: 10),
                      Text(
                        '${completedTodoItems.length} checked items',
                        style: TextStyle(
                          color: themeData.textTheme.titleSmall!.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (completedTodoItems.isNotEmpty && isExpanded)
              ...List.generate(
                completedTodoItems.length,
                (index) {
                  return buildToDoItem(
                      themeData,
                      size,
                      completedTodoItems[index],
                      completedTodoControllers[index],
                      true);
                },
              ),
            if (completedTodoItems.isNotEmpty)
              TextButton.icon(
                onPressed: () {
                  note!.todoItems!.add(TodoItem(task: '', isCompleted: true));
                  completedTodoControllers.add(TextEditingController());
                  setState(() {});
                },
                icon: Icon(
                  Icons.add,
                  color: themeData.textTheme.titleSmall!.color,
                ),
                label: Text(
                  'List item',
                  style: TextStyle(
                    color: themeData.textTheme.titleSmall!.color,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildToDoItem(ThemeData themeData, Size size, TodoItem todoItem,
      TextEditingController controller, isCompleted) {
    return Row(
      children: [
        Checkbox(
          value: todoItem.isCompleted,
          onChanged: (value) {
            todoItem.isCompleted = value!;
            _createOrUpdateNote();
            setState(() {});
          },
        ),
        Expanded(
          child: TextField(
            autofocus: todoItem.task.isEmpty ? true : false,
            style: TextStyle(
              decoration: isCompleted
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
              fontSize: UiUtils.screenSubTitleFontSize,
              color: isCompleted
                  ? Colors.grey
                  : themeData.textTheme.bodyLarge!.color,
            ),
            decoration: const InputDecoration(
              hintText: '',
              border: InputBorder.none,
            ),
            onAppPrivateCommand: (command, arguments) {
              print('command: $command, arguments: $arguments');
            },
            textInputAction: TextInputAction.next,
            onSubmitted: (value) {
              FocusScope.of(context).nextFocus();
              // if (todoItem.task.isNotEmpty) {
              //   note!.todoItems!.add(TodoItem(task: '', isCompleted: isCompleted));
              //   isCompleted
              //       ? completedTodoControllers.add(TextEditingController())
              //       : notCompletedTodoControllers.add(TextEditingController());
              //   setState(() {});
              // }
            },
            controller: controller,
            onChanged: (value) {
              todoItem.task = value;
              if (todoItem.task.isEmpty) {
                setState(() {
                  note!.todoItems!.remove(todoItem);
                  if (isCompleted) {
                    completedTodoControllers.remove(controller);
                  } else {
                    notCompletedTodoControllers.remove(controller);
                  }
                  FocusScope.of(context).previousFocus();
                });
              }
              _createOrUpdateNote();
            },
          ),
        ),
      ],
    );
  }

  Widget buildReminderAndTags(ThemeData themeData, Size size) {
    var tags = note!.tags;
    var reminder = note!.reminder;
    return Container(
      alignment: Alignment.centerLeft,
      constraints: const BoxConstraints(
        maxHeight: double.infinity,
      ),
      child: IntrinsicHeight(
        child: Wrap(spacing: 10, runSpacing: 5, children: [
          if (reminder != null &&
              reminder.toString().isNotEmpty &&
              reminder.isAfter(DateTime.now()))
            buildReminderOrTagItem(themeData, size, reminder.toString(), true),
          if (tags.isNotEmpty)
            ...List.generate(
              tags.length,
              (index) {
                return buildReminderOrTagItem(
                    themeData, size, tags[index], false);
              },
            ),
        ]),
      ),
    );
  }

  Widget buildReminderOrTagItem(
      ThemeData themeData, Size size, String text, bool isReminder) {
    return GestureDetector(
      onTap: () {
        if (isReminder) {
        } else {}
      },
      child: Chip(
        side: const BorderSide(
          color: Colors.transparent,
          width: 0,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        // labelPadding: const EdgeInsets.symmetric(horizontal: 10),
        elevation: 0,
        color: MaterialStateColor.resolveWith(
          (states) => note!.color != null && note!.color!.isNotEmpty
              ? Color(note!.color!.hashCode - 0xFD000).withOpacity(0.5)
              : themeData.textTheme.bodySmall!.color!.withOpacity(0.2),
        ),
        surfaceTintColor: Colors.transparent,
        // visualDensity: VisualDensity.compact,
        label: Text(
          text,
          style: TextStyle(
            fontSize: UiUtils.screenSubTitleFontSize,
            color: themeData.textTheme.titleSmall!.color,
          ),
        ),
      ),
    );
  }

  Widget buildBottomMenu(ThemeData themeData, Size size, Note note) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add_box_outlined),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.color_lens_outlined),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.font_download_outlined),
          ),
          Expanded(
            flex: 4,
            child: TextButton(
              onPressed: null,
              child: Text(
                'Edited ${note.updatedAt.day} days ago jwh hwe jka saj',
                softWrap: true,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
    );
  }

  AppBar buildAppBar(Note? note) {
    return AppBar(
      leading: IconButton(
        onPressed: () {
          if (note!.title.isEmpty && note.content!.isEmpty &&
              note.todoItems == null) {
            context.read<DeleteNoteCubit>().deleteNote(
                  noteId: note.id,
                );
          }
          Navigator.pop(context);
        },
        icon: const Icon(Icons.arrow_back),
      ),
      backgroundColor: Colors.transparent,
      actions: [
        IconButton(
          onPressed: () {
            note.isPinned = !note.isPinned;
            setState(() {});
          },
          icon: Icon(
            note!.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
          ),
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
          icon: const Icon(Icons.archive_outlined),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    var size = MediaQuery.sizeOf(context);
    Note note = this.note!;
    var bodyHeight = size.height;
    titleController.selection = TextSelection.fromPosition(
      TextPosition(offset: titleController.text.length),
    );
    return BlocConsumer<FetchNoteCubit, FetchNoteState>(
      listener: (context, state) {
        if (state is FetchNoteSuccess) {
          List<Note> notes = [];
          state.notes.listen((event) {
            notes = event;
            note = notes.firstWhere((element) => element.id == note.id);
            setState(() {});
          });
        }
      },
      builder: (context, state) {
        return Scaffold(
          // resizeToAvoidBottomInset: false,
          persistentFooterAlignment: AlignmentDirectional.topStart,
          persistentFooterButtons: [
            buildBottomMenu(themeData, size, note),
          ],
          backgroundColor: note.color == null || note.color!.isEmpty
              ? themeData.scaffoldBackgroundColor
              : Color(note.color.hashCode),
          appBar: buildAppBar(note),
          body: Container(
            // height: size.height * 0.9,
            constraints: BoxConstraints(
              minHeight: bodyHeight,
              maxHeight: double.infinity,
            ),
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              primary: true,
              child: Column(
                children: [
                  buildTitle(themeData, size),
                  if (!note.isTodo) buildContent(themeData, size),
                  if (note.isTodo) buildToDOs(themeData, size),
                  buildReminderAndTags(themeData, size),
                  // SingleChildScrollView(
                  //   physics: NeverScrollableScrollPhysics(),
                  //   child: Align(
                  //     alignment: Alignment.bottomCenter,
                  //     child: buildBottomMenu(themeData, size),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
