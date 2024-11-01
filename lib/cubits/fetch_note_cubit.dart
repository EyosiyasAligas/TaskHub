import 'dart:async';
import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/note.dart';
import '../data/repository/note_repository.dart';

abstract class FetchNoteState {}

class FetchNoteInitial extends FetchNoteState {}

class FetchNoteInProgress extends FetchNoteState {}

class FetchNoteSuccess extends FetchNoteState {
  Stream<List<Note>> notes;

  FetchNoteSuccess(this.notes);
}

class FetchNoteFailure extends FetchNoteState {
  final String errorMessage;

  FetchNoteFailure(this.errorMessage);
}

class FetchNoteCubit extends Cubit<FetchNoteState> {
  final NoteRepository _noteRepository;

  FetchNoteCubit(this._noteRepository) : super(FetchNoteInitial());

  List<Note> _fetchedNotes = [];

  List<Note> get fetchedNotes => _fetchedNotes;

  Stream<List<Note>> streamNote = Stream.empty();

  void updateState(FetchNoteState updatedState) {
    emit(updatedState);
  }

  Future<List<Note>> fetchNotesOnce({required String userId}) async {
    emit(FetchNoteInProgress());
    try {
      var notes = await _noteRepository.fetchNotes(userId: userId);
      _fetchedNotes = notes;
      return notes;
    } catch (e) {
      emit(FetchNoteFailure(e.toString()));
      return [];
    }
  }

  // Future<void> fetchNotesOnce({required String userId}) async {
  //   emit(FetchNoteInProgress());
  //   try {
  //     var notes = await _noteRepository.fetchNotes(userId: userId);
  //     _fetchedNotes = notes;
  //     emit(FetchNoteSuccess(Stream.value(notes)));
  //   } catch (e) {
  //     emit(FetchNoteFailure(e.toString()));
  //   }
  // }

 Stream<DatabaseEvent> fetchNotes({required String userId}) {
    emit(FetchNoteInProgress());
    try {
      var fetch = _noteRepository.fetchNotesStream(userId: userId);
      // fetchNotesOnce(userId: userId);
      // emit(FetchNoteSuccess(streamNote));
      return fetch;
    } catch (e) {
      emit(FetchNoteFailure(e.toString()));
      // return const Stream.empty();
      throw Exception('Failed to fetch notes: ${e.toString()}');
    }
  }

  Stream<DatabaseEvent> fetchSingleNotes({required String userId, required String noteId}) {
    emit(FetchNoteInProgress());
    try {
      var fetch = _noteRepository.fetchSingleNotesStream(userId: userId, noteId: noteId);
      return fetch;
    } catch (e) {
      emit(FetchNoteFailure(e.toString()));
      // return const Stream.empty();
      throw Exception('Failed to fetch notes: ${e.toString()}');
    }
  }

  Stream<List<Note>> getNotes() {
    if (state is FetchNoteSuccess) {
      return (state as FetchNoteSuccess).notes;
    }
    return const Stream.empty();
  }
}