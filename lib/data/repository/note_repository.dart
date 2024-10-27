import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../utils/api.dart';
import '../models/note.dart';

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

  final _database = FirebaseDatabase.instance.ref('notes');
  // final fetchNoteReference = FirebaseDatabase.instance.ref().child('notes');

  Future<List<Note>> fetchNotes({required String userId}) async {
    try {
      List<Note> notes = [];
      await _database.get().then((value) {
        Map<String, dynamic> fetchedData = jsonDecode(
            jsonEncode(value.value, toEncodable: (e) => e.toString()));

        print('fetchNoteReference: ${fetchedData}');
        notes = fetchedData.entries.map((entry) {
          return Note.fromMap(Map<String, dynamic>.from(entry.value));
        }).toList();
      });

      print('Fetched notes: $notes');
      return notes;
    } on FirebaseException catch (e) {
      print('Error message: ${e.toString()}');
      throw Exception('Failed to fetch notes: ${e.message}');
    }
  }

  Stream<List<Note>> fetchNotesStream({required String userId})  {
    try {
      List<Note> notes = [];
      var fetch = _database.onValue.listen((event) {
        Map<String, dynamic> fetchedData = jsonDecode(
            jsonEncode(event.snapshot.value, toEncodable: (e) => e.toString()));

        notes = fetchedData.entries.map((entry) {
          return Note.fromMap(Map<String, dynamic>.from(entry.value));
        }).toList();

        print('Fetched notes: ${notes[0].content}');

        // return notes;
      });
      return Stream.value(notes);
    } on FirebaseException catch (e) {
      print('Error message: ${e.toString()}');
      throw Exception('Failed to fetch notes: ${e.message}');
    }
  }

  void createNote({
    required Note note,
    required String userId,
  }) async {
    try {
      print('start create note');
      // data is not sent to firebase
      var id = _database.push();
      note.id = id.key.toString();
      //
      // note.createdBy = userId;
      await _database.child(note.id).update(note.toMap());
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
}
