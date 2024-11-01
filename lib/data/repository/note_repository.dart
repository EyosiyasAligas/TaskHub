import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../utils/api.dart';
import '../models/note.dart';
import 'auth_repository.dart';

class NoteRepository {
  List<Note> dummyNotes = [
    Note(
      id: '1',
      title: 'Grocery List',
      content: null,
      todoItems: [
        TodoItem(task: 'Buy milk', isCompleted: false),
        TodoItem(task: 'Buy milk', isCompleted: false),
        TodoItem(task: 'Buy milk', isCompleted: false),
        TodoItem(task: 'Buy eggs', isCompleted: true),
        TodoItem(task: 'Buy bread', isCompleted: true),
      ],
      createdBy: 'user123',
      isPinned: true,
      color: '',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      collaborators: ['user124', 'user125'],
      reminder: DateTime.now().add(const Duration(days: 1)),
      tags: ['shopping', 'personal', 'groceries', 'food'],
      isArchived: false,
      imageUrls: [
        'https://example.com/image1.jpg',
        'https://example.com/image2.jpg',
      ],
      isTodo: true,
    ),
    Note(
      id: '2',
      title: 'Project Ideas',
      content:
      'Brainstorming for new app ideas Brainstorming for new app ideas Brainstorming for new app ideas Brainstorming for new app ideas Brainstorming for new app ideas Brainstorming for new app ideas Brainstorming for new app ideas Brainstorming for new app ideas Brainstorming for new app ideas Brainstorming for new app ideas Brainstorming for new app ideas... 🤔',
      todoItems: null,
      createdBy: 'user123',
      isPinned: false,
      color: '0xFFAED581',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      collaborators: ['user124'],
      reminder: null,
      tags: ['work', 'ideas'],
      isArchived: false,
      imageUrls: [],
      isTodo: false,
    ),
    Note(
      id: '3',
      title: 'Meeting Notes',
      content: 'Discussed project milestones and deadlines.',
      todoItems: null,
      createdBy: 'user124',
      isPinned: false,
      color: '0xFFFF8A65',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now(),
      collaborators: ['user123'],
      reminder: DateTime.now().add(const Duration(hours: 2)),
      tags: ['meeting', 'work'],
      isArchived: false,
      imageUrls: ['https://example.com/image3.jpg'],
      isTodo: false,
    ),
    Note(
      id: '4',
      title: 'Vacation Plans',
      content: 'Looking for flights and accommodation options.',
      todoItems: null,
      createdBy: 'user125',
      isPinned: true,
      color: '0xFF9575CD',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now().subtract(const Duration(days: 8)),
      collaborators: [],
      reminder: null,
      tags: ['vacation', 'personal'],
      isArchived: true,
      imageUrls: [],
      isTodo: false,
    ),

    // more notes...
    Note(
      id: '5',
      title: 'Grocery List 2',
      content: null,
      todoItems: [
        TodoItem(task: 'Buy milk', isCompleted: false),
        TodoItem(task: 'Buy milk', isCompleted: false),
        TodoItem(task: 'Buy milk', isCompleted: false),
        TodoItem(task: 'Buy eggs', isCompleted: true),
        TodoItem(task: 'Buy bread', isCompleted: true),
      ],
      createdBy: 'user123',
      isPinned: true,
      color: '',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      collaborators: ['user124', 'user125'],
      reminder: DateTime.now().add(const Duration(days: 1)),
      tags: ['shopping', 'personal', 'groceries', 'food', 'urgent'],
      isArchived: false,
      imageUrls: [
        'https://example.com/image1.jpg',
        'https://example.com/image2.jpg',
      ],
      isTodo: true,
    ),
    Note(
      id: '6',
      title: 'Project Ideas',
      content: 'Mobile App Development',
      todoItems: null,
      createdBy: 'user123',
      isPinned: false,
      color: '0xFFAED581',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      collaborators: ['user124'],
      reminder: null,
      tags: ['work', 'ideas'],
      isArchived: false,
      imageUrls: [],
      isTodo: false,
    ),
    Note(
      id: '7',
      title: 'Meeting Notes',
      content: 'Discussed project milestones and deadlines.',
      todoItems: null,
      createdBy: 'user124',
      isPinned: false,
      color: '0xFFFF8A65',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now(),
      collaborators: ['user123'],
      reminder: DateTime.now().add(const Duration(hours: 2)),
      tags: ['meeting', 'work'],
      isArchived: false,
      imageUrls: ['https://example.com/image3.jpg'],
      isTodo: false,
    ),
  ];


  Future<List<Note>> fetchDummyNotes() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return dummyNotes;
  }

  String userId = AuthRepository().getUserDetails().id;
  final  _database = FirebaseDatabase.instance.ref('notes');
  // final fetchNoteReference = FirebaseDatabase.instance.ref().child('notes');

  Future<List<Note>> fetchNotes({required String userId}) async {
    try {
      List<Note> notes = [];
      await _database.get().then((value) {
        if(value.exists){
          Map<String, dynamic> fetchedData = jsonDecode(
              jsonEncode(value.value, toEncodable: (e) => e.toString()));
          notes = fetchedData.entries.map((entry) {
            return Note.fromMap(Map<String, dynamic>.from(entry.value));
          }).toList();
        }
      });

      print('Fetched notes once repo: $notes');
      return notes;
    } on FirebaseException catch (e) {
      print('Error message: ${e.toString()}');
      throw Exception('Failed to fetch notes: ${e.message}');

    }
  }

  // Stream<DatabaseEvent> fetchNotesStream({required String userId}) {
  //   try {
  //     return _database.onValue.map((event) {
  //       if (event.snapshot.value != null) {
  //         // Parse the snapshot data to a Map
  //         Map<String, dynamic> fetchedData = jsonDecode(
  //             jsonEncode(event.snapshot.value, toEncodable: (e) => e.toString()));
  //
  //         // Filter notes based on userId or collaborators
  //         Map<String, dynamic> filteredData = fetchedData.map((key, value) {
  //           var noteMap = Map<String, dynamic>.from(value);
  //           Note note = Note.fromMap(noteMap);
  //
  //           if (note.createdBy == userId ||
  //               (note.collaborators != null && note.collaborators.contains(userId))) {
  //             return MapEntry(key, value); // Keep the entry
  //           } else {
  //             return MapEntry(key, null); // Nullify non-collaborator entries
  //           }
  //         })..removeWhere((key, value) => value == null); // Remove null entries
  //
  //         // Update the snapshot value with filtered data
  //         // event.snapshot.value = filteredData;
  //       }
  //       return event;
  //     });
  //   } on FirebaseException catch (e) {
  //     print('Error message: ${e.toString()}');
  //     throw Exception('Failed to fetch notes: ${e.message}');
  //   }
  // }

  Stream<DatabaseEvent> fetchNotesStream({required String userId})  {
    try {
     // List<Note> notes = [];
     // fetchNotes(userId: userId);
     var fetch = _database.onValue;
      // var fetch = _database.child(userId).onValue.listen((event) {
      //   if(event.snapshot.value != null){
      //     Map<String, dynamic> fetchedData = jsonDecode(
      //         jsonEncode(event.snapshot.value, toEncodable: (e) => e.toString()));
      //     notes = fetchedData.entries.map((entry) {
      //       return Note.fromMap(Map<String, dynamic>.from(entry.value));
      //     }).toList();
      //   }
      // });
      // StreamController<List<Note>> streamController = StreamController<List<Note>>();
      // streamController.onListen = () {
      //   streamController.add(notes);
      // };
      // streamController.onResume = () {
      //   fetch.resume();
      // };
      // streamController.onPause = () {
      //   fetch.pause();
      // };
      // streamController.onCancel = () {
      //   fetch.cancel();
      // };
      // streamController.add(notes);
      // // return streamController.stream.asBroadcastStream();
      return fetch;
    } on FirebaseException catch (e) {
      print('Error message: ${e.toString()}');
      throw Exception('Failed to fetch notes: ${e.message}');
    }
  }

  Stream<DatabaseEvent> fetchSingleNotesStream({required String userId, required String noteId})  {
    try {
      if(noteId.isNotEmpty){
        var fetch = _database.child('/$noteId').onValue;
        return fetch;
      } else {
        return Stream.empty();
      }
    } on FirebaseException catch (e) {
      print('Error message: ${e.toString()}');
      throw Exception('Failed to fetch note: ${e.message}');
    }
  }

  Future<void> createNote({
    required Note note,
    required String userId,
  }) async {
    try {
      print('start create note');
      // data is not sent to firebase
      var id = _database.child('').push();
      note.id = id.key.toString();
      //
      // note.createdBy = userId;
      await _database.child(id.key.toString()).set(note.toMap());
      print('end create note');
    } on FirebaseException catch (e) {
      throw Exception('Failed to create note: ${e.message}');
    }
  }

  Future<void> updateNote({
    required Note note,
  }) async {
    try {
      await _database.child(note.id).update(note.toMap());
    } on FirebaseException catch (e) {
      throw Exception('Failed to update note: ${e.message}');
    }
  }

  Future<void> deleteNote({
    required String noteId,
  }) async {
    try {
      await _database.child('/$noteId').remove();
    } on FirebaseException catch (e) {
      throw Exception('Failed to delete note: ${e.message}');
    }
  }

  String fetchTags() {
    try {
      // createTag(tag: 'shopping');
      String tags = '';
      _database.child('tags').onValue.listen((value) {
        if(value.snapshot.exists){
          // print('Fetched tags : ${value.snapshot.value}');

          Object? fetchedData = value.snapshot.value;
          // String fetchedData = jsonDecode(
          //     jsonEncode(value, toEncodable: (e) => e.toString()));
          // tags = fetchedData.toString();
        }
      }).asFuture((value) {
        print('Fetched tags future: $value');
        return value;
      });

      print('Fetched tags once repo: $tags');
      return tags;
    } on FirebaseException catch (e) {
      print('Error message: ${e.toString()}');
      throw Exception('Failed to fetch tags: ${e.message}');

    }
  }

  Future<void> createTag({
    required String tag,
  }) async {
    try {
      await _database.child('tags').set(tag);
    } on FirebaseException catch (e) {
      throw Exception('Failed to create tag: ${e.message}');
    }
  }

  Future fetchUsers() async {
    try {
      var users = await _database.child('users').get();
      return users;
    } on FirebaseException catch (e) {
      throw Exception('Failed to fetch users: ${e.message}');
    }
  }

  // Future<String> addCollaborator({
  //   required String noteId,
  //   required String collaboratorEmail,
  // }) async {
  //   try {
  //     //using firebase sdk
  //     // var user = await FirebaseAuth.instance.fetchSignInMethodsForEmail(collaboratorEmail);
  //     return collaboratorEmail;
  //   } on FirebaseException catch (e) {
  //     throw Exception('Failed to add collaborator: ${e.message}');
  //   }
  // }
}
