import 'dart:convert';
import 'dart:ui';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
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
import '../styles/colors.dart';
import '../widgets/error_container.dart';

class AddOrEditNotesScreen extends StatefulWidget {
  const AddOrEditNotesScreen({super.key, this.noteId});

  final String? noteId;

  static Route route(RouteSettings routeSettings) {
    String? noteId = routeSettings.arguments as String?;
    return MaterialPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider<CreateNoteCubit>(
            create: (context) =>
                CreateNoteCubit(NoteRepository(), AuthRepository()),
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
        child: AddOrEditNotesScreen(noteId: noteId),
      ),
    );
  }

  @override
  State<AddOrEditNotesScreen> createState() => _AddOrEditNotesScreenState();
}

class _AddOrEditNotesScreenState extends State<AddOrEditNotesScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  List<TextEditingController> completedTodoControllers = [];
  List<TextEditingController> notCompletedTodoControllers = [];
  bool isExpanded = false;
  Note note = Note(
    id: '',
    title: '',
    content: '',
    createdAt: DateTime.now(),
    createdBy: '',
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.noteId != null) {
      // _fetchNote();
    } else {
      note = Note(
        id: '',
        title: '',
        content: '',
        createdAt: DateTime.now(),
        createdBy: context.read<AuthCubit>().getUserDetails().id,
      );
    }
  }

  void _fetchNote() {
    context
        .read<FetchNoteCubit>()
        .fetchSingleNotes(
          userId: context.read<AuthCubit>().getUserDetails().id,
          noteId: note.id,
        )
        .listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          note = Note.fromMap(
              Map<String, dynamic>.from(event.snapshot.value as Map));
        });
      }
    });
  }

  void _createOrUpdateNote(Note note) {
    if (note.id.isEmpty) {
      context.read<CreateNoteCubit>().createNote(
            note: note,
          );
      // _fetchNote();
    } else {
      context.read<EditNoteCubit>().editNote(
            note: note,
          );
    }
  }

  // void updateNote() {
  //   context.read<EditNoteCubit>().editNote(
  //         note: note!,
  //       );
  // }

  Widget buildTitle(ThemeData themeData, Size size, Note? note) {
    titleController = TextEditingController(text: note!.title ?? '');
    titleController.selection = TextSelection.fromPosition(
      TextPosition(offset: titleController.text.length),
    );
    return Container(
      constraints: const BoxConstraints(
        maxHeight: double.infinity,
      ),
      child: IntrinsicHeight(
        child: TextField(
          expands: true,
          maxLines: null,
          style: TextStyle(
            fontSize: themeData.textTheme.titleLarge!.fontSize,
            color: themeData.textTheme.titleSmall!.color,
          ),
          decoration: InputDecoration(
            hintText: 'Title',
            suffix: note.isTodo
                ? IconButton(
                    onPressed: () {
                      //remove todo items from note
                      showMenu(
                        context: context,
                        position: const RelativeRect.fromLTRB(1, 0, 0, 0),
                        items: [
                          PopupMenuItem(
                            child: const Text('Remove checklist'),
                            onTap: () {
                              note.isTodo = false;
                              note.content = note.todoItems!
                                  .map((e) => e.task)
                                  .toList()
                                  .join('\n');
                              note.todoItems = null;
                              setState(() {});
                              _createOrUpdateNote(note);
                            },
                          ),
                        ],
                      );
                    },
                    icon: const Icon(
                      Icons.more_vert,
                    ),
                  )
                : null,
            border: InputBorder.none,
          ),
          textInputAction: TextInputAction.next,
          controller: titleController,
          onChanged: (value) {
            note.title = value;
            _createOrUpdateNote(note);
          },
        ),
      ),
    );
  }

  Widget buildContent(ThemeData themeData, Size size, Note? note) {
    contentController = TextEditingController(text: note!.content ?? '');
    contentController.selection = TextSelection.fromPosition(
      TextPosition(offset: contentController.text.length),
    );
    return Container(
      constraints: const BoxConstraints(
        maxHeight: double.infinity,
      ),
      child: IntrinsicHeight(
        child: TextField(
          expands: true,
          autofocus: note.content!.isEmpty ? true : false,
          maxLines: null,
          style: TextStyle(
            fontSize: UiUtils.screenSubTitleFontSize + 2,
            fontWeight: FontWeight.w400,
            color: themeData.textTheme.titleSmall!.color,
          ),
          decoration: const InputDecoration(
            hintText: 'Note',
            border: InputBorder.none,
          ),
          textInputAction: TextInputAction.done,
          controller: contentController,
          onChanged: (value) {
            note.content = value;
            _createOrUpdateNote(note);
          },
        ),
      ),
    );
  }

  Widget buildToDOs(ThemeData themeData, Size size, Note? note) {
    var completedTodoItems =
        note!.todoItems!.where((element) => element.isCompleted).toList();
    var notCompletedTodoItems =
        note.todoItems!.where((element) => !element.isCompleted).toList();
    completedTodoControllers = List.generate(
      completedTodoItems.length,
      (index) => TextEditingController(text: completedTodoItems[index].task),
    );
    notCompletedTodoControllers = List.generate(
      notCompletedTodoItems.length,
      (index) => TextEditingController(text: notCompletedTodoItems[index].task),
    );
    notCompletedTodoControllers.forEach((element) {
      element.selection = TextSelection.fromPosition(
        TextPosition(offset: element.text.length),
      );
    });
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
                      false,
                      note);
                },
              ),
            if (notCompletedTodoItems.isNotEmpty)
              TextButton.icon(
                onPressed: () {
                  // FocusScope.of(context).nextFocus();
                  note.todoItems!.add(TodoItem(task: '', isCompleted: false));
                  notCompletedTodoControllers.add(TextEditingController());
                  _createOrUpdateNote(note);
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
                      const SizedBox(width: 10),
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
                      true,
                      note);
                },
              ),
            if (completedTodoItems.isNotEmpty)
              TextButton.icon(
                onPressed: () {
                  note.todoItems!.add(TodoItem(task: '', isCompleted: true));
                  completedTodoControllers.add(TextEditingController());
                  _createOrUpdateNote(note);
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
      TextEditingController controller, isCompleted, Note? note) {
    return Row(
      children: [
        Checkbox(
          value: todoItem.isCompleted,
          onChanged: (value) {
            todoItem.isCompleted = value!;
            _createOrUpdateNote(note!);
            setState(() {});
          },
        ),
        Expanded(
          child: TextField(
            autofocus: todoItem.task.isEmpty ? true : true,
            // focusNode: FocusNode(),
            style: TextStyle(
              decoration: isCompleted
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
              fontSize: UiUtils.screenSubTitleFontSize + 2,
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

              var isLast = note!.todoItems!.last.task == value;
              if(isLast) {
                note.todoItems!.add(TodoItem(task: '', isCompleted: isCompleted));
                isCompleted
                    ? completedTodoControllers.add(TextEditingController())
                    : notCompletedTodoControllers.add(TextEditingController());
              }

              FocusScope.of(context).nextFocus();
              FocusScope.of(context).nextFocus();
              _createOrUpdateNote(note);
              Future.delayed(Duration.zero).then((value) {
                if (true) {
                  FocusScope.of(context).previousFocus();
                }
              });
              // if (todoItem.task.isNotEmpty) {

              //   note!.todoItems!.add(TodoItem(task: '', isCompleted: isCompleted));
              //   isCompleted
              //       ? completedTodoControllers.add(TextEditingController())
              //       : notCompletedTodoControllers.add(TextEditingController());
              //   setState(() {});
              // }
            },
            controller: controller,
            onEditingComplete: () {
              print('Editing complete');
              // FocusScope.of(context).nextFocus();
              // FocusScope.of(context).nextFocus();
            },
            onChanged: (value) {
              todoItem.task = value;
              if (todoItem.task.isEmpty) {
                note!.todoItems!.remove(todoItem);
                if (isCompleted) {
                  completedTodoControllers.remove(controller);
                  FocusScope.of(context).previousFocus();
                  _createOrUpdateNote(note);
                  FocusScope.of(context).previousFocus();
                } else {
                  notCompletedTodoControllers.remove(controller);
                  FocusScope.of(context).previousFocus();
                  _createOrUpdateNote(note);
                  FocusScope.of(context).previousFocus();
                }
              }

            },
          ),
        ),
      ],
    );
  }

  Widget buildReminderAndTags(ThemeData themeData, Size size, Note? note) {
    var tags = note!.tags;
    var reminder = note.reminder;
    return Container(
      alignment: Alignment.centerLeft,
      constraints: const BoxConstraints(
        maxHeight: double.infinity,
      ),
      child: IntrinsicHeight(
        child: Wrap(spacing: 10, runSpacing: 5, children: [
          if (reminder != null && reminder.toString().isNotEmpty)
            buildReminderOrTagItem(
                themeData, size, UiUtils.getReminderTime(reminder), true, note),
          if (tags.isNotEmpty)
            ...List.generate(
              tags.length,
              (index) {
                return buildReminderOrTagItem(
                    themeData, size, tags[index], false, note);
              },
            ),
        ]),
      ),
    );
  }

  Widget buildReminderOrTagItem(ThemeData themeData, Size size, String text,
      bool isReminder, Note? note) {
    return GestureDetector(
      onTap: () async {
        if (isReminder) {
          var selectedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );
          if (selectedDate != null) {
            var selectedTime = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );
            if (selectedTime != null) {
              note!.reminder = DateTime(
                selectedDate.year,
                selectedDate.month,
                selectedDate.day,
                selectedTime.hour,
                selectedTime.minute,
              );
              setState(() {});
              _createOrUpdateNote(note);
            }
          }
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
          (states) => note!.color!.isNotEmpty && note.color!.isNotEmpty
              ? adjustColorIntensity(
                      note.color!, themeData.scaffoldBackgroundColor, context)
                  .withOpacity(0.5)
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
            onPressed: () {
              note.isTodo = true;
              if (note.content != null) {
                note.todoItems = note.content!
                    .split('\n')
                    .map((e) => TodoItem(task: e, isCompleted: false))
                    .toList();
                note.content = '';
              }
              setState(() {
                _createOrUpdateNote(note);
              });
            },
            icon: const Icon(Icons.add_box_outlined),
          ),
          IconButton(
            onPressed: () {
              UiUtils.showBottomSheet(
                  child: buildColorSelector(themeData, size, note),
                  context: context);
            },
            icon: const Icon(Icons.color_lens_outlined),
          ),
          Expanded(
            flex: 4,
            child: TextButton(
              onPressed: null,
              child: Text(
                'Edited ${UiUtils.getFormattedDate(note.updatedAt)}',
                style: TextStyle(
                  color: themeData.textTheme.titleSmall!.color,
                  fontSize: UiUtils.screenSubTitleFontSize - 2,
                ),
                softWrap: true,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              UiUtils.showBottomSheet(
                  child: buildMoreMenu(themeData, size, note),
                  context: context);
            },
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
    );
  }

  Widget buildColorSelector(ThemeData themeData, Size size, Note note) {
    return StatefulBuilder(builder: (context, setStat) {
      return Container(
        padding: const EdgeInsets.all(16),
        height: MediaQuery.of(context).orientation == Orientation.portrait
            ? size.height * 0.3
            : size.height * 0.5,
        color: note.color!.isNotEmpty
            ? adjustColorIntensity(
                note.color!, themeData.scaffoldBackgroundColor, context)
            : themeData.scaffoldBackgroundColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Color'),
            Container(
              height: MediaQuery.of(context).orientation == Orientation.portrait
                  ? size.height * 0.2
                  : size.height * 0.3,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(8),
                itemCount: noteColors.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      if (note.color !=
                          '0x${noteColors[index].value.toRadixString(16).padLeft(8, '0')}') {
                        note.color =
                            '0x${noteColors[index].value.toRadixString(16).padLeft(8, '0')}';
                        setStat(() {});
                        setState(() {});
                        _createOrUpdateNote(note);
                      }
                      if (noteColors[index] == Colors.transparent) {
                        note.color = '';
                        setStat(() {});
                        setState(() {});
                        _createOrUpdateNote(note);
                      } else {}
                    },
                    child: Container(
                      // padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          width: 2,
                          color: note.color!.isEmpty
                              ? themeData.primaryColorLight.withOpacity(0.5)
                              : note.color ==
                                      '0x${noteColors[index].value.toRadixString(16).padLeft(8, '0')}'
                                  ? Colors.white
                                  : Colors.transparent,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 25,
                        backgroundColor: noteColors[index] == Colors.transparent
                            ? themeData.scaffoldBackgroundColor.withOpacity(0.9)
                            : noteColors[index],
                        child: note.color!.isEmpty &&
                                noteColors[index] == Colors.transparent
                            ? const Icon(Icons.format_color_reset_outlined)
                            : note.color ==
                                    '0x${noteColors[index].value.toRadixString(16).padLeft(8, '0')}'
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                  )
                                : null,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget buildMoreMenu(ThemeData themeData, Size size, Note note) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        height: MediaQuery.of(context).orientation == Orientation.portrait
            ? size.height * 0.3
            : size.height * 0.5,
        color: note.color!.isNotEmpty
            ? adjustColorIntensity(
                note.color!, themeData.scaffoldBackgroundColor, context)
            : themeData.scaffoldBackgroundColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (note.createdBy == context.read<AuthCubit>().getUserDetails().id)
              Container(
                width: double.infinity,
                // alignment: Alignment.centerLeft,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  minVerticalPadding: 0,
                  visualDensity: VisualDensity.compact,
                  leading: Icon(
                    Icons.delete_outline,
                    color: themeData.iconTheme.color,
                    size: 22,
                  ),
                  title: Text(
                    'Delete',
                    style: TextStyle(
                        color: themeData.iconTheme.color,
                        fontSize: UiUtils.screenSubTitleFontSize + 2),
                  ),
                  onTap: () async {
                    print('Delete');
                    Navigator.pop(context);
                    Navigator.pop(context);
                    if (note.id.isNotEmpty) {
                      Future.delayed(Duration.zero).then((value) {
                        context.read<DeleteNoteCubit>().deleteNote(
                              noteId: note.id,
                            );
                      });
                    }
                    UiUtils.showSnackBar(
                      context,
                      'Note deleted',
                      successColor,
                    );
                  },
                ),
              ),
            if (note.createdBy == context.read<AuthCubit>().getUserDetails().id)
              const Divider(),
            Container(
              width: double.infinity,
              // alignment: Alignment.centerLeft,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                minVerticalPadding: 0,
                visualDensity: VisualDensity.compact,
                leading: Icon(
                  Icons.label_outline,
                  color: themeData.iconTheme.color,
                  size: 22,
                ),
                title: Text(
                  'Label',
                  style: TextStyle(
                      color: themeData.iconTheme.color,
                      fontSize: UiUtils.screenSubTitleFontSize + 2),
                ),
                onTap: () {
                  print('label');
                },
              ),
            ),
            if (note.createdBy == context.read<AuthCubit>().getUserDetails().id)
              const Divider(),
            if (note.createdBy == context.read<AuthCubit>().getUserDetails().id)
              Container(
                width: double.infinity,
                // alignment: Alignment.centerLeft,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  minVerticalPadding: 0,
                  visualDensity: VisualDensity.compact,
                  leading: Icon(
                    Icons.person_add_alt,
                    color: themeData.iconTheme.color,
                    size: 22,
                  ),
                  title: Text(
                    'Collaborators',
                    style: TextStyle(
                        color: themeData.iconTheme.color,
                        fontSize: UiUtils.screenSubTitleFontSize + 2),
                  ),
                  onTap: () {
                    print('Collaborators');
                    List<String> userEmails = [];
                    context.read<AuthCubit>().fetchUsers().then((value) {
                      userEmails = value.map((e) => e.email).toList();
                      print('userEmails: $userEmails');
                      Navigator.pop(context);
                      UiUtils.showBottomSheet(
                        child: buildCollaborators(
                            themeData, size, note, userEmails),
                        context: context,
                      );
                    });
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildCollaborators(
      ThemeData themeData, Size size, Note note, List<String> users) {
    List<String> collaborators = [];
    return StatefulBuilder(builder: (context, setStat) {
      return Container(
        padding: const EdgeInsets.all(16),
        height: MediaQuery.of(context).orientation == Orientation.portrait
            ? size.height * 0.5
            : size.height * 0.8,
        color: note.color!.isNotEmpty
            ? adjustColorIntensity(
                note.color!, themeData.scaffoldBackgroundColor, context)
            : themeData.scaffoldBackgroundColor,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Collaborators',
                style: themeData.textTheme.bodyLarge,
              ),
              const SizedBox(height: 5),
              Divider(
                color: themeData.colorScheme.secondary,
              ),
              const SizedBox(height: 5),
              ...List.generate(users.length, (index) {
                return GestureDetector(
                  onTap: () {
                    if (!note.collaborators.contains(users[index])) {
                      note.collaborators.add(users[index]);
                    } else {
                      note.collaborators.remove(users[index]);
                    }
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
                          color: note.collaborators.contains(users[index])
                              ? themeData.primaryColorLight
                              : themeData.colorScheme.onPrimary
                                  .withOpacity(0.5),
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.transparent,
                        child: Text(
                          users[index][0].toUpperCase(),
                          style: TextStyle(
                            color: themeData.textTheme.titleSmall!.color,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      users[index],
                      style: TextStyle(
                        color: themeData.textTheme.titleSmall!.color,
                      ),
                    ),
                    subtitle: Divider(),
                  ),
                );
              }),
              const SizedBox(height: 5),
              Container(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () {
                    _createOrUpdateNote(note);
                    Navigator.pop(context);
                    Navigator.pop(context);
                    UiUtils.showSnackBar(
                      context,
                      'Collaborators Added',
                      successColor,
                    );
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
      );
    });
  }

  AppBar buildAppBar(Note? note) {
    return AppBar(
      leading: IconButton(
        onPressed: () {
          if (note!.title.isEmpty &&
              note.content!.isEmpty &&
              note.todoItems == null &&
              note.id.isNotEmpty) {
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
            _createOrUpdateNote(note);
            setState(() {});
          },
          icon: Icon(
            note!.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
          ),
        ),
        IconButton(
          onPressed: () async {
            var selectedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (selectedDate != null) {
              var selectedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (selectedTime != null) {
                note.reminder = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  selectedTime.hour,
                  selectedTime.minute,
                );
                setState(() {});
                _createOrUpdateNote(note);
              }
            }
          },
          icon: const Icon(Icons.notification_add_outlined),
        ),
        IconButton(
          onPressed: () {
            if (note.title.isEmpty &&
                note.content!.isEmpty &&
                note.todoItems == null &&
                note.id.isNotEmpty) {
              context.read<DeleteNoteCubit>().deleteNote(
                    noteId: note.id,
                  );
            } else {
              note.isArchived = true;
              context.read<EditNoteCubit>().editNote(
                    note: note,
                  );
            }
            setState(() {});
            Navigator.pop(context);
            UiUtils.showSnackBar(
              context,
              'Note archived',
              successColor,
              // label: 'Undo',
              // onPressed: () {
              //   note.isArchived = false;
              //   fetchedNotes.add(note);
              //   setState(() {});
              // },
            );
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
    var bodyHeight = size.height;

    return StreamBuilder<DatabaseEvent>(
      stream: widget.noteId != null && note.id.isEmpty
          ? context.read<FetchNoteCubit>().fetchSingleNotes(
              userId: context.read<AuthCubit>().getUserDetails().id,
              noteId: widget.noteId ?? note.id)
          : context.read<FetchNoteCubit>().fetchSingleNotes(
              userId: context.read<AuthCubit>().getUserDetails().id,
              noteId: note.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            snapshot.connectionState == ConnectionState.active) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: ErrorContainer(
                errorMessageText: snapshot.error.toString(),
              ),
            ),
          );
        }
        // print('Fetched note single dd: ${snapshot.data!.snapshot.value}');
        Map<String, dynamic>? fetchedData = snapshot.hasData
            ? jsonDecode(jsonEncode(snapshot.data!.snapshot.value,
                toEncodable: (e) => e.toString()))
            : {};
        print('Fetched note single ff: ${fetchedData}');
        note = fetchedData != null && fetchedData.isNotEmpty
            ? Note.fromMap(Map<String, dynamic>.from(fetchedData))
            : Note(
                id: '',
                title: '',
                content: '',
                createdAt: DateTime.now(),
                createdBy: context.read<AuthCubit>().getUserDetails().id);
        return Scaffold(
          // resizeToAvoidBottomInset: false,
          persistentFooterAlignment: AlignmentDirectional.topStart,
          persistentFooterButtons: [
            buildBottomMenu(themeData, size, note),
          ],
          backgroundColor: note.color == null || note.color!.isEmpty
              ? themeData.scaffoldBackgroundColor
              : adjustColorIntensity(
                  note.color!, themeData.scaffoldBackgroundColor, context),
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
                  buildTitle(themeData, size, note),
                  if (!note.isTodo) buildContent(themeData, size, note),
                  if (note.isTodo) buildToDOs(themeData, size, note),
                  buildReminderAndTags(themeData, size, note),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
