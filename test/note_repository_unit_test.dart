import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shimmer/main.dart';
import 'package:task_hub/app/app.dart';
import 'package:task_hub/data/models/note.dart';
import 'package:task_hub/data/repository/note_repository.dart';



main()  {
  // test note repository
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();
  test('NoteRepository should return a list of NoteModel', () async {
    final noteRepository = NoteRepository();
    final result = await noteRepository.fetchNotes(userId: '');

    expectLater(result, isA<List<Note>>());
  });
}